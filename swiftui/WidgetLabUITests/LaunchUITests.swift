import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testSearchOpenDetailAndCopyCode() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Widget Lab"].waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("pad")
        app.buttons["entry-padding"].tap()

        XCTAssertTrue(app.navigationBars[".padding"].waitForExistence(timeout: 5))
        app.buttons["code-strip"].tap()
        app.buttons["copy"].tap()
        XCTAssertTrue(app.buttons["コピーしました"].waitForExistence(timeout: 5))
    }
}
