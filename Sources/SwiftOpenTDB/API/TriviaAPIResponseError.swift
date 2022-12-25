//
//  TriviaAPIResponseError.swift
//  
//
//  Created by Tino on 25/12/2022.
//

import Foundation

/// Error codes from an opentdb response.
public enum TriviaAPIResponseError: Error, LocalizedError {
    case tokenNotFound
    case noResults
    case invalidParameter
    case emptyToken
    
    public var errorDescription: String {
        switch self {
        case .emptyToken:
            return NSLocalizedString("The session token has returned all possible questions for the given query.", comment: "")
        case .invalidParameter:
            return NSLocalizedString("One or more of the given parameters is invalid.", comment: "")
        case .noResults:
            return NSLocalizedString("Could not return results. The API doesn't have enough questions for the given query", comment: "")
        case .tokenNotFound:
            return NSLocalizedString("The given token does not exist.", comment: "")
        }
    }
    
    public var recoverySuggestion: String {
        switch self {
        case .emptyToken:
            return NSLocalizedString("Reset the session token.", comment: "")
        case .invalidParameter:
            return NSLocalizedString("Correct the invalid parameter.", comment: "")
        case .noResults:
            return NSLocalizedString("Reset the token.", comment: "")
        case .tokenNotFound:
            return NSLocalizedString("Request a session token.", comment: "")
        }
    }
}
