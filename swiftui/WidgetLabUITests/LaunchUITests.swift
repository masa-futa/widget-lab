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

    @MainActor
    func testCompareShowsBothSides() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Widget Lab"].waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("pad")
        app.buttons["entry-padding"].tap()

        XCTAssertTrue(app.navigationBars[".padding"].waitForExistence(timeout: 5))
        let compare = app.switches["compare"]
        XCTAssertTrue(compare.waitForExistence(timeout: 5), app.debugDescription)
        compare.tap()
        XCTAssertTrue(app.staticTexts["付けない"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.staticTexts["付けた"].exists)
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = "compare"
        shot.lifetime = .keepAlways
        add(shot)
    }
}
