//
//  OpenTriviaAPIProtocol.swift
//  
//
//  Created by Tino on 24/12/2022.
//

import Foundation

public protocol OpenTriviaAPIProtocol {
    func fetch<T: Codable>(from url: URL) async throws -> T
    func resetToken(currentToken: String?) async throws -> TokenResponse
    func requestToken() async throws -> TokenResponse
    func getQuestionsResponse(triviaConfig: TriviaConfig, sessionToken: String?) async throws -> QuestionsResponse
}
