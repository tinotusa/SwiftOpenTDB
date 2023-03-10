//
//  File.swift
//  
//
//  Created by Tino on 24/12/2022.
//

import Foundation
@testable import SwiftOpenTDB

final class MockOpenTriviaAPI: OpenTriviaAPIProtocol {
    enum ResponseCode: Int {
        case success
        case noResults
        case invalidParameter
        case tokenNotFound
        case emptyToken
    }
    var questionsResponseCode: ResponseCode?
    var decoder: JSONDecoder
    
    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func resetToken(currentToken: String?) async throws -> TokenResponse {
        let data = Data(tokenResponse.utf8)
        return try decoder.decode(TokenResponse.self, from: data)
    }
    
    func requestToken() async throws -> TokenResponse {
        let data = Data(tokenResponse.utf8)
        return try decoder.decode(TokenResponse.self, from: data)
    }
    
    func getQuestionsResponse(triviaConfig: TriviaConfig, sessionToken: String?) async throws -> QuestionsResponse {
        if let questionsResponseCode {
            return .init(responseCode: questionsResponseCode.rawValue, results: [])
        }
        let data = Data(exampleQuestions.utf8)
        return try decoder.decode(QuestionsResponse.self, from: data)
    }
    
    func fetch<T>(from url: URL) async throws -> T where T : Decodable, T : Encodable {
        let data = Data(exampleQuestions.utf8)
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: Examples
let tokenResponse = """
{"response_code":0,"response_message":"Token Generated Successfully!","token":"12345"}
"""
let exampleQuestions = """
{"response_code":0,"results":[{"category":"Entertainment%3A%20Video%20Games","type":"multiple","difficulty":"medium","question":"Along%20with%20Gabe%20Newell%2C%20who%20co-founded%20Valve%3F","correct_answer":"Mike%20Harrington","incorrect_answers":["Robin%20Walker","Marc%20Laidlaw","Stephen%20Bahl"]},{"category":"Geography","type":"boolean","difficulty":"easy","question":"Alaska%20is%20the%20largest%20state%20in%20the%20United%20States.","correct_answer":"True","incorrect_answers":["False"]},{"category":"Entertainment%3A%20Japanese%20Anime%20%26%20Manga","type":"boolean","difficulty":"easy","question":"Gosho%20Aoyama%20Made%20This%20Series%3A%20%28Detective%20Conan%20%2F%20Case%20Closed%21%29","correct_answer":"True","incorrect_answers":["False"]},{"category":"Entertainment%3A%20Musicals%20%26%20Theatres","type":"multiple","difficulty":"hard","question":"Who%20wrote%20the%20lyrics%20for%20Leonard%20Bernstein%27s%201957%20Brodway%20musical%20West%20Side%20Story%3F","correct_answer":"Stephen%20Sondheim","incorrect_answers":["Himself","Oscar%20Hammerstein","Richard%20Rodgers"]},{"category":"Entertainment%3A%20Television","type":"multiple","difficulty":"easy","question":"When%20did%20the%20TV%20show%20Rick%20and%20Morty%20first%20air%20on%20Adult%20Swim%3F","correct_answer":"2013","incorrect_answers":["2014","2016","2015"]},{"category":"History","type":"boolean","difficulty":"medium","question":"Martin%20Luther%20King%20Jr.%20and%20Anne%20Frank%20were%20born%20the%20same%20year.%20","correct_answer":"True","incorrect_answers":["False"]},{"category":"Entertainment%3A%20Television","type":"multiple","difficulty":"hard","question":"In%20Star%20Trek%2C%20what%20is%20the%20name%20of%20Spock%27s%20father%3F","correct_answer":"Sarek","incorrect_answers":["Tuvok","T%27Pal","Surak"]},{"category":"Entertainment%3A%20Video%20Games","type":"multiple","difficulty":"medium","question":"In%20the%20%22Pikmin%22%20series%2C%20what%20is%20the%20only%20pikmin%20type%20to%20possess%20visible%20ears%3F","correct_answer":"Yellow","incorrect_answers":["Red","White","Winged"]},{"category":"Entertainment%3A%20Video%20Games","type":"multiple","difficulty":"hard","question":"The%20creation%20of%20the%20%20Entertainment%20Software%20Ratings%20Board%20%28ESRB%29%20is%20often%20associated%20with%20Mortal%20Kombat%20and%20what%20FMV%20video%20game%3F","correct_answer":"Night%20Trap","incorrect_answers":["Sewer%20Shark","The%20Daedalus%20Encounter","Corpse%20Killer"]},{"category":"Sports","type":"multiple","difficulty":"medium","question":"Which%20NBA%20player%20has%20the%20most%20games%20played%20over%20the%20course%20of%20their%20career%3F","correct_answer":"Robert%20Parish","incorrect_answers":["Kareem%20Abdul-Jabbar","Kevin%20Garnett","Kobe%20Bryant"]}]}
"""
