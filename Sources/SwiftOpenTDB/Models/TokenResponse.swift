//
//  TokenResponse.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

/// Model for opentdb token response.
public struct TokenResponse: Codable {
    /// The response code of the request.
    public let responseCode: Int
    /// The response message of the request.
    public let responseMessage: String?
    /// The token of the request.
    public let token: String
}
