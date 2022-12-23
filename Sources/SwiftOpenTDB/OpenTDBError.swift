//
//  OpenTDBError.swift
//  
//
//  Created by Tino on 23/12/2022.
//

import Foundation

enum OpenTDBError: Error {
    case invalidURL
    case serverStatus(code: Int)
    case invalidAPIResponse(code: ResponseCode)
    case unknownError
    // api response errors
    case noSessonToken
    case noResults
    case seenAllQuestions
    case invalidParameter
}
