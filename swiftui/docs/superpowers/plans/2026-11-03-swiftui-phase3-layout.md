# SwiftUI 版 Phase 3 束 1（レイアウト）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** layout-fundamentals・layout-adjustments・custom-layout・view-groupings の残り 33 件を収録し、4 トピックの抜けを 0 にする。収録に要るコードの形（同じ modifier を 2 回・閉じ括弧の行・入れ子の字下げ）を型に足す。

**Architecture:** Task 1 で `PropertySpec` に行の鍵 `line`、`CodeTemplate` に後ろの行 `closing` と呼び出しの字下げ `indent` を足し、`CodeGenerator` の字下げの決まりを直す。Task 2〜7 で、1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/<トピック>/<名前>Entry.swift`）を 5〜7 件ずつ足し、`Catalog.all` に並べる。33 件とも stage は `.card`（`.note` はなし）。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 1 行目と「進め方」）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`（Layout・LayoutValueKey は `nonisolated private`）
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- 今の収録 7 件（`Button`・`Text`・`VStack`・`padding`・`State`・`Binding`・`TapGesture`）は書き直さない。Task 1 の新しい引数はどれも省略できる
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む。1 行に複数並べると数えない）
- 収録のファイルは、この計画に書いたコードをそのまま写す（試作でテストとスクリーンショットを通したもの）。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests
  ```
  UI テストまで通すのは Task 7 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある（試作で確かめた。テストそのものは数秒）
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` / `refactor:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（土台の PR と同じく、実装したモデルを正しく書く）

---

## 1 件ずつの表

stage は 33 件とも `.card`。`.note` にするものはない（`ignoresSafeArea`・`scenePadding` も、プレビューの枠の中で効き目が見えた）。
「形」は、収録の型の使い方。

- **View**: `call` が View。プロパティはイニシャライザの引数（`.argument`）と、かける modifier（`.modifier`）
- **引数**: modifier の収録で、`prefix` がかける相手、`call` が `".<modifier>"`、modifier の引数が `.argument`（`padding` と同じ形）。引数を全部 OFF にしても modifier は残る
- **付け外し**: modifier の収録で、`call` がかける相手の View、modifier の引数が `.modifier` のプロパティ。OFF にすると modifier ごと消えるので、比べるで「付けない」と「付けた」を見比べられる。引数がどれも省けない modifier（`fixedSize(horizontal:vertical:)`・`alignmentGuide(_:computeValue:)`）と、2 回かける modifier（`frame`）はこの形にする

| id | トピック | 形 | プロパティ（チップの順。* は最初から ON、R は required） | コードの形（最初の値） |
|---|---|---|---|---|
| HStack | layout-fundamentals | View | alignment*（.top ほか 4）・spacing | `HStack(alignment: .top) { 大きさの違う Text 3 つ }` |
| LazyHStack | layout-fundamentals | View | alignment*・spacing・pinnedViews | `ScrollView(.horizontal) { LazyHStack(alignment: .top) { Section { 20 個 } header: footer: } }` |
| LazyVStack | layout-fundamentals | View | alignment*・spacing・pinnedViews | `ScrollView { LazyVStack(alignment: .leading) { Section { 20 行 } … } }` |
| Grid | layout-fundamentals | View | alignment*・horizontalSpacing・verticalSpacing | `Grid(alignment: .topLeading) { GridRow × 2 }` |
| GridRow | layout-fundamentals | View | alignment* | `Grid { GridRow(alignment: .top) { … } GridRow { … } }`（閉じ括弧は closing） |
| LazyHGrid | layout-fundamentals | View | rows R（固定 2 行・伸びる 3 行・入るだけ）・alignment・spacing | `ScrollView(.horizontal) { LazyHGrid(rows: [GridItem(.fixed(40)), …]) { 30 個 } }` |
| LazyVGrid | layout-fundamentals | View | columns R（固定 3 列・伸びる 2 列・入るだけ）・alignment・spacing | `ScrollView { LazyVGrid(columns: […]) { 30 個 } }` |
| ZStack | layout-fundamentals | View | alignment*（5 つ） | `ZStack(alignment: .topLeading) { Color.yellow … Text("手前") … }` |
| ViewThatFits | layout-fundamentals | View | in・.frame(width:)*（100 で短い子に切り替わる） | `ViewThatFits { Label・Text・Image }.frame(width: 100)` |
| Spacer | layout-fundamentals | View | minLength* | `HStack { Text・Spacer(minLength: 80)・Text }.frame(width: 240)` |
| Divider | layout-fundamentals | View | .overlay（色）・.padding（辺） | `VStack { Text("上")・Divider()・Text("下") }` |
| scenePadding | layout-adjustments | 引数 | edges*（4 つ） | `Text("見本").scenePadding(.horizontal).background(.yellow)` |
| frame | layout-adjustments | 付け外し | .frame(width:)*・.frame(height:)・.frame(alignment:)*・.frame(maxWidth:)・.frame(maxHeight:)（max の 2 つは `line: "frame.max"` で別の行） | `Text("見本").frame(width: 160, alignment: .leading).background(.yellow)` |
| containerRelativeFrame | layout-adjustments | 引数（入れ子、indent 16） | axes R（.horizontal 固定）・count*（count・span・spacing の組を選ぶ）・alignment | `ScrollView(.horizontal) { HStack { ForEach { Text.containerRelativeFrame(.horizontal, count: 3, span: 1, spacing: 8) } } }` |
| fixedSize | layout-adjustments | 付け外し | .fixedSize*（両方・横だけ・縦だけ） | `Text(長い文字).fixedSize(horizontal: false, vertical: true).background.frame(width: 120, height: 40).border` |
| layoutPriority | layout-adjustments | 付け外し | .layoutPriority*（-1〜2） | `HStack { Text.lineLimit(1)・Text.layoutPriority(1).lineLimit(1) }.frame(width: 240)` |
| position | layout-adjustments | 引数 | x*・y* | `Text("見本").background(.yellow).position(x: 60, y: 40).border(.secondary)` |
| offset | layout-adjustments | 引数 | x*・y | `Text("見本").background(.yellow).offset(x: 40).border(.secondary)` |
| alignmentGuide | layout-adjustments | 付け外し | .alignmentGuide.g R（.leading 固定）・.alignmentGuide(computeValue:)*（右へ 40・左へ 20・幅の半分） | `VStack(alignment: .leading) { Text・Text.alignmentGuide(.leading, computeValue: { d in d[.leading] - 40 })・Text }` |
| contentMargins | layout-adjustments | 引数（indent 0） | edges*・length R・for | `ScrollView { 20 行 }.contentMargins(.horizontal, 32)` |
| ignoresSafeArea | layout-adjustments | 付け外し | .ignoresSafeArea.regions*（.all・.container・.keyboard）・.ignoresSafeArea(edges:)* | `VStack { Rectangle().ignoresSafeArea(.container, edges: .top).foregroundStyle(.yellow) }.safeAreaPadding(.vertical, 40)` |
| safeAreaInset | layout-adjustments | 引数（indent 0） | edge R（.top・.bottom）・alignment*・spacing | `ScrollView { 20 行 }.safeAreaInset(edge: .bottom, alignment: .trailing) { Text("帯") … }` |
| safeAreaPadding | layout-adjustments | 引数（indent 0） | edges*・length* | `ScrollView { 20 行 }.safeAreaPadding(.top, 48)` |
| layoutDirectionBehavior | layout-adjustments | 付け外し | .layoutDirectionBehavior*（.mirrors ほか 3）・.environment*（右から左・左から右） | `Image(systemName: "figure.walk").layoutDirectionBehavior(.mirrors).environment(\.layoutDirection, .rightToLeft)…` |
| layoutValue | custom-layout | 付け外し | .layoutValue(key:) R（Rank.self 固定）・.layoutValue(value:)*（0〜3） | `RankedHStack { Text("A")…・Text("B").layoutValue(key: Rank.self, value: 3)・Text("C")… }` |
| Group | view-groupings | View | .font*・.foregroundStyle・.border* | `VStack { Group { Text・Text }.font(.title).border(.red)・Text("Group の外") }` |
| Section | view-groupings | View | title*（文字）・.headerProminence・.listSectionSpacing | `List { Section("見出し") { 2 行 } Section("次の節") { … } }` |
| ForEach | view-groupings | View | data R（0..<3・0..<5・1...8）・id*（\.self 固定） | `VStack { ForEach(0..<3, id: \.self) { i in Text("行 \(i)") } }` |
| containerValue | view-groupings | 付け外し | .containerValue.keyPath R（\.markColor 固定）・.containerValue.value*（色） | `MarkedList { Text("A")・Text("B").containerValue(\.markColor, .red)・Text("C") }` |
| GroupBox | view-groupings | View | title*（文字）・.backgroundStyle*（色） | `GroupBox("設定") { Text("通知を受け取る") }.backgroundStyle(.yellow)` |
| Form | view-groupings | View | .formStyle*（.automatic・.grouped・.columns）・.scrollContentBackground・.disabled | `Form { Toggle・LabeledContent }.formStyle(.columns)` |
| LabeledContent | view-groupings | View | title R・value R・.labelsHidden | `Form { LabeledContent("バージョン", value: "1.0") }` |
| ControlGroup | view-groupings | View | title（文字）・.controlGroupStyle*（5 つ） | `ControlGroup { Button × 2 }.controlGroupStyle(.navigation)` |

### 試作でわかったこと（収録の手引きに書く）

- 引数の組をまとめて 1 つの選択肢にできる。選択肢のコードにラベルごと書く（`containerRelativeFrame` の `count: 3, span: 1, spacing: 8`、`fixedSize` の `horizontal: false, vertical: true`）。片方だけでは成り立たない引数の組に使う
- 引数のない modifier（`.labelsHidden()`）は `.fixed(code: "")` の modifier にする（コードは `.labelsHidden()` になる）
- ScrollView・List・Form・GroupBox・ControlGroup の見本は、テストの `ImageRenderer` では白く描かれる（エラーにはならない）。見た目はシミュレータのスクリーンショットで確かめる
- 見本を見やすくするための `.border`・`.background` は、コードに書かなくてよい（`VStack` から続く書き方）。効き目に関わるもの（`fixedSize` の `.frame(width:height:)` など）は書く
- 同じ色の地に置くと見えないもの（`GroupBox` の箱）は、背景の modifier を最初から ON にする

## 束 1 のあとに書く手引き（`swiftui/docs/cataloging-guide.md`）の中身

束 1 を main にマージしたあと、別の PR で書く（spec の「収録の手引き」）。中身は次のとおり。

1. stage の選び方: ふつうは `.card`。全画面・sheet で開くものは `.full`（詳細画面の「試す」はまだ作っていない。最初に使う束で作る）、見た目を持たないものは `.behavior`、アプリの 1 画面で効き目を見られないものは `.note`
2. `.note` の基準と例: アプリ拡張の中で効く・iOS で効かない窓の modifier・外の仕組み（Core Data など）が要る。理由には、使う場所を一言入れる（例: 「ウィジェットの中で効く」）。迷ったら束の計画で 1 件ずつ決める
3. プロパティの選び方: 1 件に 3〜6 個を目安に、よく使う引数と、同じ節の modifier から選ぶ。API が小さいもの（`GridRow`・`ZStack`・`Spacer`）は 1〜2 個でよい
4. 形の選び方: 上の「View」「引数」「付け外し」の 3 つと、それぞれの見本（`VStack`・`padding`・`frame`）
5. コードの形: `prefix`・`indent`・`call`・`fixedArguments`・`trailing`・`suffix`・`closing` の書き方。入れ子の見本（`containerRelativeFrame`・`GridRow`・`Spacer`）。複数行の `trailing` は 2 行目から字下げを自分で書く
6. required の modifier の引数: build でも、その行の required でない引数が 1 つ以上 ON のときだけ modifier をかける。`line` で行を分けたときは行ごとに
7. 上の「試作でわかったこと」
8. テスト: `CatalogTests` が全件を組み立てて確かめるので、収録ごとのテストは書かない。新しい型の使い方を足したときだけ `CodeGeneratorTests` に足す。見た目は代表の 1〜2 件をスクリーンショットで見る
9. 進め方: 計画に表を書く → scratchpad のコピーで試作 → `ImageRenderer` の画像とスクリーンショットで見る → 計画に写す

---

### Task 1: コードの形に、行の鍵・後ろの行・呼び出しの字下げを足す

束 1 の収録に要る、3 つの形を足す。

- `PropertySpec.line`: 同じ modifier を 2 回かける（`.frame(width: 160)` のあとに `.frame(maxWidth: .infinity)`）。省けば今と同じく modifier の名前でまとめる（2026-11-03 オーナーが決定）
- `CodeTemplate.closing`: prefix で開いた括弧を閉じる行（`HStack { Text・Spacer・Text }` の `Text("右")` と `}`）
- `CodeTemplate.indent`: 入れ子の中の View にかける modifier の呼び出しの字下げ（`ScrollView { HStack { ForEach { Text.containerRelativeFrame } } }`）

あわせて、modifier と suffix の字下げの決まりを直す。今は呼び出しの種類にかかわらず 4 桁の固定。

- 呼び出しが modifier（"." で始まる）なら、呼び出しと同じ桁（今の `padding` と同じ）
- 呼び出しが View で、末尾のクロージャが複数行なら、閉じ括弧 `}` と同じ桁（`ControlGroup { … }` のあとの `.controlGroupStyle`）。今は 4 桁下がっていて、Swift のふつうの書き方と違う
- ほかは呼び出しより 1 段深く（`Button("保存") { }` のあとの `.tint`）

今の 7 件のコードは変わらない（`VStack` は modifier がない。`padding`・`TapGesture` は modifier の呼び出し）。

**Files:**
- Modify: `WidgetLab/Catalog/Model/PropertySpec.swift`
- Modify: `WidgetLab/Catalog/Model/CodeTemplate.swift`
- Modify: `WidgetLabTests/Catalog/CodeGeneratorTests.swift`（テストを 5 つ足す）
- Modify: `WidgetLabTests/Catalog/CatalogTests.swift`（`requiredModifierArgumentsHaveNonRequiredSibling` を行の鍵で見る）
- Modify: `docs/adr/ADR-0002-data-driven-demos.md`、`docs/architecture.md`

**Interfaces:**
- Produces:
  - `PropertySpec.line: String?`（既定 nil）
  - `PropertySpec.modifier(_ name: String, id: String? = nil, label: String? = nil, line: String? = nil, _ control: PropertyControl, on: Bool = false, required: Bool = false, summary: String)`
  - `CodeTemplate.indent: Int?`（既定 nil。`prefix` と `call` の間に宣言する。メンバーごとの init の引数の順もここ）
  - `CodeTemplate.closing: [String]`（既定 []。`suffix` と `wrapper` の間に宣言する）
  - `CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`（どれも既定値あり、`call` だけ必須）

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Catalog/CodeGeneratorTests.swift` の最後のテスト（`multilineTrailingClosureMarksOnlyCallLine` のあとの、struct を閉じる `}` の前）に足す:

```swift
    @Test func lineKeySplitsSameModifierIntoTwoLines() {
        let frame: [PropertySpec] = [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 0...200, step: 10, initial: 120),
                summary: ""),
            .modifier(
                "frame", id: "frame.maxWidth", label: "maxWidth", line: "frame.max", .fixed(code: ".infinity"),
                summary: ""),
        ]
        #expect(frame.map(\.displayName) == [".frame(width:)", ".frame(maxWidth:)"])
        let template = CodeTemplate(call: "Text", fixedArguments: ["\"A\""])
        let both = CodeGenerator.lines(
            template: template, properties: frame,
            values: PropertyValues(["frame.width": .number(120), "frame.maxWidth": .flag(true)]),
            changed: ["frame.maxWidth"])
        #expect(both.map(\.text) == ["Text(\"A\")", "    .frame(width: 120)", "    .frame(maxWidth: .infinity)"])
        #expect(both.map(\.propertyIDs) == [[], ["frame.width"], ["frame.maxWidth"]])
        #expect(both.map(\.isChanged) == [false, false, true])

        let maxOnly = CodeGenerator.lines(
            template: template, properties: frame, values: PropertyValues(["frame.maxWidth": .flag(true)]))
        #expect(maxOnly.map(\.text) == ["Text(\"A\")", "    .frame(maxWidth: .infinity)"])
    }

    @Test func closingLinesComeLastWithoutIndent() {
        let spec = PropertySpec.argument("minLength", .slider(range: 0...40, step: 4, initial: 8), summary: "")
        let template = CodeTemplate(
            prefix: ["HStack {", "    Text(\"左\")"], call: "Spacer", closing: ["    Text(\"右\")", "}"])
        let lines = CodeGenerator.lines(
            template: template, properties: [spec], values: PropertyValues(["minLength": .number(8)]))
        #expect(
            lines.map(\.text) == ["HStack {", "    Text(\"左\")", "    Spacer(minLength: 8)", "    Text(\"右\")", "}"])
        #expect(lines.map(\.propertyIDs) == [[], [], ["minLength"], [], []])
    }

    @Test func indentsModifiersOneLevelDeeperThanViewCall() {
        let spec = PropertySpec.modifier(
            "layoutPriority", .slider(range: -1...2, step: 1, initial: 1), summary: "")
        let template = CodeTemplate(
            prefix: ["HStack {", "    Text(\"左\")"], call: "Text", fixedArguments: ["\"右\""],
            suffix: [".lineLimit(1)"], closing: ["}"])
        let lines = CodeGenerator.lines(
            template: template, properties: [spec], values: PropertyValues(["layoutPriority": .number(1)]))
        #expect(
            lines.map(\.text) == [
                "HStack {", "    Text(\"左\")", "    Text(\"右\")", "        .layoutPriority(1)", "        .lineLimit(1)",
                "}",
            ])
    }

    @Test func explicitIndentPlacesModifierCall() {
        let template = CodeTemplate(
            prefix: ["ScrollView {", "    Text(\"A\")", "}"], indent: 0, call: ".contentMargins",
            fixedArguments: ["24"])
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["ScrollView {", "    Text(\"A\")", "}", ".contentMargins(24)"])
    }

    @Test func modifiersAfterMultilineTrailingClosureAlignWithClosingBrace() {
        let spec = PropertySpec.modifier("font", .choice([Choice(".title")], initial: 0), summary: "")
        let values = PropertyValues(["font": .choice(0)])
        let top = CodeGenerator.lines(
            template: CodeTemplate(call: "Group", trailing: " {\n    Text(\"A\")\n}"), properties: [spec],
            values: values)
        #expect(top.map(\.text) == ["Group {", "    Text(\"A\")", "}", ".font(.title)"])
        let nested = CodeGenerator.lines(
            template: CodeTemplate(
                prefix: ["VStack {"], call: "Group", trailing: " {\n        Text(\"A\")\n    }", closing: ["}"]),
            properties: [spec], values: values)
        #expect(
            nested.map(\.text) == ["VStack {", "    Group {", "        Text(\"A\")", "    }", "    .font(.title)", "}"])
    }
```

- [ ] **Step 2: 落ちることを確かめる**

Run: Global Constraints の確かめのコマンド
Expected: ビルドが失敗する（`extra argument 'line' in call`、`extra argument 'closing' in call`、`extra argument 'indent' in call`）

- [ ] **Step 3: `PropertySpec` に `line` を足す**

`WidgetLab/Catalog/Model/PropertySpec.swift` の `isRequired` のあとに足す:

```swift
    /// OFF にできない（Text の文字など、省くとコードが成り立たない引数）
    var isRequired: Bool = false
    /// modifier のプロパティを、コードで 1 行にまとめる鍵。nil なら modifier の名前でまとめる
    var line: String? = nil
```

`static func modifier` をまるごと置き換える:

```swift
    /// modifier のプロパティ。id を省くと modifier の名前を id にする。同じ modifier に複数のプロパティを付けるときは
    /// id を分ける（例: "frame.width"・"frame.height"）。コードでは同じ modifier のプロパティを 1 行にまとめる。
    /// required の引数は、OFF にできず、同じ modifier のほかのプロパティが ON のときだけコードに書く。
    /// 同じ modifier を 2 回かけるとき（.frame(width:) のあとの .frame(maxWidth:) など）は、line で行を分ける
    static func modifier(
        _ name: String, id: String? = nil, label: String? = nil, line: String? = nil, _ control: PropertyControl,
        on: Bool = false, required: Bool = false, summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id ?? name, placement: .modifier(name: name, label: label), control: control,
            initiallyOn: on || required, isRequired: required, line: line, summary: summary)
    }
```

- [ ] **Step 4: `CodeTemplate` に `indent` と `closing` を足し、`CodeGenerator` を直す**

`WidgetLab/Catalog/Model/CodeTemplate.swift` をまるごと次にする（`WrapperCode`・`CodeLine`・`wrapperLines`・`argument` は今のまま）:

```swift
import Foundation

/// コードの形。CodeGenerator が、ON のプロパティを埋めてコードにする
///
/// 例: Button("保存", role: .destructive) { } に .tint(.red) が付くとき
///     call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"
nonisolated struct CodeTemplate: Sendable {
    /// 呼び出しより前の行（modifier の収録で、かける相手の見本。例: ["Text(\"見本\")"]）
    var prefix: [String] = []
    /// 呼び出しの行の字下げの桁数。nil なら、prefix があるとき 4、ないとき 0
    /// （入れ子の中の View にかける modifier の収録で、prefix の最後の行に合わせて決める）
    var indent: Int? = nil
    /// 呼び出しの名前（例: "Button"、".padding"）
    var call: String
    /// いつも書く引数（ON の引数のプロパティより前に並ぶ）
    var fixedArguments: [String] = []
    /// 呼び出しのあとの末尾のクロージャ（例: " { }"。複数行は "\n" で区切る）
    var trailing: String = ""
    /// いちばん最後に付ける modifier の行（例: [".background(.yellow)"]）
    var suffix: [String] = []
    /// suffix のあとに、字下げせずにそのまま書く行（prefix で開いた括弧を閉じる "}" など）
    var closing: [String] = []
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
        let indent = String(repeating: " ", count: template.indent ?? (template.prefix.isEmpty ? 0 : 4))
        // modifier と suffix の字下げ。呼び出しが modifier（"." で始まる）か、末尾のクロージャが複数行（"}" で閉じる）なら
        // 呼び出しと同じ桁、ほかは 1 段深く
        let chain = template.call.hasPrefix(".") || template.trailing.contains("\n") ? indent : indent + "    "
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

        result += modifierLines(properties: properties, values: values, changed: changed, indent: chain)
        result += template.suffix.map { CodeLine(text: chain + $0, propertyIDs: [], isChanged: false) }
        result += template.closing.map { CodeLine(text: $0, propertyIDs: [], isChanged: false) }
        return result
    }

    /// modifier のプロパティを、行の鍵（line、なければ modifier の名前）ごとに 1 行にまとめる
    /// （並びは最初に出てきた順、引数は定義の順）。required でない引数が 1 つも ON でない行は書かない
    private static func modifierLines(
        properties: [PropertySpec], values: PropertyValues, changed: Set<String>, indent: String
    ) -> [CodeLine] {
        var keys: [(key: String, name: String)] = []
        var groups: [String: [(spec: PropertySpec, label: String?)]] = [:]
        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement else { continue }
            let key = spec.line ?? name
            if groups[key] == nil { keys.append((key, name)) }
            groups[key, default: []].append((spec, label))
        }
        return keys.compactMap { key, name in
            let members = groups[key, default: []].compactMap { member in
                values[member.spec.id].map { (spec: member.spec, label: member.label, value: $0) }
            }
            guard members.contains(where: { !$0.spec.isRequired }) else { return nil }
            let arguments = members.map { argument(label: $0.label, code: $0.spec.control.code(for: $0.value)) }
            let ids = members.map(\.spec.id)
            return CodeLine(
                text: indent + ".\(name)(" + arguments.joined(separator: ", ") + ")", propertyIDs: ids,
                isChanged: !changed.isDisjoint(with: ids))
        }
    }

    /// 付けた形では宣言の行に、外した形では付けた形と違う行に、ラッパーの id を付ける
    private static func wrapperLines(_ code: WrapperCode, id: String, isOn: Bool, isChanged: Bool) -> [CodeLine] {
        if isOn {
            return code.withWrapper.map { text in
                // 語として一致させる（@State で @StateObject の行に当たらないように）
                let isDeclaration =
                    text.range(of: "@\(NSRegularExpression.escapedPattern(for: id))\\b", options: .regularExpression)
                    != nil
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

- [ ] **Step 5: `CatalogTests` の required の確かめを行の鍵で見る**

`WidgetLabTests/Catalog/CatalogTests.swift` の `requiredModifierArgumentsHaveNonRequiredSibling` をまるごと置き換える:

```swift
    @Test func requiredModifierArgumentsHaveNonRequiredSibling() {
        for entry in Catalog.all {
            for spec in entry.properties where spec.isRequired {
                guard case .modifier(let name, _) = spec.placement else { continue }
                let key = spec.line ?? name
                let hasSibling = entry.properties.contains {
                    guard case .modifier(let other, _) = $0.placement else { return false }
                    return ($0.line ?? other) == key && !$0.isRequired
                }
                #expect(hasSibling, "\(entry.id): \(spec.id) は required だが、同じ行の .\(name) に required でない引数がない")
            }
        }
    }
```

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る

- [ ] **Step 7: ADR-0002 と architecture.md を直す**

`docs/adr/ADR-0002-data-driven-demos.md` の「全トピックの収録に向けて（2026-11-02 追加）」の節で、次の行を

```
- 同じ modifier を 2 回かける書き方（`.frame(width:)` のあとに `.frame(maxWidth:)`、`.padding` を 2 回）は 1 行にまとまるので表せない。組み合わせられないラベル（`maxWidth` と `width` など）を同じ modifier に付けない。要るときは束 1 で決める
```

次の 2 行に置き換える:

```
- 同じ modifier を 2 回かけるとき（`.frame(width:)` のあとに `.frame(maxWidth:)`）は、`PropertySpec.modifier` の `line:` で行の鍵を分ける。省けば modifier の名前でまとめる。組み合わせられないラベル（`maxWidth` と `width` など）は同じ行に入れない（2026-11-03 束 1 で決定。選ばなかった案: `frame` は決めた大きさだけにする。いちばんよく使う `.frame(maxWidth: .infinity)` が抜けるため）
- コードの形に、prefix で開いた括弧を閉じる後ろの行（`CodeTemplate.closing`）と、呼び出しの字下げ（`CodeTemplate.indent`）を足す（2026-11-03）。並びや入れ物の中に置く View（`Spacer`・`GridRow`・`Section`）と、入れ子の中の View にかける modifier（`containerRelativeFrame`）を、そのまま写せる形で見せるため
```

`docs/architecture.md` の「コードの生成」の節で、

```
同じ modifier の名前を持つプロパティは 1 行にまとめる（`.frame(width:height:)` など）。
```

を次に置き換える:

```
同じ modifier の名前を持つプロパティは 1 行にまとめる（`.frame(width:height:)` など）。同じ modifier を 2 回かけるときは、プロパティの `line` で行を分ける。呼び出しの前後の行は `prefix`・`suffix`・`closing`（字下げせずに書く閉じ括弧など）で書き、呼び出しの字下げは `indent` で決める（省けば prefix があるとき 4）。modifier と suffix は、呼び出しが modifier か末尾のクロージャが複数行なら呼び出しと同じ桁、ほかは 1 段深く書く。
```

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/Model/PropertySpec.swift WidgetLab/Catalog/Model/CodeTemplate.swift \
  WidgetLabTests/Catalog/CodeGeneratorTests.swift WidgetLabTests/Catalog/CatalogTests.swift \
  docs/adr/ADR-0002-data-driven-demos.md docs/architecture.md
git commit -m "feat: 同じ modifier の 2 回目・閉じ括弧の行・入れ子の字下げをコードの形で書けるようにする"
```

### Task 2: レイアウトの基本 1（HStack・LazyHStack・LazyVStack・Grid・GridRow・ZStack）

**Files:**
- Create: `WidgetLab/Catalog/LayoutFundamentals/HStackEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/LazyHStackEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/LazyVStackEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/GridEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/GridRowEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/ZStackEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.hStack`、`CatalogEntry.lazyHStack`、`CatalogEntry.lazyVStack`、`CatalogEntry.grid`、`CatalogEntry.gridRow`、`CatalogEntry.zStack`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py layout-fundamentals`
Expected: 終了コード 1。抜けに HStack・LazyHStack・LazyVStack・Grid・GridRow・ZStack がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/LayoutFundamentals/HStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let hStack = CatalogEntry(
        id: "HStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を横に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/hstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice(
                    [Choice(".top"), Choice(".center"), Choice(".bottom"), Choice(".firstTextBaseline")], initial: 0),
                on: true, summary: "子の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Text(\"A\").font(.largeTitle)\n    Text(\"B\")\n    Text(\"C\").font(.caption)\n}"),
        build: { v in
            AnyView(
                HStack(
                    alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom, .firstTextBaseline])
                        ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("A").font(.largeTitle)
                    Text("B")
                    Text("C").font(.caption)
                }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/LazyHStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyHStack = CatalogEntry(
        id: "LazyHStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を横に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyhstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), on: true,
                summary: "子の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
            .argument(
                "pinnedViews",
                .choice([Choice("[.sectionHeaders]"), Choice("[.sectionHeaders, .sectionFooters]")], initial: 0),
                summary: "スクロールしても端に残す、節の見出しと結び"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHStack",
            trailing: " {\n        Section {\n            ForEach(1...20, id: \\.self) { i in\n"
                + "                Text(\"\\(i)\")\n                    .frame(width: 44, height: i % 2 == 0 ? 40 : 80)\n"
                + "                    .background(.yellow)\n            }\n        } header: {\n            Text(\"見出し\")\n"
                + "        } footer: {\n            Text(\"結び\")\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    LazyHStack(
                        alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom]) ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) },
                        pinnedViews: v.pick(
                            "pinnedViews", from: [[.sectionHeaders], [.sectionHeaders, .sectionFooters]])
                            ?? PinnedScrollableViews()
                    ) {
                        Section {
                            ForEach(1...20, id: \.self) { i in
                                Text("\(i)")
                                    .frame(width: 44, height: i % 2 == 0 ? 40 : 80)
                                    .background(.yellow)
                            }
                        } header: {
                            Text("見出し").background(.background)
                        } footer: {
                            Text("結び").background(.background)
                        }
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/LazyVStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyVStack = CatalogEntry(
        id: "LazyVStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を縦に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyvstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true, summary: "子の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
            .argument(
                "pinnedViews",
                .choice([Choice("[.sectionHeaders]"), Choice("[.sectionHeaders, .sectionFooters]")], initial: 0),
                summary: "スクロールしても端に残す、節の見出しと結び"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView {"], call: "LazyVStack",
            trailing: " {\n        Section {\n            ForEach(1...20, id: \\.self) { i in\n"
                + "                Text(\"行 \\(i)\")\n                    .frame(width: i % 2 == 0 ? 80 : 160)\n"
                + "                    .background(.yellow)\n            }\n        } header: {\n            Text(\"見出し\")\n"
                + "        } footer: {\n            Text(\"結び\")\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView {
                    LazyVStack(
                        alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing])
                            ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) },
                        pinnedViews: v.pick(
                            "pinnedViews", from: [[.sectionHeaders], [.sectionHeaders, .sectionFooters]])
                            ?? PinnedScrollableViews()
                    ) {
                        Section {
                            ForEach(1...20, id: \.self) { i in
                                Text("行 \(i)")
                                    .frame(width: i % 2 == 0 ? 80 : 160)
                                    .background(.yellow)
                            }
                        } header: {
                            Text("見出し").frame(maxWidth: .infinity).background(.background)
                        } footer: {
                            Text("結び").frame(maxWidth: .infinity).background(.background)
                        }
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/GridEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let grid = CatalogEntry(
        id: "Grid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を行と列の表の形に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/grid")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice([Choice(".topLeading"), Choice(".center"), Choice(".bottomTrailing")], initial: 0), on: true,
                summary: "マスの中の揃え方"),
            .argument(
                "horizontalSpacing", .slider(range: 0...40, step: 4, initial: 16), summary: "列と列の間の距離"),
            .argument("verticalSpacing", .slider(range: 0...40, step: 4, initial: 16), summary: "行と行の間の距離"),
        ],
        code: CodeTemplate(
            call: "Grid",
            trailing: " {\n    GridRow {\n        Text(\"A\")\n        Text(\"BBBB\")\n    }\n"
                + "    GridRow {\n        Text(\"CCCCCC\")\n        Text(\"D\").font(.largeTitle)\n    }\n}"),
        build: { v in
            AnyView(
                Grid(
                    alignment: v.pick("alignment", from: [Alignment.topLeading, .center, .bottomTrailing]) ?? .center,
                    horizontalSpacing: v.number("horizontalSpacing").map { CGFloat($0) },
                    verticalSpacing: v.number("verticalSpacing").map { CGFloat($0) }
                ) {
                    GridRow {
                        Text("A").background(.yellow)
                        Text("BBBB").background(.yellow)
                    }
                    GridRow {
                        Text("CCCCCC").background(.yellow)
                        Text("D").font(.largeTitle).background(.yellow)
                    }
                }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/GridRowEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let gridRow = CatalogEntry(
        id: "GridRow",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "Grid の中で、子の View を 1 行に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gridrow")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), on: true,
                summary: "この行のマスの縦の揃え方（Grid の alignment より優先する）")
        ],
        code: CodeTemplate(
            prefix: ["Grid {"], call: "GridRow",
            trailing: " {\n        Text(\"A\").font(.largeTitle)\n        Text(\"b\")\n    }",
            closing: ["    GridRow {", "        Text(\"C\")", "        Text(\"d\")", "    }", "}"]),
        build: { v in
            AnyView(
                Grid {
                    GridRow(alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom])) {
                        Text("A").font(.largeTitle).background(.yellow)
                        Text("b").background(.yellow)
                    }
                    GridRow {
                        Text("C").background(.yellow)
                        Text("d").background(.yellow)
                    }
                }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/ZStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let zStack = CatalogEntry(
        id: "ZStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を奥から手前へ重ねる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/zstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice(
                    [
                        Choice(".topLeading"), Choice(".top"), Choice(".center"), Choice(".bottom"),
                        Choice(".bottomTrailing"),
                    ],
                    initial: 0),
                on: true, summary: "重ねる子の揃え方")
        ],
        code: CodeTemplate(
            call: "ZStack",
            trailing:
                " {\n    Color.yellow\n        .frame(width: 160, height: 100)\n    Text(\"手前\")\n        .padding(8)\n"
                + "        .background(.orange)\n}"),
        build: { v in
            AnyView(
                ZStack(
                    alignment: v.pick(
                        "alignment", from: [Alignment.topLeading, .top, .center, .bottom, .bottomTrailing])
                        ?? .center
                ) {
                    Color.yellow
                        .frame(width: 160, height: 100)
                    Text("手前")
                        .padding(8)
                        .background(.orange)
                }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .hStack,
        .lazyHStack,
        .lazyVStack,
        .grid,
        .gridRow,
        .zStack,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py layout-fundamentals`
Expected: 抜けに HStack・LazyHStack・LazyVStack・Grid・GridRow・ZStack がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/LayoutFundamentals/HStackEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/LazyHStackEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/LazyVStackEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/GridEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/GridRowEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/ZStackEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: HStack・LazyHStack・LazyVStack・Grid・GridRow・ZStack を収録する"
```

### Task 3: レイアウトの基本 2（LazyHGrid・LazyVGrid・ViewThatFits・Spacer・Divider）

**Files:**
- Create: `WidgetLab/Catalog/LayoutFundamentals/LazyHGridEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/LazyVGridEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/ViewThatFitsEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/SpacerEntry.swift`
- Create: `WidgetLab/Catalog/LayoutFundamentals/DividerEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.lazyHGrid`、`CatalogEntry.lazyVGrid`、`CatalogEntry.viewThatFits`、`CatalogEntry.spacer`、`CatalogEntry.divider`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py layout-fundamentals`
Expected: 終了コード 1。抜けに LazyHGrid・LazyVGrid・ViewThatFits・Spacer・Divider がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/LayoutFundamentals/LazyHGridEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyHGrid = CatalogEntry(
        id: "LazyHGrid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を、決めた行の数で横に伸びる表に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyhgrid")!,
        stage: .card,
        properties: [
            .argument(
                "rows",
                .choice(
                    [
                        Choice("固定 2 行", code: "[GridItem(.fixed(40)), GridItem(.fixed(40))]"),
                        Choice("伸びる 3 行", code: "[GridItem(), GridItem(), GridItem()]"),
                        Choice("入るだけ", code: "[GridItem(.adaptive(minimum: 40))]"),
                    ],
                    initial: 0),
                required: true, summary: "行の数と高さの決め方（GridItem の配列）"),
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0),
                summary: "表全体の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "列と列の間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHGrid",
            trailing: " {\n        ForEach(1...30, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 40)\n                .background(.yellow)\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    LazyHGrid(
                        rows: v.pick(
                            "rows",
                            from: [
                                [GridItem(.fixed(40)), GridItem(.fixed(40))], [GridItem(), GridItem(), GridItem()],
                                [GridItem(.adaptive(minimum: 40))],
                            ]) ?? [],
                        alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom]) ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) }
                    ) {
                        ForEach(1...30, id: \.self) { i in
                            Text("\(i)")
                                .frame(width: 40)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/LazyVGridEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyVGrid = CatalogEntry(
        id: "LazyVGrid",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を、決めた列の数で縦に伸びる表に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyvgrid")!,
        stage: .card,
        properties: [
            .argument(
                "columns",
                .choice(
                    [
                        Choice("固定 3 列", code: "[GridItem(.fixed(60)), GridItem(.fixed(60)), GridItem(.fixed(60))]"),
                        Choice("伸びる 2 列", code: "[GridItem(), GridItem()]"),
                        Choice("入るだけ", code: "[GridItem(.adaptive(minimum: 60))]"),
                    ],
                    initial: 0),
                required: true, summary: "列の数と幅の決め方（GridItem の配列）"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                summary: "表全体の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "行と行の間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView {"], call: "LazyVGrid",
            trailing: " {\n        ForEach(1...30, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(height: 40)\n                .frame(maxWidth: .infinity)\n"
                + "                .background(.yellow)\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView {
                    LazyVGrid(
                        columns: v.pick(
                            "columns",
                            from: [
                                [GridItem(.fixed(60)), GridItem(.fixed(60)), GridItem(.fixed(60))],
                                [GridItem(), GridItem()], [GridItem(.adaptive(minimum: 60))],
                            ]) ?? [],
                        alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing])
                            ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) }
                    ) {
                        ForEach(1...30, id: \.self) { i in
                            Text("\(i)")
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/ViewThatFitsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let viewThatFits = CatalogEntry(
        id: "ViewThatFits",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を上から順に試し、入る大きさのものを 1 つだけ出す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/viewthatfits")!,
        stage: .card,
        properties: [
            .argument(
                "in",
                .choice([Choice(".horizontal"), Choice(".vertical"), Choice("[.horizontal, .vertical]")], initial: 0),
                summary: "入るかを確かめる向き（OFF なら縦横の両方）"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...280, step: 20, initial: 100), on: true,
                summary: "置く場所の幅（狭くすると、短い子に切り替わる）"),
        ],
        code: CodeTemplate(
            call: "ViewThatFits",
            trailing: " {\n    Label(\"お気に入りに追加\", systemImage: \"star\")\n    Text(\"お気に入り\")\n"
                + "    Image(systemName: \"star\")\n}",
            suffix: [".border(.secondary)"]),
        build: { v in
            let axes =
                v.pick("in", from: [Axis.Set.horizontal, .vertical, [.horizontal, .vertical]]) ?? [
                    .horizontal, .vertical,
                ]
            return AnyView(
                ViewThatFits(in: axes) {
                    Label("お気に入りに追加", systemImage: "star")
                    Text("お気に入り")
                    Image(systemName: "star")
                }
                .apply(v.number("frame.width")) { $0.frame(width: CGFloat($1)) }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/SpacerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let spacer = CatalogEntry(
        id: "Spacer",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "並びの中で、空いた場所いっぱいに伸びる空白の View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spacer")!,
        stage: .card,
        properties: [
            .argument(
                "minLength", .slider(range: 0...120, step: 10, initial: 80), on: true,
                summary: "縮めても残す長さ（OFF なら環境に合わせた既定の長さ）")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左の文字が長いとき\")"], call: "Spacer",
            closing: ["    Text(\"右\")", "}", ".frame(width: 240)"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左の文字が長いとき").background(.yellow)
                    Spacer(minLength: v.number("minLength").map { CGFloat($0) })
                    Text("右").background(.yellow)
                }
                .frame(width: 240)
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutFundamentals/DividerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let divider = CatalogEntry(
        id: "Divider",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "中身を区切る線。並びの向きに交わる向きに引く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/divider")!,
        stage: .card,
        properties: [
            .modifier("overlay", .color(initial: 0), summary: "線の色（線の上に色を重ねる）"),
            .modifier(
                "padding", .choice([Choice(".horizontal"), Choice(".vertical")], initial: 0),
                summary: "線のまわりの余白"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"上\")"], call: "Divider", closing: ["    Text(\"下\")", "}"]),
        build: { v in
            AnyView(
                VStack {
                    Text("上")
                    Divider()
                        .apply(v.color("overlay")) { $0.overlay($1) }
                        .apply(v.pick("padding", from: [Edge.Set.horizontal, .vertical])) { $0.padding($1) }
                    Text("下")
                }
                .frame(width: 200)
                .border(.secondary)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .lazyHGrid,
        .lazyVGrid,
        .viewThatFits,
        .spacer,
        .divider,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py layout-fundamentals`
Expected: 抜けに LazyHGrid・LazyVGrid・ViewThatFits・Spacer・Divider がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/LayoutFundamentals/LazyHGridEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/LazyVGridEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/ViewThatFitsEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/SpacerEntry.swift \
  WidgetLab/Catalog/LayoutFundamentals/DividerEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: LazyHGrid・LazyVGrid・ViewThatFits・Spacer・Divider を収録する"
```

### Task 4: レイアウトの調整 1（scenePadding・frame・containerRelativeFrame・fixedSize・layoutPriority・position・offset）

**Files:**
- Create: `WidgetLab/Catalog/LayoutAdjustments/ScenePaddingEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/FrameEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/ContainerRelativeFrameEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/FixedSizeEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/LayoutPriorityEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/PositionEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/OffsetEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.scenePadding`、`CatalogEntry.frame`、`CatalogEntry.containerRelativeFrame`、`CatalogEntry.fixedSize`、`CatalogEntry.layoutPriority`、`CatalogEntry.position`、`CatalogEntry.offset`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py layout-adjustments`
Expected: 終了コード 1。抜けに scenePadding・frame・containerRelativeFrame・fixedSize・layoutPriority・position・offset がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/LayoutAdjustments/ScenePaddingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scenePadding = CatalogEntry(
        id: "scenePadding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "画面（シーン）の端に合わせた余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scenepadding(_:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 1),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）")
        ],
        code: CodeTemplate(prefix: ["Text(\"見本\")"], call: ".scenePadding", suffix: [".background(.yellow)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .scenePadding(v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all)
                    .background(.yellow)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/FrameEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let frame = CatalogEntry(
        id: "frame",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を決めた大きさ、または伸び縮みの範囲の枠に入れる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:)")!,
        stage: .card,
        properties: [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 160), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 20...160, step: 10, initial: 60),
                summary: "枠の高さ"),
            .modifier(
                "frame", id: "frame.alignment", label: "alignment",
                .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0), on: true,
                summary: "枠の中の揃え方"),
            .modifier(
                "frame", id: "frame.maxWidth", label: "maxWidth", line: "frame.max", .fixed(code: ".infinity"),
                summary: "伸ばせる幅の上限（.infinity で置き場所いっぱいに伸びる）。決めた大きさの枠の外にもう 1 つ枠をかける"),
            .modifier(
                "frame", id: "frame.maxHeight", label: "maxHeight", line: "frame.max", .fixed(code: ".infinity"),
                summary: "伸ばせる高さの上限"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本\""], suffix: [".background(.yellow)"]),
        build: { v in
            let width = v.number("frame.width").map { CGFloat($0) }
            let height = v.number("frame.height").map { CGFloat($0) }
            let alignment = v.pick("frame.alignment", from: [Alignment.leading, .center, .trailing])
            let maxWidth: CGFloat? = v.flag("frame.maxWidth") != nil ? .infinity : nil
            let maxHeight: CGFloat? = v.flag("frame.maxHeight") != nil ? .infinity : nil
            let hasFixed = width != nil || height != nil || alignment != nil
            let hasMax = maxWidth != nil || maxHeight != nil
            return AnyView(
                Text("見本")
                    .apply(hasFixed ? alignment ?? .center : nil) {
                        $0.frame(width: width, height: height, alignment: $1)
                    }
                    .apply(hasMax ? () : nil) { view, _ in view.frame(maxWidth: maxWidth, maxHeight: maxHeight) }
                    .background(.yellow)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/ContainerRelativeFrameEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let containerRelativeFrame = CatalogEntry(
        id: "containerRelativeFrame",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "いちばん近い入れ物（ScrollView など）の大きさをもとに、View の枠を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/containerrelativeframe(_:alignment:)")!,
        stage: .card,
        properties: [
            .argument("axes", unlabeled: true, .fixed(code: ".horizontal"), required: true, summary: "大きさを決める向き"),
            .argument(
                "count", unlabeled: true,
                .choice(
                    [
                        Choice("3 等分", code: "count: 3, span: 1, spacing: 8"),
                        Choice("2 等分", code: "count: 2, span: 1, spacing: 8"),
                        Choice("3 等分の 2 つ分", code: "count: 3, span: 2, spacing: 8"),
                    ],
                    initial: 0),
                on: true, summary: "入れ物を count 等分し、span 個分の大きさにする（OFF なら入れ物と同じ大きさ）"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                summary: "枠の中の揃え方"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView(.horizontal) {", "    HStack(spacing: 8) {", "        ForEach(1...6, id: \\.self) { i in",
                "            Text(\"\\(i)\")",
            ],
            indent: 16, call: ".containerRelativeFrame", suffix: [".background(.yellow)"],
            closing: ["        }", "    }", "}"]),
        build: { v in
            let split = v.pick("count", from: [(3, 1), (2, 1), (3, 2)])
            let alignment = v.pick("alignment", from: [Alignment.leading, .center, .trailing]) ?? .center
            return AnyView(
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(1...6, id: \.self) { i in
                            ContainerRelativeFrameDemo.framed(Text("\(i)"), split: split, alignment: alignment)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}

private enum ContainerRelativeFrameDemo {
    @ViewBuilder
    static func framed(_ view: some View, split: (count: Int, span: Int)?, alignment: Alignment) -> some View {
        if let split {
            view.containerRelativeFrame(
                .horizontal, count: split.count, span: split.span, spacing: 8, alignment: alignment)
        } else {
            view.containerRelativeFrame(.horizontal, alignment: alignment)
        }
    }
}
```

`WidgetLab/Catalog/LayoutAdjustments/FixedSizeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fixedSize = CatalogEntry(
        id: "fixedSize",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を、置き場所の大きさにかかわらず、自分のちょうどよい大きさにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fixedsize()")!,
        stage: .card,
        properties: [
            .modifier(
                "fixedSize",
                .choice(
                    [
                        Choice("両方", code: ""), Choice("横だけ", code: "horizontal: true, vertical: false"),
                        Choice("縦だけ", code: "horizontal: false, vertical: true"),
                    ],
                    initial: 2),
                on: true, summary: "ちょうどよい大きさにする向き")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"長い文字は、置き場所の幅で折り返す\""],
            suffix: [".background(.yellow)", ".frame(width: 120, height: 40)", ".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("長い文字は、置き場所の幅で折り返す")
                    .apply(v.pick("fixedSize", from: [(true, true), (true, false), (false, true)])) {
                        $0.fixedSize(horizontal: $1.0, vertical: $1.1)
                    }
                    .background(.yellow)
                    .frame(width: 120, height: 40)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/LayoutPriorityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let layoutPriority = CatalogEntry(
        id: "layoutPriority",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "並びの中で、場所を先にもらう順を決める modifier。大きい値ほど先に場所をもらう。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/layoutpriority(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layoutPriority", .slider(range: -1...2, step: 1, initial: 1), on: true,
                summary: "場所をもらう順（既定は 0）")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左の長い文字の見本\").lineLimit(1)"], call: "Text",
            fixedArguments: ["\"右の長い文字の見本\""], suffix: [".lineLimit(1)"], closing: ["}", ".frame(width: 240)"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左の長い文字の見本").lineLimit(1).background(.yellow)
                    Text("右の長い文字の見本")
                        .apply(v.number("layoutPriority")) { $0.layoutPriority($1) }
                        .lineLimit(1)
                        .background(.orange)
                }
                .frame(width: 240)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/PositionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let position = CatalogEntry(
        id: "position",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の中心を、置き場所の中の決めた座標に置く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/position(x:y:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: 0...300, step: 10, initial: 60), on: true, summary: "中心の横の座標（OFF なら 0）"),
            .argument("y", .slider(range: 0...200, step: 10, initial: 40), on: true, summary: "中心の縦の座標（OFF なら 0）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .background(.yellow)"], call: ".position", suffix: [".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .background(.yellow)
                    .position(x: v.number("x").map { CGFloat($0) } ?? 0, y: v.number("y").map { CGFloat($0) } ?? 0)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/OffsetEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let offset = CatalogEntry(
        id: "offset",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の描く場所だけをずらす modifier。並びの中の場所は変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/offset(x:y:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: -100...100, step: 10, initial: 40), on: true, summary: "横にずらす距離（OFF なら 0）"),
            .argument("y", .slider(range: -60...60, step: 10, initial: 20), summary: "縦にずらす距離（OFF なら 0）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .background(.yellow)"], call: ".offset", suffix: [".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .background(.yellow)
                    .offset(x: v.number("x").map { CGFloat($0) } ?? 0, y: v.number("y").map { CGFloat($0) } ?? 0)
                    .border(.secondary)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .scenePadding,
        .frame,
        .containerRelativeFrame,
        .fixedSize,
        .layoutPriority,
        .position,
        .offset,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py layout-adjustments`
Expected: 抜けに scenePadding・frame・containerRelativeFrame・fixedSize・layoutPriority・position・offset がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/LayoutAdjustments/ScenePaddingEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/FrameEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/ContainerRelativeFrameEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/FixedSizeEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/LayoutPriorityEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/PositionEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/OffsetEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: scenePadding・frame・containerRelativeFrame・fixedSize・layoutPriority・position・offset を収録する"
```

### Task 5: レイアウトの調整 2（alignmentGuide・contentMargins・ignoresSafeArea・safeAreaInset・safeAreaPadding・layoutDirectionBehavior）

**Files:**
- Create: `WidgetLab/Catalog/LayoutAdjustments/AlignmentGuideEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/ContentMarginsEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/IgnoresSafeAreaEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/SafeAreaInsetEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/SafeAreaPaddingEntry.swift`
- Create: `WidgetLab/Catalog/LayoutAdjustments/LayoutDirectionBehaviorEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.alignmentGuide`、`CatalogEntry.contentMargins`、`CatalogEntry.ignoresSafeArea`、`CatalogEntry.safeAreaInset`、`CatalogEntry.safeAreaPadding`、`CatalogEntry.layoutDirectionBehavior`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py layout-adjustments`
Expected: 終了コード 1。抜けに alignmentGuide・contentMargins・ignoresSafeArea・safeAreaInset・safeAreaPadding・layoutDirectionBehavior がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/LayoutAdjustments/AlignmentGuideEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let alignmentGuide = CatalogEntry(
        id: "alignmentGuide",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "並びで揃えるときに使う位置（揃えの線）を、View ごとに変える modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/alignmentguide(_:computevalue:)-6y3u2")!,
        stage: .card,
        properties: [
            .modifier(
                "alignmentGuide", id: "alignmentGuide.g", .fixed(code: ".leading"), required: true,
                summary: "変える揃えの線（並びの alignment と同じもの）"),
            .modifier(
                "alignmentGuide", id: "alignmentGuide.computeValue", label: "computeValue",
                .choice(
                    [
                        Choice("右へ 40", code: "{ d in d[.leading] - 40 }"),
                        Choice("左へ 20", code: "{ d in d[.leading] + 20 }"),
                        Choice("幅の半分", code: "{ d in d.width / 2 }"),
                    ],
                    initial: 0),
                on: true, summary: "揃えの線の位置を、View の大きさ（d）から計算する"),
        ],
        code: CodeTemplate(
            prefix: ["VStack(alignment: .leading) {", "    Text(\"上の行\")"], call: "Text", fixedArguments: ["\"ずらす行\""],
            suffix: [".background(.yellow)"], closing: ["    Text(\"下の行\")", "}"]),
        build: { v in
            let compute = v.pick(
                "alignmentGuide.computeValue",
                from: [
                    { (d: ViewDimensions) in d[.leading] - 40 }, { (d: ViewDimensions) in d[.leading] + 20 },
                    { (d: ViewDimensions) in d.width / 2 },
                ])
            return AnyView(
                VStack(alignment: .leading) {
                    Text("上の行")
                    Text("ずらす行")
                        .apply(compute) { $0.alignmentGuide(.leading, computeValue: $1) }
                        .background(.yellow)
                    Text("下の行")
                }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/ContentMarginsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contentMargins = CatalogEntry(
        id: "contentMargins",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "ScrollView や List の中身・スクロールバーのまわりに余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contentmargins(_:_:for:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 1),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...60, step: 4, initial: 32), required: true,
                summary: "余白の大きさ"),
            .argument(
                "for",
                .choice([Choice(".automatic"), Choice(".scrollContent"), Choice(".scrollIndicators")], initial: 1),
                summary: "余白を足すもの（OFF なら .automatic）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "            .background(.yellow)", "    }", "}",
            ],
            indent: 0, call: ".contentMargins"),
        build: { v in
            let edges = v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all
            let placement =
                v.pick("for", from: [ContentMarginPlacement.automatic, .scrollContent, .scrollIndicators]) ?? .automatic
            return AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                            .background(.yellow)
                    }
                }
                .contentMargins(edges, v.number("length").map { CGFloat($0) }, for: placement)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/IgnoresSafeAreaEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let ignoresSafeArea = CatalogEntry(
        id: "ignoresSafeArea",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を、安全な領域（バーやキーボードを避けた範囲）の外まで広げる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "ignoresSafeArea", id: "ignoresSafeArea.regions",
                .choice([Choice(".all"), Choice(".container"), Choice(".keyboard")], initial: 1), on: true,
                summary: "無視する安全な領域の種類（.container はバーなど、.keyboard はキーボード）"),
            .modifier(
                "ignoresSafeArea", id: "ignoresSafeArea.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 1), on: true,
                summary: "無視する辺"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "Rectangle", suffix: [".foregroundStyle(.yellow)"],
            closing: ["}", ".safeAreaPadding(.vertical, 40)"]),
        build: { v in
            let regions = v.pick("ignoresSafeArea.regions", from: [SafeAreaRegions.all, .container, .keyboard])
            let edges = v.pick("ignoresSafeArea.edges", from: [Edge.Set.all, .top, .bottom])
            return AnyView(
                VStack {
                    Rectangle()
                        .apply(regions != nil || edges != nil ? () : nil) { view, _ in
                            view.ignoresSafeArea(regions ?? .all, edges: edges ?? .all)
                        }
                        .foregroundStyle(.yellow)
                }
                .safeAreaPadding(.vertical, 40)
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/SafeAreaInsetEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaInset = CatalogEntry(
        id: "safeAreaInset",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View の端に別の View を置き、そのぶん安全な領域を狭める modifier。中身は下に隠れずに済む。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)-6gwby"
        )!,
        stage: .card,
        properties: [
            .argument(
                "edge", .choice([Choice(".top"), Choice(".bottom")], initial: 1), required: true, summary: "置く辺"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 2),
                on: true, summary: "置く View の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "中身と置く View の間の距離"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "    }", "}",
            ],
            indent: 0, call: ".safeAreaInset",
            trailing: " {\n    Text(\"帯\")\n        .padding(8)\n        .background(.yellow)\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .safeAreaInset(
                    edge: v.pick("edge", from: [VerticalEdge.top, .bottom]) ?? .bottom,
                    alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing]) ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("帯")
                        .padding(8)
                        .background(.yellow)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/SafeAreaPaddingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaPadding = CatalogEntry(
        id: "safeAreaPadding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "安全な領域を狭めて余白を足す modifier。ScrollView なら、中身は余白の下までスクロールできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/safeareapadding(_:_:)-5wm4i")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 3),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...80, step: 8, initial: 48), on: true,
                summary: "余白の大きさ（OFF なら環境に合わせた既定の大きさ）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "            .background(.yellow)", "    }", "}",
            ],
            indent: 0, call: ".safeAreaPadding"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                            .background(.yellow)
                    }
                }
                .safeAreaPadding(
                    v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all,
                    v.number("length").map { CGFloat($0) })
            )
        }
    )
}
```

`WidgetLab/Catalog/LayoutAdjustments/LayoutDirectionBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let layoutDirectionBehavior = CatalogEntry(
        id: "layoutDirectionBehavior",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "右から左に書く言語のとき、View を左右反転して描くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/layoutdirectionbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layoutDirectionBehavior",
                .choice([Choice(".mirrors"), Choice(".mirrors(in: .leftToRight)"), Choice(".fixed")], initial: 0),
                on: true, summary: "左右反転するか（.mirrors は右から左のとき反転する）"),
            .modifier(
                "environment",
                .choice(
                    [
                        Choice("右から左", code: "\\.layoutDirection, .rightToLeft"),
                        Choice("左から右", code: "\\.layoutDirection, .leftToRight"),
                    ],
                    initial: 0),
                on: true, summary: "試すための書く向き（アラビア語などは右から左）"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"figure.walk\""],
            suffix: [".font(.largeTitle)", ".padding(8)", ".background(.yellow)"]),
        build: { v in
            AnyView(
                Image(systemName: "figure.walk")
                    .apply(
                        v.pick(
                            "layoutDirectionBehavior",
                            from: [LayoutDirectionBehavior.mirrors, .mirrors(in: .leftToRight), .fixed])
                    ) { $0.layoutDirectionBehavior($1) }
                    .apply(v.pick("environment", from: [LayoutDirection.rightToLeft, .leftToRight])) {
                        $0.environment(\.layoutDirection, $1)
                    }
                    .font(.largeTitle)
                    .padding(8)
                    .background(.yellow)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .alignmentGuide,
        .contentMargins,
        .ignoresSafeArea,
        .safeAreaInset,
        .safeAreaPadding,
        .layoutDirectionBehavior,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py layout-adjustments`
Expected: 抜けに alignmentGuide・contentMargins・ignoresSafeArea・safeAreaInset・safeAreaPadding・layoutDirectionBehavior がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/LayoutAdjustments/AlignmentGuideEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/ContentMarginsEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/IgnoresSafeAreaEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/SafeAreaInsetEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/SafeAreaPaddingEntry.swift \
  WidgetLab/Catalog/LayoutAdjustments/LayoutDirectionBehaviorEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: alignmentGuide・contentMargins・ignoresSafeArea・safeAreaInset・safeAreaPadding・layoutDirectionBehavior を収録する"
```

### Task 6: 自作のレイアウトとまとめる View 1（layoutValue・Group・Section・ForEach・containerValue）

**Files:**
- Create: `WidgetLab/Catalog/CustomLayout/LayoutValueEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/GroupEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/SectionEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/ForEachEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/ContainerValueEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.layoutValue`、`CatalogEntry.group`、`CatalogEntry.section`、`CatalogEntry.forEach`、`CatalogEntry.containerValue`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py custom-layout view-groupings`
Expected: 終了コード 1。抜けに layoutValue・Group・Section・ForEach・containerValue がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/CustomLayout/LayoutValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let layoutValue = CatalogEntry(
        id: "layoutValue",
        kind: .modifier,
        topic: .customLayout,
        summary: "自作の Layout が読む値を、子の View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/layoutvalue(key:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layoutValue", id: "layoutValue.key", label: "key", .fixed(code: "Rank.self"), required: true,
                summary: "値の種類（LayoutValueKey に合わせた型）"),
            .modifier(
                "layoutValue", id: "layoutValue.value", label: "value", .slider(range: 0...3, step: 1, initial: 3),
                on: true, summary: "付ける値。RankedHStack は小さい順に左から並べる（OFF なら既定の 0）"),
        ],
        code: CodeTemplate(
            prefix: [
                "// Rank: 既定 0 の LayoutValueKey、RankedHStack: Rank の小さい順に左から並べる Layout",
                "RankedHStack {", "    Text(\"A\").layoutValue(key: Rank.self, value: 1)",
            ],
            call: "Text", fixedArguments: ["\"B\""], suffix: [".background(.yellow)"],
            closing: ["    Text(\"C\").layoutValue(key: Rank.self, value: 2)", "}"]),
        build: { v in
            AnyView(
                RankedHStack {
                    Text("A").layoutValue(key: Rank.self, value: 1)
                    Text("B")
                        .apply(v.number("layoutValue.value")) { $0.layoutValue(key: Rank.self, value: $1) }
                        .background(.yellow)
                    Text("C").layoutValue(key: Rank.self, value: 2)
                }
                .font(.largeTitle)
                .border(.secondary)
            )
        }
    )
}

/// 並べる順の値（小さいほど左）
nonisolated private struct Rank: LayoutValueKey {
    static let defaultValue: Double = 0
}

/// 子を Rank の小さい順に左から並べる Layout
nonisolated private struct RankedHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let width = sizes.map(\.width).reduce(0, +) + spacing * CGFloat(max(sizes.count - 1, 0))
        return CGSize(width: width, height: sizes.map(\.height).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        for subview in subviews.sorted(by: { $0[Rank.self] < $1[Rank.self] }) {
            let size = subview.sizeThatFits(.unspecified)
            subview.place(at: CGPoint(x: x, y: bounds.midY), anchor: .leading, proposal: ProposedViewSize(size))
            x += size.width + spacing
        }
    }
}
```

`WidgetLab/Catalog/ViewGroupings/GroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let group = CatalogEntry(
        id: "Group",
        kind: .view,
        topic: .viewGroupings,
        summary: "子の View をまとめる View。かけた modifier は、子の 1 つずつにかかる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/group")!,
        stage: .card,
        properties: [
            .modifier(
                "font", .choice([Choice(".largeTitle"), Choice(".title"), Choice(".caption")], initial: 1), on: true,
                summary: "子の文字の大きさ"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "子の文字の色"),
            .modifier("border", .color(initial: 0), on: true, summary: "枠線（子の 1 つずつに付く）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "Group", trailing: " {\n        Text(\"A\")\n        Text(\"BBBB\")\n    }",
            closing: ["    Text(\"Group の外\")", "}"]),
        build: { v in
            AnyView(
                VStack {
                    Group {
                        Text("A")
                        Text("BBBB")
                    }
                    .apply(v.pick("font", from: [Font.largeTitle, .title, .caption])) { $0.font($1) }
                    .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                    .apply(v.color("border")) { $0.border($1) }
                    Text("Group の外")
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewGroupings/SectionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let section = CatalogEntry(
        id: "Section",
        kind: .view,
        topic: .viewGroupings,
        summary: "List や Form の中身を、見出しの付いた節に分ける View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/section")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "見出し"), on: true, summary: "節の見出し"),
            .modifier(
                "headerProminence", .choice([Choice(".standard"), Choice(".increased")], initial: 1),
                summary: "見出しの目立たせ方"),
            .modifier(
                "listSectionSpacing", .choice([Choice(".default"), Choice(".compact")], initial: 1),
                summary: "次の節との間の距離"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", trailing: " {\n        Text(\"行 1\")\n        Text(\"行 2\")\n    }",
            closing: ["    Section(\"次の節\") {", "        Text(\"行 3\")", "    }", "}"]),
        build: { v in
            AnyView(
                List {
                    SectionDemo.section(title: v.text("title"))
                        .apply(v.pick("headerProminence", from: [Prominence.standard, .increased])) {
                            $0.headerProminence($1)
                        }
                        .apply(v.pick("listSectionSpacing", from: [ListSectionSpacing.default, .compact])) {
                            $0.listSectionSpacing($1)
                        }
                    Section("次の節") {
                        Text("行 3")
                    }
                }
            )
        }
    )
}

private enum SectionDemo {
    @ViewBuilder
    static func section(title: String?) -> some View {
        if let title {
            Section(title) { rows }
        } else {
            Section { rows }
        }
    }

    @ViewBuilder
    private static var rows: some View {
        Text("行 1")
        Text("行 2")
    }
}
```

`WidgetLab/Catalog/ViewGroupings/ForEachEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let forEach = CatalogEntry(
        id: "ForEach",
        kind: .view,
        topic: .viewGroupings,
        summary: "データの 1 件ずつから View を作って並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/foreach")!,
        stage: .card,
        properties: [
            .argument(
                "data", unlabeled: true, .choice([Choice("0..<3"), Choice("0..<5"), Choice("1...8")], initial: 0),
                required: true, summary: "並べるデータ"),
            .argument(
                "id", .fixed(code: "\\.self"), on: true,
                summary: "1 件ずつを見分ける値（数の範囲のデータでは OFF にできる。範囲が変わるときは要る）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "ForEach", trailing: " { i in\n        Text(\"行 \\(i)\")\n    }", closing: ["}"]
        ),
        build: { v in
            let data = v.pick("data", from: [Array(0..<3), Array(0..<5), Array(1...8)]) ?? []
            return AnyView(
                VStack {
                    ForEach(data, id: \.self) { i in
                        Text("行 \(i)")
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewGroupings/ContainerValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let containerValue = CatalogEntry(
        id: "containerValue",
        kind: .modifier,
        topic: .viewGroupings,
        summary: "子の View に値を付け、入れ物が ForEach(subviews:) で読めるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/containervalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "containerValue", id: "containerValue.keyPath", .fixed(code: "\\.markColor"), required: true,
                summary: "値の種類（ContainerValues に @Entry で足したもの）"),
            .modifier(
                "containerValue", id: "containerValue.value", .color(initial: 0), on: true,
                summary: "付ける値。MarkedList は、この色の印を行の頭に付ける"),
        ],
        code: CodeTemplate(
            prefix: [
                "// markColor: ContainerValues に @Entry で足した Color?、MarkedList: 子ごとに markColor の印を付ける入れ物",
                "MarkedList {", "    Text(\"A\")",
            ],
            call: "Text", fixedArguments: ["\"B\""], closing: ["    Text(\"C\")", "}"]),
        build: { v in
            AnyView(
                MarkedList {
                    Text("A")
                    Text("B")
                        .apply(v.color("containerValue.value")) { $0.containerValue(\.markColor, $1) }
                    Text("C")
                }
            )
        }
    )
}

extension ContainerValues {
    /// 行の頭に付ける印の色
    @Entry var markColor: Color? = nil
}

/// 子を縦に並べ、markColor のある子の頭に印を付ける入れ物
private struct MarkedList<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(subviews: content) { subview in
                HStack {
                    Circle()
                        .fill(subview.containerValues.markColor ?? .clear)
                        .frame(width: 12, height: 12)
                    subview
                }
            }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .layoutValue,
        .group,
        .section,
        .forEach,
        .containerValue,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py custom-layout view-groupings`
Expected: 抜けに layoutValue・Group・Section・ForEach・containerValue がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/CustomLayout/LayoutValueEntry.swift \
  WidgetLab/Catalog/ViewGroupings/GroupEntry.swift \
  WidgetLab/Catalog/ViewGroupings/SectionEntry.swift \
  WidgetLab/Catalog/ViewGroupings/ForEachEntry.swift \
  WidgetLab/Catalog/ViewGroupings/ContainerValueEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: layoutValue・Group・Section・ForEach・containerValue を収録する"
```

### Task 7: まとめる View 2（GroupBox・Form・LabeledContent・ControlGroup）と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/ViewGroupings/GroupBoxEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/FormEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/LabeledContentEntry.swift`
- Create: `WidgetLab/Catalog/ViewGroupings/ControlGroupEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）

**Interfaces:**
- Consumes: Task 1 の `PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`
- Produces: `CatalogEntry.groupBox`、`CatalogEntry.form`、`CatalogEntry.labeledContent`、`CatalogEntry.controlGroup`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-groupings`
Expected: 終了コード 1。抜けに GroupBox・Form・LabeledContent・ControlGroup がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ViewGroupings/GroupBoxEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let groupBox = CatalogEntry(
        id: "GroupBox",
        kind: .view,
        topic: .viewGroupings,
        summary: "見出しと中身を、背景の付いた箱にまとめる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/groupbox")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "設定"), on: true, summary: "箱の見出し"),
            .modifier("backgroundStyle", .color(initial: 2), on: true, summary: "箱の背景"),
        ],
        code: CodeTemplate(call: "GroupBox", trailing: " {\n    Text(\"通知を受け取る\")\n}"),
        build: { v in
            AnyView(
                GroupBoxDemo.box(title: v.text("title"))
                    .apply(v.color("backgroundStyle")) { $0.backgroundStyle($1) }
                    .padding()
            )
        }
    )
}

private enum GroupBoxDemo {
    @ViewBuilder
    static func box(title: String?) -> some View {
        if let title {
            GroupBox(title) { Text("通知を受け取る") }
        } else {
            GroupBox { Text("通知を受け取る") }
        }
    }
}
```

`WidgetLab/Catalog/ViewGroupings/FormEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let form = CatalogEntry(
        id: "Form",
        kind: .view,
        topic: .viewGroupings,
        summary: "設定やデータの入力に使う操作部品を、まとめて並べる入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/form")!,
        stage: .card,
        properties: [
            .modifier(
                "formStyle", .choice([Choice(".automatic"), Choice(".grouped"), Choice(".columns")], initial: 2),
                on: true, summary: "並べ方のスタイル"),
            .modifier(
                "scrollContentBackground", .choice([Choice(".hidden"), Choice(".visible")], initial: 0),
                summary: "Form の背景を出すか"),
            .modifier("disabled", .toggle(initial: true), summary: "中の操作部品を全部押せなくする"),
        ],
        code: CodeTemplate(
            call: "Form",
            trailing: " {\n    Toggle(\"通知\", isOn: .constant(true))\n"
                + "    LabeledContent(\"バージョン\", value: \"1.0\")\n}"),
        build: { v in
            AnyView(
                Form {
                    Toggle("通知", isOn: .constant(true))
                    LabeledContent("バージョン", value: "1.0")
                }
                .apply(v.pick("formStyle", from: FormDemo.Style.allCases)) { FormDemo.styled($0, $1) }
                .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible])) {
                    $0.scrollContentBackground($1)
                }
                .apply(v.flag("disabled")) { $0.disabled($1) }
            )
        }
    )
}

private enum FormDemo {
    enum Style: CaseIterable {
        case automatic, grouped, columns
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.formStyle(.automatic)
        case .grouped: view.formStyle(.grouped)
        case .columns: view.formStyle(.columns)
        }
    }
}
```

`WidgetLab/Catalog/ViewGroupings/LabeledContentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let labeledContent = CatalogEntry(
        id: "LabeledContent",
        kind: .view,
        topic: .viewGroupings,
        summary: "名前と値を 1 組にして並べる View。Form の中では、名前を左、値を右に置く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/labeledcontent")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "バージョン"), required: true, summary: "名前"),
            .argument("value", .text(initial: "1.0"), required: true, summary: "値"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(prefix: ["Form {"], call: "LabeledContent", closing: ["}"]),
        build: { v in
            AnyView(
                Form {
                    LabeledContent(v.text("title") ?? "", value: v.text("value") ?? "")
                        .apply(v.flag("labelsHidden")) { view, _ in view.labelsHidden() }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewGroupings/ControlGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let controlGroup = CatalogEntry(
        id: "ControlGroup",
        kind: .view,
        topic: .viewGroupings,
        summary: "関係のある操作部品（ボタンなど）を 1 つのまとまりとして出す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/controlgroup")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "文字の大きさ"), summary: "まとまりの名前（メニューのスタイルで出る）"),
            .modifier(
                "controlGroupStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigation"), Choice(".compactMenu"), Choice(".menu"),
                        Choice(".palette"),
                    ],
                    initial: 1),
                on: true, summary: "まとまりの見た目のスタイル"),
        ],
        code: CodeTemplate(
            call: "ControlGroup",
            trailing:
                " {\n    Button(\"小さく\", systemImage: \"minus\") { }\n    Button(\"大きく\", systemImage: \"plus\") { }\n}"
        ),
        build: { v in
            AnyView(
                ControlGroupDemo.group(title: v.text("title"))
                    .apply(v.pick("controlGroupStyle", from: ControlGroupDemo.Style.allCases)) {
                        ControlGroupDemo.styled($0, $1)
                    }
            )
        }
    )
}

private enum ControlGroupDemo {
    enum Style: CaseIterable {
        case automatic, navigation, compactMenu, menu, palette
    }

    @ViewBuilder
    static func group(title: String?) -> some View {
        if let title {
            ControlGroup(title) { buttons }
        } else {
            ControlGroup { buttons }
        }
    }

    @ViewBuilder
    private static var buttons: some View {
        Button("小さく", systemImage: "minus") {}
        Button("大きく", systemImage: "plus") {}
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.controlGroupStyle(.automatic)
        case .navigation: view.controlGroupStyle(.navigation)
        case .compactMenu: view.controlGroupStyle(.compactMenu)
        case .menu: view.controlGroupStyle(.menu)
        case .palette: view.controlGroupStyle(.palette)
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .groupBox,
        .form,
        .labeledContent,
        .controlGroup,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `testStateRedrawsOnlyWithWrapper` のあと（`/// 起動して、検索の結果から詳細を開く` の前）に足す。ScrollView と付け外しの形の代表を 1 件ずつ撮る:

```swift
    @MainActor
    func testLayoutEntriesShowPreview() {
        for (id, title) in [("frame", ".frame"), ("LazyVGrid", "LazyVGrid")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行を直す:

```
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピー、詳細で比べるを開いて左右が出ること、`@State` を比べて付けた側だけ表示が変わること、レイアウトの代表 2 件のスクリーンショットの 4 本）
```

- [ ] **Step 5: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト 12 件・単体テスト・UI テスト 4 本が全部通る

Run: `python3 tools/catalog_progress.py layout-fundamentals layout-adjustments custom-layout view-groupings`
Expected: 終了コード 0。`合計 35 / 35（抜け 0）`

- [ ] **Step 6: スクリーンショットを見る**

Run: `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `frame` の画像で、黄色の地の「見本」が幅 160 の枠の左に寄っている。`LazyVGrid` の画像で、黄色のマスが 3 列に並ぶ（ScrollView はテストの `ImageRenderer` では描けないので、ここで見る）

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Catalog/ViewGroupings/GroupBoxEntry.swift \
  WidgetLab/Catalog/ViewGroupings/FormEntry.swift \
  WidgetLab/Catalog/ViewGroupings/LabeledContentEntry.swift \
  WidgetLab/Catalog/ViewGroupings/ControlGroupEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  docs/architecture.md
git commit -m "feat: GroupBox・Form・LabeledContent・ControlGroup を収録する"
```

## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、main にマージして push する（ブランチは消さない）
- そのあと、上の「束 1 のあとに書く手引き」の中身で `swiftui/docs/cataloging-guide.md` を書く（別の PR）
