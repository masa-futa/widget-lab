import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testSearchOpenDetailAndCopyCode() {
        let app = openDetail(searching: "pad", entryID: "padding", title: ".padding")
        app.buttons["code-strip"].tap()
        app.buttons["copy"].tap()
        XCTAssertTrue(app.buttons["コピーしました"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCompareShowsBothSides() {
        let app = openDetail(searching: "pad", entryID: "padding", title: ".padding")
        let compare = app.switches["compare"]
        XCTAssertTrue(compare.waitForExistence(timeout: 5), app.debugDescription)
        compare.tap()
        XCTAssertTrue(app.staticTexts["付けない"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.staticTexts["付けた"].exists)
        attachScreenshot(app, name: "compare")
    }

    @MainActor
    func testStateRedrawsOnlyWithWrapper() {
        let app = openDetail(searching: "@State", entryID: "State", title: "@State")
        let compare = app.switches["compare"]
        XCTAssertTrue(compare.waitForExistence(timeout: 5), app.debugDescription)
        compare.tap()
        let plusOne = app.buttons.matching(NSPredicate(format: "label == %@", "+1"))
        XCTAssertTrue(plusOne.element(boundBy: 1).waitForExistence(timeout: 5), app.debugDescription)
        // 左が付けない側、右が付けた側
        plusOne.element(boundBy: 0).tap()
        plusOne.element(boundBy: 1).tap()
        XCTAssertTrue(app.staticTexts["count: 1"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.staticTexts["count: 0"].exists, "付けない側の表示は変わらない")
        attachScreenshot(app, name: "state-compare")
    }

    @MainActor
    func testLayoutEntriesShowPreview() {
        for (id, title) in [("frame", ".frame"), ("LazyVGrid", "LazyVGrid")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

    @MainActor
    func testDrawingEntriesShowPreview() {
        for (id, title) in [("visualEffect", ".visualEffect"), ("colorEffect", ".colorEffect")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

    @MainActor
    func testControlEntriesShowPreview() {
        for (id, title) in [("Picker", "Picker"), ("MultiDatePicker", "MultiDatePicker")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

    @MainActor
    func testListEntriesShowPreview() {
        for (id, title) in [("deleteDisabled", ".deleteDisabled"), ("safeAreaBar", ".safeAreaBar")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

    @MainActor
    func testTextEntriesShowPreview() {
        let editor = openDetail(searching: "TextEditor", entryID: "TextEditor", title: "TextEditor")
        attachScreenshot(editor, name: "TextEditor")
        editor.terminate()
        let field = openDetail(searching: "keyboardType", entryID: "keyboardType", title: ".keyboardType")
        field.textFields.firstMatch.tap()
        // ハードウェアキーボードをつないだシミュレータでは出ないので、出るのを待つだけにする
        _ = field.keyboards.firstMatch.waitForExistence(timeout: 5)
        attachScreenshot(field, name: "keyboardType")
        field.terminate()
    }

    @MainActor
    func testStyleEntriesShowPreview() {
        for (id, title) in [("listStyle", ".listStyle"), ("AsyncImage", "AsyncImage")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

    /// 起動して、検索の結果から詳細を開く
    @MainActor
    private func openDetail(searching text: String, entryID: String, title: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars["Widget Lab"].waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText(text)
        app.buttons["entry-\(entryID)"].tap()
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5), app.debugDescription)
        return app
    }

    @MainActor
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
