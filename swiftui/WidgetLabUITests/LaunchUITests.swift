import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testSearchOpenDetailAndCopyCode() {
        let app = openDetail(searching: "pad", entryID: "padding", title: ".padding")
        // VoiceOver では、コードの帯をコードの 1 行として読む
        XCTAssertEqual(app.buttons["code-strip"].label, ".padding(24)")
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
        // 左右の列の中で探す（並びの番号に頼らない）
        let without = app.otherElements["side-without"]
        let with = app.otherElements["side-with"]
        XCTAssertTrue(with.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(without.exists, app.debugDescription)
        XCTAssertLessThan(without.frame.midX, with.frame.midX, "付けない側が左")
        let withoutRedraws = redraws(in: without)
        let withRedraws = redraws(in: with)
        XCTAssertGreaterThanOrEqual(withoutRedraws, 0, app.debugDescription)
        without.buttons["+1"].tap()
        with.buttons["+1"].tap()
        XCTAssertTrue(with.staticTexts["count: 1"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(without.staticTexts["count: 0"].exists, "付けない側の表示は変わらない")
        XCTAssertGreaterThan(redraws(in: with), withRedraws, "付けた側は描き直す")
        XCTAssertEqual(redraws(in: without), withoutRedraws, "付けない側は描き直さない")
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

    @MainActor
    func testA11yEntriesShowPreview() {
        // UI テストはアクセシビリティの木を読めるので、modifier が木に届いたことを確かめる
        let label = openDetail(
            searching: "accessibilityLabel", entryID: "accessibilityLabel", title: ".accessibilityLabel")
        XCTAssertTrue(label.buttons["ごみ箱に入れる"].waitForExistence(timeout: 5), label.debugDescription)
        attachScreenshot(label, name: "accessibilityLabel")
        label.terminate()
        let element = openDetail(
            searching: "accessibilityElement", entryID: "accessibilityElement", title: ".accessibilityElement")
        XCTAssertTrue(element.staticTexts["星、お気に入り、12"].waitForExistence(timeout: 5), element.debugDescription)
        attachScreenshot(element, name: "accessibilityElement")
        element.terminate()
    }

    @MainActor
    func testInputEntriesShowPreview() {
        let tap = openDetail(searching: "onTapGesture", entryID: "onTapGesture", title: ".onTapGesture")
        tap.buttons["2 回タップ"].doubleTap()
        XCTAssertTrue(tap.staticTexts["タップ（2 回）"].waitForExistence(timeout: 5), tap.debugDescription)
        attachScreenshot(tap, name: "onTapGesture")
        tap.terminate()
        let drag = openDetail(searching: "draggable", entryID: "draggable", title: ".draggable")
        let apple = drag.staticTexts.matching(NSPredicate(format: "label == %@", "りんご")).firstMatch
        let box = drag.staticTexts["ここに落とす"]
        XCTAssertTrue(apple.waitForExistence(timeout: 5), drag.debugDescription)
        XCTAssertTrue(box.waitForExistence(timeout: 5), drag.debugDescription)
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "hittable == true"), object: apple)
        XCTAssertEqual(XCTWaiter().wait(for: [hittable], timeout: 5), .completed, drag.debugDescription)
        for _ in 0..<3 where box.exists {
            apple.press(forDuration: 1.5, thenDragTo: box, withVelocity: .slow, thenHoldForDuration: 1.5)
            _ = box.waitForNonExistence(timeout: 3)
        }
        XCTAssertFalse(box.exists, drag.debugDescription)
        attachScreenshot(drag, name: "draggable")
        drag.terminate()
    }

    /// 列の上の「描き直し N 回」の N
    @MainActor
    private func redraws(in column: XCUIElement) -> Int {
        let label = column.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "描き直し")).firstMatch.label
        return Int(label.filter(\.isNumber)) ?? -1
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
