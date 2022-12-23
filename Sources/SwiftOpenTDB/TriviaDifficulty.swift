//
//  TriviaDifficulty.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

/// Difficulty options for the trivia.
public enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case any
    case easy
    case medium
    case hard
    
    /// A unique id.
    public var id: Self { self }
//
//    /// The title of the case.
//    public var title: LocalizedStringKey {
//        switch self {
//        case .any: return LocalizedStringKey("Any")
//        case .easy: return LocalizedStringKey("Easy")
//        case .hard: return LocalizedStringKey("Hard")
//        case .medium: return LocalizedStringKey("Medium")
//        }
//    }
}
