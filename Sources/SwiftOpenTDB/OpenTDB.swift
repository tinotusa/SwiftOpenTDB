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
    /// Logger for the class.
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "TriviaAPI")
    /// The api being used.
    private let openTDBAPI: OpenTriviaAPIProtocol
    
    public convenience init() {
        self.init(openTriviaAPI: OpenTriviaAPI())
    }
    
    /// Creates a TriviaAPI.
    public init(openTriviaAPI: OpenTriviaAPIProtocol = OpenTriviaAPI()) {
        triviaConfig = .default
        self.openTDBAPI = openTriviaAPI
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
        let questionsResponse = try await openTDBAPI.getQuestionsResponse(triviaConfig: triviaConfig, sessionToken: sessionToken)
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
            throw OpenTDBError.noSessionToken
        case .tokenEmpty:
            log.debug("Token is empty.")
            throw OpenTDBError.emptyToken
        default:
            log.debug("Unknown response code \(responseCode.rawValue).")
            break
        }
        
        log.debug("Successfully got \(questionsResponse.results.count) questions from the api.")
        return questionsResponse.results
    }
    
    /// Resets the current session token.
    func resetToken() async throws {
        if sessionToken == nil {
            log.error("Failed to reset the token. The token is nil.")
            throw OpenTDBError.noSessionToken
        }
        let tokenResponse = try await openTDBAPI.resetToken(currentToken: self.sessionToken)
        self.sessionToken = tokenResponse.token
    }

    /// Requests opentdb for a session token.
    ///
    /// This token is used to keep track of the questions that have already been asked.
    /// This token will also help indicate when the user has exhausted all questions and
    /// needs to the refreshed.
    func requestToken() async throws {
        let tokenResponse = try await openTDBAPI.requestToken()
        self.sessionToken = tokenResponse.token
    }
}
