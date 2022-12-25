//
//  OpenTriviaAPI.swift
//  
//
//  Created by Tino on 24/12/2022.
//

import Foundation
import os

/// A wrapper for opentdb.
public struct OpenTriviaAPI: OpenTriviaAPIProtocol {
    private let log = Logger(subsystem: "com.tinotusa.SwiftOpenTDB", category: "OpenTriviaAPI")
    private let decoder: JSONDecoder
    
    /// Creates an instance of OpenTriviaAPI.
    public init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Gets some data from the given url and decodes it.
    /// - Parameter url: The url to get the data from.
    /// - Returns: Some decoded data.
    public func fetch<T: Codable>(from url: URL) async throws -> T {
        log.debug("Fetching some data from the url: \(url)")
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        // TODO: look this up
        if let response = response as? HTTPURLResponse,
           !(200 ..< 300).contains(response.statusCode)
        {
            log.error("Failed to get data. Invalid server response: \(response.statusCode)")
            throw OpenTDBError.serverStatus(code: response.statusCode)
        }
        let decodedData = try decoder.decode(T.self, from: data)
        log.debug("Successfully got some data from the url: \(url)")
        return decodedData
    }
    
    /// Returns whether or not the given code is valid.
    ///
    /// A valid code is 0.
    ///
    /// Everything else is not valid.
    ///
    /// - Parameter code: The code from the server
    /// - Returns: True if the code is valid, false otherwise.
    public func isValidAPIResponse(_ code: Int) -> Bool {
        code == 0
    }
    
    /// Returns whether or not the given response has a successful status code.
    /// - Parameter response: The response to check.
    /// - Returns: True if the response's status code is valid, false otherwise.
    public func isSuccessfulStatusCode(_ response: HTTPURLResponse) -> Bool {
        (200 ..< 300).contains(response.statusCode)
    }
    
    /// Resets the given token.
    /// - Parameter currentToken: The token to reset.
    /// - Returns: A token response containing the new token.
    public func resetToken(currentToken: String?) async throws -> TokenResponse {
        log.debug("Reseting the token")
        let url = createOpenTriviaDatabaseURL(
            endpoint: .apiToken,
            queryItems: [
                .init(name: "command", value: "reset"),
                .init(name: "token", value: currentToken)
            ]
        )
        guard let url else {
            log.error("Failed to reset token. Invalid url.")
            throw OpenTDBError.invalidURL
        }
        let tokenResponse: TokenResponse = try await fetch(from: url)
        
        if !isValidAPIResponse(tokenResponse.responseCode) {
            log.error("Failed to reset token. Got invalid server response code: \(tokenResponse.responseCode)")
            throw OpenTDBError.invalidAPIResponse(code: ResponseCode(rawValue: tokenResponse.responseCode)!)
        }
        
        log.debug("Successfully reset token.")
        
        return tokenResponse
    }
    
    /// Requests opentdb for a session token.
    ///
    /// This token is used to keep track of the questions that have already been asked.
    /// This token will also help indicate when the user has exhausted all questions and
    /// needs to the refreshed.
    public func requestToken() async throws -> TokenResponse {
        log.debug("Requesting token.")
        let url = createOpenTriviaDatabaseURL(
            endpoint: .apiToken,
            queryItems: [.init(name: "command", value: "request")]
        )
        
        guard let url else {
            log.error("Failed to request token. URL is invalid.")
            throw OpenTDBError.invalidURL
        }
        
        let tokenResponse: TokenResponse = try await fetch(from: url)
        
        if let responseCode = ResponseCode(rawValue: tokenResponse.responseCode),
            responseCode != .success
        {
            log.error("Invalid api response code: \(responseCode)")
            throw OpenTDBError.invalidAPIResponse(code: responseCode)
        }
        
        log.debug("Successfully got session token.")
        return tokenResponse
    }
    
    /// Creates a url for opentdb with the given path and query items.
    /// - Parameters:
    ///   - path: The path for the api.
    ///   - queryItems: The query items for the api.
    /// - Returns: A url if the path is valid, nil otherwise.
    public func createOpenTriviaDatabaseURL(endpoint: APIEndpoint, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = endpoint.rawValue
        components.queryItems = queryItems
        
        return components.url
    }
    
    /// Fetches the QuestionsResponse from opentdb.
    ///
    /// - Parameters:
    ///   - triviaConfig: The settings for the trivia.
    ///   - sessionToken: The session token(if one is available).
    /// - Returns: <#description#>
    public func getQuestionsResponse(triviaConfig: TriviaConfig, sessionToken: String? = nil) async throws -> QuestionsResponse {
        log.debug("Fetching questions response from opentdb.")
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
        
        let questionsResponse: QuestionsResponse = try await fetch(from: url)
        log.debug("Successfully got the questions response.")
        return questionsResponse
    }
}
