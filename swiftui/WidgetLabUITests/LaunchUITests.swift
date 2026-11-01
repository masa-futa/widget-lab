import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Widget Lab"].waitForExistence(timeout: 5))
    }
}
