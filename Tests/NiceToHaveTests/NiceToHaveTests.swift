import XCTest
@testable import NiceToHave

final class NiceToHaveTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NiceToHave().text, "Hello, World!")
    }

    func testArrayBuilder() async throws {
        enum Test: Equatable{
            case a, b, c
        }

        let arr = Array {
            Test.a
            Test.b
            Test.c
        }
        XCTAssertEqual(arr, [Test.a, Test.b, Test.c])
    }
}
