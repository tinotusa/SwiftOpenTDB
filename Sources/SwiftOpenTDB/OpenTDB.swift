import Foundation
import os

/// Endpoints for opentdb.
public enum APIEndpoint: String {
    case api = "/api.php"
    case apiToken = "/api_token.php"
}

/// API wrapper for [Opentdb](https://opentdb.com).
public final class OpenTDB {
    /// The current sessions token.
    public var sessionToken: String?
    /// Settings for the trivia questions.
    public var triviaConfig: TriviaConfig
    
    /// The shared TriviaAPI instance.
    public static var shared = OpenTDB()
    
    /// Decoder for the wrapper.
    private let decoder: JSONDecoder
    /// Logger for the class.
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "TriviaAPI")
    
    /// Creates a TriviaAPI.
    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        triviaConfig = .default
    }
}

public extension OpenTDB {
    /// A boolean value indicating whether or not there is a session.
    var hasSessionToken: Bool {
        sessionToken != nil
    }
    
    /// Gets questions from opentdb based on the config settings.
    /// - Returns: An array of questions.
    func getQuestions() async throws -> [Question] {
        log.debug("Getting questions using the config settings: \(self.triviaConfig)")
        
        if !hasSessionToken {
            log.debug("No session token. Requesting a new one.")
            try await requestToken()
        }
        
        let url = createOpenTriviaDatabaseURL(
            endpoint: .api,
            queryItems: [
                .init(name: "amount", value: "\(triviaConfig.numberOfQuestions)"),
                .init(name: "category", value: triviaConfig.category.id != 0 ? "\(triviaConfig.category.id)" : nil),
                .init(name: "difficulty", value: triviaConfig.difficulty != .any ? triviaConfig.difficulty.rawValue : nil),
                .init(name: "type", value: triviaConfig.triviaType != .any ? triviaConfig.triviaType.rawValue : nil),
                .init(name: "token", value: sessionToken),
                .init(name: "encode", value: "url3986")
            ]
        )
        
        guard let url else {
            log.error("Failed to get questions. URL is invalid.")
            throw OpenTDBError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse,
           !isSuccessfulStatusCode(response)
        {
            log.error("Failed to get questions. Invalid server response: \(response.statusCode)")
            throw OpenTDBError.serverStatus(code: response.statusCode)
        }
        
        let questionsResponse = try decoder.decode(QuestionsResponse.self, from: data)
        guard let responseCode = ResponseCode(rawValue: questionsResponse.responseCode) else {
            log.error("Failed to get questions. Unknown response code: \(questionsResponse.responseCode)")
            throw OpenTDBError.unknownError
        }
        
        switch responseCode {
        case .noResults:
            log.error("Failed to get questions. There were no results.")
            throw OpenTDBError.noResults
        case .invalidParameter:
            log.error("Failed to get questions. A parameter was invalid.")
            throw OpenTDBError.invalidParameter
        case .tokenNotFound:
            log.debug("Failed to get questions. No token found. Will try to request for a new token.")
            try await requestToken()
            return try await getQuestions()
        case .tokenEmpty:
            if self.sessionToken != nil && questionsResponse.results.isEmpty {
                log.error("No results found. Might have seen all questions.")
                throw OpenTDBError.seenAllQuestions
            }
            try await resetToken()
            return try await getQuestions()
        default:
            break
        }
        
        log.debug("Successfully got \(questionsResponse.results.count) questions from the api.")
        return questionsResponse.results
    }
    
    /// Resets the current session token.
    func resetToken() async throws {
        if sessionToken == nil {
            log.error("Failed to reset the token. The token is nil.")
            throw OpenTDBError.noSessonToken
        }
        
        log.debug("Reseting the token")
        let url = createOpenTriviaDatabaseURL(
            endpoint: .apiToken,
            queryItems: [
                .init(name: "command", value: "reset"),
                .init(name: "token", value: self.sessionToken)
            ]
        )
        guard let url else {
            log.error("Failed to reset token. Invalid url.")
            throw OpenTDBError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            log.error("Failed to cast url response and http url response.")
            throw OpenTDBError.unknownError
        }
        if !isSuccessfulStatusCode(httpResponse) {
            log.error("Invalid server response status code: \(httpResponse.statusCode)")
            throw OpenTDBError.serverStatus(code: httpResponse.statusCode)
        }
        
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        if !isValidAPIResponse(tokenResponse.responseCode) {
            log.error("Failed to reset token. Got invalid server response code: \(tokenResponse.responseCode)")
            throw OpenTDBError.invalidAPIResponse(code: ResponseCode(rawValue: tokenResponse.responseCode)!)
        }
        
        log.debug("Successfully reset token.")
        self.sessionToken = tokenResponse.token
    }

    /// Requests opentdb for a session token.
    ///
    /// This token is used to keep track of the questions that have already been asked.
    /// This token will also help indicate when the user has exhausted all questions and
    /// needs to the refreshed.
    func requestToken() async throws {
        log.debug("Requesting token.")
        let url = createOpenTriviaDatabaseURL(
            endpoint: .apiToken,
            queryItems: [.init(name: "command", value: "request")]
        )
        
        guard let url else {
            log.error("Failed to request token. URL is invalid.")
            throw OpenTDBError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse,
           !isSuccessfulStatusCode(response)
        {
            log.error("Invalid server status code: \(response.statusCode)")
            throw OpenTDBError.serverStatus(code: response.statusCode)
        }
        
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        if let responseCode = ResponseCode(rawValue: tokenResponse.responseCode),
            responseCode != .success
        {
            log.error("Invalid api response code: \(responseCode)")
            throw OpenTDBError.invalidAPIResponse(code: responseCode)
        }
        
        log.debug("Successfully got session token.")
        self.sessionToken = tokenResponse.token
    }
    
    /// Creates a url for opentdb with the given path and query items.
    /// - Parameters:
    ///   - path: The path for the api.
    ///   - queryItems: The query items for the api.
    /// - Returns: A url if the path is valid, nil otherwise.
    func createOpenTriviaDatabaseURL(endpoint: APIEndpoint, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = endpoint.rawValue
        components.queryItems = queryItems
        
        return components.url
    }
    
    /// Returns whether or not the given code is valid.
    ///
    /// A valid code is 0.
    ///
    /// Everything else is not valid.
    ///
    /// - Parameter code: The code from the server
    /// - Returns: True if the code is valid, false otherwise.
    func isValidAPIResponse(_ code: Int) -> Bool {
        code == 0
    }
    
    /// Returns whether or not the given response has a successful status code.
    /// - Parameter response: The response to check.
    /// - Returns: True if the response's status code is valid, false otherwise.
    func isSuccessfulStatusCode(_ response: HTTPURLResponse) -> Bool {
        (200 ..< 300).contains(response.statusCode)
    }
}
