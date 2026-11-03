# SwiftUI 版 Phase 3 束 3（操作の部品）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** controls-and-indicators・menus-and-commands・view-fundamentals・view-configuration の残り 42 件を収録し、4 トピックの抜けを 0 にする。

**Architecture:** 収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。Task 1〜6 で、1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/<トピック>/<名前>Entry.swift`）を 6〜8 件ずつ足し、`Catalog.all` に並べる。stage は `.card` が 30 件、`.behavior` が 6 件、`.full` が 3 件、`.note` が 3 件。Task 6 で代表 2 件のスクリーンショットの UI テストと、試作でわかったことを収録の手引きに足す。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 3 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone Air**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` は、この束では `name=iPhone Air` に置き換える（並列で動く束とシミュレータを分けるため）
- `WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない。変えたくなったら、変える前にコントローラーに知らせて止まる（並列の束とぶつかるため）
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）
- 収録のファイルは、この計画に書いたコードをそのまま写す（試作でテストとスクリーンショットを通したもの）。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける。コントローラーが試作のファイルと `cmp` で比べる
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone Air,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests
  ```
  UI テストまで通すのは Task 6 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。プロパティはチップの順。* は最初から ON、R は required。

### controls-and-indicators（16 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| EditButton | .card | View | .buttonStyle*（3 つ）・.tint | `VStack { EditButton().buttonStyle(.bordered); List { ForEach(items).onDelete } }` |
| PasteButton | .card | View | .labelStyle*（3 つ）・.buttonBorderShape・.tint | `PasteButton(payloadType: String.self) { strings in pasted = … }.labelStyle(.iconOnly)` |
| Link | .card | View | title R・destination R（URL 固定）・.buttonStyle・.tint* | `Link("Apple のサイト", destination: URL(…)!).tint(.purple)` |
| ShareLink | .card | View | title*・item R（URL 固定）・subject・message・.labelStyle | `ShareLink("サイトを共有", item: URL(…)!)` |
| Slider | .card | View | value R（`$volume`）・in R（2 つ）・step*・.tint | `Slider(value: $volume, in: 0...100, step: 10)`。`step` は `in` なしでは書けないので `in` を R にした |
| Stepper | .card | View | in*・step・.labelsHidden | `Stepper("数: \(count)", value: $count, in: 0...10)` |
| Toggle | .card | View | .toggleStyle*（3 つ）・.tint・.labelsHidden | `Toggle("通知", isOn: $isOn).toggleStyle(.button)` |
| Picker | .card | View | .pickerStyle*（5 つ）・.labelsHidden・.tint | `Picker("果物", selection: $fruit) { 3 つ }.pickerStyle(.segmented)` |
| DatePicker | .card | View | in（今日から・今日まで）・displayedComponents*・.datePickerStyle*（4 つ）・.labelsHidden | `DatePicker("日付", selection: $date, displayedComponents: .date).datePickerStyle(.compact)`。収まらないスタイルのときだけ ScrollView |
| MultiDatePicker | .card | View | in*（今日から・今日より前）・.tint | `MultiDatePicker("予定の日", selection: $dates, in: Date.now...)`。見本は ScrollView の中 |
| ColorPicker | .card | View | supportsOpacity*・.labelsHidden | `ColorPicker("色", selection: $color, supportsOpacity: false)` |
| Gauge | .card | View | value R・.gaugeStyle*（6 つ）・.tint | `Gauge(value: 0.4) { Text("電池") } currentValueLabel: { … }.gaugeStyle(.accessoryCircular)` |
| ProgressView | .card | View | title*・value*・.progressViewStyle・.tint | `ProgressView("読み込み中", value: 0.4)` |
| ContentUnavailableView | .card | View | title R・systemImage R（3 つ）・description* | `ContentUnavailableView("項目がありません", systemImage: "tray", description: Text(…))` |
| sensoryFeedback | .behavior | 付け外し | .sensoryFeedback*（6 つ）・.sensoryFeedback(trigger:) R | `Button("+1") { count += 1 }.sensoryFeedback(.success, trigger: count)`。記録に「鳴らす／鳴らさない」を出す |
| controlSize | .card | 付け外し | .controlSize*（5 つ） | `HStack { Button.buttonStyle(.bordered); ProgressView() }.controlSize(.large)` |

### menus-and-commands（4 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| Menu | .card | View | title R・.buttonStyle*（4 つ）・.tint | `Menu("並べ替え") { 3 つの Button }.buttonStyle(.bordered)` |
| contextMenu | .card | 付け外し | .contextMenu(menuItems:)*（コピー・削除） | `Text("長押しする").contextMenu(menuItems: { Button("コピー", …) { } })` |
| menuActionDismissBehavior | .card | 付け外し（入れ子） | .menuActionDismissBehavior*（3 つ） | `Menu("数: \(count)") { Button("+1") { … }.menuActionDismissBehavior(.disabled) }` |
| menuOrder | .card | 付け外し | .menuOrder*（3 つ） | `Menu("並び") { 3 つ }.menuOrder(.fixed)` |

### view-fundamentals（7 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| modifier | .card | 付け外し | .modifier*（Card()・Card(color: .mint)・EmptyModifier()） | `Text("見本").modifier(Card())` と `struct Card: ViewModifier`（closing） |
| onAppear | .behavior | 付け外し（入れ子） | .onAppear(perform:)* | `VStack { Toggle; if shows { Text("子").onAppear(perform: { … }) } }`。記録に「子が現れた」 |
| onDisappear | .behavior | 付け外し（入れ子） | .onDisappear(perform:)* | 同じ形で `.onDisappear`。記録に「子が消えた」 |
| task | .behavior | 付け外し（入れ子） | .task*（現れたときだけ・count が変わるたび） | `Text("count: …").task(id: count, { await load(count) })`。記録に始めた・終わった・取り消した |
| id | .behavior | 付け外し（入れ子） | .id*（`generation`） | `VStack { Button("作り直す"); Counter().id(generation) }` と `struct Counter`。記録に「子を作った」 |
| tag | .card | 付け外し（入れ子） | .tag*（"みかん"・includeOptional: false） | `Picker(selection: $fruit /* String? */) { Text("りんご").tag("りんご"); Text("みかん").tag("みかん") }` |
| equatable | .behavior | 付け外し（入れ子） | .equatable* | `VStack { Button("+1"); Child(count: count).equatable() }` と `struct Child: View, Equatable`。描き直しの回数の「子」で違いを見る |

### view-configuration（15 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| opacity | .card | 付け外し | .opacity*（0〜1） | `Image(systemName: "star.fill").opacity(0.3)` |
| hidden | .card | 付け外し（入れ子） | .hidden* | `HStack { Text("左"); Text("真ん中").hidden(); Text("右") }` |
| labelsHidden | .card | 付け外し | .labelsHidden* | `VStack { Toggle; Stepper }.labelsHidden()` |
| labelsVisibility | .card | 付け外し | .labelsVisibility*（3 つ） | `VStack { Toggle; Picker }.labelsVisibility(.hidden)` |
| menuIndicator | .card | 付け外し | .menuIndicator*（3 つ、最初は .hidden） | `Picker("果物", selection: $fruit) { … }.menuIndicator(.hidden)` |
| persistentSystemOverlays | .full | 付け外し | .persistentSystemOverlays*（3 つ） | `Text("画面のいちばん下のバーを見る").persistentSystemOverlays(.hidden)` |
| statusBarHidden | .full | 付け外し | .statusBarHidden* | `Text("画面のいちばん上の時刻を見る").statusBarHidden(true)` |
| disabled | .card | 付け外し | .disabled* | `VStack { Button; Toggle }.disabled(true)` |
| interactionActivityTrackingTag | .note | 付け外し | .interactionActivityTrackingTag*（文字） | `Button("保存") { }.interactionActivityTrackingTag("保存ボタン")` |
| invalidatableContent | .note | 付け外し | .invalidatableContent* | `Text("気温 18℃").invalidatableContent(true)` |
| help | .note | 付け外し | .help*（文字） | `Button("保存") { }.help("書いた内容を保存する")` |
| preferredColorScheme | .full | 付け外し | .preferredColorScheme*（.light・.dark） | `Text("画面ぜんたいが切り替わる").preferredColorScheme(.dark)` |
| privacySensitive | .card | 付け外し（入れ子） | .privacySensitive* | `VStack { Text("口座番号"); Text("1234-5678").privacySensitive(true) }.redacted(reason: .privacy)` |
| redacted | .card | 付け外し | .redacted(reason:)*（.placeholder・.invalidated） | `VStack { Image; Text; Text }.redacted(reason: .placeholder)` |
| unredacted | .card | 付け外し（入れ子） | .unredacted* | `VStack { Text("山田 花子"); Text("読み込み済み").unredacted() }.redacted(reason: .placeholder)` |

### `.note` にするもの（3 件、7%）と理由

| id | 理由（`noteReason`） |
|---|---|
| interactionActivityTrackingTag | 操作の速さの記録（Instruments など）に名前を付けるもので、画面の見た目は変わらない |
| invalidatableContent | ウィジェットとライブアクティビティの中で、ボタンの処理を待つ間に効く |
| help | iPhone では見た目が変わらない。iPad と Mac で、ポインタを重ねたときに説明が出る |

### `.full` にするもの（3 件）と理由（2026-11-03 オーナーが決定）

`preferredColorScheme`・`statusBarHidden`・`persistentSystemOverlays` は、表示の単位（presentation）ぜんたいに効く。試作で `.card` にしたところ、次の 2 つが起きた。

- 一覧の行の見本は最初の値で組み立てるので、`preferredColorScheme(.dark)` の行が見えただけで、アプリ全体が暗くなった
- `statusBarHidden(true)` は、押し込んだ詳細画面からではステータスバーが消えなかった（スクリーンショットで確認）。`persistentSystemOverlays` は、シミュレータのスクリーンショットにホームのバーが写らないので確かめられなかった

`.full` にすると、一覧の行は絵になり、行から効かなくなる。詳細画面の「試す」から全画面で開く仕組みは束 7 で作る約束なので、それまでは枠の中に描かれ、`statusBarHidden` などは効かない。全画面で開けば、その表示の単位で効く。

### 試作でわかったこと（Task 6 で収録の手引きに足す）

- `ImageRenderer` は、UIKit で描くコントロール（Toggle・Slider・Stepper・Picker・DatePicker・ColorPicker・Menu など）を、黄色の地に禁止の印で描く（エラーにはならない）。見た目はシミュレータのスクリーンショットで確かめる
- `MultiDatePicker` のカレンダーは一覧の行の見本の枠に収まらず、行が高くなって押す場所がずれた。見本を `ScrollView` に入れて直した。スタイルで高さが変わる `DatePicker` は、`ViewThatFits(in: .vertical)` で収まらないときだけスクロールにした
- 表示の単位に効く modifier は、一覧の行の見本からも効く（上の `.full` の理由）
- `CodeGenerator` は modifier を末尾のクロージャの形では書けないので、クロージャを渡す modifier は `.onAppear(perform: { … })`・`.contextMenu(menuItems: { … })` の形にした。`task` は、`id:` の有無を `Choice("count が変わるたび", code: "id: count, { await load(count) }")` の組で選ぶ
- `redacted(reason: .placeholder)` の中の `privacySensitive()` の View は、伏せられずに見えた。紛らわしいので、`redacted` の見本からは外し、`.privacy` は `privacySensitive` の収録で見せる
- `menuIndicator` の `.visible` は、Picker では付けないときと同じに見えた。最初の値を `.hidden` にした

---

### Task 1: 操作の部品 1（EditButton・PasteButton・Link・ShareLink・Slider・Stepper・Toggle）

**Files:**
- Create: `WidgetLab/Catalog/ControlsAndIndicators/EditButtonEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/PasteButtonEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/LinkEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ShareLinkEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/SliderEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/StepperEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ToggleEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.editButton`、`CatalogEntry.pasteButton`、`CatalogEntry.link`、`CatalogEntry.shareLink`、`CatalogEntry.slider`、`CatalogEntry.stepper`、`CatalogEntry.toggle`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py controls-and-indicators`
Expected: 終了コード 1。抜けに EditButton・PasteButton・Link・ShareLink・Slider・Stepper・Toggle がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ControlsAndIndicators/EditButtonEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let editButton = CatalogEntry(
        id: "EditButton",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すたびに編集モード（環境の editMode）を切り替えるボタン。List の行の削除や並べ替えに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/editbutton")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "EditButton",
            closing: [
                "    List {",
                "        ForEach(items, id: \\.self) { Text($0) }",
                "            .onDelete { items.remove(atOffsets: $0) }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                EditButtonDemo(
                    style: v.pick("buttonStyle", from: EditButtonDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct EditButtonDemo: View {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent
    }

    let style: Style?
    let tint: Color?
    @State private var items = ["りんご", "みかん", "ぶどう"]

    var body: some View {
        VStack {
            EditButton()
                .apply(style) { view, style in
                    switch style {
                    case .automatic: view.buttonStyle(.automatic)
                    case .bordered: view.buttonStyle(.bordered)
                    case .borderedProminent: view.buttonStyle(.borderedProminent)
                    }
                }
                .apply(tint) { $0.tint($1) }
            List {
                ForEach(items, id: \.self) { Text($0) }
                    .onDelete { items.remove(atOffsets: $0) }
            }
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/PasteButtonEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let pasteButton = CatalogEntry(
        id: "PasteButton",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "クリップボードの中身を読み、クロージャに渡すシステムのボタン。押したときだけ読むので、貼り付けの許可の確認が出ない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/pastebutton")!,
        stage: .card,
        properties: [
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 1),
                on: true, summary: "名前とアイコンの出し方"),
            .modifier(
                "buttonBorderShape",
                .choice([Choice(".capsule"), Choice(".roundedRectangle"), Choice(".circle")], initial: 0),
                summary: "ボタンの縁の形"),
            .modifier("tint", .color(initial: 3), summary: "ボタンの色"),
        ],
        code: CodeTemplate(
            call: "PasteButton", fixedArguments: ["payloadType: String.self"],
            trailing: " { strings in\n    pasted = strings.first ?? \"\"\n}"),
        build: { v in
            AnyView(
                PasteButtonDemo(
                    labelStyle: v.pick("labelStyle", from: PasteButtonDemo.LabelKind.allCases),
                    shape: v.pick("buttonBorderShape", from: [ButtonBorderShape.capsule, .roundedRectangle, .circle]),
                    tint: v.color("tint")))
        }
    )
}

private struct PasteButtonDemo: View {
    enum LabelKind: CaseIterable {
        case titleAndIcon, iconOnly, titleOnly
    }

    let labelStyle: LabelKind?
    let shape: ButtonBorderShape?
    let tint: Color?
    @State private var pasted = ""

    var body: some View {
        VStack(spacing: 12) {
            PasteButton(payloadType: String.self) { strings in
                pasted = strings.first ?? ""
            }
            .apply(labelStyle) { view, style in
                switch style {
                case .titleAndIcon: view.labelStyle(.titleAndIcon)
                case .iconOnly: view.labelStyle(.iconOnly)
                case .titleOnly: view.labelStyle(.titleOnly)
                }
            }
            .apply(shape) { $0.buttonBorderShape($1) }
            .apply(tint) { $0.tint($1) }
            Text(pasted.isEmpty ? "（まだ貼っていない）" : pasted)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/LinkEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let link = CatalogEntry(
        id: "Link",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すと URL を開くコントロール。Web の URL なら Safari で開く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/link")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "Apple のサイト"), required: true, summary: "名前"),
            .argument(
                "destination", .fixed(code: "URL(string: \"https://www.apple.com\")!"), required: true,
                summary: "開く URL"),
            .modifier(
                "buttonStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                summary: "見た目のスタイル。ボタンと同じスタイルが使える"),
            .modifier("tint", .color(initial: 5), on: true, summary: "文字の色"),
        ],
        code: CodeTemplate(call: "Link"),
        build: { v in
            AnyView(
                Link(v.text("title") ?? "", destination: URL(string: "https://www.apple.com")!)
                    .apply(v.pick("buttonStyle", from: LinkDemo.Style.allCases)) { LinkDemo.styled($0, $1) }
                    .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum LinkDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ShareLinkEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let shareLink = CatalogEntry(
        id: "ShareLink",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すと共有のシートを出す View。URL・文字・画像などを、ほかのアプリに渡せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sharelink")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "サイトを共有"), on: true, summary: "名前。省くと「共有」"),
            .argument(
                "item", .fixed(code: "URL(string: \"https://www.apple.com\")!"), required: true, summary: "共有するもの"),
            .argument("subject", .fixed(code: "Text(\"おすすめのサイト\")"), summary: "件名（メールで共有するときなど）"),
            .argument("message", .fixed(code: "Text(\"見てみて\")"), summary: "添える文"),
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 1),
                summary: "名前とアイコンの出し方"),
        ],
        code: CodeTemplate(call: "ShareLink"),
        build: { v in
            AnyView(
                ShareLinkDemo.link(
                    title: v.text("title"), subject: v["subject"] != nil ? Text("おすすめのサイト") : nil,
                    message: v["message"] != nil ? Text("見てみて") : nil
                )
                .apply(v.pick("labelStyle", from: ShareLinkDemo.LabelKind.allCases)) { ShareLinkDemo.styled($0, $1) }
            )
        }
    )
}

private enum ShareLinkDemo {
    enum LabelKind: CaseIterable {
        case titleAndIcon, iconOnly, titleOnly
    }

    static let url = URL(string: "https://www.apple.com")!

    @ViewBuilder
    static func link(title: String?, subject: Text?, message: Text?) -> some View {
        if let title {
            ShareLink(title, item: url, subject: subject, message: message)
        } else {
            ShareLink(item: url, subject: subject, message: message)
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: LabelKind) -> some View {
        switch style {
        case .titleAndIcon: view.labelStyle(.titleAndIcon)
        case .iconOnly: view.labelStyle(.iconOnly)
        case .titleOnly: view.labelStyle(.titleOnly)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/SliderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let slider = CatalogEntry(
        id: "Slider",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "決まった範囲の中から、つまみを動かして値を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/slider")!,
        stage: .card,
        properties: [
            .argument("value", .fixed(code: "$volume"), required: true, summary: "選んだ値を入れる Binding"),
            .argument(
                "in", .choice([Choice("0...100"), Choice("0...10")], initial: 0), required: true,
                summary: "選べる範囲"),
            .argument("step", .slider(range: 1...25, step: 1, initial: 10), on: true, summary: "値の刻み。省くと切れ目なく動く"),
            .modifier("tint", .color(initial: 1), summary: "つまみの左側の色"),
        ],
        code: CodeTemplate(call: "Slider"),
        build: { v in
            AnyView(
                SliderDemo(
                    range: v.pick("in", from: [0.0...100.0, 0.0...10.0]) ?? 0...100, step: v.number("step"),
                    tint: v.color("tint")))
        }
    )
}

private struct SliderDemo: View {
    let range: ClosedRange<Double>
    let step: Double?
    let tint: Color?
    @State private var volume = 40.0

    var body: some View {
        VStack(spacing: 8) {
            slider
                .apply(tint) { $0.tint($1) }
            Text("volume: \(volume, format: .number.precision(.fractionLength(1)))")
                .monospacedDigit()
        }
        .frame(width: 260)
    }

    @ViewBuilder
    private var slider: some View {
        if let step {
            Slider(value: $volume, in: range, step: step)
        } else {
            Slider(value: $volume, in: range)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/StepperEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let stepper = CatalogEntry(
        id: "Stepper",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "＋と−のボタンで、値を 1 刻みずつ増やしたり減らしたりするコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/stepper")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("0...10"), Choice("0...4")], initial: 0), on: true,
                summary: "選べる範囲。端まで来るとボタンが押せなくなる"),
            .argument("step", .slider(range: 1...5, step: 1, initial: 2), summary: "1 回で変わる量。省くと 1"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "Stepper", fixedArguments: ["\"数: \\(count)\"", "value: $count"]),
        build: { v in
            AnyView(
                StepperDemo(
                    range: v.pick("in", from: [0...10, 0...4]), step: v.number("step").map { Int($0) },
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct StepperDemo: View {
    let range: ClosedRange<Int>?
    let step: Int?
    let hidesLabel: Bool
    @State private var count = 2

    var body: some View {
        stepper
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .monospacedDigit()
            .frame(width: 240)
    }

    @ViewBuilder
    private var stepper: some View {
        if let range {
            Stepper("数: \(count)", value: $count, in: range, step: step ?? 1)
        } else {
            Stepper("数: \(count)", value: $count, step: step ?? 1)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ToggleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toggle = CatalogEntry(
        id: "Toggle",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "ON と OFF を切り替えるコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/toggle")!,
        stage: .card,
        properties: [
            .modifier(
                "toggleStyle", .choice([Choice(".automatic"), Choice(".switch"), Choice(".button")], initial: 2),
                on: true, summary: "見た目のスタイル。.button は押すたびに色が変わるボタンになる"),
            .modifier("tint", .color(initial: 1), summary: "ON のときの色"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "Toggle", fixedArguments: ["\"通知\"", "isOn: $isOn"]),
        build: { v in
            AnyView(
                ToggleDemo(
                    style: v.pick("toggleStyle", from: ToggleDemo.Style.allCases), tint: v.color("tint"),
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct ToggleDemo: View {
    enum Style: CaseIterable {
        case automatic, `switch`, button
    }

    let style: Style?
    let tint: Color?
    let hidesLabel: Bool
    @State private var isOn = true

    var body: some View {
        Toggle("通知", isOn: $isOn)
            .apply(style) { view, style in
                switch style {
                case .automatic: view.toggleStyle(.automatic)
                case .switch: view.toggleStyle(.switch)
                case .button: view.toggleStyle(.button)
                }
            }
            .apply(tint) { $0.tint($1) }
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .fixedSize()
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .editButton,
        .pasteButton,
        .link,
        .shareLink,
        .slider,
        .stepper,
        .toggle,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py controls-and-indicators`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`controls-and-indicators` の行が `8 / 17`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ControlsAndIndicators/EditButtonEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/PasteButtonEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/LinkEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ShareLinkEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/SliderEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/StepperEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ToggleEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: EditButton・PasteButton・Link・ShareLink・Slider・Stepper・Toggle を収録する"
```

---

### Task 2: 操作の部品 2（Picker・DatePicker・MultiDatePicker・ColorPicker・Gauge・ProgressView・ContentUnavailableView）

**Files:**
- Create: `WidgetLab/Catalog/ControlsAndIndicators/PickerEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/DatePickerEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/MultiDatePickerEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ColorPickerEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/GaugeEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ProgressViewEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ContentUnavailableViewEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.picker`、`CatalogEntry.datePicker`、`CatalogEntry.multiDatePicker`、`CatalogEntry.colorPicker`、`CatalogEntry.gauge`、`CatalogEntry.progressView`、`CatalogEntry.contentUnavailableView`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py controls-and-indicators`
Expected: 終了コード 1。抜けに Picker・DatePicker・MultiDatePicker・ColorPicker・Gauge・ProgressView・ContentUnavailableView がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ControlsAndIndicators/PickerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let picker = CatalogEntry(
        id: "Picker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "いくつかの中から 1 つを選ぶコントロール。選択肢は tag の値で見分ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/picker")!,
        stage: .card,
        properties: [
            .modifier(
                "pickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".menu"), Choice(".segmented"), Choice(".wheel"), Choice(".inline")],
                    initial: 2),
                on: true, summary: "見た目のスタイル"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
            .modifier("tint", .color(initial: 6), summary: "強調の色（.menu の文字など）"),
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing:
                " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n    Text(\"ぶどう\").tag(\"ぶどう\")\n}"),
        build: { v in
            AnyView(
                PickerDemo(
                    style: v.pick("pickerStyle", from: PickerDemo.Style.allCases), hidesLabel: v["labelsHidden"] != nil,
                    tint: v.color("tint")))
        }
    )
}

private struct PickerDemo: View {
    enum Style: CaseIterable {
        case automatic, menu, segmented, wheel, inline
    }

    let style: Style?
    let hidesLabel: Bool
    let tint: Color?
    @State private var fruit = "りんご"

    var body: some View {
        Picker("果物", selection: $fruit) {
            Text("りんご").tag("りんご")
            Text("みかん").tag("みかん")
            Text("ぶどう").tag("ぶどう")
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.pickerStyle(.automatic)
            case .menu: view.pickerStyle(.menu)
            case .segmented: view.pickerStyle(.segmented)
            case .wheel: view.pickerStyle(.wheel)
            case .inline: view.pickerStyle(.inline)
            }
        }
        .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
        .apply(tint) { $0.tint($1) }
        .frame(width: 260)
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/DatePickerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let datePicker = CatalogEntry(
        id: "DatePicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "日付と時刻を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/datepicker")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("今日から", code: "Date.now..."), Choice("今日まで", code: "...Date.now")], initial: 0),
                summary: "選べる範囲。外の日は選べない"),
            .argument(
                "displayedComponents",
                .choice([Choice(".date"), Choice(".hourAndMinute"), Choice("[.date, .hourAndMinute]")], initial: 0),
                on: true, summary: "選ぶ項目。省くと日付と時刻の両方"),
            .modifier(
                "datePickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".compact"), Choice(".graphical"), Choice(".wheel")], initial: 1),
                on: true, summary: "見た目のスタイル"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "DatePicker", fixedArguments: ["\"日付\"", "selection: $date"]),
        build: { v in
            AnyView(
                DatePickerDemo(
                    range: v.pick("in", from: DatePickerDemo.Range.allCases),
                    components: v.pick("displayedComponents", from: [.date, .hourAndMinute, [.date, .hourAndMinute]]),
                    style: v.pick("datePickerStyle", from: DatePickerDemo.Style.allCases),
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct DatePickerDemo: View {
    enum Range: CaseIterable {
        case fromNow, throughNow
    }

    enum Style: CaseIterable {
        case automatic, compact, graphical, wheel
    }

    let range: Range?
    let components: DatePickerComponents?
    let style: Style?
    let hidesLabel: Bool
    @State private var date = Date.now

    var body: some View {
        // .graphical・.wheel はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
        picker
            .apply(style) { view, style in
                switch style {
                case .automatic: view.datePickerStyle(.automatic)
                case .compact: view.datePickerStyle(.compact)
                case .graphical: view.datePickerStyle(.graphical)
                case .wheel: view.datePickerStyle(.wheel)
                }
            }
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .frame(maxWidth: 320)
    }

    @ViewBuilder
    private var picker: some View {
        let components = components ?? [.date, .hourAndMinute]
        switch range {
        case .fromNow: DatePicker("日付", selection: $date, in: Date.now..., displayedComponents: components)
        case .throughNow: DatePicker("日付", selection: $date, in: ...Date.now, displayedComponents: components)
        case nil: DatePicker("日付", selection: $date, displayedComponents: components)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/MultiDatePickerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let multiDatePicker = CatalogEntry(
        id: "MultiDatePicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "カレンダーで、日付をいくつも選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/multidatepicker")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("今日から", code: "Date.now..."), Choice("今日より前", code: "..<Date.now")], initial: 0),
                on: true, summary: "選べる範囲。外の日は薄くなり、選べない"),
            .modifier("tint", .color(initial: 3), summary: "選んだ日の色"),
        ],
        code: CodeTemplate(call: "MultiDatePicker", fixedArguments: ["\"予定の日\"", "selection: $dates"]),
        build: { v in
            AnyView(
                MultiDatePickerDemo(range: v.pick("in", from: MultiDatePickerDemo.Range.allCases))
                    .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private struct MultiDatePickerDemo: View {
    enum Range: CaseIterable {
        case fromNow, beforeNow
    }

    let range: Range?
    @State private var dates: Set<DateComponents> = []

    var body: some View {
        // カレンダーはプレビューの枠より高いので、スクロールして見る（一覧の行の見本も、行の高さに収まる）
        ScrollView {
            VStack(spacing: 4) {
                Text("選んだ日: \(dates.count)")
                    .font(.caption)
                    .monospacedDigit()
                picker
            }
            .frame(maxWidth: 320)
        }
    }

    @ViewBuilder
    private var picker: some View {
        switch range {
        case .fromNow: MultiDatePicker("予定の日", selection: $dates, in: Date.now...)
        case .beforeNow: MultiDatePicker("予定の日", selection: $dates, in: ..<Date.now)
        case nil: MultiDatePicker("予定の日", selection: $dates)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ColorPickerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let colorPicker = CatalogEntry(
        id: "ColorPicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "システムの色の選び方の画面を開き、色を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/colorpicker")!,
        stage: .card,
        properties: [
            .argument("supportsOpacity", .toggle(initial: false), on: true, summary: "透明度も選べるようにする。省くと true"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠し、色の丸だけにする"),
        ],
        code: CodeTemplate(call: "ColorPicker", fixedArguments: ["\"色\"", "selection: $color"]),
        build: { v in
            AnyView(ColorPickerDemo(supportsOpacity: v.flag("supportsOpacity"), hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct ColorPickerDemo: View {
    let supportsOpacity: Bool?
    let hidesLabel: Bool
    @State private var color = Color.orange

    var body: some View {
        HStack(spacing: 16) {
            ColorPicker("色", selection: $color, supportsOpacity: supportsOpacity ?? true)
                .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 44, height: 44)
        }
        .frame(width: 240)
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/GaugeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let gauge = CatalogEntry(
        id: "Gauge",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "範囲の中で、今の値がどこにあるかを示す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gauge")!,
        stage: .card,
        properties: [
            .argument("value", .slider(range: 0...1, step: 0.1, initial: 0.4), required: true, summary: "今の値"),
            .modifier(
                "gaugeStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".linearCapacity"), Choice(".accessoryLinear"),
                        Choice(".accessoryLinearCapacity"), Choice(".accessoryCircular"),
                        Choice(".accessoryCircularCapacity"),
                    ],
                    initial: 4),
                on: true, summary: "見た目のスタイル。accessory はロック画面のウィジェットと同じ形"),
            .modifier("tint", .color(initial: 3), summary: "目盛りの色"),
        ],
        code: CodeTemplate(
            call: "Gauge",
            trailing: " {\n    Text(\"電池\")\n} currentValueLabel: {\n    Image(systemName: \"bolt.fill\")\n}"),
        build: { v in
            AnyView(
                Gauge(value: v.number("value") ?? 0) {
                    Text("電池")
                } currentValueLabel: {
                    Image(systemName: "bolt.fill")
                }
                .apply(v.pick("gaugeStyle", from: GaugeDemo.Style.allCases)) { GaugeDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(maxWidth: 260)
            )
        }
    )
}

private enum GaugeDemo {
    enum Style: CaseIterable {
        case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity, accessoryCircular,
            accessoryCircularCapacity
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.gaugeStyle(.automatic)
        case .linearCapacity: view.gaugeStyle(.linearCapacity)
        case .accessoryLinear: view.gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity: view.gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular: view.gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: view.gaugeStyle(.accessoryCircularCapacity)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ProgressViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let progressView = CatalogEntry(
        id: "ProgressView",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "作業の進み具合を示す View。値を渡すと棒、渡さないと回る印になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/progressview")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "読み込み中"), on: true, summary: "名前"),
            .argument(
                "value", .slider(range: 0...1, step: 0.1, initial: 0.4), on: true, summary: "進み具合（0〜1）。省くと終わりの見えない待ちの印"),
            .modifier(
                "progressViewStyle",
                .choice([Choice(".automatic"), Choice(".linear"), Choice(".circular")], initial: 2),
                summary: "見た目のスタイル"),
            .modifier("tint", .color(initial: 6), summary: "棒の色"),
        ],
        code: CodeTemplate(call: "ProgressView"),
        build: { v in
            AnyView(
                ProgressViewDemo.view(title: v.text("title"), value: v.number("value"))
                    .apply(v.pick("progressViewStyle", from: ProgressViewDemo.Style.allCases)) {
                        ProgressViewDemo.styled($0, $1)
                    }
                    .apply(v.color("tint")) { $0.tint($1) }
                    .frame(width: 240)
            )
        }
    )
}

private enum ProgressViewDemo {
    enum Style: CaseIterable {
        case automatic, linear, circular
    }

    @ViewBuilder
    static func view(title: String?, value: Double?) -> some View {
        switch (title, value) {
        case (let title?, let value?): ProgressView(title, value: value)
        case (let title?, nil): ProgressView(title)
        case (nil, let value?): ProgressView(value: value)
        case (nil, nil): ProgressView()
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.progressViewStyle(.automatic)
        case .linear: view.progressViewStyle(.linear)
        case .circular: view.progressViewStyle(.circular)
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ContentUnavailableViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contentUnavailableView = CatalogEntry(
        id: "ContentUnavailableView",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "見せる中身がないとき（検索の結果が 0 件など）に出す、アイコンと説明の View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/contentunavailableview")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "項目がありません"), required: true, summary: "見出し"),
            .argument(
                "systemImage",
                .choice([Choice("\"tray\""), Choice("\"magnifyingglass\""), Choice("\"wifi.slash\"")], initial: 0),
                required: true, summary: "SF Symbols のアイコンの名前"),
            .argument("description", .fixed(code: "Text(\"右上の + で足せます\")"), on: true, summary: "見出しの下の説明"),
        ],
        code: CodeTemplate(call: "ContentUnavailableView"),
        build: { v in
            AnyView(
                ContentUnavailableView(
                    v.text("title") ?? "",
                    systemImage: v.pick("systemImage", from: ["tray", "magnifyingglass", "wifi.slash"]) ?? "tray",
                    description: v["description"] != nil ? Text("右上の + で足せます") : nil)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .picker,
        .datePicker,
        .multiDatePicker,
        .colorPicker,
        .gauge,
        .progressView,
        .contentUnavailableView,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py controls-and-indicators`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`controls-and-indicators` の行が `15 / 17`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ControlsAndIndicators/PickerEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/DatePickerEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/MultiDatePickerEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ColorPickerEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/GaugeEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ProgressViewEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ContentUnavailableViewEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: Picker・DatePicker・MultiDatePicker・ColorPicker・Gauge・ProgressView・ContentUnavailableView を収録する"
```

---

### Task 3: 操作の部品 3 とメニュー（sensoryFeedback・controlSize・Menu・contextMenu・menuActionDismissBehavior・menuOrder）

**Files:**
- Create: `WidgetLab/Catalog/ControlsAndIndicators/SensoryFeedbackEntry.swift`
- Create: `WidgetLab/Catalog/ControlsAndIndicators/ControlSizeEntry.swift`
- Create: `WidgetLab/Catalog/MenusAndCommands/MenuEntry.swift`
- Create: `WidgetLab/Catalog/MenusAndCommands/ContextMenuEntry.swift`
- Create: `WidgetLab/Catalog/MenusAndCommands/MenuActionDismissBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/MenusAndCommands/MenuOrderEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.sensoryFeedback`、`CatalogEntry.controlSize`、`CatalogEntry.menu`、`CatalogEntry.contextMenu`、`CatalogEntry.menuActionDismissBehavior`、`CatalogEntry.menuOrder`

`MenusAndCommands/` は新しいフォルダ。Xcode のフォルダの同期で、project.pbxproj は変わらない。

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py controls-and-indicators menus-and-commands`
Expected: 終了コード 1。抜けに sensoryFeedback・controlSize・Menu・contextMenu・menuActionDismissBehavior・menuOrder がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ControlsAndIndicators/SensoryFeedbackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sensoryFeedback = CatalogEntry(
        id: "sensoryFeedback",
        kind: .modifier,
        topic: .controlsAndIndicators,
        summary: "trigger の値が変わるたびに、触覚（と音）のフィードバックを鳴らす modifier。実機で震える。シミュレータでは震えない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "sensoryFeedback",
                .choice(
                    [
                        Choice(".success"), Choice(".warning"), Choice(".error"), Choice(".increase"),
                        Choice(".selection"), Choice(".impact"),
                    ],
                    initial: 0),
                on: true, summary: "鳴らすフィードバックの種類"),
            .modifier(
                "sensoryFeedback", id: "sensoryFeedback.trigger", label: "trigger", .fixed(code: "count"),
                required: true, summary: "見張る値。変わるたびに鳴らす"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"+1\""], trailing: " { count += 1 }"),
        build: { v in
            AnyView(
                SensoryFeedbackDemo(
                    feedback: v.pick(
                        "sensoryFeedback",
                        from: [
                            (SensoryFeedback.success, ".success"), (.warning, ".warning"), (.error, ".error"),
                            (.increase, ".increase"), (.selection, ".selection"), (.impact, ".impact"),
                        ])))
        }
    )
}

private struct SensoryFeedbackDemo: View {
    /// 鳴らすフィードバックと、記録に出す名前。nil なら鳴らさない
    let feedback: (value: SensoryFeedback, name: String)?
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") {
                count += 1
                if let feedback {
                    recorder?.log("count を \(count) にした（\(feedback.name) を鳴らす）")
                } else {
                    recorder?.log("count を \(count) にした（鳴らさない）")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .apply(feedback) { $0.sensoryFeedback($1.value, trigger: count) }
            Text("count: \(count)")
                .monospacedDigit()
        }
    }
}
```

`WidgetLab/Catalog/ControlsAndIndicators/ControlSizeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let controlSize = CatalogEntry(
        id: "controlSize",
        kind: .modifier,
        topic: .controlsAndIndicators,
        summary: "中にあるコントロールの大きさを、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlsize(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "controlSize",
                .choice(
                    [Choice(".mini"), Choice(".small"), Choice(".regular"), Choice(".large"), Choice(".extraLarge")],
                    initial: 3),
                on: true, summary: "コントロールの大きさ")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Button(\"保存\") { }\n        .buttonStyle(.bordered)\n    ProgressView()\n}"),
        build: { v in
            AnyView(
                HStack {
                    Button("保存") {}
                        .buttonStyle(.bordered)
                    ProgressView()
                }
                .apply(v.pick("controlSize", from: [ControlSize.mini, .small, .regular, .large, .extraLarge])) {
                    $0.controlSize($1)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/MenusAndCommands/MenuEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let menu = CatalogEntry(
        id: "Menu",
        kind: .view,
        topic: .menusAndCommands,
        summary: "押すと、操作の一覧（メニュー）を出すコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/menu")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "並べ替え"), required: true, summary: "名前"),
            .modifier(
                "buttonStyle",
                .choice(
                    [Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".glass")],
                    initial: 1),
                on: true, summary: "押す部分の見た目。ボタンと同じスタイルが使える"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
        ],
        code: CodeTemplate(
            call: "Menu",
            trailing:
                " {\n    Button(\"名前\") { }\n    Button(\"日付\") { }\n    Button(\"削除\", role: .destructive) { }\n}"),
        build: { v in
            AnyView(
                Menu(v.text("title") ?? "") {
                    Button("名前") {}
                    Button("日付") {}
                    Button("削除", role: .destructive) {}
                }
                .apply(v.pick("buttonStyle", from: MenuDemo.Style.allCases)) { MenuDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum MenuDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, glass
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        case .glass: view.buttonStyle(.glass)
        }
    }
}
```

`WidgetLab/Catalog/MenusAndCommands/ContextMenuEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contextMenu = CatalogEntry(
        id: "contextMenu",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "長押しで出るメニューを、View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contextMenu", label: "menuItems",
                .choice(
                    [
                        Choice("コピー", code: "{ Button(\"コピー\", systemImage: \"doc.on.doc\") { } }"),
                        Choice("削除", code: "{ Button(\"削除\", systemImage: \"trash\", role: .destructive) { } }"),
                    ],
                    initial: 0),
                on: true, summary: "メニューの中身")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"長押しする\""]),
        build: { v in
            AnyView(
                Text("長押しする")
                    .padding()
                    .background(.yellow, in: .rect(cornerRadius: 12))
                    .apply(v.pick("contextMenu", from: [false, true])) { view, deletes in
                        view.contextMenu {
                            if deletes {
                                Button("削除", systemImage: "trash", role: .destructive) {}
                            } else {
                                Button("コピー", systemImage: "doc.on.doc") {}
                            }
                        }
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/MenusAndCommands/MenuActionDismissBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let menuActionDismissBehavior = CatalogEntry(
        id: "menuActionDismissBehavior",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "メニューの項目を押したあと、メニューを閉じるかどうかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuactiondismissbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuActionDismissBehavior",
                .choice([Choice(".automatic"), Choice(".enabled"), Choice(".disabled")], initial: 2), on: true,
                summary: "押したあとに閉じるか。.disabled なら開いたまま続けて押せる")
        ],
        code: CodeTemplate(
            prefix: ["Menu(\"数: \\(count)\") {"], call: "Button", fixedArguments: ["\"+1\""],
            trailing: " { count += 1 }", closing: ["}"]),
        build: { v in
            AnyView(
                MenuActionDismissBehaviorDemo(
                    behavior: v.pick(
                        "menuActionDismissBehavior", from: [MenuActionDismissBehavior.automatic, .enabled, .disabled])))
        }
    )
}

private struct MenuActionDismissBehaviorDemo: View {
    let behavior: MenuActionDismissBehavior?
    @State private var count = 0

    var body: some View {
        Menu("数: \(count)") {
            Button("+1") { count += 1 }
                .apply(behavior) { $0.menuActionDismissBehavior($1) }
        }
        .buttonStyle(.bordered)
        .monospacedDigit()
    }
}
```

`WidgetLab/Catalog/MenusAndCommands/MenuOrderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let menuOrder = CatalogEntry(
        id: "menuOrder",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "メニューの項目を並べる順を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuorder(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuOrder", .choice([Choice(".automatic"), Choice(".priority"), Choice(".fixed")], initial: 2),
                on: true, summary: "並べる順。.priority は先頭の項目を押した場所の近くに、.fixed は書いた順のまま上から並べる")
        ],
        code: CodeTemplate(
            call: "Menu", fixedArguments: ["\"並び\""],
            trailing: " {\n    Button(\"1 番目\") { }\n    Button(\"2 番目\") { }\n    Button(\"3 番目\") { }\n}"),
        build: { v in
            AnyView(
                Menu("並び") {
                    Button("1 番目") {}
                    Button("2 番目") {}
                    Button("3 番目") {}
                }
                .buttonStyle(.bordered)
                .apply(v.pick("menuOrder", from: [MenuOrder.automatic, .priority, .fixed])) { $0.menuOrder($1) }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .sensoryFeedback,
        .controlSize,
        .menu,
        .contextMenu,
        .menuActionDismissBehavior,
        .menuOrder,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py controls-and-indicators`
Expected: 終了コード 0。`controls-and-indicators` の行が `17 / 17`

Run: `python3 tools/catalog_progress.py menus-and-commands`
Expected: 終了コード 0。`menus-and-commands` の行が `4 / 4`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ControlsAndIndicators/SensoryFeedbackEntry.swift \
  WidgetLab/Catalog/ControlsAndIndicators/ControlSizeEntry.swift \
  WidgetLab/Catalog/MenusAndCommands/MenuEntry.swift \
  WidgetLab/Catalog/MenusAndCommands/ContextMenuEntry.swift \
  WidgetLab/Catalog/MenusAndCommands/MenuActionDismissBehaviorEntry.swift \
  WidgetLab/Catalog/MenusAndCommands/MenuOrderEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: sensoryFeedback・controlSize・Menu・contextMenu・menuActionDismissBehavior・menuOrder を収録する"
```

---

### Task 4: View の基本（modifier・onAppear・onDisappear・task・id・tag・equatable）

**Files:**
- Create: `WidgetLab/Catalog/ViewFundamentals/ModifierEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/OnAppearEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/OnDisappearEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/TaskEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/IdEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/TagEntry.swift`
- Create: `WidgetLab/Catalog/ViewFundamentals/EquatableEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.modifier`、`CatalogEntry.onAppear`、`CatalogEntry.onDisappear`、`CatalogEntry.task`、`CatalogEntry.id`、`CatalogEntry.tag`、`CatalogEntry.equatable`

`ViewFundamentals/` は新しいフォルダ。`static let id`・`static let task` などは `CatalogEntry` のインスタンスのプロパティ `id` と名前が同じだが、static なので重ならない（試作でビルドとテストを通した）。

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-fundamentals`
Expected: 終了コード 1。抜けに modifier・onAppear・onDisappear・task・id・tag・equatable がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ViewFundamentals/ModifierEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let modifier = CatalogEntry(
        id: "modifier",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "自分で作った ViewModifier を View にかける modifier。いくつもの modifier の組を、名前を付けて使い回せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/modifier(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "modifier",
                .choice(
                    [Choice("Card()"), Choice("Card(color: .mint)"), Choice("EmptyModifier()")], initial: 0),
                on: true, summary: "かける ViewModifier。EmptyModifier は何もしない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"見本\""],
            closing: [
                "",
                "struct Card: ViewModifier {",
                "    var color: Color = .yellow",
                "",
                "    func body(content: Content) -> some View {",
                "        content",
                "            .padding()",
                "            .background(color, in: .rect(cornerRadius: 12))",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                Text("見本")
                    .apply(v.pick("modifier", from: [Color?.some(.yellow), .some(.mint), .none])) { view, color in
                        if let color {
                            view.modifier(ModifierDemoCard(color: color))
                        } else {
                            view.modifier(EmptyModifier())
                        }
                    }
            )
        }
    )
}

private struct ModifierDemoCard: ViewModifier {
    var color: Color = .yellow

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color, in: .rect(cornerRadius: 12))
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/OnAppearEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onAppear = CatalogEntry(
        id: "onAppear",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が画面に現れる前に、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onappear(perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onAppear", label: "perform", .fixed(code: "{ print(\"子が現れた\") }"), on: true,
                summary: "現れるときの処理。トグルで子を出すたびに記録に出る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Toggle(\"子を出す\", isOn: $shows)", "    if shows {"], indent: 8, call: "Text",
            fixedArguments: ["\"子\""], closing: ["    }", "}"]),
        build: { v in
            AnyView(OnAppearDemo(watches: v["onAppear"] != nil))
        }
    )
}

private struct OnAppearDemo: View {
    let watches: Bool
    @State private var shows = true
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 12) {
            Toggle("子を出す", isOn: $shows)
                .fixedSize()
            if shows {
                Text("子")
                    .padding(8)
                    .background(.yellow)
                    .apply(watches ? () : nil) { view, _ in
                        view.onAppear { recorder?.log("子が現れた") }
                    }
            }
        }
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/OnDisappearEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onDisappear = CatalogEntry(
        id: "onDisappear",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が画面から消えたあとに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondisappear(perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onDisappear", label: "perform", .fixed(code: "{ print(\"子が消えた\") }"), on: true,
                summary: "消えたときの処理。トグルで子を消すたびに記録に出る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Toggle(\"子を出す\", isOn: $shows)", "    if shows {"], indent: 8, call: "Text",
            fixedArguments: ["\"子\""], closing: ["    }", "}"]),
        build: { v in
            AnyView(OnDisappearDemo(watches: v["onDisappear"] != nil))
        }
    )
}

private struct OnDisappearDemo: View {
    let watches: Bool
    @State private var shows = true
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 12) {
            Toggle("子を出す", isOn: $shows)
                .fixedSize()
            if shows {
                Text("子")
                    .padding(8)
                    .background(.yellow)
                    .apply(watches ? () : nil) { view, _ in
                        view.onDisappear { recorder?.log("子が消えた") }
                    }
            }
        }
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/TaskEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let task = CatalogEntry(
        id: "task",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が現れる前に、非同期の処理を始める modifier。View が消えると取り消す。id を渡すと、値が変わるたびに取り消してやり直す。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/task(id:name:priority:file:line:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "task",
                .choice(
                    [
                        Choice("現れたときだけ", code: "{ await load(count) }"),
                        Choice("count が変わるたび", code: "id: count, { await load(count) }"),
                    ],
                    initial: 1),
                on: true, summary: "始める処理と、やり直すきっかけ。load は 1 秒待って終わる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Text",
            fixedArguments: ["\"count: \\(count)\""], closing: ["}"]),
        build: { v in
            AnyView(TaskDemo(followsCount: v.pick("task", from: [false, true])))
        }
    )
}

private struct TaskDemo: View {
    /// nil なら task をかけない。true なら count が変わるたびにやり直す
    let followsCount: Bool?
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
                .controlSize(.large)
            label
        }
    }

    @ViewBuilder
    private var label: some View {
        let text = Text("count: \(count)").monospacedDigit()
        switch followsCount {
        case nil: text
        case false?: text.task { await load(count) }
        case true?: text.task(id: count) { await load(count) }
        }
    }

    private func load(_ count: Int) async {
        recorder?.log("count \(count) の読み込みを始めた")
        do {
            try await Task.sleep(for: .seconds(1))
            recorder?.log("count \(count) の読み込みが終わった")
        } catch {
            recorder?.log("count \(count) の読み込みを取り消した")
        }
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/IdEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let id = CatalogEntry(
        id: "id",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View の見分けの印（識別子）を決める modifier。値が変わると別の View とみなされ、中の @State も作り直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/id(_:)")!,
        stage: .behavior,
        properties: [
            .modifier("id", .fixed(code: "generation"), on: true, summary: "見分けの印。「作り直す」で値を変えると、子の count が 0 に戻る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"作り直す\") { generation += 1 }"], call: "Counter",
            closing: [
                "}",
                "",
                "struct Counter: View {",
                "    @State private var count = 0",
                "",
                "    var body: some View {",
                "        Stepper(\"count: \\(count)\", value: $count)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(IdDemo.Parent(usesID: v["id"] != nil))
        }
    )
}

private enum IdDemo {
    struct Parent: View {
        let usesID: Bool
        @State private var generation = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button("作り直す") {
                    generation += 1
                    recorder?.log("generation を \(generation) にした")
                }
                .buttonStyle(.bordered)
                Counter()
                    .apply(usesID ? generation : nil) { $0.id($1) }
            }
        }
    }

    struct Counter: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            Stepper(value: $count) {
                Text("count: \(count)").monospacedDigit()
            }
            .fixedSize()
            .onAppear { recorder?.log("子を作った（count は 0 から）") }
        }
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/TagEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tag = CatalogEntry(
        id: "tag",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "Picker や TabView の選択肢に、見分けるための値を付ける modifier。選んだ値と同じ型の値を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tag(_:includeoptional:)")!,
        stage: .card,
        properties: [
            .modifier(
                "tag",
                .choice(
                    [
                        Choice("\"みかん\""),
                        Choice("includeOptional: false", code: "\"みかん\", includeOptional: false"),
                    ],
                    initial: 0),
                on: true,
                summary: "「みかん」の値。付けないか、includeOptional を false にすると、Optional の selection と合わず選べない")
        ],
        code: CodeTemplate(
            prefix: ["Picker(\"果物\", selection: $fruit) {  // fruit は String?", "    Text(\"りんご\").tag(\"りんご\")"],
            call: "Text", fixedArguments: ["\"みかん\""], closing: ["}", ".pickerStyle(.segmented)"]),
        build: { v in
            AnyView(TagDemo(includesOptional: v.pick("tag", from: [true, false])))
        }
    )
}

private struct TagDemo: View {
    /// nil なら「みかん」に tag を付けない
    let includesOptional: Bool?
    @State private var fruit: String? = "りんご"

    var body: some View {
        VStack(spacing: 12) {
            Picker("果物", selection: $fruit) {
                Text("りんご").tag("りんご")
                Text("みかん")
                    .apply(includesOptional) { $0.tag("みかん", includeOptional: $1) }
            }
            .pickerStyle(.segmented)
            Text("選んだ: \(fruit ?? "なし")")
                .font(.caption)
        }
        .frame(width: 240)
    }
}
```

`WidgetLab/Catalog/ViewFundamentals/EquatableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let equatable = CatalogEntry(
        id: "equatable",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View を == で前の値と比べ、同じなら中を描き直さないようにする modifier。View が Equatable に準拠しているときに使える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/equatable()")!,
        stage: .behavior,
        properties: [
            .modifier("equatable", .fixed(code: ""), on: true, summary: "付けると、子の == が true の間（5 ごとに切り替わるまで）、子を描き直さない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Child",
            fixedArguments: ["count: count"],
            closing: [
                "}",
                "",
                "struct Child: View, Equatable {",
                "    let count: Int",
                "",
                "    // 5 ごとにだけ違うとみなす",
                "    static func == (a: Self, b: Self) -> Bool { a.count / 5 == b.count / 5 }",
                "",
                "    var body: some View {",
                "        Text(\"\\(count / 5 * 5) 台\")",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(EquatableDemo.Parent(usesEquatable: v["equatable"] != nil))
        }
    )
}

private enum EquatableDemo {
    struct Parent: View {
        let usesEquatable: Bool
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button("+1") {
                    count += 1
                    recorder?.log("count を \(count) にした")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                if usesEquatable {
                    Child(count: count).equatable()
                } else {
                    Child(count: count)
                }
            }
        }
    }

    struct Child: View, Equatable {
        let count: Int
        @Environment(\.demoRecorder) private var recorder

        nonisolated static func == (a: Self, b: Self) -> Bool { a.count / 5 == b.count / 5 }

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("\(count / 5 * 5) 台")
                .monospacedDigit()
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .modifier,
        .onAppear,
        .onDisappear,
        .task,
        .id,
        .tag,
        .equatable,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py view-fundamentals`
Expected: 終了コード 0。`view-fundamentals` の行が `7 / 7`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ViewFundamentals/ModifierEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/OnAppearEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/OnDisappearEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/TaskEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/IdEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/TagEntry.swift \
  WidgetLab/Catalog/ViewFundamentals/EquatableEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: modifier・onAppear・onDisappear・task・id・tag・equatable を収録する"
```

---

### Task 5: View の設定 1（opacity・hidden・labelsHidden・labelsVisibility・menuIndicator・persistentSystemOverlays・statusBarHidden・disabled）

**Files:**
- Create: `WidgetLab/Catalog/ViewConfiguration/OpacityEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/HiddenEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/LabelsHiddenEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/LabelsVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/MenuIndicatorEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/PersistentSystemOverlaysEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/StatusBarHiddenEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/DisabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.opacity`、`CatalogEntry.hidden`、`CatalogEntry.labelsHidden`、`CatalogEntry.labelsVisibility`、`CatalogEntry.menuIndicator`、`CatalogEntry.persistentSystemOverlays`、`CatalogEntry.statusBarHidden`、`CatalogEntry.disabled`

`ViewConfiguration/` は新しいフォルダ。`persistentSystemOverlays`・`statusBarHidden` の stage は `.full`（表の「`.full` にするもの」）。

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-configuration`
Expected: 終了コード 1。抜けに opacity・hidden・labelsHidden・labelsVisibility・menuIndicator・persistentSystemOverlays・statusBarHidden・disabled がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ViewConfiguration/OpacityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let opacity = CatalogEntry(
        id: "opacity",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View の不透明度を決める modifier。0 で見えなくなるが、場所は取ったまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/opacity(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "opacity", .slider(range: 0...1, step: 0.1, initial: 0.3), on: true, summary: "不透明度（0 で透明、1 でそのまま）")
        ],
        code: CodeTemplate(call: "Image", fixedArguments: ["systemName: \"star.fill\""]),
        build: { v in
            AnyView(
                Image(systemName: "star.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
                    .apply(v.number("opacity")) { $0.opacity($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/HiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let hidden = CatalogEntry(
        id: "hidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View を隠す modifier。見えなくなるが、場所は取ったまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hidden()")!,
        stage: .card,
        properties: [
            .modifier("hidden", .fixed(code: ""), on: true, summary: "隠す。左右の文字の間は空いたまま")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左\")"], call: "Text", fixedArguments: ["\"真ん中\""],
            closing: ["    Text(\"右\")", "}"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左")
                    Text("真ん中")
                        .apply(v["hidden"] != nil ? () : nil) { view, _ in view.hidden() }
                    Text("右")
                }
                .padding(8)
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/LabelsHiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let labelsHidden = CatalogEntry(
        id: "labelsHidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にあるコントロールの名前（ラベル）を隠す modifier。名前は読み上げには残る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelshidden()")!,
        stage: .card,
        properties: [
            .modifier("labelsHidden", .fixed(code: ""), on: true, summary: "名前を隠す。中のコントロールすべてに効く")
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Toggle(\"通知\", isOn: $isOn)\n    Stepper(\"数\", value: $count)\n}"),
        build: { v in
            AnyView(LabelsHiddenDemo(hidesLabels: v["labelsHidden"] != nil))
        }
    )
}

private struct LabelsHiddenDemo: View {
    let hidesLabels: Bool
    @State private var isOn = true
    @State private var count = 0

    var body: some View {
        VStack {
            Toggle("通知", isOn: $isOn)
            Stepper("数", value: $count)
        }
        .apply(hidesLabels ? () : nil) { view, _ in view.labelsHidden() }
        .frame(width: 240)
    }
}
```

`WidgetLab/Catalog/ViewConfiguration/LabelsVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let labelsVisibility = CatalogEntry(
        id: "labelsVisibility",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にあるコントロールの名前（ラベル）を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelsvisibility(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labelsVisibility", .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "名前の出し方。.hidden は labelsHidden() と同じ")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Toggle(\"通知\", isOn: $isOn)\n    Picker(\"果物\", selection: $fruit) {\n"
                + "        Text(\"りんご\").tag(\"りんご\")\n        Text(\"みかん\").tag(\"みかん\")\n    }\n}"),
        build: { v in
            AnyView(
                LabelsVisibilityDemo(
                    visibility: v.pick("labelsVisibility", from: [Visibility.automatic, .visible, .hidden])))
        }
    )
}

private struct LabelsVisibilityDemo: View {
    let visibility: Visibility?
    @State private var isOn = true
    @State private var fruit = "りんご"

    var body: some View {
        VStack {
            Toggle("通知", isOn: $isOn)
            Picker("果物", selection: $fruit) {
                Text("りんご").tag("りんご")
                Text("みかん").tag("みかん")
            }
        }
        .apply(visibility) { $0.labelsVisibility($1) }
        .frame(width: 240)
    }
}
```

`WidgetLab/Catalog/ViewConfiguration/MenuIndicatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let menuIndicator = CatalogEntry(
        id: "menuIndicator",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "メニューを開くコントロールに、開けることを示す印（山形の矢印）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuindicator(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuIndicator", .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "印の出し方。.hidden で、選んだ値の横の山形の矢印が消える")
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing: " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n}"),
        build: { v in
            AnyView(
                MenuIndicatorDemo(visibility: v.pick("menuIndicator", from: [Visibility.automatic, .visible, .hidden])))
        }
    )
}

private struct MenuIndicatorDemo: View {
    let visibility: Visibility?
    @State private var fruit = "りんご"

    var body: some View {
        Picker("果物", selection: $fruit) {
            Text("りんご").tag("りんご")
            Text("みかん").tag("みかん")
        }
        .apply(visibility) { $0.menuIndicator($1) }
    }
}
```

`WidgetLab/Catalog/ViewConfiguration/PersistentSystemOverlaysEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let persistentSystemOverlays = CatalogEntry(
        id: "persistentSystemOverlays",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面に出しっぱなしのシステムの表示（ホームに戻るためのバーなど）を、目立たなくするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/persistentsystemoverlays(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "persistentSystemOverlays",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2), on: true,
                summary: "出し方。.hidden にすると、しばらく触らないでいると画面のいちばん下のバーが消える")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面のいちばん下のバーを見る\""]),
        build: { v in
            AnyView(
                Text("画面のいちばん下のバーを見る")
                    .apply(v.pick("persistentSystemOverlays", from: [Visibility.automatic, .visible, .hidden])) {
                        $0.persistentSystemOverlays($1)
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/StatusBarHiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let statusBarHidden = CatalogEntry(
        id: "statusBarHidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面のいちばん上のステータスバー（時刻や電池の表示）を隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/statusbarhidden(_:)")!,
        stage: .full,
        properties: [
            .modifier("statusBarHidden", .toggle(initial: true), on: true, summary: "true でステータスバーを隠す。省くと true")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面のいちばん上の時刻を見る\""]),
        build: { v in
            AnyView(
                Text("画面のいちばん上の時刻を見る")
                    .apply(v.flag("statusBarHidden")) { $0.statusBarHidden($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/DisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let disabled = CatalogEntry(
        id: "disabled",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にある View を、触れなくする modifier。コントロールは薄い色になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/disabled(_:)")!,
        stage: .card,
        properties: [
            .modifier("disabled", .toggle(initial: true), on: true, summary: "true で触れなくする。中のコントロールすべてに効く")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Button(\"保存\") { }\n        .buttonStyle(.borderedProminent)\n    Toggle(\"通知\", isOn: $isOn)\n}"
        ),
        build: { v in
            AnyView(DisabledDemo(disabled: v.flag("disabled")))
        }
    )
}

private struct DisabledDemo: View {
    let disabled: Bool?
    @State private var isOn = true

    var body: some View {
        VStack {
            Button("保存") {}
                .buttonStyle(.borderedProminent)
            Toggle("通知", isOn: $isOn)
        }
        .apply(disabled) { $0.disabled($1) }
        .frame(width: 240)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .opacity,
        .hidden,
        .labelsHidden,
        .labelsVisibility,
        .menuIndicator,
        .persistentSystemOverlays,
        .statusBarHidden,
        .disabled,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py view-configuration`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`view-configuration` の行が `8 / 15`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ViewConfiguration/OpacityEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/HiddenEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/LabelsHiddenEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/LabelsVisibilityEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/MenuIndicatorEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/PersistentSystemOverlaysEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/StatusBarHiddenEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/DisabledEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: opacity・hidden・labelsHidden・labelsVisibility・menuIndicator・persistentSystemOverlays・statusBarHidden・disabled を収録する"
```

---

### Task 6: View の設定 2（interactionActivityTrackingTag・invalidatableContent・help・preferredColorScheme・privacySensitive・redacted・unredacted）と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/ViewConfiguration/InteractionActivityTrackingTagEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/InvalidatableContentEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/HelpEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/PreferredColorSchemeEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/PrivacySensitiveEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/RedactedEntry.swift`
- Create: `WidgetLab/Catalog/ViewConfiguration/UnredactedEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（試作でわかったこと）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.interactionActivityTrackingTag`、`CatalogEntry.invalidatableContent`、`CatalogEntry.help`、`CatalogEntry.preferredColorScheme`、`CatalogEntry.privacySensitive`、`CatalogEntry.redacted`、`CatalogEntry.unredacted`

`.note` の 3 件（interactionActivityTrackingTag・invalidatableContent・help）は `build` を書かない初期化（`noteReason:`）を使う。`preferredColorScheme` の stage は `.full`。

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-configuration`
Expected: 終了コード 1。抜けに interactionActivityTrackingTag・invalidatableContent・help・preferredColorScheme・privacySensitive・redacted・unredacted がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ViewConfiguration/InteractionActivityTrackingTagEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let interactionActivityTrackingTag = CatalogEntry(
        id: "interactionActivityTrackingTag",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "操作の速さを測るときに、どの View への操作かを見分ける名前（タグ）を付ける modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/interactionactivitytrackingtag(_:)")!,
        noteReason: "操作の速さの記録（Instruments など）に名前を付けるもので、画面の見た目は変わらない",
        properties: [
            .modifier("interactionActivityTrackingTag", .text(initial: "保存ボタン"), on: true, summary: "記録に付ける名前")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/InvalidatableContentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let invalidatableContent = CatalogEntry(
        id: "invalidatableContent",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中身が古くなるかもしれない View に印を付ける modifier。ウィジェットのボタンの処理を待つ間、印の付いた View を薄く見せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/invalidatablecontent(_:)")!,
        noteReason: "ウィジェットとライブアクティビティの中で、ボタンの処理を待つ間に効く",
        properties: [
            .modifier("invalidatableContent", .toggle(initial: true), on: true, summary: "true で印を付ける。省くと true")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"気温 18℃\""])
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/HelpEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let help = CatalogEntry(
        id: "help",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View に、操作の手助けになる短い説明を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/help(_:)")!,
        noteReason: "iPhone では見た目が変わらない。iPad と Mac で、ポインタを重ねたときに説明が出る",
        properties: [
            .modifier("help", .text(initial: "書いた内容を保存する"), on: true, summary: "説明の文")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/PreferredColorSchemeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let preferredColorScheme = CatalogEntry(
        id: "preferredColorScheme",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面（表示中の画面のまとまり）を、ライトとダークのどちらの見た目で出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "preferredColorScheme", .choice([Choice(".light"), Choice(".dark")], initial: 1), on: true,
                summary: "見た目。この画面ぜんたいが切り替わり、前の画面に戻ると元に戻る")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面ぜんたいが切り替わる\""]),
        build: { v in
            AnyView(
                Text("画面ぜんたいが切り替わる")
                    .apply(v.pick("preferredColorScheme", from: [ColorScheme.light, .dark])) {
                        $0.preferredColorScheme($1)
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/PrivacySensitiveEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let privacySensitive = CatalogEntry(
        id: "privacySensitive",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "人に見せたくない情報の View に印を付ける modifier。redacted(reason: .privacy) のとき（ロック画面のウィジェットなど）に伏せられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/privacysensitive(_:)")!,
        stage: .card,
        properties: [
            .modifier("privacySensitive", .toggle(initial: true), on: true, summary: "true で印を付ける。省くと true")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"口座番号\")"], call: "Text", fixedArguments: ["\"1234-5678\""],
            closing: ["}", ".redacted(reason: .privacy)"]),
        build: { v in
            AnyView(
                VStack {
                    Text("口座番号")
                    Text("1234-5678")
                        .apply(v.flag("privacySensitive")) { $0.privacySensitive($1) }
                }
                .redacted(reason: .privacy)
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/RedactedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let redacted = CatalogEntry(
        id: "redacted",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にある View を伏せて見せる modifier。読み込み中の仮の表示などに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)")!,
        stage: .card,
        properties: [
            .modifier(
                "redacted", label: "reason",
                .choice([Choice(".placeholder"), Choice(".invalidated")], initial: 0), on: true,
                summary: "伏せる理由。.placeholder は文字と画像を灰色の形に、.invalidated は中身を薄くする。.privacy は privacySensitive の収録で見る")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Image(systemName: \"person.crop.circle\")\n    Text(\"山田 花子\")\n    Text(\"1234-5678\")\n}"),
        build: { v in
            AnyView(
                VStack {
                    Image(systemName: "person.crop.circle")
                        .font(.largeTitle)
                    Text("山田 花子")
                    Text("1234-5678")
                }
                .apply(v.pick("redacted", from: [RedactionReasons.placeholder, .invalidated])) {
                    $0.redacted(reason: $1)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewConfiguration/UnredactedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let unredacted = CatalogEntry(
        id: "unredacted",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "外側の redacted で伏せられていても、この View だけは伏せずに見せる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/unredacted()")!,
        stage: .card,
        properties: [
            .modifier("unredacted", .fixed(code: ""), on: true, summary: "伏せずに見せる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"山田 花子\")"], call: "Text", fixedArguments: ["\"読み込み済み\""],
            closing: ["}", ".redacted(reason: .placeholder)"]),
        build: { v in
            AnyView(
                VStack {
                    Text("山田 花子")
                    Text("読み込み済み")
                        .apply(v["unredacted"] != nil ? () : nil) { view, _ in view.unredacted() }
                }
                .redacted(reason: .placeholder)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .interactionActivityTrackingTag,
        .invalidatableContent,
        .help,
        .preferredColorScheme,
        .privacySensitive,
        .redacted,
        .unredacted,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `testLayoutEntriesShowPreview` のあと（`/// 起動して、検索の結果から詳細を開く` の前）に足す。UIKit で描くコントロール（`ImageRenderer` では描けない）と、ScrollView に入れた見本の代表を 1 件ずつ撮る:

```swift
    @MainActor
    func testControlEntriesShowPreview() {
        for (id, title) in [("Picker", "Picker"), ("MultiDatePicker", "MultiDatePicker")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行を、次の 1 行に置き換える:

```
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピー、詳細で比べるを開いて左右が出ること、`@State` を比べて付けた側だけ表示が変わること、レイアウトの代表 2 件と操作の部品の代表 2 件のスクリーンショットの 5 本）
```

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 5 か所だけ直す（ほかの行は変えない）。

1. 3 章の `**`.full` はまだ動かない（2026-11-03 時点）。**` の段落の最後の文「最初に `.full` を使う束（束 7 の画面の行き来が候補）で、その仕組みも作る。」を、次に置き換える:

```markdown
仕組みは束 7（画面の行き来）で作る。束 3 では、表示の単位（presentation）ぜんたいに効く modifier（`preferredColorScheme`・`statusBarHidden`・`persistentSystemOverlays`）を、仕組みより先に `.full` にした（2026-11-03 オーナーが決定）。`.card` にすると一覧の行の見本からも効いてしまい（行が見えただけでアプリ全体が暗くなる）、押し込んだ詳細画面からではステータスバーが消えないため。
```

2. 5 章の「ただし `ImageRenderer` は、ScrollView・List・Form・GroupBox・ControlGroup を白く描く。」を、次に置き換える:

```markdown
ただし `ImageRenderer` は、ScrollView・List・Form・GroupBox・ControlGroup を白く描き、UIKit で描くコントロール（Toggle・Slider・Stepper・Picker・DatePicker・ColorPicker・Menu など）を黄色の地に禁止の印で描く。
```

3. 同じ段落の「（束 1 は `testLayoutEntriesShowPreview`）。」を「（束 1 は `testLayoutEntriesShowPreview`、束 3 は `testControlEntriesShowPreview`）。」に置き換える

4. 7 章の `**一覧の行の見本が崩れていないか気になる → トピック画面を撮る。**` の段落のあと（`## 用語` の前）に、空行を挟んで 3 つの段落を足す:

```markdown
**高いコントロールで一覧の行が伸びる → 見本を ScrollView に入れる。** `MultiDatePicker` のカレンダーは、行の見本の枠に収まらず、行が高くなって押す場所がずれた。見本を `ScrollView` に入れると、行にも詳細のプレビューにも収まる。スタイルで高さが変わるもの（`DatePicker` の `.graphical`）は、`ViewThatFits(in: .vertical) { 見本; ScrollView { 見本 } }` で、収まらないときだけスクロールにする。

**画面ぜんたいに効く modifier がある → `.full` にする。** `.card` の見本は一覧の行でも組み立てるので、表示の単位に効くもの（`preferredColorScheme` など）は、行が見えただけで効いてしまう（3 章）。

**クロージャを渡す modifier を付け外ししたい → ラベル付きの引数にクロージャごと書く。** `CodeGenerator` は modifier を末尾のクロージャの形では書けないので、`.onAppear(perform: { … })`・`.contextMenu(menuItems: { … })` の形にする。`task` のように、引数の組でやり直すきっかけが変わるものは、`Choice("count が変わるたび", code: "id: count, { await load(count) }")` のように組で選ぶ。

**テストが何分も進まない → 最初のビルドとシミュレータの複製を待つ。** 試作では 5〜10 分かかったが、テストそのものは数秒だった。本当に止まったときは `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。
```

5. 最後の行「最終更新: 2026-11-03（束 1 のあと）」を「最終更新: 2026-11-03（束 3 のあと）」に置き換える

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テスト 5 本が全部通る

Run: `python3 tools/catalog_progress.py controls-and-indicators menus-and-commands view-fundamentals view-configuration`
Expected: 終了コード 0。`合計 43 / 43（抜け 0）`

- [ ] **Step 7: スクリーンショットを見る**

Run: `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `Picker` の画像で、りんご・みかん・ぶどうの区切られたボタン（.segmented）が出ている。`MultiDatePicker` の画像で、今月のカレンダーが出て、今日より前の日が薄い（どちらも `ImageRenderer` では描けないので、ここで見る）

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/ViewConfiguration/InteractionActivityTrackingTagEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/InvalidatableContentEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/HelpEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/PreferredColorSchemeEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/PrivacySensitiveEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/RedactedEntry.swift \
  WidgetLab/Catalog/ViewConfiguration/UnredactedEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  docs/architecture.md \
  docs/cataloging-guide.md
git commit -m "feat: interactionActivityTrackingTag・invalidatableContent・help・preferredColorScheme・privacySensitive・redacted・unredacted を収録する"
```

---

## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、`~/dev/widget-lab`（main）で `--no-ff` でマージする。マージの前に `git -C ~/dev/widget-lab status` がきれいなことと、ほかの束がマージの途中でないことを確かめる。`Catalog.swift` がぶつかったら両方の行を残す（`cataloging-guide.md` がぶつかったら、両方の束の追記を残す）
- マージのあとで main の lint と単体テストを流し、通ってから push する。ブランチは消さない
