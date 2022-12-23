import XCTest
@testable import SwiftOpenTDB

final class OpenTDBTests: XCTestCase {
    var openTDB = OpenTDB.shared
    
    override func setUpWithError() throws {
        
    }
    
    func testURLCreation() async throws {
        openTDB.triviaConfig = .init(
            numberOfQuestions: 10,
            category: .animals,
            difficulty: .easy,
            triviaType: .any
        )
        
    }
}
