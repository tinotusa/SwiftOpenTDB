import XCTest
@testable import SwiftOpenTDB

final class OpenTDBTests: XCTestCase {
    var openTDB = OpenTDB.shared
    
    override func setUpWithError() throws {
        
    }
    
    func testURLCreation() async throws {
        let triviaConfig = TriviaConfig(
            numberOfQuestions: 10,
            category: .animals,
            difficulty: .easy,
            triviaType: .any
        )
        let urlQueryItems: [URLQueryItem] = [
            .init(name: "amount", value: "\(triviaConfig.numberOfQuestions)"),
            .init(name: "category", value: "\(triviaConfig.category.id)"),
            .init(name: "difficulty", value: "\(triviaConfig.difficulty.rawValue)"),
            .init(name: "type", value: "\(triviaConfig.triviaType.rawValue)")
        ]
        let url = openTDB.createOpenTriviaDatabaseURL(endpoint: .api, queryItems: urlQueryItems)
        
        let unwrappedULR = try XCTUnwrap(url, "Expected a valid url to be non nil.")
        let components = URLComponents(string: unwrappedULR.absoluteString)
        let host = try XCTUnwrap(components?.host, "Expected url to have a host component.")
        let path = try XCTUnwrap(components?.path, "Expected url to have a path component.")
        let queryItems = try XCTUnwrap(components?.queryItems, "Expected url to have a query items component.")
        
        let expectedHost = "opentdb.com"
        let expectedPath = "/api.php"
        let expectedQueryCount = urlQueryItems.count
        
        XCTAssertEqual(host, expectedHost, "Expected host to be \(expectedHost)")
        XCTAssertEqual(path, expectedPath, "Expected path to be \(expectedPath)")
        XCTAssertEqual(queryItems.count, expectedQueryCount, "Expected query item count to be \(expectedQueryCount)")
        
        for queryItem in queryItems {
            XCTAssertTrue(urlQueryItems.contains(queryItem), "Expected \(queryItem) to exist.")
        }
    }
}
