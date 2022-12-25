//
//  OpenTDBError.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

public enum OpenTDBError: Error, Equatable {
    case invalidURL
    case serverStatus(code: Int)
    case invalidAPIResponse(code: ResponseCode)
    case unknownError
}
