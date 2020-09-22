import XCTest
@testable import SwiftyKeychain

final class SwiftyKeychainTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftyKeychain().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
