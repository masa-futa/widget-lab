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

    /// 全画面の収録は「試す」で全画面に開き、付けない側に切り替えられ、閉じると詳細に戻る
    @MainActor
    func testFullEntryOpensFullScreenAndCloses() {
        let app = openDetail(searching: "statusBarHidden", entryID: "statusBarHidden", title: ".statusBarHidden")
        app.buttons["try-full"].tap()
        let close = app.buttons["close-full"]
        XCTAssertTrue(close.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(app.staticTexts["画面のいちばん上の時刻を見る"].exists)
        attachScreenshot(app, name: "statusBarHidden-full")
        app.buttons["付けない"].tap()
        attachScreenshot(app, name: "statusBarHidden-full-without")
        close.tap()
        XCTAssertTrue(app.navigationBars[".statusBarHidden"].waitForExistence(timeout: 5), app.debugDescription)
    }

    @MainActor
    func testNavigationEntriesShowPreview() {
        let sheet = openDetail(
            searching: "presentationDetents", entryID: "presentationDetents", title: ".presentationDetents")
        sheet.buttons["シートを開く"].tap()
        XCTAssertTrue(sheet.staticTexts["シートの中身"].waitForExistence(timeout: 5), sheet.debugDescription)
        attachScreenshot(sheet, name: "presentationDetents")
        sheet.terminate()
        let stack = openDetail(searching: "NavigationStack", entryID: "NavigationStack", title: "NavigationStack")
        stack.buttons["try-full"].tap()
        stack.buttons["ぶどうの先まで"].tap()
        XCTAssertTrue(stack.staticTexts["ぶどうの先"].waitForExistence(timeout: 5), stack.debugDescription)
        attachScreenshot(stack, name: "NavigationStack")
        stack.terminate()
    }

    @MainActor
    func testShellEntriesShowPreview() {
        let scopes = openDetail(searching: "searchScopes", entryID: "searchScopes", title: ".searchScopes")
        scopes.buttons["try-full"].tap()
        scopes.searchFields.firstMatch.tap()
        XCTAssertTrue(scopes.buttons["野菜"].waitForExistence(timeout: 5), scopes.debugDescription)
        attachScreenshot(scopes, name: "searchScopes")
        scopes.terminate()
        let rename = openDetail(searching: "RenameButton", entryID: "RenameButton", title: "RenameButton")
        rename.buttons["名称変更"].tap()
        XCTAssertTrue(rename.keyboards.firstMatch.waitForExistence(timeout: 5), rename.debugDescription)
        attachScreenshot(rename, name: "RenameButton")
        rename.terminate()
    }

    @MainActor
    func testDataEntriesShowPreview() {
        let focus = openDetail(searching: "focusedValue", entryID: "focusedValue", title: ".focusedValue")
        focus.textFields["メモ A"].tap()
        XCTAssertTrue(
            focus.staticTexts["フォーカスのあるメモ: メモ A"].waitForExistence(timeout: 5), focus.debugDescription)
        attachScreenshot(focus, name: "focusedValue")
        focus.terminate()
        let anchor = openDetail(searching: "anchorPreference", entryID: "anchorPreference", title: ".anchorPreference")
        attachScreenshot(anchor, name: "anchorPreference")
        anchor.terminate()
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
