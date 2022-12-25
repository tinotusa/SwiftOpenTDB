//
//  OpenTDBError.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation
import SwiftUI

public enum OpenTDBError: Error, Equatable, LocalizedError {
    case invalidURL
    case serverStatus(code: Int)
    case invalidAPIResponse(code: ResponseCode)
    case unknownError
    
    public var errorDescription: String {
        switch self {
        case .invalidAPIResponse(let code):
            return NSLocalizedString("Got some data but received a bad response code from opentdb. code: \(code).", comment: "")
        case .invalidURL:
            return NSLocalizedString("The url is invalid.", comment: "")
        case .serverStatus(let code):
            return NSLocalizedString("Got a bad status code from opentdb. code: \(code).", comment: "")
        case .unknownError:
            return NSLocalizedString("An unknown error has occurred", comment: "")
        }
    }
    
    public var recoverySuggestion: String {
        switch self {
        case .invalidAPIResponse(let code):
            switch code {
            case .invalidParameter:
                return NSLocalizedString("Check the parameters and correct the wrong one.", comment: "")
            case .noResults:
                return NSLocalizedString("The API doesn't have enough questions for the query.", comment: "")
            case .tokenEmpty:
                return NSLocalizedString("Session token has returned all possible questions. Resetting the token is necessary.", comment: "")
            case .tokenNotFound:
                return NSLocalizedString("No session token, request a token.", comment: "")
            case .success:
                return NSLocalizedString("Response is successful. No actions are needed.", comment: "")
            }
        case .invalidURL:
            return NSLocalizedString("Fix the url structure.", comment: "")
        case .serverStatus:
            return NSLocalizedString("No recovery, since this is a server issue.", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown error.", comment: "")
        }
    }
}
