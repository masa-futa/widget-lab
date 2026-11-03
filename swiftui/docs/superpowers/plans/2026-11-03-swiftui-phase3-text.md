# SwiftUI 版 Phase 3 束 2（テキスト）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** text-input-and-output の残り 43 件を収録し、トピックの抜けを 0 にする。

**Architecture:** 収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。Task 1〜7 で、1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/TextInputAndOutput/<名前>Entry.swift`）を 5〜7 件ずつ足し、`Catalog.all` に並べる。入力欄の見本が使う、値を持つ入れ物 `TextInputDemo` を Task 1 で足す。stage は 39 件が `.card`、4 件が `.note`。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 2 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは iPhone 17（`name=iPhone 17,OS=27.0`）を使う
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`（TextRenderer は `nonisolated private`）
- `WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない（並列の束とぶつかるため。変えたくなったら止まってオーナーに聞く）
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- 今の収録（`Text` など 40 件）は書き直さない
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）。並列の束の行とぶつかったら、両方の行を残す
- 収録のファイルは、この計画に書いたコードをそのまま写す（試作でテストとスクリーンショットを通したもの）。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける。コントローラーが試作のファイルと `cmp` で比べる
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
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` / `refactor:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く）

---

## 1 件ずつの表

トピックは 43 件とも text-input-and-output。「形」は手引きの 4 章（View・引数・付け外し）。プロパティの `*` は最初から ON、`R` は required。

| id | stage | 形 | プロパティ（チップの順） | コードの形（最初の値） |
|---|---|---|---|---|
| Label | card | View | title R・systemImage R（3 つ）・.labelStyle*（4 つ）・.font*（3 つ） | `Label("ダウンロード", systemImage: "arrow.down.circle").labelStyle(.titleAndIcon).font(.title)` |
| TextField | card | View | prompt*・axis・.textFieldStyle*（.automatic・.bordered・.plain）・.lineLimit（2...4・1...2） | `TextField("名前", text: $name, prompt: Text("例: 山田 花子")).textFieldStyle(.bordered)` |
| SecureField | card | View | prompt*・.textFieldStyle* | `SecureField("パスワード", text: $password, prompt: Text("8 文字以上")).textFieldStyle(.bordered)` |
| TextEditor | card | View | .font*・.foregroundStyle・.scrollContentBackground | `TextEditor(text: $memo).font(.title3).frame(height: 120)` |
| textSelection | card | 付け外し | .textSelection*（.enabled・.disabled） | `Text("長押しすると…").textSelection(.enabled)` |
| textSelectionAffinity | card | 付け外し | .textSelectionAffinity*（3 つ） | `TextEditor(text: $memo).textSelectionAffinity(.upstream).frame(height: 120)` |
| font | card | 付け外し | .font*（6 つ。.system・.custom を含む） | `Text("見本 Sample 123").font(.title)` |
| fontDesign | card | 付け外し | .fontDesign*（4 つ） | `Text("見本 Sample 123").fontDesign(.serif).font(.title)` |
| fontWeight | card | 付け外し | .fontWeight*（6 つ） | `Text("見本 Sample 123").fontWeight(.bold).font(.title)` |
| fontWidth | card | 付け外し | .fontWidth*（4 つ） | `Text("Widget Lab 123").fontWidth(.expanded).font(.title)` |
| textScale | card | 付け外し（入れ子） | .textScale*（.secondary・.default） | `HStack(alignment: .firstTextBaseline) { Text("1,280")・Text("円（税込）").textScale(.secondary) }.font(.title)` |
| dynamicTypeSize | card | 付け外し | .dynamicTypeSize*（4 つ） | `VStack(alignment: .leading) { 見出し・本文 }.dynamicTypeSize(.xxxLarge)` |
| ScaledMetric | card | ラッパー | @ScaledMetric | `struct Favorite { @ScaledMetric private var size = 24.0 … }`、使う側で `.dynamicTypeSize(.accessibility2)` |
| bold | card | 付け外し | .bold*（true・false） | `Text("Bold 太字").bold(true).font(.title)` |
| italic | card | 付け外し | .italic*（true・false） | `Text("Italic 斜体").italic(true).font(.title)` |
| underline | card | 付け外し | .underline*・.underline(pattern:)*（5 つ）・.underline(color:) | `Text("Underline 下線").underline(true, pattern: .dash).font(.title)` |
| strikethrough | card | 付け外し | .strikethrough*・.strikethrough(pattern:)・.strikethrough(color:)* | `Text("Strikethrough 取り消し").strikethrough(true, color: .red).font(.title)` |
| textCase | card | 付け外し | .textCase*（.uppercase・.lowercase） | `Text("Hello SwiftUI").textCase(.uppercase).font(.title)` |
| monospaced | card | 付け外し | .monospaced*（true・false） | `VStack(alignment: .leading) { 2 行 }.monospaced(true).font(.title)` |
| monospacedDigit | card | 付け外し | .monospacedDigit*（引数なし） | `VStack(alignment: .trailing) { 2 行 }.monospacedDigit().font(.title)` |
| truncationMode | card | 付け外し | .truncationMode*（3 つ） | `Text(長い文字).truncationMode(.middle).lineLimit(1).frame(width: 200)` |
| allowsTightening | card | 付け外し | .allowsTightening*（true・false） | `Text("Tightening squeezes letters").allowsTightening(true).lineLimit(1).frame(width: 206)` |
| minimumScaleFactor | card | 付け外し | .minimumScaleFactor*（0.1〜1） | `Text(長い文字).minimumScaleFactor(0.5).lineLimit(1).frame(width: 200)` |
| baselineOffset | card | 付け外し（入れ子） | .baselineOffset*（-20〜20） | `HStack(alignment: .firstTextBaseline, spacing: 0) { Text("E = mc")・Text("2").baselineOffset(12).font(.title3) }.font(.largeTitle)` |
| kerning | card | 付け外し | .kerning*（-4〜12） | `Text("Kerning 字間").kerning(8).font(.title)` |
| tracking | card | 付け外し | .tracking*（-4〜12） | `Text("Tracking 字間").tracking(8).font(.title)` |
| flipsForRightToLeftLayoutDirection | card | 付け外し | .flipsForRightToLeftLayoutDirection*・.environment*（書く向き） | `Image(systemName: "figure.walk").flipsForRightToLeftLayoutDirection(true).environment(\.layoutDirection, .rightToLeft)…` |
| textRenderer | card | 付け外し | .textRenderer*（波・影） | `Text("文字の描き方を変える").textRenderer(WaveRenderer()).font(.title)` |
| lineLimit | card | 付け外し | .lineLimit*（1・2・3・2 行を取っておく） | `Text(長い文字).lineLimit(2).frame(width: 200)` |
| lineSpacing | card | 付け外し | .lineSpacing*（0〜24） | `Text(長い文字).lineSpacing(12).frame(width: 200)` |
| multilineTextAlignment | card | 付け外し | .multilineTextAlignment*（3 つ） | `Text(3 行).multilineTextAlignment(.center).frame(width: 220)` |
| typesettingLanguage | card | 付け外し | .typesettingLanguage*（タイ語・日本語・英語） | `Text("สวัสดีครับ\nภาษาไทย").typesettingLanguage(Locale.Language(identifier: "th")).font(.title)` |
| autocorrectionDisabled | card | 付け外し | .autocorrectionDisabled*（true・false） | `TextField("ユーザー名", text: $userName).autocorrectionDisabled(true).textFieldStyle(.bordered)` |
| keyboardType | card | 付け外し | .keyboardType*（6 つ） | `TextField("郵便番号", text: $postalCode).keyboardType(.numberPad).textFieldStyle(.bordered)` |
| scrollDismissesKeyboard | card | 付け外し | .scrollDismissesKeyboard*（4 つ） | `ScrollView { TextField・20 行 }.scrollDismissesKeyboard(.immediately)` |
| textInputAutocapitalization | card | 付け外し | .textInputAutocapitalization*（4 つ） | `TextField("Full name", text: $fullName).textInputAutocapitalization(.words).textFieldStyle(.bordered)` |
| textInputBorderShape | **note** | 付け外し | .textInputBorderShape*（3 つ） | `TextField("名前", text: $name).textInputBorderShape(.capsule).textFieldStyle(.bordered)` |
| textContentType | card | 付け外し | .textContentType*（5 つ） | `TextField("連絡先", text: $contact).textContentType(.emailAddress).textFieldStyle(.bordered)` |
| textInputFormattingControlVisibility | card | 付け外し | .textInputFormattingControlVisibility*（3 つ）・(for:) R（3 つ） | `TextEditor(text: $memo).textInputFormattingControlVisibility(.hidden, for: .all).frame(height: 120)` |
| searchDictationBehavior | **note** | 付け外し | .searchDictationBehavior*（3 つ） | `NavigationStack { List(…).searchable(text: $query) }.searchDictationBehavior(.inline(activation: .onLook))` |
| writingToolsBehavior | card | 付け外し | .writingToolsBehavior*（4 つ） | `TextEditor(text: $memo).writingToolsBehavior(.disabled).frame(height: 120)` |
| writingToolsAffordanceVisibility | **note** | 付け外し | .writingToolsAffordanceVisibility*（3 つ） | `TextEditor(text: $memo).writingToolsAffordanceVisibility(.hidden).frame(height: 120)` |
| typeSelectEquivalent | **note** | 付け外し（入れ子） | .typeSelectEquivalent*（Text(fruit)・空の文字） | `List(fruits, id: \.self) { fruit in Label(fruit, systemImage: "leaf").typeSelectEquivalent(Text(fruit)) }` |

### `.note` にする 4 件と理由

`.note` は 43 件中 4 件（9.3%）で、手引きの「1 割を超えたら ADR-0002 を見直す」には届かない。

| id | 理由（noteReason） | 決めた根拠 |
|---|---|---|
| textInputBorderShape | Mac などの入力欄の枠で効く。iPhone（iOS 27.0）では、.bordered の入力欄でも枠の形が変わらない | 試作で、自動・`.bordered`・`.roundedBorder` の TextField、SecureField、TextEditor に `.capsule` をかけて撮り、どれも形が変わらなかった。SDK の `.roundedBorder` の置き換えの案内は macOS 向けに「`.bordered` と `textInputBorderShape(.roundedRectangle)`」とある |
| searchDictationBehavior | visionOS の検索欄で効く（見つめるだけで音声入力が始まるなど）。iPhone では見た目も動きも変わらない | 公式の説明が「visionOS の検索欄は、音声入力のボタンを見つめると始まる。この modifier で変えられる」。`.onLook` も visionOS のもの |
| writingToolsAffordanceVisibility | Mac（Mac Catalyst を含む）の入力欄で効く。iPhone では作文ツールのボタンの出方は変わらない | 公式の説明が「macOS か Mac Catalyst で動くときに、作文ツールのボタンを消すのに使う」 |
| typeSelectEquivalent | Mac で、キーボードから一覧の行を選ぶときに効く。iPhone の画面では試せない | 一覧の行を、ハードウェアキーボードで名前の頭を打って選ぶ仕組み。iPhone の画面の操作では起きない |

`writingToolsBehavior` は `.card` にした。Apple Intelligence が使える端末なら、文字を選んで作文ツールの出方の違いを試せる（シミュレータでは確かめられないことを summary に書いた）。

### 試作でわかったこと（Task 7 で手引きに足す）

- TextField・SecureField・TextEditor（UIKit で描く入力欄）は、`ImageRenderer` では黄色の地に赤い禁止の印で描かれる。エラーにはならないので、テストが通っても見た目は確かめられていない。一時的な UI テストで詳細画面を撮って確かめた
- 入力した値を持つ見本は、`build` の中で `@State` を持てないので、値を持つ入れ物 `TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）から Binding を受け取る。String でも AttributedString でも使える
- 公式の要約と URL は、リファレンスの JSON（`https://developer.apple.com/tutorials/data/documentation/swiftui/text-input-and-output.json` の `references`）で確かめた。`textContentType(_:)` は素の URL が macOS 版で、iOS 版は `textcontenttype(_:)-ufdv`
- iOS 27 の SDK では、`.textFieldStyle(.roundedBorder)` が `.bordered` と `textInputBorderShape(.roundedRectangle)` に置き換える予定（deprecated: 100000）になっている。束 2 の入力欄はすべて `.bordered` にした
- `typesettingLanguage` は漢字の字形を変えない（日本語と中国語で同じに描かれた）。公式のとおり行の高さ・改行・字の間に効くので、上下に飾りのあるタイ語の行の高さで見せた
- `allowsTightening` は、詰めれば収まり、付けなければ省かれる幅でないと違いが見えない。幅を 2 ずつ変えて描き比べ、206 にした
- `@ScaledMetric` の見本は、文字の大きさ（`.dynamicTypeSize`）をラッパーを持つ View の外側でかける。同じ View の body の中でかけても、その View の `@ScaledMetric` は大きくならない

---
### Task 1: 入力欄と選択（Label・TextField・SecureField・TextEditor・textSelection・textSelectionAffinity）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextInputDemo.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/LabelEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextFieldEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/SecureFieldEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextEditorEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextSelectionEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextSelectionAffinityEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）
- Produces: `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`。Task 1・6・7 の入力欄の見本が使う）、`CatalogEntry.label`、`.textField`、`.secureField`、`.textEditor`、`.textSelection`、`.textSelectionAffinity`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに Label・TextField・SecureField・TextEditor・textSelection・textSelectionAffinity がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/TextInputDemo.swift`:

```swift
import SwiftUI

/// 文字の入力の見本が使う入れ物。入力した値を @State で持ち、その Binding を content に渡す
/// （見本は収録の build で組み立て直されるが、@State は残るので、打った文字は消えない）
struct TextInputDemo<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
```

`WidgetLab/Catalog/TextInputAndOutput/LabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let label = CatalogEntry(
        id: "Label",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "文字とアイコンを組にして出す、ふつうの見出しの View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/label")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "ダウンロード"), required: true, summary: "見出しの文字"),
            .argument(
                "systemImage",
                .choice([Choice("\"arrow.down.circle\""), Choice("\"star.fill\""), Choice("\"bell\"")], initial: 0),
                required: true, summary: "アイコン（SF Symbols の名前）"),
            .modifier(
                "labelStyle",
                .choice(
                    [Choice(".automatic"), Choice(".titleAndIcon"), Choice(".titleOnly"), Choice(".iconOnly")],
                    initial: 1),
                on: true, summary: "文字とアイコンのどちらを出すか"),
            .modifier(
                "font", .choice([Choice(".title"), Choice(".body"), Choice(".caption")], initial: 0),
                on: true, summary: "文字とアイコンの大きさ"),
        ],
        code: CodeTemplate(call: "Label"),
        build: { v in
            AnyView(
                Label(
                    v.text("title") ?? "",
                    systemImage: v.pick("systemImage", from: ["arrow.down.circle", "star.fill", "bell"])
                        ?? "arrow.down.circle"
                )
                .apply(v.pick("labelStyle", from: LabelDemo.Style.allCases)) { LabelDemo.styled($0, $1) }
                .apply(v.pick("font", from: [Font.title, .body, .caption])) { $0.font($1) }
            )
        }
    )
}

private enum LabelDemo {
    enum Style: CaseIterable {
        case automatic, titleAndIcon, titleOnly, iconOnly
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.labelStyle(.automatic)
        case .titleAndIcon: view.labelStyle(.titleAndIcon)
        case .titleOnly: view.labelStyle(.titleOnly)
        case .iconOnly: view.labelStyle(.iconOnly)
        }
    }
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextFieldEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textField = CatalogEntry(
        id: "TextField",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "編集できる文字を出す操作部品。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/textfield")!,
        stage: .card,
        properties: [
            .argument(
                "prompt", .choice([Choice("例: 山田 花子", code: "Text(\"例: 山田 花子\")")], initial: 0), on: true,
                summary: "空のときに薄く出す手がかり（OFF ならタイトルを出す）"),
            .argument(
                "axis", .choice([Choice(".horizontal"), Choice(".vertical")], initial: 1),
                summary: "長い文字を入れたとき、横にずらすか（.horizontal）縦に伸ばすか（.vertical）"),
            .modifier(
                "textFieldStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".plain")], initial: 1),
                on: true, summary: "入力欄の見た目のスタイル"),
            .modifier(
                "lineLimit", .choice([Choice("2...4"), Choice("1...2")], initial: 0),
                summary: "縦に伸ばすときの行の数の幅（axis が .vertical のとき効く）"),
        ],
        code: CodeTemplate(call: "TextField", fixedArguments: ["\"名前\"", "text: $name"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextFieldDemo.field(
                        text: text, prompt: v.pick("prompt", from: [Text("例: 山田 花子")]),
                        axis: v.pick("axis", from: [Axis.horizontal, .vertical])
                    )
                    .apply(v.pick("textFieldStyle", from: TextFieldDemo.Style.allCases)) {
                        TextFieldDemo.styled($0, $1)
                    }
                    .apply(v.pick("lineLimit", from: [2...4, 1...2])) { $0.lineLimit($1) }
                }
                .padding()
            )
        }
    )
}

private enum TextFieldDemo {
    enum Style: CaseIterable {
        case automatic, bordered, plain
    }

    @ViewBuilder
    static func field(text: Binding<String>, prompt: Text?, axis: Axis?) -> some View {
        if let axis {
            TextField("名前", text: text, prompt: prompt, axis: axis)
        } else {
            TextField("名前", text: text, prompt: prompt)
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.textFieldStyle(.automatic)
        case .bordered: view.textFieldStyle(.bordered)
        case .plain: view.textFieldStyle(.plain)
        }
    }
}
```

`WidgetLab/Catalog/TextInputAndOutput/SecureFieldEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let secureField = CatalogEntry(
        id: "SecureField",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "パスワードなどの秘密の文字を、伏せて入力する操作部品。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/securefield")!,
        stage: .card,
        properties: [
            .argument(
                "prompt", .choice([Choice("8 文字以上", code: "Text(\"8 文字以上\")")], initial: 0), on: true,
                summary: "空のときに薄く出す手がかり（OFF ならタイトルを出す）"),
            .modifier(
                "textFieldStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".plain")], initial: 1),
                on: true, summary: "入力欄の見た目のスタイル"),
        ],
        code: CodeTemplate(call: "SecureField", fixedArguments: ["\"パスワード\"", "text: $password"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    SecureField("パスワード", text: text, prompt: v.pick("prompt", from: [Text("8 文字以上")]))
                        .apply(v.pick("textFieldStyle", from: SecureFieldDemo.Style.allCases)) {
                            SecureFieldDemo.styled($0, $1)
                        }
                }
                .padding()
            )
        }
    )
}

private enum SecureFieldDemo {
    enum Style: CaseIterable {
        case automatic, bordered, plain
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.textFieldStyle(.automatic)
        case .bordered: view.textFieldStyle(.bordered)
        case .plain: view.textFieldStyle(.plain)
        }
    }
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextEditorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textEditor = CatalogEntry(
        id: "TextEditor",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "長い文字を、複数行で表示して編集できる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/texteditor")!,
        stage: .card,
        properties: [
            .modifier(
                "font", .choice([Choice(".body"), Choice(".title3"), Choice(".caption")], initial: 1), on: true,
                summary: "文字の大きさ"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字の色"),
            .modifier(
                "scrollContentBackground", .choice([Choice(".hidden"), Choice(".visible")], initial: 0),
                summary: "入力欄の地を出すか（.hidden なら後ろの色が透ける）"),
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("買うもの\n・牛乳\n・パン\n行を足して編集できる") { text in
                    TextEditor(text: text)
                        .apply(v.pick("font", from: [Font.body, .title3, .caption])) { $0.font($1) }
                        .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                        .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible])) {
                            $0.scrollContentBackground($1)
                        }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextSelectionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textSelection = CatalogEntry(
        id: "textSelection",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を、長押しで選んでコピーできるようにするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textselection(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textSelection", .choice([Choice(".enabled"), Choice(".disabled")], initial: 0), on: true,
                summary: "文字を選べるか（OFF なら選べない）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"長押しすると、この文字を選んでコピーできる\""]),
        build: { v in
            AnyView(
                Text("長押しすると、この文字を選んでコピーできる")
                    .apply(v.pick("textSelection", from: [true, false])) { view, enabled in
                        if enabled {
                            view.textSelection(.enabled)
                        } else {
                            view.textSelection(.disabled)
                        }
                    }
                    .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextSelectionAffinityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textSelectionAffinity = CatalogEntry(
        id: "textSelectionAffinity",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "折り返しの境目にカーソルを置いたとき、前の行の末尾と次の行の頭のどちらに出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textselectionaffinity(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textSelectionAffinity",
                .choice([Choice(".automatic"), Choice(".upstream"), Choice(".downstream")], initial: 1), on: true,
                summary: "境目のカーソルを前の行の末尾（.upstream）か次の行の頭（.downstream）に寄せる")
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("折り返しの境目をタップして、カーソルがどちらの行に出るかを見る。長い文字は枠の幅で折り返す。") {
                    text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "textSelectionAffinity",
                                from: [TextSelectionAffinity.automatic, .upstream, .downstream])
                        ) { $0.textSelectionAffinity($1) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .label,
        .textField,
        .secureField,
        .textEditor,
        .textSelection,
        .textSelectionAffinity,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに Label・TextField・SecureField・TextEditor・textSelection・textSelectionAffinity がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/TextInputDemo.swift \
  WidgetLab/Catalog/TextInputAndOutput/LabelEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextFieldEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/SecureFieldEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextEditorEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextSelectionEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextSelectionAffinityEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: Label・TextField・SecureField・TextEditor・textSelection・textSelectionAffinity を収録する"
```

### Task 2: フォント（font・fontDesign・fontWeight・fontWidth・textScale・dynamicTypeSize・ScaledMetric）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/FontEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/FontDesignEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/FontWeightEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/FontWidthEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextScaleEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/DynamicTypeSizeEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/ScaledMetricEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.font`、`.fontDesign`、`.fontWeight`、`.fontWidth`、`.textScale`、`.dynamicTypeSize`、`.scaledMetric`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに font・fontDesign・fontWeight・fontWidth・textScale・dynamicTypeSize・ScaledMetric がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/FontEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let font = CatalogEntry(
        id: "font",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に使うフォントを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/font(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "font",
                .choice(
                    [
                        Choice(".largeTitle"), Choice(".title"), Choice(".body"), Choice(".caption"),
                        Choice(".system(size: 28, weight: .bold, design: .rounded)"),
                        Choice(".custom(\"Georgia\", size: 28)"),
                    ],
                    initial: 1),
                on: true, summary: "フォント（.title などの文字の役割は、文字の大きさの設定に合わせて変わる）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(
                        v.pick(
                            "font",
                            from: [
                                Font.largeTitle, .title, .body, .caption,
                                .system(size: 28, weight: .bold, design: .rounded), .custom("Georgia", size: 28),
                            ])
                    ) { $0.font($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/FontDesignEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fontDesign = CatalogEntry(
        id: "fontDesign",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字のフォントの系統（明朝のような serif・丸ゴシックのような rounded など）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontdesign(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontDesign",
                .choice([Choice(".default"), Choice(".serif"), Choice(".rounded"), Choice(".monospaced")], initial: 1),
                on: true, summary: "フォントの系統")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(v.pick("fontDesign", from: [Font.Design.default, .serif, .rounded, .monospaced])) {
                        $0.fontDesign($1)
                    }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/FontWeightEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fontWeight = CatalogEntry(
        id: "fontWeight",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の太さを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontweight(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontWeight",
                .choice(
                    [
                        Choice(".ultraLight"), Choice(".light"), Choice(".regular"), Choice(".semibold"),
                        Choice(".bold"),
                        Choice(".black"),
                    ],
                    initial: 4),
                on: true, summary: "文字の太さ")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本 Sample 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("見本 Sample 123")
                    .apply(
                        v.pick(
                            "fontWeight", from: [Font.Weight.ultraLight, .light, .regular, .semibold, .bold, .black])
                    ) { $0.fontWeight($1) }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/FontWidthEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fontWidth = CatalogEntry(
        id: "fontWidth",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の幅（詰めた形・広げた形）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fontwidth(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fontWidth",
                .choice(
                    [Choice(".compressed"), Choice(".condensed"), Choice(".standard"), Choice(".expanded")], initial: 3),
                on: true, summary: "文字の幅（幅の違う形を持つフォントで効く。日本語の文字は変わらない）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Widget Lab 123\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Widget Lab 123")
                    .apply(v.pick("fontWidth", from: [Font.Width.compressed, .condensed, .standard, .expanded])) {
                        $0.fontWidth($1)
                    }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextScaleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textScale = CatalogEntry(
        id: "textScale",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を、まわりの文字より一段小さい大きさ（.secondary）で出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textscale(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textScale", .choice([Choice(".secondary"), Choice(".default")], initial: 0), on: true,
                summary: "文字の大きさの段（.secondary は一段小さい）")
        ],
        code: CodeTemplate(
            prefix: ["HStack(alignment: .firstTextBaseline) {", "    Text(\"1,280\")"], call: "Text",
            fixedArguments: ["\"円（税込）\""], closing: ["}", ".font(.title)"]),
        build: { v in
            AnyView(
                HStack(alignment: .firstTextBaseline) {
                    Text("1,280")
                    Text("円（税込）")
                        .apply(v.pick("textScale", from: [Text.Scale.secondary, .default])) { $0.textScale($1) }
                }
                .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/DynamicTypeSizeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dynamicTypeSize = CatalogEntry(
        id: "dynamicTypeSize",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の大きさの設定（Dynamic Type）を、端末の設定にかかわらず決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dynamictypesize(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dynamicTypeSize",
                .choice(
                    [Choice(".xSmall"), Choice(".large"), Choice(".xxxLarge"), Choice(".accessibility2")], initial: 2),
                on: true, summary: "文字の大きさの設定（OFF なら端末の設定に従う。.large が標準）")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .leading"],
            trailing: " {\n    Text(\"見出し\").font(.headline)\n    Text(\"本文の文字\").font(.body)\n}"),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Text("見出し").font(.headline)
                    Text("本文の文字").font(.body)
                }
                .apply(
                    v.pick("dynamicTypeSize", from: [DynamicTypeSize.xSmall, .large, .xxxLarge, .accessibility2])
                ) { $0.dynamicTypeSize($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/ScaledMetricEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scaledMetric = CatalogEntry(
        id: "ScaledMetric",
        kind: .propertyWrapper,
        topic: .textInputAndOutput,
        summary: "数値を、文字の大きさの設定（Dynamic Type）に合わせて大きくしたり小さくしたりするプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scaledmetric")!,
        stage: .card,
        properties: [
            .wrapper(
                "ScaledMetric",
                summary: "外すと、文字が大きくなってもアイコンは 24 ポイントのまま。見本は使う側で文字の大きさを .accessibility2 にしてある")
        ],
        code: CodeTemplate(
            call: "ScaledMetric",
            wrapper: WrapperCode(
                withWrapper: [
                    "struct Favorite: View {",
                    "    @ScaledMetric private var size = 24.0",
                    "",
                    "    var body: some View {",
                    "        HStack {",
                    "            Image(systemName: \"star.fill\")",
                    "                .resizable()",
                    "                .frame(width: size, height: size)",
                    "                .foregroundStyle(.yellow)",
                    "            Text(\"お気に入り\")",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "// 使う側",
                    "Favorite().dynamicTypeSize(.accessibility2)",
                ],
                withoutWrapper: [
                    "struct Favorite: View {",
                    "    private let size = 24.0",
                    "",
                    "    var body: some View {",
                    "        HStack {",
                    "            Image(systemName: \"star.fill\")",
                    "                .resizable()",
                    "                .frame(width: size, height: size)",
                    "                .foregroundStyle(.yellow)",
                    "            Text(\"お気に入り\")",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "// 使う側",
                    "Favorite().dynamicTypeSize(.accessibility2)",
                ])),
        build: { v in
            AnyView(
                Group {
                    if v["ScaledMetric"] != nil {
                        ScaledMetricDemo.Scaled()
                    } else {
                        ScaledMetricDemo.Fixed()
                    }
                }
                .dynamicTypeSize(.accessibility2)
            )
        }
    )
}

private enum ScaledMetricDemo {
    struct Scaled: View {
        @ScaledMetric private var size = 24.0

        var body: some View {
            Row(size: size)
        }
    }

    struct Fixed: View {
        private let size = 24.0

        var body: some View {
            Row(size: size)
        }
    }

    struct Row: View {
        let size: Double

        var body: some View {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.yellow)
                Text("お気に入り")
            }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .font,
        .fontDesign,
        .fontWeight,
        .fontWidth,
        .textScale,
        .dynamicTypeSize,
        .scaledMetric,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに font・fontDesign・fontWeight・fontWidth・textScale・dynamicTypeSize・ScaledMetric がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/FontEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/FontDesignEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/FontWeightEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/FontWidthEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextScaleEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/DynamicTypeSizeEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/ScaledMetricEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: font・fontDesign・fontWeight・fontWidth・textScale・dynamicTypeSize・ScaledMetric を収録する"
```

### Task 3: 文字の飾り（bold・italic・underline・strikethrough・textCase・monospaced・monospacedDigit）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/BoldEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/ItalicEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/UnderlineEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/StrikethroughEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextCaseEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/MonospacedEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/MonospacedDigitEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.bold`、`.italic`、`.underline`、`.strikethrough`、`.textCase`、`.monospaced`、`.monospacedDigit`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに bold・italic・underline・strikethrough・textCase・monospaced・monospacedDigit がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/BoldEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let bold = CatalogEntry(
        id: "bold",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を太字にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/bold(_:)")!,
        stage: .card,
        properties: [
            .modifier("bold", .toggle(initial: true), on: true, summary: "太字にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Bold 太字\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Bold 太字")
                    .apply(v.flag("bold")) { $0.bold($1) }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/ItalicEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let italic = CatalogEntry(
        id: "italic",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を斜体にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/italic(_:)")!,
        stage: .card,
        properties: [
            .modifier("italic", .toggle(initial: true), on: true, summary: "斜体にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Italic 斜体\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Italic 斜体")
                    .apply(v.flag("italic")) { $0.italic($1) }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/UnderlineEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let underline = CatalogEntry(
        id: "underline",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に下線を引く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/underline(_:pattern:color:)")!,
        stage: .card,
        properties: [
            .modifier("underline", .toggle(initial: true), on: true, summary: "下線を引くか（OFF なら既定の true）"),
            .modifier(
                "underline", id: "underline.pattern", label: "pattern",
                .choice(
                    [Choice(".solid"), Choice(".dot"), Choice(".dash"), Choice(".dashDot"), Choice(".dashDotDot")],
                    initial: 2),
                on: true, summary: "線の模様"),
            .modifier(
                "underline", id: "underline.color", label: "color", .color(initial: 0),
                summary: "線の色（OFF なら文字と同じ色）"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Underline 下線\""], suffix: [".font(.title)"]),
        build: { v in
            let isOn = v["underline"] != nil || v["underline.pattern"] != nil || v["underline.color"] != nil
            return AnyView(
                Text("Underline 下線")
                    .apply(isOn ? () : nil) { view, _ in
                        view.underline(
                            v.flag("underline") ?? true,
                            pattern: v.pick(
                                "underline.pattern",
                                from: [Text.LineStyle.Pattern.solid, .dot, .dash, .dashDot, .dashDotDot])
                                ?? .solid,
                            color: v.color("underline.color"))
                    }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/StrikethroughEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let strikethrough = CatalogEntry(
        id: "strikethrough",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に取り消し線を引く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/strikethrough(_:pattern:color:)")!,
        stage: .card,
        properties: [
            .modifier(
                "strikethrough", .toggle(initial: true), on: true, summary: "取り消し線を引くか（OFF なら既定の true）"),
            .modifier(
                "strikethrough", id: "strikethrough.pattern", label: "pattern",
                .choice(
                    [Choice(".solid"), Choice(".dot"), Choice(".dash"), Choice(".dashDot"), Choice(".dashDotDot")],
                    initial: 0),
                summary: "線の模様"),
            .modifier(
                "strikethrough", id: "strikethrough.color", label: "color", .color(initial: 0), on: true,
                summary: "線の色（OFF なら文字と同じ色）"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Strikethrough 取り消し\""], suffix: [".font(.title)"]),
        build: { v in
            let isOn =
                v["strikethrough"] != nil || v["strikethrough.pattern"] != nil || v["strikethrough.color"] != nil
            return AnyView(
                Text("Strikethrough 取り消し")
                    .apply(isOn ? () : nil) { view, _ in
                        view.strikethrough(
                            v.flag("strikethrough") ?? true,
                            pattern: v.pick(
                                "strikethrough.pattern",
                                from: [Text.LineStyle.Pattern.solid, .dot, .dash, .dashDot, .dashDotDot]) ?? .solid,
                            color: v.color("strikethrough.color"))
                    }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextCaseEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textCase = CatalogEntry(
        id: "textCase",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の英字を、大文字か小文字にそろえて出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textcase(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textCase", .choice([Choice(".uppercase"), Choice(".lowercase")], initial: 0), on: true,
                summary: "そろえる文字の形（OFF なら書いたまま）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Hello SwiftUI\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Hello SwiftUI")
                    .apply(v.pick("textCase", from: [Text.Case.uppercase, .lowercase])) { $0.textCase($1) }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/MonospacedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let monospaced = CatalogEntry(
        id: "monospaced",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を、どの文字も同じ幅の等幅のフォントにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/monospaced(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "monospaced", .toggle(initial: true), on: true, summary: "等幅にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .leading"],
            trailing: " {\n    Text(\"iiiii 11111\")\n    Text(\"WWWWW 88888\")\n}", suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Text("iiiii 11111")
                    Text("WWWWW 88888")
                }
                .apply(v.flag("monospaced")) { $0.monospaced($1) }
                .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/MonospacedDigitEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let monospacedDigit = CatalogEntry(
        id: "monospacedDigit",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の数字だけを同じ幅にする modifier。桁がそろい、数字が変わっても幅が揺れない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/monospaceddigit()")!,
        stage: .card,
        properties: [
            .modifier("monospacedDigit", .fixed(code: ""), on: true, summary: "数字を同じ幅にする")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .trailing"],
            trailing: " {\n    Text(\"1,111.11\")\n    Text(\"8,888.88\")\n}", suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                VStack(alignment: .trailing) {
                    Text("1,111.11")
                    Text("8,888.88")
                }
                .apply(v.flag("monospacedDigit")) { view, _ in view.monospacedDigit() }
                .font(.title)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .bold,
        .italic,
        .underline,
        .strikethrough,
        .textCase,
        .monospaced,
        .monospacedDigit,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに bold・italic・underline・strikethrough・textCase・monospaced・monospacedDigit がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/BoldEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/ItalicEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/UnderlineEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/StrikethroughEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextCaseEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/MonospacedEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/MonospacedDigitEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: bold・italic・underline・strikethrough・textCase・monospaced・monospacedDigit を収録する"
```

### Task 4: 省き方と字の間（truncationMode・allowsTightening・minimumScaleFactor・baselineOffset・kerning・tracking）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/TruncationModeEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/AllowsTighteningEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/MinimumScaleFactorEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/BaselineOffsetEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/KerningEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TrackingEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.truncationMode`、`.allowsTightening`、`.minimumScaleFactor`、`.baselineOffset`、`.kerning`、`.tracking`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに truncationMode・allowsTightening・minimumScaleFactor・baselineOffset・kerning・tracking がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/TruncationModeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let truncationMode = CatalogEntry(
        id: "truncationMode",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "収まらない文字を「…」で省くとき、頭・真ん中・末尾のどこを省くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/truncationmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "truncationMode", .choice([Choice(".head"), Choice(".middle"), Choice(".tail")], initial: 1), on: true,
                summary: "省く場所（OFF なら .tail）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"はじめ・なかほど・おわりのどこを省くか\""],
            suffix: [".lineLimit(1)", ".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("はじめ・なかほど・おわりのどこを省くか")
                    .apply(v.pick("truncationMode", from: [Text.TruncationMode.head, .middle, .tail])) {
                        $0.truncationMode($1)
                    }
                    .lineLimit(1)
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/AllowsTighteningEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let allowsTightening = CatalogEntry(
        id: "allowsTightening",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字が 1 行に収まらないとき、省く前に字の間を詰めて収めてよいかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/allowstightening(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "allowsTightening", .toggle(initial: true), on: true,
                summary: "字の間を詰めてよいか（false なら付けないのと同じで、すぐ「…」で省く）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"Tightening squeezes letters\""],
            suffix: [".lineLimit(1)", ".frame(width: 206)"]),
        build: { v in
            AnyView(
                Text("Tightening squeezes letters")
                    .apply(v.flag("allowsTightening")) { $0.allowsTightening($1) }
                    .lineLimit(1)
                    .frame(width: 206)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/MinimumScaleFactorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let minimumScaleFactor = CatalogEntry(
        id: "minimumScaleFactor",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字が収まらないとき、どこまで小さくして収めてよいかを、元の大きさとの比で決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/minimumscalefactor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "minimumScaleFactor", .slider(range: 0.1...1, step: 0.1, initial: 0.5), on: true,
                summary: "小さくしてよい下限（1 なら小さくしない）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"長い文字は、枠に収まるまで小さくなる\""],
            suffix: [".lineLimit(1)", ".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("長い文字は、枠に収まるまで小さくなる")
                    .apply(v.number("minimumScaleFactor")) { $0.minimumScaleFactor($1) }
                    .lineLimit(1)
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/BaselineOffsetEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let baselineOffset = CatalogEntry(
        id: "baselineOffset",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を、文字の並ぶ線（ベースライン）から上下にずらす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/baselineoffset(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "baselineOffset", .slider(range: -20...20, step: 2, initial: 12), on: true,
                summary: "ずらす量（ポイント。プラスで上、マイナスで下）")
        ],
        code: CodeTemplate(
            prefix: ["HStack(alignment: .firstTextBaseline, spacing: 0) {", "    Text(\"E = mc\")"], call: "Text",
            fixedArguments: ["\"2\""], suffix: [".font(.title3)"], closing: ["}", ".font(.largeTitle)"]),
        build: { v in
            AnyView(
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("E = mc")
                    Text("2")
                        .apply(v.number("baselineOffset")) { $0.baselineOffset($1) }
                        .font(.title3)
                }
                .font(.largeTitle)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/KerningEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let kerning = CatalogEntry(
        id: "kerning",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字と文字の間隔を、フォントの既定の間隔からずらす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/kerning(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "kerning", .slider(range: -4...12, step: 1, initial: 8), on: true,
                summary: "ずらす量（ポイント。マイナスで詰める）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Kerning 字間\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Kerning 字間")
                    .apply(v.number("kerning")) { $0.kerning($1) }
                    .font(.title)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TrackingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tracking = CatalogEntry(
        id: "tracking",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字ごとの後ろに、決まった間隔を足す modifier。kerning と違い、合字（fi など）は外れることがある。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tracking(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "tracking", .slider(range: -4...12, step: 1, initial: 8), on: true,
                summary: "足す間隔（ポイント。マイナスで詰める）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Tracking 字間\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Tracking 字間")
                    .apply(v.number("tracking")) { $0.tracking($1) }
                    .font(.title)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .truncationMode,
        .allowsTightening,
        .minimumScaleFactor,
        .baselineOffset,
        .kerning,
        .tracking,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに truncationMode・allowsTightening・minimumScaleFactor・baselineOffset・kerning・tracking がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/TruncationModeEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/AllowsTighteningEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/MinimumScaleFactorEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/BaselineOffsetEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/KerningEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TrackingEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: truncationMode・allowsTightening・minimumScaleFactor・baselineOffset・kerning・tracking を収録する"
```

### Task 5: 行と描き方（flipsForRightToLeftLayoutDirection・textRenderer・lineLimit・lineSpacing・multilineTextAlignment・typesettingLanguage）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/FlipsForRightToLeftLayoutDirectionEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextRendererEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/LineLimitEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/LineSpacingEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/MultilineTextAlignmentEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TypesettingLanguageEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.flipsForRightToLeftLayoutDirection`、`.textRenderer`、`.lineLimit`、`.lineSpacing`、`.multilineTextAlignment`、`.typesettingLanguage`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに flipsForRightToLeftLayoutDirection・textRenderer・lineLimit・lineSpacing・multilineTextAlignment・typesettingLanguage がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/FlipsForRightToLeftLayoutDirectionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let flipsForRightToLeftLayoutDirection = CatalogEntry(
        id: "flipsForRightToLeftLayoutDirection",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "右から左に書く言語のとき、View を左右反転して描くかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/flipsforrighttoleftlayoutdirection(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "flipsForRightToLeftLayoutDirection", .toggle(initial: true), on: true,
                summary: "右から左のとき反転するか（false なら付けないのと同じ）"),
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
                    .apply(v.flag("flipsForRightToLeftLayoutDirection")) {
                        $0.flipsForRightToLeftLayoutDirection($1)
                    }
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

`WidgetLab/Catalog/TextInputAndOutput/TextRendererEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textRenderer = CatalogEntry(
        id: "textRenderer",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の描き方を、自分で書いた TextRenderer に任せる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textrenderer(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textRenderer",
                .choice(
                    [Choice("波", code: "WaveRenderer()"), Choice("影", code: "ShadowRenderer()")], initial: 0),
                on: true, summary: "描き方（波: 字ごとに上下にずらす、影: 赤い影を足す）")
        ],
        code: CodeTemplate(
            prefix: ["// WaveRenderer・ShadowRenderer: draw(layout:in:) で字や行を描く TextRenderer"], indent: 0, call: "Text",
            fixedArguments: ["\"文字の描き方を変える\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("文字の描き方を変える")
                    .apply(v.pick("textRenderer", from: [true, false])) { view, isWave in
                        if isWave {
                            view.textRenderer(WaveRenderer())
                        } else {
                            view.textRenderer(ShadowRenderer())
                        }
                    }
                    .font(.title)
            )
        }
    )
}

/// 字ごとに上下にずらして、波のように描く
nonisolated private struct WaveRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for (index, glyph) in run.enumerated() {
                    var copy = ctx
                    copy.translateBy(x: 0, y: sin(Double(index) * 0.9) * 6)
                    copy.draw(glyph)
                }
            }
        }
    }
}

/// 行ごとに、右下へずらした赤い影を足して描く
nonisolated private struct ShadowRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            var copy = ctx
            copy.addFilter(.shadow(color: .red, radius: 0, x: 3, y: 3))
            copy.draw(line)
        }
    }
}
```

`WidgetLab/Catalog/TextInputAndOutput/LineLimitEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lineLimit = CatalogEntry(
        id: "lineLimit",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を出す行の数の上限を決める modifier。あふれた分は「…」で省く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/linelimit(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "lineLimit",
                .choice(
                    [Choice("1"), Choice("2"), Choice("3"), Choice("2 行を取っておく", code: "2, reservesSpace: true")],
                    initial: 1),
                on: true, summary: "行の数の上限（OFF なら上限なし。reservesSpace は短い文字でもその行の数の高さを取る）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"行の数の上限を決めると、あふれた分は省かれる。上限がなければ、文字の分だけ行が増える。\""],
            suffix: [".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("行の数の上限を決めると、あふれた分は省かれる。上限がなければ、文字の分だけ行が増える。")
                    .apply(v.pick("lineLimit", from: [(1, false), (2, false), (3, false), (2, true)])) {
                        $0.lineLimit($1.0, reservesSpace: $1.1)
                    }
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/LineSpacingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let lineSpacing = CatalogEntry(
        id: "lineSpacing",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "複数行の文字の、行と行の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/linespacing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "lineSpacing", .slider(range: 0...24, step: 2, initial: 12), on: true,
                summary: "行と行の間に足す量（ポイント）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"行と行の間を広げると、長い文字が読みやすくなることがある。\""],
            suffix: [".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("行と行の間を広げると、長い文字が読みやすくなることがある。")
                    .apply(v.number("lineSpacing")) { $0.lineSpacing($1) }
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/MultilineTextAlignmentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let multilineTextAlignment = CatalogEntry(
        id: "multilineTextAlignment",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "複数行の文字の、行の揃え方（左寄せ・中央・右寄せ）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/multilinetextalignment(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "multilineTextAlignment",
                .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 1),
                on: true, summary: "行の揃え方（OFF なら .leading）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"短い行と、\\nそれより少し長い行と、\\n最後の行\""],
            suffix: [".frame(width: 220)"]),
        build: { v in
            AnyView(
                Text("短い行と、\nそれより少し長い行と、\n最後の行")
                    .apply(v.pick("multilineTextAlignment", from: [TextAlignment.leading, .center, .trailing])) {
                        $0.multilineTextAlignment($1)
                    }
                    .frame(width: 220)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TypesettingLanguageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let typesettingLanguage = CatalogEntry(
        id: "typesettingLanguage",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を組むときの言語を決める modifier。行の高さ・改行・字の間が、その言語の文字に合わせて変わる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/typesettinglanguage(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "typesettingLanguage",
                .choice(
                    [
                        Choice("タイ語", code: "Locale.Language(identifier: \"th\")"),
                        Choice("日本語", code: "Locale.Language(identifier: \"ja\")"),
                        Choice("英語", code: "Locale.Language(identifier: \"en\")"),
                    ],
                    initial: 0),
                on: true, summary: "組む言語（OFF なら端末の言語。タイ語のように上下に飾りのある文字は、行を高くとる）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"สวัสดีครับ\\nภาษาไทย\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("สวัสดีครับ\nภาษาไทย")
                    .apply(v.pick("typesettingLanguage", from: ["th", "ja", "en"])) {
                        $0.typesettingLanguage(Locale.Language(identifier: $1))
                    }
                    .font(.title)
                    .border(.secondary)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .flipsForRightToLeftLayoutDirection,
        .textRenderer,
        .lineLimit,
        .lineSpacing,
        .multilineTextAlignment,
        .typesettingLanguage,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに flipsForRightToLeftLayoutDirection・textRenderer・lineLimit・lineSpacing・multilineTextAlignment・typesettingLanguage がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/FlipsForRightToLeftLayoutDirectionEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextRendererEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/LineLimitEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/LineSpacingEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/MultilineTextAlignmentEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TypesettingLanguageEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: flipsForRightToLeftLayoutDirection・textRenderer・lineLimit・lineSpacing・multilineTextAlignment・typesettingLanguage を収録する"
```

### Task 6: キーボード（autocorrectionDisabled・keyboardType・scrollDismissesKeyboard・textInputAutocapitalization・textInputBorderShape・textContentType）

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/AutocorrectionDisabledEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/KeyboardTypeEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/ScrollDismissesKeyboardEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextInputAutocapitalizationEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextInputBorderShapeEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextContentTypeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.autocorrectionDisabled`、`.keyboardType`、`.scrollDismissesKeyboard`、`.textInputAutocapitalization`、`.textInputBorderShape`（`.note`）、`.textContentType`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに autocorrectionDisabled・keyboardType・scrollDismissesKeyboard・textInputAutocapitalization・textInputBorderShape・textContentType がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/AutocorrectionDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let autocorrectionDisabled = CatalogEntry(
        id: "autocorrectionDisabled",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄で、打ち間違いの自動修正を止める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/autocorrectiondisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "autocorrectionDisabled", .toggle(initial: true), on: true,
                summary: "自動修正を止めるか（false なら付けないのと同じ）。試すには英語のキーボードで打ち間違える")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"ユーザー名\"", "text: $userName"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("ユーザー名", text: text)
                        .apply(v.flag("autocorrectionDisabled")) { $0.autocorrectionDisabled($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/KeyboardTypeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let keyboardType = CatalogEntry(
        id: "keyboardType",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄を選んだときに出すキーボードの種類を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/keyboardtype(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "keyboardType",
                .choice(
                    [
                        Choice(".default"), Choice(".numberPad"), Choice(".decimalPad"), Choice(".emailAddress"),
                        Choice(".URL"), Choice(".phonePad"),
                    ],
                    initial: 1),
                on: true, summary: "キーボードの種類（入力欄をタップすると出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"郵便番号\"", "text: $postalCode"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("郵便番号", text: text)
                        .apply(
                            v.pick(
                                "keyboardType",
                                from: [
                                    UIKeyboardType.default, .numberPad, .decimalPad, .emailAddress, .URL, .phonePad,
                                ])
                        ) { $0.keyboardType($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/ScrollDismissesKeyboardEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollDismissesKeyboard = CatalogEntry(
        id: "scrollDismissesKeyboard",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "スクロールしたときに、出ているキーボードを閉じるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolldismisseskeyboard(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollDismissesKeyboard",
                .choice(
                    [Choice(".automatic"), Choice(".immediately"), Choice(".interactively"), Choice(".never")],
                    initial: 1),
                on: true, summary: "閉じ方（.interactively は指に合わせて下げる。入力欄をタップしてからスクロールする）")
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    TextField(\"メモ\", text: $memo)\n        .textFieldStyle(.bordered)\n"
                + "    ForEach(0..<20, id: \\.self) { i in\n        Text(\"行 \\(i)\")\n    }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    TextInputDemo("") { text in
                        TextField("メモ", text: text)
                            .textFieldStyle(.bordered)
                    }
                    ForEach(0..<20, id: \.self) { i in
                        Text("行 \(i)")
                    }
                }
                .apply(
                    v.pick(
                        "scrollDismissesKeyboard",
                        from: [ScrollDismissesKeyboardMode.automatic, .immediately, .interactively, .never])
                ) { $0.scrollDismissesKeyboard($1) }
                .padding(.horizontal)
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextInputAutocapitalizationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputAutocapitalization = CatalogEntry(
        id: "textInputAutocapitalization",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄で英字を打つとき、どこを自動で大文字にするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textinputautocapitalization(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textInputAutocapitalization",
                .choice([Choice(".never"), Choice(".words"), Choice(".sentences"), Choice(".characters")], initial: 1),
                on: true, summary: "大文字にする単位（OFF なら .sentences。英語のキーボードで打つと違いが出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"Full name\"", "text: $fullName"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("Full name", text: text)
                        .apply(
                            v.pick(
                                "textInputAutocapitalization",
                                from: [TextInputAutocapitalization.never, .words, .sentences, .characters])
                        ) { $0.textInputAutocapitalization($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextInputBorderShapeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputBorderShape = CatalogEntry(
        id: "textInputBorderShape",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄などの枠の形を決める modifier。中の入力欄にまとめて効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textinputbordershape(_:)")!,
        noteReason: "Mac などの入力欄の枠で効く。iPhone（iOS 27.0）では、.bordered の入力欄でも枠の形が変わらない",
        properties: [
            .modifier(
                "textInputBorderShape",
                .choice([Choice(".capsule"), Choice(".roundedRectangle"), Choice(".automatic")], initial: 0),
                on: true, summary: "枠の形")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"名前\"", "text: $name"], suffix: [".textFieldStyle(.bordered)"])
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TextContentTypeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textContentType = CatalogEntry(
        id: "textContentType",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄に入れる中身の種類を伝え、キーボードの上に自動入力の候補を出せるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textcontenttype(_:)-ufdv")!,
        stage: .card,
        properties: [
            .modifier(
                "textContentType",
                .choice(
                    [
                        Choice(".emailAddress"), Choice(".name"), Choice(".telephoneNumber"), Choice(".oneTimeCode"),
                        Choice(".password"),
                    ],
                    initial: 0),
                on: true, summary: "中身の種類（入力欄をタップすると、連絡先などからの候補が出る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"連絡先\"", "text: $contact"],
            suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("連絡先", text: text)
                        .apply(
                            v.pick(
                                "textContentType",
                                from: [
                                    UITextContentType.emailAddress, .name, .telephoneNumber, .oneTimeCode, .password,
                                ])
                        ) { $0.textContentType($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .autocorrectionDisabled,
        .keyboardType,
        .scrollDismissesKeyboard,
        .textInputAutocapitalization,
        .textInputBorderShape,
        .textContentType,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト 12 件・単体テストが全部通る（`CatalogTests` の `buildsAllCombinations` に、足した件の id が並ぶ）

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 抜けに autocorrectionDisabled・keyboardType・scrollDismissesKeyboard・textInputAutocapitalization・textInputBorderShape・textContentType がない

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/AutocorrectionDisabledEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/KeyboardTypeEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/ScrollDismissesKeyboardEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextInputAutocapitalizationEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextInputBorderShapeEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TextContentTypeEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: autocorrectionDisabled・keyboardType・scrollDismissesKeyboard・textInputAutocapitalization・textInputBorderShape・textContentType を収録する"
```

### Task 7: 書式と作文ツールと type select（textInputFormattingControlVisibility・searchDictationBehavior・writingToolsBehavior・writingToolsAffordanceVisibility・typeSelectEquivalent）と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/TextInputAndOutput/TextInputFormattingControlVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/SearchDictationBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/WritingToolsBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/WritingToolsAffordanceVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/TextInputAndOutput/TypeSelectEquivalentEntry.swift`
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（7 章に束 2 でわかったことを足す）
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.apply`（今のまま。`WidgetLab/Catalog/Model/`）、Task 1 の `TextInputDemo<Value, Content: View>`（`init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content)`）
- Produces: `CatalogEntry.textInputFormattingControlVisibility`、`.searchDictationBehavior`（`.note`）、`.writingToolsBehavior`、`.writingToolsAffordanceVisibility`（`.note`）、`.typeSelectEquivalent`（`.note`）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 1。抜けに textInputFormattingControlVisibility・searchDictationBehavior・writingToolsBehavior・writingToolsAffordanceVisibility・typeSelectEquivalent がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/TextInputAndOutput/TextInputFormattingControlVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textInputFormattingControlVisibility = CatalogEntry(
        id: "textInputFormattingControlVisibility",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "書式を付けられる入力欄で、太字などの書式の操作を出すかを、出す場所ごとに決める modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/textinputformattingcontrolvisibility(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textInputFormattingControlVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "書式の操作を出すか（文字を選ぶと出るメニューで確かめる）"),
            .modifier(
                "textInputFormattingControlVisibility", id: "textInputFormattingControlVisibility.for", label: "for",
                .choice([Choice(".all"), Choice(".contextMenu"), Choice(".inputAssistant")], initial: 0),
                required: true, summary: "出す場所（.contextMenu は選んだときのメニュー、.inputAssistant はキーボードの上）"),
        ],
        code: CodeTemplate(
            prefix: ["// memo は AttributedString（書式を付けられる文字）"], indent: 0, call: "TextEditor",
            fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            let placement = v.pick(
                "textInputFormattingControlVisibility.for",
                from: [TextInputFormattingControlPlacement.Set.all, .contextMenu, .inputAssistant])
            return AnyView(
                TextInputDemo(AttributedString("文字を選ぶと出るメニューに、太字や斜体などの書式の操作が出る。")) { text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "textInputFormattingControlVisibility", from: [Visibility.hidden, .visible, .automatic])
                        ) { $0.textInputFormattingControlVisibility($1, for: placement ?? .all) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/SearchDictationBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchDictationBehavior = CatalogEntry(
        id: "searchDictationBehavior",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "searchable で付けた検索欄で、音声入力をどう始めるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchdictationbehavior(_:)")!,
        noteReason: "visionOS の検索欄で効く（見つめるだけで音声入力が始まるなど）。iPhone では見た目も動きも変わらない",
        properties: [
            .modifier(
                "searchDictationBehavior",
                .choice(
                    [
                        Choice(".inline(activation: .onLook)"), Choice(".inline(activation: .onSelect)"),
                        Choice(".automatic"),
                    ],
                    initial: 0),
                on: true, summary: "音声入力の始め方（.onLook は見つめたとき、.onSelect は検索欄を選んだとき）")
        ],
        code: CodeTemplate(
            call: "NavigationStack",
            trailing: " {\n    List(fruits, id: \\.self) { Text($0) }\n        .searchable(text: $query)\n}")
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/WritingToolsBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let writingToolsBehavior = CatalogEntry(
        id: "writingToolsBehavior",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "Apple Intelligence の作文ツール（書き直し・要約など）を、文字の上でどこまで使えるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/writingtoolsbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "writingToolsBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".complete"), Choice(".limited"), Choice(".disabled")], initial: 3),
                on: true,
                summary:
                    "使える範囲（.complete はその場で書き換える、.limited は別の枠に出す、.disabled は使わせない）。Apple Intelligence が使える端末で、文字を選ぶと試せる"
            )
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("明日の会議は 10 時から。資料はまだできていないので、朝のうちに仕上げる。") { text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "writingToolsBehavior",
                                from: [WritingToolsBehavior.automatic, .complete, .limited, .disabled])
                        ) { $0.writingToolsBehavior($1) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/WritingToolsAffordanceVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let writingToolsAffordanceVisibility = CatalogEntry(
        id: "writingToolsAffordanceVisibility",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "入力欄に、作文ツール（Writing Tools）を開くボタンを出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/writingtoolsaffordancevisibility(_:)")!,
        noteReason: "Mac（Mac Catalyst を含む）の入力欄で効く。iPhone では作文ツールのボタンの出方は変わらない",
        properties: [
            .modifier(
                "writingToolsAffordanceVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "作文ツールのボタンを出すか")
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"])
    )
}
```

`WidgetLab/Catalog/TextInputAndOutput/TypeSelectEquivalentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let typeSelectEquivalent = CatalogEntry(
        id: "typeSelectEquivalent",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "一覧で、キーボードで名前の頭を打って行を選ぶ（type select）ときに、行と照らす文字を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/typeselectequivalent(_:)")!,
        noteReason: "Mac で、キーボードから一覧の行を選ぶときに効く。iPhone の画面では試せない",
        properties: [
            .modifier(
                "typeSelectEquivalent", .choice([Choice("Text(fruit)"), Choice("\"\"")], initial: 0), on: true,
                summary: "照らす文字（OFF なら行の中の Text から決まる。空の文字なら、この行は打って選べない）")
        ],
        code: CodeTemplate(
            prefix: ["List(fruits, id: \\.self) { fruit in"], call: "Label",
            fixedArguments: ["fruit", "systemImage: \"leaf\""], closing: ["}"])
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .textInputFormattingControlVisibility,
        .searchDictationBehavior,
        .writingToolsBehavior,
        .writingToolsAffordanceVisibility,
        .typeSelectEquivalent,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `testLayoutEntriesShowPreview` のあと（`/// 起動して、検索の結果から詳細を開く` の前）に足す。入力欄の代表を 2 件撮る（TextEditor と、入力欄をタップしてキーボードを出す keyboardType）:

```swift
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
    }
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行を直す:

```
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピー、詳細で比べるを開いて左右が出ること、`@State` を比べて付けた側だけ表示が変わること、レイアウトの代表 2 件のスクリーンショット、テキストの代表 2 件のスクリーンショットの 5 本）
```

- [ ] **Step 5: 収録の手引きに、束 2 でわかったことを足す**

`docs/cataloging-guide.md` の 7 章の最後の項目（`**テストが何分も進まない → 最初のビルドとシミュレータの複製を待つ。**` の段落）のあと、`## 用語` の前に足す:

```markdown
**入力欄の見本が禁止の印になる → シミュレータで撮る。** TextField・SecureField・TextEditor（UIKit で描く入力欄）は、`ImageRenderer` では黄色の地に赤い禁止の印で描かれる。エラーにはならないので、5 章の ScrollView と同じく、一時的な UI テストで詳細画面を撮って見る。

**入力した値を持つ見本 → `TextInputDemo` に包む。** `build` の中では `@State` を持てないので、`TextInputDemo("") { text in TextField("名前", text: text) }` のように、値を持つ入れ物（`Catalog/TextInputAndOutput/TextInputDemo.swift`）から Binding を受け取る。String でも AttributedString でも使える。

**公式の要約と URL → リファレンスの JSON で確かめる。** `https://developer.apple.com/tutorials/data/documentation/swiftui/<トピックの slug>.json` の `references` に、記号ごとの URL と要約（`abstract`）がある。OS ごとに同じ名前の記号があるもの（`textContentType(_:)`）は、素の URL が macOS 版のことがあるので、iOS 版の URL（`textcontenttype(_:)-ufdv`）を使う。

**効き目が出るか怪しいもの → 公式の説明と試作で確かめてから `.note` にする。** 束 2 では、公式に「visionOS で効く」「macOS・Mac Catalyst で効く」とあるもの（`searchDictationBehavior`・`writingToolsAffordanceVisibility`）、iOS 27.0 の iPhone で試して変わらなかったもの（`textInputBorderShape`）、Mac のキーボード操作で効くもの（`typeSelectEquivalent`）の 4 件を `.note` にした。

**入力欄の枠 → `.textFieldStyle(.bordered)`。** iOS 27 の SDK では、`.roundedBorder` が `.bordered` と `textInputBorderShape(.roundedRectangle)` に置き換える予定になっている。

**違いが幅に左右されるもの → 幅を刻んで描き比べる。** `allowsTightening` は、詰めれば収まり、付けなければ省かれる幅でないと違いが見えない。一時的なテストで幅を 2 ずつ変えて描き、206 に決めた。
```

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト 12 件・単体テスト・UI テスト 5 本が全部通る

Run: `python3 tools/catalog_progress.py text-input-and-output`
Expected: 終了コード 0。`合計 44 / 44（抜け 0）`

- [ ] **Step 7: スクリーンショットを見る**

Run: `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `TextEditor` の画像で、白い入力欄に「買うもの」から 4 行の文字が title3 の大きさで出る。`keyboardType` の画像で、「郵便番号」の入力欄にカーソルがあり、数字のキーボード（.numberPad）が出ている（TextEditor と入力欄はテストの `ImageRenderer` では描けないので、ここで見る）

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/TextInputAndOutput/TextInputFormattingControlVisibilityEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/SearchDictationBehaviorEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/WritingToolsBehaviorEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/WritingToolsAffordanceVisibilityEntry.swift \
  WidgetLab/Catalog/TextInputAndOutput/TypeSelectEquivalentEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  docs/architecture.md \
  docs/cataloging-guide.md
git commit -m "feat: textInputFormattingControlVisibility・searchDictationBehavior・writingToolsBehavior・writingToolsAffordanceVisibility・typeSelectEquivalent を収録する"
```

## 最終レビューで直したこと

- `textRenderer`・`textInputFormattingControlVisibility` の `CodeTemplate` に `indent: 0` を足した。`prefix` がコメントの行だけなのに、呼び出しが 4 桁下がっていた（手引きの 7 章に足した）
- `ScaledMetric` のコードの 2 つの形に `.foregroundStyle(.yellow)` を足した。プレビューの星は黄色なのに、コードでは既定の色だった
- UI テスト `testTextEntriesShowPreview` で、keyboardType のアプリも閉じる（`field.terminate()`）
- 手引きの「条件だけで modifier をかけ分けたい」の件数を 4 件に直した（`underline`・`strikethrough` が増えた）。補助を足すのは `Model/` を変えるので、並列の束が落ち着いてから決める
- 直さなかったもの: `TextFieldEntry` と `SecureFieldEntry` の `textFieldStyle` の切り替えの重複（1 件 1 ファイルで閉じる書き方を優先した）。`typeSelectEquivalent` の理由に iPad を足す案（iPad で効くかを確かめていない）

## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、`~/dev/widget-lab`（main）で `--no-ff` でマージし、main で lint と単体テストを流してから push する（ブランチは消さない）
- マージの前に、`git -C ~/dev/widget-lab status` がきれいなことと、ほかの束がマージの途中でないことを確かめる。`Catalog.swift` がぶつかったら両方の行を残す
