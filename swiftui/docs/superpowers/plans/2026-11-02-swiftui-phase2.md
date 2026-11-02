# SwiftUI 版 Phase 2（見た目を持たないもの）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `@State`・`@Binding`・`TapGesture` の 3 件で、見た目を持たないものの仕組み（記録の窓口・body の回数・イベントのログ・左右に並べる比べる）を通す。

**Architecture:** 記録の窓口 `DemoRecorder` を収録データの側（`Catalog/Model/Demo/`）に置き、SwiftUI の Environment で見本に渡す。詳細画面の `DetailRecorder`（`@Observable`）が側ごとの窓口を作り、回数とログを持つ。プロパティラッパーは `.wrapper` のプロパティとして付け外しし、コードは `WrapperCode` の 2 つの形を使う。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Observation / Swift Testing / XCTest（UI テストだけ）/ swift-format

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase2-design.md`

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする。組み立ての関数と、記録の窓口（`DemoRecorder`・`reportBody`）だけが `@MainActor`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。タップできるものは 44pt 以上
- 比べるの左右は、`.card` と同じく左が「付けない」、右が「付けた」
- 記録のログは新しい順で、最大 20 行（`DetailRecorder.maxLines`）
- body の回数は「増えた／増えない」で確かめる（SwiftUI の都合で 1〜2 回ずれるので、正確な数をテストしない）
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120
  ```
- 整形: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests`
- コミットの最後に `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` を付ける。署名鍵・認証情報・`.env` はコミットしない

## ファイルの地図

| ファイル | 役割 | タスク |
|---|---|---|
| `WidgetLab/Catalog/Model/PropertySpec.swift` | `.wrapper` の置き場所と `PropertySpec.wrapper` | 1 |
| `WidgetLab/Catalog/Model/CodeTemplate.swift` | `WrapperCode`、ラッパーのコード、括弧の決まり | 1 |
| `WidgetLab/Catalog/Model/Demo/DemoRecorder.swift`（新規） | 記録の窓口・Environment・`reportBody` | 2 |
| `WidgetLab/Features/Detail/ViewModel/DetailRecorder.swift`（新規） | 詳細の記録（側ごとの窓口・回数・ログ） | 2 |
| `WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift` | 記録を持ち、変えたら見本を作り直す。ラッパーのチップの値 | 2・3 |
| `WidgetLab/Catalog/ModelData/StateEntry.swift`・`BindingEntry.swift`、`WidgetLab/Catalog/Gestures/TapGestureEntry.swift`（新規） | 収録の 3 件 | 3 |
| `WidgetLab/Catalog/Catalog.swift` | 3 件を並べる | 3 |
| `WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`・`UI/HomeScreen.swift` | 表示の名前で検索、`isSearching` | 4 |
| `WidgetLab/Features/Detail/UI/PreviewArea.swift`・`RecordPanel.swift`（新規） | 左右に並べる見本と記録の欄 | 5 |
| `WidgetLab/Features/Catalog/UI/TopicScreen.swift` | 一覧の行の見本を stage で分ける | 5 |
| `WidgetLabUITests/LaunchUITests.swift` | 準備の補助と 3 本目 | 5 |
| `docs/adr/ADR-0002-data-driven-demos.md`・`docs/architecture.md`・`docs/PRD.md`・`docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md` | ドキュメント | 6 |

---

### Task 1: プロパティラッパーのコード（`.wrapper` と `WrapperCode`）

**Files:**
- Modify: `WidgetLab/Catalog/Model/PropertySpec.swift`
- Modify: `WidgetLab/Catalog/Model/CodeTemplate.swift`
- Test: `WidgetLabTests/Catalog/CodeGeneratorTests.swift`

**Interfaces:**
- Produces: `PropertySpec.Placement.wrapper`、`PropertySpec.wrapper(_ id: String, summary: String) -> PropertySpec`（操作部品は `.fixed(code: "@" + id)`、最初は ON、`displayName` は `"@" + id`）、`CodeTemplate.wrapper: WrapperCode?`（既定 `nil`）、`WrapperCode(withWrapper: [String], withoutWrapper: [String])`
- 括弧の決まりが変わる: 引数がなく、`trailing` が `" {"` で始まるときだけ括弧を省く

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Catalog/CodeGeneratorTests.swift` の最後の `}`（struct の閉じ）の直前に足す:

```swift
    @Test func keepsParenthesesWhenTrailingIsNotClosure() {
        let template = CodeTemplate(prefix: ["Rectangle()"], call: ".gesture(TapGesture", trailing: ".onEnded { })")
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["Rectangle()", "    .gesture(TapGesture().onEnded { })"])
    }

    private let wrapperCode = WrapperCode(
        withWrapper: ["@State private var count = 0", "", "var body: some View {", "    Text(\"\\(count)\")", "}"],
        withoutWrapper: ["private let box = Box()", "", "var body: some View {", "    Text(\"\\(box.count)\")", "}"])

    @Test func wrapperOnUsesWrappedFormAndPointsAtDeclaration() {
        let spec = PropertySpec.wrapper("State", summary: "")
        #expect(spec.displayName == "@State")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "State", wrapper: wrapperCode), properties: [spec],
            values: PropertyValues(["State": spec.control.initialValue]))
        #expect(lines.map(\.text) == wrapperCode.withWrapper)
        #expect(lines.map(\.propertyIDs) == [["State"], [], [], [], []])
        #expect(lines.allSatisfy { !$0.isChanged })
    }

    @Test func wrapperOffUsesUnwrappedFormAndMarksDifferentLines() {
        let spec = PropertySpec.wrapper("State", summary: "")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "State", wrapper: wrapperCode), properties: [spec], values: PropertyValues(),
            changed: ["State"])
        #expect(lines.map(\.text) == wrapperCode.withoutWrapper)
        #expect(lines.map(\.isChanged) == [true, false, false, true, false])
        #expect(lines.map(\.propertyIDs) == [["State"], [], [], ["State"], []])
    }
```

- [ ] **Step 2: テストが失敗することを確かめる**

Run: `xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' -derivedDataPath build CODE_SIGNING_ALLOWED=NO -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 -only-testing:WidgetLabTests`
Expected: ビルドが失敗する（`WrapperCode`・`PropertySpec.wrapper`・`CodeTemplate(call:wrapper:)` がない）

- [ ] **Step 3: `PropertySpec.swift` を直す**

ファイル全体をこの内容にする（`Placement.wrapper`・`displayName` の `.wrapper`・`static func wrapper` を足した）:

```swift
import SwiftUI

/// 操作できるプロパティ 1 つの定義
nonisolated struct PropertySpec: Identifiable, Sendable {
    enum Placement: Equatable, Sendable {
        /// イニシャライザ（modifier の収録なら、その modifier）の引数。label が nil なら名前なしの引数
        case argument(label: String?)
        /// modifier。label が nil なら名前なしの引数
        case modifier(name: String, label: String?)
        /// プロパティラッパーそのもの（宣言の頭の @State など）。OFF にすると、ラッパーを外した書き方になる
        case wrapper
    }

    let id: String
    let placement: Placement
    let control: PropertyControl
    let initiallyOn: Bool
    /// OFF にできない（Text の文字など、省くとコードが成り立たない引数）
    var isRequired: Bool = false
    /// 一言の説明（日本語）
    let summary: String

    /// チップと編集パネルに出す名前（例: "role"、".tint"）
    var displayName: String {
        switch placement {
        case .argument: id
        case .modifier(let name, _): "." + name
        case .wrapper: "@" + id
        }
    }

    /// 引数のプロパティ。引数のラベルは id と同じ（unlabeled なら名前なし）。required ならいつも ON
    static func argument(
        _ id: String, unlabeled: Bool = false, _ control: PropertyControl, on: Bool = false, required: Bool = false,
        summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id, placement: .argument(label: unlabeled ? nil : id), control: control, initiallyOn: on || required,
            isRequired: required, summary: summary)
    }

    static func modifier(
        _ name: String, label: String? = nil, _ control: PropertyControl, on: Bool = false, summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: name, placement: .modifier(name: name, label: label), control: control, initiallyOn: on,
            summary: summary)
    }

    /// プロパティラッパーそのもの。いつも最初は ON。コードは CodeTemplate.wrapper の 2 つの形を使う
    static func wrapper(_ id: String, summary: String) -> PropertySpec {
        PropertySpec(id: id, placement: .wrapper, control: .fixed(code: "@" + id), initiallyOn: true, summary: summary)
    }
}

/// 操作部品の種類。値の型とコードの書き方を持つ
nonisolated enum PropertyControl: Sendable {
    case slider(range: ClosedRange<Double>, step: Double, initial: Double)
    case toggle(initial: Bool)
    case choice([Choice], initial: Int)
    case color(initial: Int)
    case text(initial: String)
    /// 値を変えられない。ON/OFF だけ切り替える
    case fixed(code: String)

    var initialValue: PropertyValue {
        switch self {
        case .slider(_, _, let initial): .number(initial)
        case .toggle(let initial): .flag(initial)
        case .choice(_, let initial): .choice(initial)
        case .color(let initial): .color(initial)
        case .text(let initial): .text(initial)
        case .fixed: .flag(true)
        }
    }

    /// 値を Swift のコードの文字列にする
    func code(for value: PropertyValue) -> String {
        switch (self, value) {
        case (.slider, .number(let n)):
            n.rounded() == n ? String(Int(n)) : String(format: "%.1f", n)
        case (.toggle, .flag(let b)):
            b ? "true" : "false"
        case (.choice(let choices, _), .choice(let i)):
            choices[i].code
        case (.color, .color(let i)):
            Palette.colors[i].code
        case (.text, .text(let s)):
            "\"" + s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
        case (.fixed(let code), _):
            code
        default:
            preconditionFailure("操作部品と値の種類が合わない: \(self) / \(value)")
        }
    }
}

/// 選択肢 1 つ。表示の名前とコードの文字列の組
nonisolated struct Choice: Sendable {
    let label: String
    let code: String

    init(_ label: String, code: String) {
        self.label = label
        self.code = code
    }

    /// 表示の名前とコードが同じもの（例: ".bordered"）
    init(_ code: String) {
        self.init(code, code: code)
    }
}

/// 色の操作部品で選べる色
nonisolated enum Palette {
    struct Entry: Sendable {
        let name: String
        let code: String
        let color: Color
    }

    static let colors: [Entry] = [
        Entry(name: "red", code: ".red", color: .red),
        Entry(name: "orange", code: ".orange", color: .orange),
        Entry(name: "yellow", code: ".yellow", color: .yellow),
        Entry(name: "green", code: ".green", color: .green),
        Entry(name: "blue", code: ".blue", color: .blue),
        Entry(name: "purple", code: ".purple", color: .purple),
        Entry(name: "pink", code: ".pink", color: .pink),
        Entry(name: "gray", code: ".gray", color: .gray),
    ]
}
```

- [ ] **Step 4: `CodeTemplate.swift` を直す**

ファイル全体をこの内容にする（`wrapper`・`WrapperCode`・`wrapperLines`、括弧の決まり）:

```swift
import Foundation

/// コードの形。CodeGenerator が、ON のプロパティを埋めてコードにする
///
/// 例: Button("保存", role: .destructive) { } に .tint(.red) が付くとき
///     call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"
nonisolated struct CodeTemplate: Sendable {
    /// 呼び出しより前の行（modifier の収録で、かける相手の見本。例: ["Text(\"見本\")"]）
    var prefix: [String] = []
    /// 呼び出しの名前（例: "Button"、".padding"）
    var call: String
    /// いつも書く引数（ON の引数のプロパティより前に並ぶ）
    var fixedArguments: [String] = []
    /// 呼び出しのあとの末尾のクロージャ（例: " { }"。複数行は "\n" で区切る）
    var trailing: String = ""
    /// いちばん最後に付ける modifier の行（例: [".background(.yellow)"]）
    var suffix: [String] = []
    /// プロパティラッパーの収録のコード。あるときは、ここまでの穴埋めの形の代わりに使う
    var wrapper: WrapperCode?
}

/// プロパティラッパーの収録のコード。宣言と body を、付けた形と外した形の 2 通りで持つ
/// （ラッパーを外すと、宣言だけでなく使う側の行も変わるため）
nonisolated struct WrapperCode: Sendable {
    let withWrapper: [String]
    let withoutWrapper: [String]
}

/// コードの 1 行
nonisolated struct CodeLine: Equatable, Sendable {
    let text: String
    /// この行に書いたプロパティの id
    let propertyIDs: [String]
    /// 最初の値から変えたプロパティがこの行にあるか
    let isChanged: Bool
}

nonisolated enum CodeGenerator {
    /// ON のプロパティを埋めて、コードを行ごとに返す
    static func lines(
        template: CodeTemplate, properties: [PropertySpec], values: PropertyValues, changed: Set<String> = []
    ) -> [CodeLine] {
        if let wrapper = template.wrapper, let spec = properties.first(where: { $0.placement == .wrapper }) {
            return wrapperLines(
                wrapper, id: spec.id, isOn: values[spec.id] != nil, isChanged: changed.contains(spec.id))
        }
        let indent = template.prefix.isEmpty ? "" : "    "
        var result = template.prefix.map { CodeLine(text: $0, propertyIDs: [], isChanged: false) }

        var arguments = template.fixedArguments
        var argumentIDs: [String] = []
        for spec in properties {
            guard case .argument(let label) = spec.placement, let value = values[spec.id] else { continue }
            arguments.append(argument(label: label, code: spec.control.code(for: value)))
            argumentIDs.append(spec.id)
        }
        // 末尾のクロージャだけなら括弧を省く（Button { } など）。.onEnded { } のような続きなら省かない
        let parentheses =
            arguments.isEmpty && template.trailing.hasPrefix(" {") ? "" : "(" + arguments.joined(separator: ", ") + ")"
        let callLines = (indent + template.call + parentheses + template.trailing).components(separatedBy: "\n")
        let callChanged = !changed.isDisjoint(with: argumentIDs)
        result += callLines.enumerated().map { index, text in
            CodeLine(text: text, propertyIDs: index == 0 ? argumentIDs : [], isChanged: index == 0 && callChanged)
        }

        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement, let value = values[spec.id] else { continue }
            let text = "    .\(name)(" + argument(label: label, code: spec.control.code(for: value)) + ")"
            result.append(CodeLine(text: text, propertyIDs: [spec.id], isChanged: changed.contains(spec.id)))
        }
        result += template.suffix.map { CodeLine(text: "    " + $0, propertyIDs: [], isChanged: false) }
        return result
    }

    /// 付けた形では宣言の行に、外した形では付けた形と違う行に、ラッパーの id を付ける
    private static func wrapperLines(_ code: WrapperCode, id: String, isOn: Bool, isChanged: Bool) -> [CodeLine] {
        if isOn {
            return code.withWrapper.map { text in
                let isDeclaration = text.contains("@" + id)
                return CodeLine(
                    text: text, propertyIDs: isDeclaration ? [id] : [], isChanged: isDeclaration && isChanged)
            }
        }
        return code.withoutWrapper.map { text in
            let differs = !code.withWrapper.contains(text)
            return CodeLine(text: text, propertyIDs: differs ? [id] : [], isChanged: differs && isChanged)
        }
    }

    private static func argument(label: String?, code: String) -> String {
        label.map { "\($0): \(code)" } ?? code
    }
}
```

- [ ] **Step 5: 整形・lint・テストを通す**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の「確かめ」
Expected: lint の出力なし、`OK`、`** TEST SUCCEEDED **`（既存の `omitsParenthesesWhenOnlyTrailingClosure` も通る）

- [ ] **Step 6: コミット**

```bash
git add WidgetLab/Catalog/Model/PropertySpec.swift WidgetLab/Catalog/Model/CodeTemplate.swift WidgetLabTests/Catalog/CodeGeneratorTests.swift
git commit -m "feat: プロパティラッパーを付け外しするプロパティと、2 つの形のコードを足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: 記録の仕組み（`DemoRecorder`・`DetailRecorder`・見本の作り直し）

**Files:**
- Create: `WidgetLab/Catalog/Model/Demo/DemoRecorder.swift`
- Create: `WidgetLab/Features/Detail/ViewModel/DetailRecorder.swift`
- Modify: `WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`
- Test: `WidgetLabTests/Features/Detail/DetailRecorderTests.swift`（新規）、`WidgetLabTests/Features/Detail/DetailViewModelTests.swift`

**Interfaces:**
- Produces:
  - `@MainActor protocol DemoRecorder: AnyObject, Sendable { func bodyEvaluated(_ name: String); func log(_ event: String) }`
  - `EnvironmentValues.demoRecorder: (any DemoRecorder)?`（既定 `nil`）
  - `@MainActor func reportBody(_ recorder: (any DemoRecorder)?, _ name: String)`（見本の body の中で `let _ = reportBody(recorder, "見本")`）
  - `enum RecordSide { case with, without }`、`struct BodyCount: Equatable { name: String; count: Int }`、`struct RecordLine: Identifiable, Equatable { id: Int; side: RecordSide; text: String }`
  - `@Observable final class DetailRecorder`: `static let maxLines = 20`、`private(set) var lines: [RecordLine]`（新しい順）、`func recorder(for: RecordSide) -> any DemoRecorder`（同じ側には同じもの）、`func bodyCounts(_: RecordSide) -> [BodyCount]`、`func clear()`
  - `DetailViewModel`: `let recorder: DetailRecorder`、`private(set) var demoGeneration: Int`。`setOn`・`setValue`・`reset` と、`isComparing`・`selectedID` を変えたときに、記録を消して `demoGeneration` を増やす
- フォルダはファイルと同期する（project.pbxproj を直す必要はない）

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Features/Detail/DetailRecorderTests.swift` を作る:

```swift
import Testing
@testable import WidgetLab

@MainActor
struct DetailRecorderTests {
    private let recorder = DetailRecorder()

    @Test func countsBodyPerSideAndNameInFirstSeenOrder() {
        let with = recorder.recorder(for: .with)
        with.bodyEvaluated("親")
        with.bodyEvaluated("子")
        with.bodyEvaluated("親")
        recorder.recorder(for: .without).bodyEvaluated("親")
        #expect(recorder.bodyCounts(.with) == [BodyCount(name: "親", count: 2), BodyCount(name: "子", count: 1)])
        #expect(recorder.bodyCounts(.without) == [BodyCount(name: "親", count: 1)])
    }

    @Test func returnsSameRecorderForSameSide() {
        #expect(recorder.recorder(for: .with) === recorder.recorder(for: .with))
        #expect(recorder.recorder(for: .with) !== recorder.recorder(for: .without))
    }

    @Test func keepsNewestLinesFirstWithSideUpToMax() {
        recorder.recorder(for: .without).log("最初")
        for i in 1...DetailRecorder.maxLines {
            recorder.recorder(for: .with).log("\(i)")
        }
        #expect(recorder.lines.count == DetailRecorder.maxLines)
        #expect(recorder.lines.first?.text == "\(DetailRecorder.maxLines)")
        #expect(recorder.lines.first?.side == .with)
        #expect(recorder.lines.last?.text == "1")
        #expect(Set(recorder.lines.map(\.id)).count == recorder.lines.count)
    }

    @Test func clearEmptiesCountsAndLines() {
        recorder.recorder(for: .with).bodyEvaluated("見本")
        recorder.recorder(for: .with).log("タップ")
        recorder.clear()
        #expect(recorder.bodyCounts(.with).isEmpty)
        #expect(recorder.lines.isEmpty)
    }
}
```

`WidgetLabTests/Features/Detail/DetailViewModelTests.swift` の最後の `}`（struct の閉じ）の直前に足す:

```swift
    @Test func editingAndResettingClearRecordsAndRestartDemo() {
        let viewModel = makeViewModel()
        viewModel.recorder.recorder(for: .with).log("タップ")
        let start = viewModel.demoGeneration
        viewModel.setValue("size", .number(8))
        #expect(viewModel.recorder.lines.isEmpty)
        #expect(viewModel.demoGeneration > start)

        viewModel.recorder.recorder(for: .without).bodyEvaluated("見本")
        viewModel.setOn("tint", true)
        #expect(viewModel.recorder.bodyCounts(.without).isEmpty)

        viewModel.recorder.recorder(for: .with).log("タップ")
        let beforeReset = viewModel.demoGeneration
        viewModel.reset()
        #expect(viewModel.recorder.lines.isEmpty)
        #expect(viewModel.demoGeneration > beforeReset)
    }

    @Test func togglingCompareOrSelectingClearsRecords() {
        let viewModel = makeViewModel()
        viewModel.recorder.recorder(for: .with).log("タップ")
        viewModel.isComparing = true
        #expect(viewModel.recorder.lines.isEmpty)

        viewModel.recorder.recorder(for: .with).log("タップ")
        viewModel.selectedID = "tint"
        #expect(viewModel.recorder.lines.isEmpty)
    }
```

- [ ] **Step 2: テストが失敗することを確かめる**

Run: `xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' -derivedDataPath build CODE_SIGNING_ALLOWED=NO -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 -only-testing:WidgetLabTests`
Expected: ビルドが失敗する（`DetailRecorder`・`recorder`・`demoGeneration` がない）

- [ ] **Step 3: 記録の窓口を作る**

`WidgetLab/Catalog/Model/Demo/DemoRecorder.swift`:

```swift
import SwiftUI

/// 見本の記録の窓口。見た目を持たないものの見本が、body の評価とイベントを書く。詳細画面が実装する
@MainActor
protocol DemoRecorder: AnyObject, Sendable {
    /// 見本の body が評価された（name は "見本"・"親"・"子" など）
    func bodyEvaluated(_ name: String)
    /// イベントが起きた（"タップを認識（2 回）" など）
    func log(_ event: String)
}

extension EnvironmentValues {
    /// 見本の記録の窓口。nil（一覧の行・テスト）なら記録しない
    @Entry var demoRecorder: (any DemoRecorder)? = nil
}

/// 見本の body の中で `let _ = reportBody(recorder, "見本")` と呼ぶ。body が評価されたことを、body が終わったあとで知らせる
/// （body の中で見張られた値を書くと、描き直しが止まらなくなるため）
@MainActor
func reportBody(_ recorder: (any DemoRecorder)?, _ name: String) {
    guard let recorder else { return }
    Task { recorder.bodyEvaluated(name) }
}
```

- [ ] **Step 4: 詳細の記録を作る**

`WidgetLab/Features/Detail/ViewModel/DetailRecorder.swift`:

```swift
import Foundation
import Observation

/// 比べるときの側
enum RecordSide: Sendable {
    /// 付けた（比べないときの見本もこちら）
    case with
    /// 付けない
    case without
}

/// body を評価した回数 1 つ
struct BodyCount: Equatable {
    let name: String
    let count: Int
}

/// 記録の 1 行
struct RecordLine: Identifiable, Equatable {
    let id: Int
    let side: RecordSide
    let text: String
}

/// 見本の記録（body を評価した回数とイベントのログ）。詳細画面が持ち、側ごとの窓口を見本に渡す
@Observable
final class DetailRecorder {
    static let maxLines = 20

    /// 新しい順
    private(set) var lines: [RecordLine] = []
    private var counts: [RecordSide: [BodyCount]] = [:]
    @ObservationIgnored private var nextID = 0
    @ObservationIgnored private var sides: [RecordSide: SideRecorder] = [:]

    /// 側ごとの窓口。同じ側には同じものを返す（Environment の値が変わって見本が描き直されないように）
    func recorder(for side: RecordSide) -> any DemoRecorder {
        if let recorder = sides[side] { return recorder }
        let recorder = SideRecorder(side: side, owner: self)
        sides[side] = recorder
        return recorder
    }

    /// 名前ごとの回数（最初に記録した順）
    func bodyCounts(_ side: RecordSide) -> [BodyCount] {
        counts[side] ?? []
    }

    func clear() {
        lines = []
        counts = [:]
    }

    fileprivate func countBody(_ name: String, side: RecordSide) {
        var list = counts[side] ?? []
        if let i = list.firstIndex(where: { $0.name == name }) {
            list[i] = BodyCount(name: name, count: list[i].count + 1)
        } else {
            list.append(BodyCount(name: name, count: 1))
        }
        counts[side] = list
    }

    fileprivate func append(_ text: String, side: RecordSide) {
        lines.insert(RecordLine(id: nextID, side: side, text: text), at: 0)
        nextID += 1
        if lines.count > Self.maxLines {
            lines.removeLast(lines.count - Self.maxLines)
        }
    }
}

/// 側 1 つの窓口。書かれたものに側を付けて DetailRecorder に渡す
private final class SideRecorder: DemoRecorder {
    let side: RecordSide
    /// DetailRecorder が窓口を持つので、こちらは弱く持つ
    weak var owner: DetailRecorder?

    init(side: RecordSide, owner: DetailRecorder) {
        self.side = side
        self.owner = owner
    }

    func bodyEvaluated(_ name: String) {
        owner?.countBody(name, side: side)
    }

    func log(_ event: String) {
        owner?.append(event, side: side)
    }
}
```

- [ ] **Step 5: `DetailViewModel` に記録と作り直しを足す**

ファイル全体をこの内容にする（`selectedID`・`isComparing` の `didSet`、`recorder`・`demoGeneration`、`restartDemo` と、`setOn`・`setValue`・`reset` からの呼び出しを足した）:

```swift
import Foundation
import Observation

/// 詳細画面の状態（プロパティの値・選んでいるプロパティ・比べる）
@Observable
final class DetailViewModel {
    let entry: CatalogEntry
    /// 選んでいるプロパティの id
    var selectedID: String? {
        didSet { restartDemo() }
    }
    var isComparing = false {
        didSet { restartDemo() }
    }
    /// コードをコピーした直後に true
    private(set) var didCopy = false
    /// 見本の記録（見た目を持たないものの見本が書く）
    let recorder = DetailRecorder()
    /// 見本を作り直すたびに増える。プレビューが見本の id に使う
    private(set) var demoGeneration = 0

    /// 全プロパティの今の値（OFF のものも、ON に戻したときのために値を覚えておく）
    private var values: [String: PropertyValue]
    private var enabled: Set<String>
    private let clipboard: any ClipboardClient

    init(entry: CatalogEntry, clipboard: any ClipboardClient) {
        self.entry = entry
        self.clipboard = clipboard
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        // required のプロパティは付けない状態がないので、比べられるものを先に選ぶ
        let properties = entry.properties
        selectedID =
            (properties.first { $0.initiallyOn && !$0.isRequired } ?? properties.first { !$0.isRequired }
            ?? properties.first)?.id
    }

    var selected: PropertySpec? {
        entry.properties.first { $0.id == selectedID }
    }

    func isOn(_ id: String) -> Bool {
        enabled.contains(id)
    }

    func setOn(_ id: String, _ on: Bool) {
        guard entry.properties.first(where: { $0.id == id })?.isRequired != true else { return }
        if on { enabled.insert(id) } else { enabled.remove(id) }
        didCopy = false
        restartDemo()
    }

    func value(_ id: String) -> PropertyValue? {
        values[id]
    }

    /// 値を変える。OFF なら ON にする
    func setValue(_ id: String, _ value: PropertyValue) {
        values[id] = value
        enabled.insert(id)
        didCopy = false
        restartDemo()
    }

    func reset() {
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        isComparing = false
        didCopy = false
        restartDemo()
    }

    /// 記録を消して、見本を作り直す（回数を 0 から数え直す）
    private func restartDemo() {
        recorder.clear()
        demoGeneration += 1
    }

    /// プレビューに渡す値（ON のものだけ）
    var current: PropertyValues {
        PropertyValues(values.filter { enabled.contains($0.key) })
    }

    /// 選んでいるプロパティを比べられるか（required は付けない状態がないので比べられない）
    var canCompare: Bool {
        selected.map { !$0.isRequired } ?? false
    }

    /// 比べるときの 2 つ（選んでいるプロパティを付けない／付けた。ほかは同じ）
    var comparison: (without: PropertyValues, with: PropertyValues)? {
        guard isComparing, canCompare, let id = selectedID else { return nil }
        var without = current
        var with = current
        without[id] = nil
        with[id] = values[id]
        return (without, with)
    }

    /// チップに出す今の値（OFF なら "OFF"）
    func valueLabel(_ id: String) -> String {
        guard let spec = entry.properties.first(where: { $0.id == id }), enabled.contains(id), let value = values[id]
        else { return "OFF" }
        if case .text(let s) = value { return s }
        return spec.control.code(for: value)
    }

    /// 最初の値から変えたプロパティ
    var changedIDs: Set<String> {
        let initial = entry.initialValues
        let now = current
        return Set(entry.properties.map(\.id).filter { initial[$0] != now[$0] })
    }

    var codeLines: [CodeLine] {
        CodeGenerator.lines(
            template: entry.code, properties: entry.properties, values: current, changed: changedIDs)
    }

    /// 選んでいるプロパティを書いた行。なければ呼び出しの行
    var selectedLine: CodeLine? {
        let lines = codeLines
        if let id = selectedID, let line = lines.first(where: { $0.propertyIDs.contains(id) }) { return line }
        return lines.first { $0.text.trimmingCharacters(in: .whitespaces).hasPrefix(entry.code.call) }
    }

    var codeText: String {
        codeLines.map(\.text).joined(separator: "\n")
    }

    func copyCode() {
        clipboard.copy(codeText)
        didCopy = true
    }
}
```

- [ ] **Step 6: 整形・lint・テストを通す**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の「確かめ」
Expected: lint の出力なし、`OK`、`** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Catalog/Model/Demo WidgetLab/Features/Detail/ViewModel WidgetLabTests/Features/Detail
git commit -m "feat: 見本の記録の窓口と、詳細で回数とログを持つ記録を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: 収録の 3 件（`@State`・`@Binding`・`TapGesture`）

**Files:**
- Create: `WidgetLab/Catalog/ModelData/StateEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/BindingEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/TapGestureEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`
- Modify: `WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`（`valueLabel`）
- Test: `WidgetLabTests/Catalog/CatalogTests.swift`、`WidgetLabTests/Features/Detail/DetailViewModelTests.swift`

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.wrapper`・`CodeTemplate(call:wrapper:)`・`WrapperCode`、Task 2 の `EnvironmentValues.demoRecorder`・`reportBody`
- Produces: `CatalogEntry.state`（id `"State"`）、`CatalogEntry.binding`（id `"Binding"`）、`CatalogEntry.tapGesture`（id `"TapGesture"`）。3 件とも `stage: .behavior`。`@State` の見本には `"+1"` のボタンと `"count: N"` の文字がある（Task 5 の UI テストが使う）
- id・種類・トピックは `Generated/Manifest.swift` と同じ（`State`・`Binding` は `.propertyWrapper`・`.modelData`、`TapGesture` は `.gesture`・`.gestures`）

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Features/Detail/DetailViewModelTests.swift` の最後の `}`（struct の閉じ）の直前に足す:

```swift
    @Test func stateEntrySelectsWrapperAndComparesWithAndWithout() {
        let viewModel = DetailViewModel(entry: .state, clipboard: clipboard)
        #expect(viewModel.selectedID == "State")
        #expect(viewModel.canCompare)
        #expect(viewModel.valueLabel("State") == "ON")
        #expect(viewModel.selectedLine?.text == "@State private var count = 0")
        viewModel.isComparing = true
        #expect(viewModel.comparison?.without["State"] == nil)
        #expect(viewModel.comparison?.with["State"] != nil)
        viewModel.setOn("State", false)
        #expect(viewModel.valueLabel("State") == "OFF")
        #expect(viewModel.selectedLine?.text == "private let box = Box()  // SwiftUI が見張らない参照型")
    }
```

`WidgetLabTests/Catalog/CatalogTests.swift` の `buildsAllCombinations` の `for` の中身を、stage で分ける（`.full`・`.behavior` は組み立てだけ）:

```swift
        for values in Self.combinations(of: entry) {
            let view = entry.build(values)
            // .full・.behavior は組み立てだけ（全画面や記録の窓口がないと、描いても確かめられない）
            if entry.stage == .card {
                let renderer = ImageRenderer(content: view.frame(width: 320, height: 240))
                #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            }
            _ = CodeGenerator.lines(template: entry.code, properties: entry.properties, values: values)
        }
```

- [ ] **Step 2: テストが失敗することを確かめる**

Run: `xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' -derivedDataPath build CODE_SIGNING_ALLOWED=NO -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 -only-testing:WidgetLabTests`
Expected: ビルドが失敗する（`CatalogEntry.state` がない）

- [ ] **Step 3: `@State` を作る**

`WidgetLab/Catalog/ModelData/StateEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let state = CatalogEntry(
        id: "State",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "View が持つ値。値が変わると、その値を使う View が描き直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/state")!,
        stage: .behavior,
        properties: [
            .wrapper("State", summary: "外すと、値は変わっても SwiftUI が見張らないので、表示が描き直されない")
        ],
        code: CodeTemplate(
            call: "State",
            wrapper: WrapperCode(
                withWrapper: [
                    "@State private var count = 0",
                    "",
                    "var body: some View {",
                    "    Button(\"+1\") { count += 1 }",
                    "    Text(\"count: \\(count)\")",
                    "}",
                ],
                withoutWrapper: [
                    "private let box = Box()  // SwiftUI が見張らない参照型",
                    "",
                    "var body: some View {",
                    "    Button(\"+1\") { box.count += 1 }",
                    "    Text(\"count: \\(box.count)\")",
                    "}",
                ])),
        build: { v in
            v["State"] != nil ? AnyView(StateDemo.WithState()) : AnyView(StateDemo.WithoutState())
        }
    )
}

private enum StateDemo {
    struct WithState: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "見本")
            VStack(spacing: 8) {
                Button("+1") {
                    count += 1
                    recorder?.log("count を \(count) にした")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Text("count: \(count)")
                    .monospacedDigit()
            }
        }
    }

    /// SwiftUI が見張らない参照型
    final class Box {
        var count = 0
    }

    struct WithoutState: View {
        private let box = Box()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "見本")
            VStack(spacing: 8) {
                Button("+1") {
                    box.count += 1
                    recorder?.log("count を \(box.count) にした（表示は変わらない）")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Text("count: \(box.count)")
                    .monospacedDigit()
            }
        }
    }
}
```

- [ ] **Step 4: `@Binding` を作る**

`WidgetLab/Catalog/ModelData/BindingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let binding = CatalogEntry(
        id: "Binding",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "ほかの View が持つ値を読み書きする参照。子の View から親の値を変えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/binding")!,
        stage: .behavior,
        properties: [
            .wrapper("Binding", summary: "外して値のコピーを持つと、子で変えても親に届かない")
        ],
        code: CodeTemplate(
            call: "Binding",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: $count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@Binding var count: Int",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@State var count: Int  // 親の値のコピー",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ])),
        build: { v in
            AnyView(BindingDemo.Parent(usesBinding: v["Binding"] != nil))
        }
    )
}

private enum BindingDemo {
    struct Parent: View {
        let usesBinding: Bool
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Text("親: \(count)")
                    .monospacedDigit()
                if usesBinding {
                    BoundChild(count: $count)
                } else {
                    CopiedChild(count: count)
                }
            }
        }
    }

    struct BoundChild: View {
        @Binding var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした") }
        }
    }

    struct CopiedChild: View {
        /// 親の値のコピー
        @State var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした（親には届かない）") }
        }
    }

    struct ChildStepper: View {
        @Binding var count: Int

        var body: some View {
            Stepper(value: $count) {
                Text("子: \(count)").monospacedDigit()
            }
            .fixedSize()
        }
    }
}
```

- [ ] **Step 5: `TapGesture` を作る**

`WidgetLab/Catalog/Gestures/TapGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tapGesture = CatalogEntry(
        id: "TapGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった回数のタップを認識するジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/tapgesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "認識するタップの回数。省くと 1 回")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(TapGesture", trailing: ".onEnded { })"),
        build: { v in
            AnyView(TapGestureDemo(count: v.number("count").map { Int($0) }))
        }
    )
}

private struct TapGestureDemo: View {
    /// nil なら TapGesture()（1 回）
    let count: Int?
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        RoundedRectangle(cornerRadius: 12)
            .fill(.tint.opacity(0.25))
            .frame(width: 120, height: 72)
            .overlay {
                Text("\(count ?? 1) 回タップ")
                    .font(.caption)
            }
            .gesture(gesture.onEnded { recorder?.log("タップを認識（\(count ?? 1) 回）") })
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
    }

    private var gesture: TapGesture {
        if let count { TapGesture(count: count) } else { TapGesture() }
    }
}
```

- [ ] **Step 6: 全件の一覧に並べる**

`WidgetLab/Catalog/Catalog.swift`:

```swift
/// 収録の全件。収録データを足したら、ここに並べる
nonisolated enum Catalog {
    static let all: [CatalogEntry] = [
        .button,
        .text,
        .vStack,
        .padding,
        .state,
        .binding,
        .tapGesture,
    ]
}
```

- [ ] **Step 7: ラッパーのチップの値を「ON」にする**

`WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift` の `valueLabel(_:)` で、`else { return "OFF" }` の次の行に足す（チップの名前と値が両方 `@State` にならないように）:

```swift
        if spec.placement == .wrapper { return "ON" }
```

- [ ] **Step 8: 整形・lint・テストを通す**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の「確かめ」
Expected: lint の出力なし、`OK`、`** TEST SUCCEEDED **`（`buildsAllCombinations` が 7 件分になる）

- [ ] **Step 9: コミット**

```bash
git add WidgetLab/Catalog WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift WidgetLabTests
git commit -m "feat: @State・@Binding・TapGesture を収録する

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: 表示の名前で検索し、検索中かを ViewModel に持たせる

**Files:**
- Modify: `WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`
- Modify: `WidgetLab/Features/Catalog/UI/HomeScreen.swift`
- Modify: `WidgetLabTests/Support/Fakes.swift`
- Test: `WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift`

**Interfaces:**
- Produces: `CatalogViewModel.isSearching: Bool`（前後の空白を除いて `query` が空でない）。`results` は `displayName`（`"@State"`・`".padding"`。id を含む）の部分一致
- `CatalogEntry.fake(id:kind:topic:)` に `kind: EntryKind = .view` を足す（既存の呼び出しはそのまま動く）

- [ ] **Step 1: fake に種類を足す**

`WidgetLabTests/Support/Fakes.swift` の `fake` の宣言と `kind:` の行を、次のように直す:

```swift
    static func fake(id: String = "Sample", kind: EntryKind = .view, topic: Topic = .controlsAndIndicators)
        -> CatalogEntry
    {
        CatalogEntry(
            id: id,
            kind: kind,
```

- [ ] **Step 2: 失敗するテストを書く**

`WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift` を、この内容にする（fake に modifier と プロパティラッパーを足し、表示の名前と `isSearching` のテストを足した）:

```swift
import Testing
@testable import WidgetLab

@MainActor
struct CatalogViewModelTests {
    private func makeViewModel() -> CatalogViewModel {
        CatalogViewModel(
            repository: FakeCatalogRepository(entries: [
                .fake(id: "Button", topic: .controlsAndIndicators),
                .fake(id: "Toggle", topic: .controlsAndIndicators),
                .fake(id: "padding", kind: .modifier, topic: .layoutAdjustments),
                .fake(id: "State", kind: .propertyWrapper, topic: .modelData),
            ]))
    }

    @Test func sectionsListOnlyTopicsWithEntriesInDeclarationOrder() {
        let sections = makeViewModel().sections
        #expect(sections.map(\.category) == [.views, .viewLayout, .dataAndStorage])
        #expect(sections[0].topics.map(\.topic) == [.controlsAndIndicators])
        #expect(sections[0].topics[0].count == 2)
        #expect(sections[0].topics[0].sampleNames == ["Button", "Toggle"])
    }

    @Test func searchMatchesPartOfNameIgnoringCaseInAlphabeticalOrder() {
        let viewModel = makeViewModel()
        viewModel.query = "T"
        #expect(viewModel.results.map(\.id) == ["Button", "State", "Toggle"])
        viewModel.query = "PAD"
        #expect(viewModel.results.map(\.id) == ["padding"])
    }

    @Test func searchMatchesDisplayName() {
        let viewModel = makeViewModel()
        viewModel.query = ".pad"
        #expect(viewModel.results.map(\.id) == ["padding"])
        viewModel.query = "@state"
        #expect(viewModel.results.map(\.id) == ["State"])
    }

    @Test func blankQueryIsNotSearchingAndHasNoResults() {
        let viewModel = makeViewModel()
        viewModel.query = "  "
        #expect(!viewModel.isSearching)
        #expect(viewModel.results.isEmpty)
        viewModel.query = " pad "
        #expect(viewModel.isSearching)
        #expect(viewModel.results.map(\.id) == ["padding"])
    }
}
```

- [ ] **Step 3: テストが失敗することを確かめる**

Run: `xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' -derivedDataPath build CODE_SIGNING_ALLOWED=NO -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 -only-testing:WidgetLabTests`
Expected: ビルドが失敗する（`isSearching` がない）

- [ ] **Step 4: `CatalogViewModel` を直す**

ファイル全体をこの内容にする:

```swift
import Foundation
import Observation

/// ホームの大分類の節 1 つ
struct CategorySection: Identifiable, Equatable {
    let category: Category
    let topics: [TopicSummary]

    var id: Category { category }
}

/// ホームのトピックの行 1 つ
struct TopicSummary: Identifiable, Equatable {
    let topic: Topic
    let count: Int
    /// 代表の名前（最初の 3 件）
    let sampleNames: [String]

    var id: Topic { topic }
}

/// ホームとトピック画面の状態
@Observable
final class CatalogViewModel {
    var query = ""
    private let entries: [CatalogEntry]

    init(repository: any CatalogRepository) {
        entries = repository.allEntries()
    }

    /// 収録が 1 件以上あるトピックを、大分類ごとに並べる（並びは Category・Topic の宣言の順）
    var sections: [CategorySection] {
        Category.allCases.compactMap { category in
            let topics = Topic.allCases.filter { $0.category == category }.compactMap { topic -> TopicSummary? in
                let names = entries(in: topic).map(\.displayName)
                return names.isEmpty
                    ? nil : TopicSummary(topic: topic, count: names.count, sampleNames: Array(names.prefix(3)))
            }
            return topics.isEmpty ? nil : CategorySection(category: category, topics: topics)
        }
    }

    /// 検索中か（前後の空白を除いて、query が空でない）
    var isSearching: Bool {
        !trimmedQuery.isEmpty
    }

    /// 検索の結果。検索中でなければ空。表示の名前（"@State"・".padding"。id を含む）の部分一致で、
    /// 大文字・小文字を区別せず、id の ABC 順
    var results: [CatalogEntry] {
        guard isSearching else { return [] }
        let trimmed = trimmedQuery
        return
            entries
            .filter { $0.displayName.localizedCaseInsensitiveContains(trimmed) }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    func entries(in topic: Topic) -> [CatalogEntry] {
        entries.filter { $0.topic == topic }
    }

    func entry(id: String) -> CatalogEntry? {
        entries.first { $0.id == id }
    }
}
```

- [ ] **Step 5: `HomeScreen` で `isSearching` を使う**

`WidgetLab/Features/Catalog/UI/HomeScreen.swift` の

```swift
            if viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
```

を、次にする:

```swift
            if !viewModel.isSearching {
```

- [ ] **Step 6: 整形・lint・テストを通す**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の「確かめ」
Expected: lint の出力なし、`OK`、`** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Features/Catalog WidgetLabTests
git commit -m "feat: 検索を表示の名前でも当て、検索中かを ViewModel に持たせる

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: 詳細の左右の見本と記録の欄、一覧の行の絵、UI テスト

**Files:**
- Modify: `WidgetLab/Features/Detail/UI/PreviewArea.swift`
- Create: `WidgetLab/Features/Detail/UI/RecordPanel.swift`
- Modify: `WidgetLab/Features/Catalog/UI/TopicScreen.swift`
- Test: `WidgetLabUITests/LaunchUITests.swift`

**Interfaces:**
- Consumes: Task 2 の `DetailViewModel.recorder`・`demoGeneration`・`DetailRecorder`・`RecordSide`・`EnvironmentValues.demoRecorder`、Task 3 の `CatalogEntry.state`（`"+1"`・`"count: N"`）、Task 4 の表示の名前の検索（`@State` で見つかる）
- Produces: `RecordPanel<Accessory: View>(recorder:showsSide:accessory:)`、`RecordSide.title`（`"付けた"`・`"付けない"`）
- 比べるの切り替えの `accessibilityIdentifier("compare")` は、`.card` でも `.behavior` でも同じ（UI テストは `app.switches["compare"]` で探す）

- [ ] **Step 1: 失敗する UI テストを書く**

`WidgetLabUITests/LaunchUITests.swift` を、この内容にする（準備を `openDetail` にまとめ、3 本目を足した）:

```swift
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
```

- [ ] **Step 2: UI テストが失敗することを確かめる**

Run: `xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' -derivedDataPath build CODE_SIGNING_ALLOWED=NO -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 -only-testing:WidgetLabUITests/LaunchUITests/testStateRedrawsOnlyWithWrapper`
Expected: `testStateRedrawsOnlyWithWrapper` が失敗する（`.behavior` もいまは重ねて比べるので、左右の「+1」が 2 つ押せない）。時間の上限付きで、止まらずに終わる

- [ ] **Step 3: 記録の欄を作る**

`WidgetLab/Features/Detail/UI/RecordPanel.swift`:

```swift
import SwiftUI

/// 見た目を持たないものの記録の欄。イベントのログを新しい順に出す。見出しの行に accessory（比べるの切り替え）を置く
struct RecordPanel<Accessory: View>: View {
    let recorder: DetailRecorder
    /// 比べているとき、行の頭に側を付ける
    let showsSide: Bool
    @ViewBuilder let accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("記録")
                    .font(.caption.bold())
                Spacer()
                accessory
                Button {
                    recorder.clear()
                } label: {
                    Text("消す").frame(minWidth: 44, minHeight: 44)
                }
                .font(.caption)
                .disabled(recorder.lines.isEmpty)
            }
            if recorder.lines.isEmpty {
                Text("見本を触ると、ここに記録が出ます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(recorder.lines) { line in
                            Text(showsSide ? "\(line.side.title): \(line.text)" : line.text)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

extension RecordSide {
    /// 比べるときの見出し
    var title: String {
        switch self {
        case .with: "付けた"
        case .without: "付けない"
        }
    }
}
```

- [ ] **Step 4: プレビューを直す**

`WidgetLab/Features/Detail/UI/PreviewArea.swift` の全体をこの内容にする（`.behavior` は左右に並べて記録の欄を出す。比べるの切り替えは `.behavior` では記録の欄の見出しに、`.card` ではいまのとおり右下に置く）:

```swift
import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出す
/// 見た目のもの（.card）は重ねて仕切りで見比べ、見た目を持たないもの（.behavior）は左右に並べて下に記録を出す
struct PreviewArea: View {
    let viewModel: DetailViewModel
    /// 仕切りの位置（左端 0 〜 右端 1）
    @State private var split: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.entry.stage == .behavior {
                // 見本に重ならないよう、比べるの切り替えは記録の欄の見出しに置く
                content
                Divider()
                RecordPanel(recorder: viewModel.recorder, showsSide: viewModel.comparison != nil) {
                    compareToggle
                }
                .frame(height: 90)
            } else {
                content
                    .overlay(alignment: .bottomTrailing) {
                        compareToggle.padding(12)
                    }
            }
        }
        .background(Self.areaBackground)
        .clipped()
    }

    @ViewBuilder
    private var compareToggle: some View {
        if viewModel.canCompare {
            Toggle(isOn: Binding(get: { viewModel.isComparing }, set: { viewModel.isComparing = $0 })) {
                // 押せる範囲は label の大きさになるので、ここで 44pt 以上にする
                Text("比べる").frame(minWidth: 44, minHeight: 44)
            }
            .toggleStyle(.button)
            .accessibilityIdentifier("compare")
        }
    }

    @ViewBuilder
    private var content: some View {
        let pair = viewModel.comparison
        if viewModel.entry.stage == .behavior {
            if let pair {
                HStack(spacing: 0) {
                    behavior(pair.without, side: .without, showsSide: true)
                    Divider()
                    behavior(pair.with, side: .with, showsSide: true)
                }
            } else {
                behavior(viewModel.current, side: .with, showsSide: false)
            }
        } else if let pair {
            compare(pair.without, pair.with)
        } else {
            preview(viewModel.current)
        }
    }

    private static let areaBackground = Color(.secondarySystemBackground)

    private func preview(_ values: PropertyValues) -> some View {
        viewModel.entry.build(values)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// 見た目を持たないものの見本 1 つ。側の窓口を渡し、上に body を評価した回数を出す
    private func behavior(_ values: PropertyValues, side: RecordSide, showsSide: Bool) -> some View {
        VStack(spacing: 0) {
            BodyCountLabel(recorder: viewModel.recorder, side: side, showsSide: showsSide)
            viewModel.entry.build(values)
                .environment(\.demoRecorder, viewModel.recorder.recorder(for: side))
                .id(viewModel.demoGeneration)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(8)
    }

    private func compare(_ without: PropertyValues, _ with: PropertyValues) -> some View {
        GeometryReader { geometry in
            let x = geometry.size.width * split
            ZStack(alignment: .topLeading) {
                preview(with)
                preview(without)
                    .background(Self.areaBackground)
                    .mask(alignment: .leading) { Rectangle().frame(width: x) }
                    .accessibilityHidden(true)
                Rectangle()
                    .fill(.tint)
                    .frame(width: 2)
                    .offset(x: x - 1)
                HStack {
                    Text("付けない")
                    Spacer()
                    Text("付けた")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    split = min(max(value.location.x / geometry.size.width, 0), 1)
                }
            )
            .overlay(alignment: .topLeading) {
                // VoiceOver で操作できるよう、仕切りだけを 1 つの要素にする
                Color.clear
                    .frame(width: 44, height: geometry.size.height)
                    .offset(x: x - 22)
                    .accessibilityElement()
                    .accessibilityLabel("仕切り")
                    .accessibilityValue("付けた側 \(Int(((1 - split) * 100).rounded()))%")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: split = max(split - 0.1, 0)
                        case .decrement: split = min(split + 0.1, 1)
                        @unknown default: break
                        }
                    }
            }
        }
    }
}

/// 側 1 つの、見本の body を評価した回数（例: 「描き直し 4 回」「描き直し 親 4 回・子 4 回」）
private struct BodyCountLabel: View {
    let recorder: DetailRecorder
    let side: RecordSide
    let showsSide: Bool

    var body: some View {
        VStack(spacing: 2) {
            if showsSide {
                Text(side.title)
            }
            Text(countText)
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsSide ? "\(side.title)側、\(countText)" : countText)
    }

    private var countText: String {
        let counts = recorder.bodyCounts(side)
        guard counts.count > 1 else { return "描き直し \(counts.first?.count ?? 0) 回" }
        return "描き直し " + counts.map { "\($0.name) \($0.count) 回" }.joined(separator: "・")
    }
}
```

- [ ] **Step 5: 一覧の行の見本を stage で分ける**

`WidgetLab/Features/Catalog/UI/TopicScreen.swift` の全体をこの内容にする:

```swift
import SwiftUI

/// トピック画面。収録したものの行（見本つき）
struct TopicScreen: View {
    let topic: Topic
    let entries: [CatalogEntry]
    let onEntryTapped: (String) -> Void

    var body: some View {
        List(entries) { entry in
            Button {
                onEntryTapped(entry.id)
            } label: {
                EntryRow(entry: entry)
            }
            .buttonStyle(.navigationRow)
            .accessibilityIdentifier("entry-\(entry.id)")
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 収録 1 件の行。見本（.card は最初の値で組み立てて縮めたもの、ほかは絵）・名前・種類の印
struct EntryRow: View {
    let entry: CatalogEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 80, height: 48)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayName)
                    .foregroundStyle(.primary)
                Text(entry.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            KindBadge(kind: entry.kind)
        }
        .contentShape(.rect)
    }
}

private extension EntryRow {
    /// .full・.behavior は行で組み立てない（sheet が行から出る・NavigationStack が入れ子になる・記録の窓口がない）
    @ViewBuilder
    var thumbnail: some View {
        switch entry.stage {
        case .card:
            entry.build(entry.initialValues)
                .frame(width: 200, height: 120)
                .scaleEffect(0.4)
                .frame(width: 80, height: 48)
                .clipped()
                .allowsHitTesting(false)
        case .full:
            symbol("rectangle.portrait")
        case .behavior:
            symbol(entry.kind == .propertyWrapper ? "at" : "hand.tap")
        }
    }

    func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

private struct KindBadge: View {
    let kind: EntryKind

    var body: some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: .capsule)
    }

    private var label: String {
        switch kind {
        case .view: "View"
        case .modifier: "modifier"
        case .propertyWrapper: "@"
        case .gesture: "ジェスチャー"
        }
    }
}
```

- [ ] **Step 6: 整形・lint・全部のテストを通す**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の「確かめ」
Expected: lint の出力なし、`OK`、`** TEST SUCCEEDED **`（UI テスト 3 本を含む）

- [ ] **Step 7: スクリーンショットで見た目を確かめる**

```bash
R=$(ls -td build/Logs/Test/*.xcresult | head -1)
xcrun xcresulttool export attachments --path "$R" --output-path /tmp/widgetlab-shots
```

`state-compare` の画像で、次を確かめる: 左に「付けない」、右に「付けた」。付けた側は `count: 1`・描き直し 2 回、付けない側は `count: 0`・描き直し 1 回。記録の欄に 2 行。「比べる」が見本に重ならない。

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Features WidgetLabUITests
git commit -m "feat: 見た目を持たないものを左右に並べて記録を出し、一覧の行は絵にする

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: ドキュメント

**Files:**
- Modify: `docs/adr/ADR-0002-data-driven-demos.md`
- Modify: `docs/architecture.md`
- Modify: `docs/PRD.md`
- Modify: `docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md`

- [ ] **Step 1: ADR-0002 に節を足す**

`## 結果` の前に、次の節を足す:

```markdown
## 見た目を持たないもの（2026-11-02 追加）
- プロパティラッパーは、ラッパーそのものを付け外しのできるプロパティ（`PropertySpec.wrapper`、置き場所 `.wrapper`）にする。付けない側は、同じことをラッパーなしで書いたもの（`@State` なら SwiftUI が見張らない参照型の箱）。コードは `CodeTemplate.wrapper`（`WrapperCode`）の付けた形と外した形を使う
- 記録の窓口 `DemoRecorder` を収録データの側（`Catalog/Model/Demo/`）に置き、SwiftUI の Environment（`\.demoRecorder`）で見本に渡す。`build` の型を変えずに済み、記録を使わない収録に要らない引数が付かない。依存は「詳細 → 収録データ」の一方向のまま
- body の回数は、見本の body の中で `reportBody` を呼んで数える。書き込みは `Task` で body のあとに遅らせ、回数とログを読むのは記録を出す View だけにする（見本が自分の記録で描き直されないように）
- `.behavior` の比べるは、重ねずに左右に並べ、どちらも触れるようにする。それぞれの側が自分の窓口を持つ
- 選ばなかった案: `build` の引数に窓口を足す（記録を使わない 400 件以上に要らない引数が付く）／アプリに 1 つの窓口（左右を分けられず、テストしにくい）／重ねる形のまま前後を切り替える（2 つの回数を同時に見られない）
```

`## 結果` の「見直すきっかけ」の行の「`.full`・`.behavior` の収録で詳細画面の形が合わなくなったとき」を「`.full` の収録で詳細画面の形が合わなくなったとき、記録の窓口に載らないもの（VoiceOver の読み上げ文など）が要るとき」にする。

- [ ] **Step 2: architecture.md を直す**

- 構成の `Model/` の行の後ろに 1 行足す: `    Model/Demo/             見本の記録の窓口（DemoRecorder・Environment の demoRecorder・reportBody）`
- 構成の `Detail/{UI,ViewModel}` の説明を「詳細（プレビュー・コードの 1 行・チップ・編集パネル・比べる・説明とコードのシート・見た目を持たないものの記録 DetailRecorder と RecordPanel）」にする
- 構成の `WidgetLabUITests/` の説明を「XCTest の UI テスト（起動 → 検索 → 詳細 → コピー、詳細で比べるを開いて左右が出ること、`@State` を比べて付けた側だけ表示が変わることの 3 本）」にする
- 「状態と依存の受け渡し」の最後に足す: `- 見た目を持たないものの記録は、詳細の ViewModel が DetailRecorder を持ち、側ごとの窓口を Environment で見本に渡す。見本は窓口に書くだけで読まない。プロパティや比べるを変えたら、記録を消して見本を作り直す（demoGeneration を見本の id にする）`

- [ ] **Step 3: PRD を直す**

`### 詳細: 比べる` の最後に足す: `- 見た目を持たないもの（@State など）は、重ねずに左右に並べ、どちらも触れる。それぞれに body の回数を出し、下の記録の欄にイベントのログを出す`

- [ ] **Step 4: followups の Phase 2 の表に済んだ印を付ける**

`## Phase 2 の計画の前に決める・直す` の表の 4 行の「こと」の頭に `済: ` を付ける。`DemoRecorder` の行の中身の最後に「→ Environment で渡した（ADR-0002）」を足す。

- [ ] **Step 5: コミット**

```bash
git add docs
git commit -m "docs: 見た目を持たないものの仕組みを ADR・architecture・PRD に書き、followups に済んだ印を付ける

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
