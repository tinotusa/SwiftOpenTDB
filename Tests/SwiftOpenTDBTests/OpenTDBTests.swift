import XCTest
@testable import SwiftOpenTDB

final class OpenTDBTests: XCTestCase {
    var mockOpenTriviaAPI: MockOpenTriviaAPI!
    var openTDB: OpenTDB!
    
    override func setUpWithError() throws {
        mockOpenTriviaAPI = MockOpenTriviaAPI()
        openTDB = .init(openTriviaAPI: mockOpenTriviaAPI)
    }
    
    func testGetQuestions() async throws {
        let questions = try await openTDB.getQuestions()
        XCTAssertEqual(questions.count, 10, "Expected the questions count to be 10")
    }
    
    func testGetQuestionsThrowsNoResults() async throws {
        mockOpenTriviaAPI.questionsResponseCode = .noResults
        do {
            _ = try await openTDB.getQuestions()
        } catch let error as TriviaAPIResponseError {
            XCTAssertEqual(error, .noResults, "Expected error to be no results error.")
        } catch {
            XCTFail("Unknown error \(error)")
        }
    }
    
    func testGetQuestionsThrowsInvalidParameter() async throws {
        mockOpenTriviaAPI.questionsResponseCode = .invalidParameter
        do {
            _ = try await openTDB.getQuestions()
        } catch let error as TriviaAPIResponseError {
            XCTAssertEqual(error, .invalidParameter, "Expected error to be invalid parameter error.")
        } catch {
            XCTFail("Unknown error \(error)")
        }
    }
    
    func testGetQuestionsThrowsTokenNotFound() async throws {
        mockOpenTriviaAPI.questionsResponseCode = .tokenNotFound
        do {
            _ = try await openTDB.getQuestions()
        } catch let error as TriviaAPIResponseError {
            XCTAssertEqual(error, .tokenNotFound, "Expected error to be no session token.")
        } catch {
            XCTFail("This isn't the expected error. \(error)")
        }
    }
    
    func testGetQuestionsThrowsTokenEmpty() async throws {
        mockOpenTriviaAPI.questionsResponseCode = .emptyToken
        do {
            _ = try await openTDB.getQuestions()
        } catch let error as TriviaAPIResponseError {
            XCTAssertEqual(error, .emptyToken, "Expected error to be empty token.")
        } catch {
            XCTFail("This isn't the expected error. \(error)")
        }
    }
    
    func testResetTokenWithNoCurrentToken() async throws {
        do {
            try await openTDB.resetToken()
        } catch let error as TriviaAPIResponseError {
            XCTAssertEqual(error, .tokenNotFound, "Expected the token to be empty.")
        } catch {
            XCTFail("This is not the expected error. \(error)")
        }
    }
    
    func testResetToken() async throws {
        openTDB.sessionToken = "321"
        try await openTDB.resetToken()
        let token = try XCTUnwrap(openTDB.sessionToken, "Expected a non nil session token.")
        XCTAssertEqual(token, "12345")
    }
    
    func testRequestToken() async throws {
        try await openTDB.requestToken()
        let token = try XCTUnwrap(openTDB.sessionToken, "Expected a non nil session token.")
        XCTAssertEqual(token, "12345")
    }
}
