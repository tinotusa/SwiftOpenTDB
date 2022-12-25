//
//  TriviaAPIResponseError.swift
//  
//
//  Created by Tino on 25/12/2022.
//

import Foundation

/// Error codes from an opentdb response.
public enum TriviaAPIResponseError: Error {
    case noSessionToken
    case noResults
    case seenAllQuestions
    case invalidParameter
    case emptyToken
}
