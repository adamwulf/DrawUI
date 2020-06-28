import XCTest
@testable import DrawUI

final class DrawUITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DrawUI().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
