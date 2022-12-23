//
//  QuestionsResponse.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

/// Model for opentdb's questions
public struct QuestionsResponse: Codable {
    /// The response code.
    public let responseCode: Int
    /// The questions and answers.
    public let results: [Question]
}
