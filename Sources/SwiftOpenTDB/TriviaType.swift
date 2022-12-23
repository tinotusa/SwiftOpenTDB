//
//  TriviaType.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

/// The question types for the trivia.
public enum TriviaType: String, CaseIterable, Identifiable {
    case any
    case multipleChoice = "multiple"
    case trueOrFalse = "boolean"
    
    /// A unique id.
    public var id: Self { self }
    
    /// The title of the type.
    public var title: String {
        switch self {
        case .any: return "Any"
        case .multipleChoice: return "Multiple choice"
        case .trueOrFalse: return "True or false"
        }
    }
}
