//
//  Question.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

/// Model for the questions of the trivia.
public struct Question: Codable, Hashable {
    /// The type of question.
    public let type: String
    /// The difficulty of the question.
    public let difficulty: String
    /// The category of the question.
    public let category: String
    /// The question.
    public let question: String
    /// The correct answer.
    public let correctAnswer: String
    /// The incorrect answers.
    public let incorrectAnswers: [String]
    
    /// All of the answers to the question
    public let allAnswers: [String]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try container.decode(String.self, forKey: .category).removingPercentEncoding!
        self.type = try container.decode(String.self, forKey: .type)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)
        self.question = try container.decode(String.self, forKey: .question).removingPercentEncoding!
        self.correctAnswer = try container.decode(String.self, forKey: .correctAnswer).removingPercentEncoding!
        self.incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers).compactMap { $0.removingPercentEncoding! }
        
        var allAnswers = incorrectAnswers
        allAnswers.append(correctAnswer)
        allAnswers.shuffle()
        if type == "boolean" {
            allAnswers = allAnswers.sorted()
        }
        self.allAnswers = allAnswers
    }
    
    public static var examples: [Self] {
        let url = Bundle.main.url(forResource: "exampleQuestions", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(QuestionsResponse.self, from: data).results
        } catch {
            fatalError("Failed to decode example questions json. \(error)")
        }
    }
}
