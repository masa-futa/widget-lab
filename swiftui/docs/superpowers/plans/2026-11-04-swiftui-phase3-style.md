# SwiftUI 版 Phase 3 束 5（スタイルと動き）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** view-styles・images・animations の 40 件を収録し、3 トピックの抜けを 0 にする。

**Architecture:** 1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/<トピック>/<名前>Entry.swift`）を、Task 1〜6 で 6〜8 件ずつ足し、`Catalog.all` に並べる。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。複数の収録で使う補助（`MatchedGeometryDemo`・`ZoomTransitionDemo`）と、AsyncImage が読む画像を書き出す `AsyncImageDemo` はトピックのフォルダに置く。38 件が `.card`、2 件（`textEditorStyle`・`tableStyle`）が `.note`。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / AuthenticationServices（`SignInWithAppleButton` の 1 件）/ Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 5 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- **シミュレータは iPhone 17（iOS 27.0）を使う**（束 6・7 と並列で動いている。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` をそのまま使う）
- **`WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない。** 変えたくなったら、変える前に止まってオーナーに聞く（ほかの束とぶつかるため）
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）
- 収録のファイルは、この計画に書いたコードをそのまま写す（試作でテストと画像を通したもの）。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける
- 試作は `/private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-p3-style/cf019d16-e1be-4ae8-aa40-ae650768388f/scratchpad/proto/swiftui`（以下「試作」）にある。コントローラーは各タスクのあと、写したファイルを試作と `cmp` で比べる（`Catalog.swift` と `LaunchUITests.swift` は最後のタスクのあとに比べる）
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests > build/test.log 2>&1
  ```
  UI テストまで通すのは Task 6 だけ（`-only-testing:WidgetLabTests` を外す）。結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `xcrun simctl shutdown all` と `pkill -f "xcodebuild test"` は**使わない**（ほかの束のシミュレータとテストも止まる）。自分の xcodebuild を止め、`xcrun simctl shutdown "iPhone 17"` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。* は最初から ON、R は required。view-styles の modifier は、どれも引数を省けない（`.toggleStyle()` と書けない）ので「付け外し」にし、スタイルを受ける View を 2 つ並べられるものは並べる（この View の中のものにまとめてかかることを見せるため）。

| id | トピック | 形 | プロパティ（チップの順） | コードの形（最初の値） |
|---|---|---|---|---|
| GlassEffectContainer | view-styles | View | spacing* | `GlassEffectContainer(spacing: 40) { HStack(spacing: 20) { Image(…).frame(…).glassEffect() ×2 } }` |
| buttonStyle | view-styles | 付け外し | .buttonStyle*（7 つ）・.buttonBorderShape・.controlSize・.tint | `VStack { Button("保存") { }; Button("削除", role: .destructive) { } }.buttonStyle(.borderedProminent)` |
| signInWithAppleButtonStyle | view-styles | 付け外し | .signInWithAppleButtonStyle*（.black・.white・.whiteOutline） | `// import AuthenticationServices が要る` + `SignInWithAppleButton(.signIn) { … } onCompletion: { … }.signInWithAppleButtonStyle(.black).frame(width: 260, height: 48)` |
| buttonSizing | view-styles | 付け外し | .buttonSizing*（.automatic・.fitted・.flexible） | `HStack { Button("戻る"); Button("次へ") }.buttonSizing(.flexible).buttonStyle(.borderedProminent).frame(width: 300)` |
| pickerStyle | view-styles | 付け外し | .pickerStyle*（6 つ）・.tint | `Picker("果物", selection: $fruit) { … }.pickerStyle(.segmented)` |
| datePickerStyle | view-styles | 付け外し | .datePickerStyle*（4 つ）・.tint | `DatePicker("日付", selection: $date, displayedComponents: .date).datePickerStyle(.graphical)` |
| menuStyle | view-styles | 付け外し | .menuStyle*（.automatic・.button・.borderlessButton）・.buttonStyle | `Menu("並べ替え") { … }.menuStyle(.borderlessButton)` |
| toggleStyle | view-styles | 付け外し | .toggleStyle*・.tint | `VStack { Toggle("通知"…); Toggle("音"…) }.toggleStyle(.button)` |
| gaugeStyle | view-styles | 付け外し | .gaugeStyle*（6 つ）・.tint | `Gauge(value: 0.6) { Text("電池") } currentValueLabel: { Text("60") }.gaugeStyle(.accessoryCircularCapacity)` |
| progressViewStyle | view-styles | 付け外し | .progressViewStyle*・.tint | `VStack { ProgressView(value: 0.4); ProgressView() }.progressViewStyle(.linear)` |
| labelStyle | view-styles | 付け外し | .labelStyle*（4 つ）・.foregroundStyle | `VStack(alignment: .leading) { Label ×2 }.labelStyle(.iconOnly).font(.title2)` |
| textFieldStyle | view-styles | 付け外し | .textFieldStyle*（.automatic・.plain・.bordered） | `VStack { TextField("名前"…); TextField("メール"…) }.textFieldStyle(.bordered)` |
| textEditorStyle | view-styles | 付け外し・**.note** | .textEditorStyle*（.automatic・.plain） | `TextEditor(text: $memo).textEditorStyle(.plain).frame(width: 260, height: 100)` |
| listStyle | view-styles | 付け外し | .listStyle*（6 つ） | `List { Section("果物") { … } }.listStyle(.plain).frame(height: 160)` |
| tableStyle | view-styles | 付け外し・**.note** | .tableStyle*（.automatic・.inset） | `Table(fruits) { TableColumn ×2 }.tableStyle(.inset).frame(height: 160)` |
| disclosureGroupStyle | view-styles | 付け外し | .disclosureGroupStyle*（.automatic・自作） | `DisclosureGroup("詳細", isExpanded: $isExpanded) { … }.disclosureGroupStyle(PlusDisclosureGroupStyle())` + struct の定義 |
| controlGroupStyle | view-styles | 付け外し | .controlGroupStyle*（5 つ） | `ControlGroup { 戻る・進む } label: { Label("移動"…) }.controlGroupStyle(.navigation)` |
| formStyle | view-styles | 付け外し | .formStyle*（3 つ） | `Form { Toggle; LabeledContent }.formStyle(.columns).frame(height: 200)` |
| groupBoxStyle | view-styles | 付け外し | .groupBoxStyle*（.automatic・自作） | `GroupBox("設定") { … }.groupBoxStyle(TintedGroupBoxStyle())` + struct の定義 |
| indexViewStyle | view-styles | 付け外し | .indexViewStyle*（.page と backgroundDisplayMode 3 つ） | `TabView { 3 色 }.indexViewStyle(.page(backgroundDisplayMode: .always)).tabViewStyle(.page).frame(…)` |
| labeledContentStyle | view-styles | 付け外し | .labeledContentStyle*（.automatic・自作） | `VStack { LabeledContent ×2 }.labeledContentStyle(StackedLabeledContentStyle())` + struct の定義 |
| Image | images | View | systemName R・variableValue*・.resizable*・.scaledToFit*・.foregroundStyle | `Image(systemName: "wifi", variableValue: 0.5).resizable().scaledToFit().frame(width: 120, height: 120)` |
| imageScale | images | 付け外し | .imageScale*・.font* | `HStack { Image(systemName: "star.fill"); Text("お気に入り") }.imageScale(.large).font(.title)` |
| AsyncImage | images | View | url R（読める・読めない）・scale* | `AsyncImage(url: URL(string: "https://example.com/photo.png"), scale: 2) { phase in 成功・失敗・読み込み中 }` |
| symbolVariant | images | 付け外し | .symbolVariant*（6 つ）・.foregroundStyle | `HStack { heart・bell・person }.symbolVariant(.fill).font(.largeTitle)` |
| symbolEffect | images | 付け外し | 動き R（6 つ。options か isActive が ON のときだけ書く）・options・isActive* | `Image(systemName: "speaker.wave.3.fill").font(…).foregroundStyle(.blue).symbolEffect(.variableColor.iterative, isActive: true)` |
| symbolEffectsRemoved | images | 付け外し（入れ子、indent 8） | .symbolEffectsRemoved*（true） | `HStack { bell; star.foregroundStyle(.orange).symbolEffectsRemoved(true) }.font(…).symbolEffect(.pulse)` |
| symbolRenderingMode | images | 付け外し | .symbolRenderingMode*（4 つ）・.foregroundStyle*（1 色・3 色） | `Image(systemName: "cloud.sun.rain.fill").symbolRenderingMode(.palette).foregroundStyle(.blue, .yellow, .gray).font(…)` |
| animation | animations | 付け外し（入れ子、indent 8） | .animation*（6 つ）・value R | `VStack { Circle()….offset(x: moved ? 80 : -80).animation(.spring(duration: 1, bounce: 0.5), value: moved); Button("動かす") }` |
| PhaseAnimator | animations | View（入れ子） | phases R（2 段・3 段）・trigger | `PhaseAnimator([1.0, 1.4]) { scale in ハート } animation: { _ in .bouncy }` + `Button("+1")` |
| KeyframeAnimator | animations | View（入れ子） | initialValue R・trigger R（`trigger: count`・`repeating: true`） | `KeyframeAnimator(initialValue: 1.0, trigger: count) { scale in 星 } keyframes: { _ in KeyframeTrack { … } }` + `Button("+1")` |
| TimelineView | animations | View | schedule R（4 つ） | `TimelineView(.periodic(from: .now, by: 1)) { context in 時刻と秒針 }` |
| transition | animations | 付け外し（入れ子、indent 12） | .transition*（6 つ） | `VStack { Button("出し入れ"); if isShown { Text("見本").padding().background(.yellow).transition(.slide) } }` |
| contentTransition | animations | 付け外し（入れ子、indent 8） | .contentTransition*（5 つ） | `VStack { Text("\(count)").font(…).contentTransition(.numericText()); Button("+1") }` |
| transaction | animations | 付け外し（入れ子、indent 8） | .transaction*（動きを消す・ゆっくり・跳ねる） | `VStack { 青い円; 橙の円….transaction({ $0.animation = .linear(duration: 2) }); Button("動かす") }` |
| matchedGeometryEffect | animations | 付け外し（入れ子、indent 8） | id R・in R・properties*・anchor・isSource R | `HStack { ForEach { Text(name).matchedGeometryEffect(id: name, in: namespace) } }.background { Capsule().fill(.yellow).matchedGeometryEffect(id: selected, in: namespace, properties: .frame, isSource: false) }` |
| Namespace | animations | プロパティラッパー | @Namespace | `@Namespace private var namespace` と、それを使う 2 か所の matchedGeometryEffect（外した形ではどちらも消える） |
| geometryGroup | animations | 付け外し（入れ子） | .geometryGroup* | `VStack { ZStack(alignment: .topLeading) { Color.yellow; 星.transaction { $0.animation = nil } }.geometryGroup().frame(…); Button }` |
| matchedTransitionSource | animations | 付け外し | id R・in R・configuration*（そのまま・背景と角・影） | `Button { isShown = true } label: { 写真 }.matchedTransitionSource(id: "photo", in: namespace, configuration: { … }).sheet { ….navigationTransition(.zoom(…)) }` |
| navigationTransition | animations | 付け外し（入れ子、indent 8） | .navigationTransition*（.zoom(sourceID:in:)・.automatic） | `….sheet(isPresented: $isShown) { Image(…).font(.system(size: 120)).navigationTransition(.zoom(sourceID: "photo", in: namespace)) }` |

### `.note` にするもの（2 件、全体の 5%）

| id | 理由 |
|---|---|
| textEditorStyle | iOS で選べる既製のスタイルは `.automatic` と `.plain` だけで、iPhone ではどちらも同じ見た目になる（iOS 27.0 のシミュレータで比べるを開いて変わらなかった）。枠の付く `.roundedBorder` は `'roundedBorder' is unavailable in iOS` でビルドできない（macOS・visionOS で効く）。`TextEditorStyleConfiguration` は中身を何も渡さないので、ほかの束のように自作のスタイルで見せることもできない |
| tableStyle | iPhone では `Table` が最初の列だけの一覧になり、`.automatic` と `.inset` が同じ見た目になる（iOS 27.0 で試して変わらなかった）。`.bordered` は macOS だけ。列が並ぶ iPad の広い画面と Mac で効く |

`.note` にしかけて `.card` にしたもの:

- `disclosureGroupStyle`・`groupBoxStyle`・`labeledContentStyle`: iOS の既製のスタイルは `.automatic` だけ。自作のスタイル（`PlusDisclosureGroupStyle`・`TintedGroupBoxStyle`・`StackedLabeledContentStyle`）と比べる形にし、struct の定義をコードの `closing` に書いた
- `AsyncImage`: ネットが要る。端末の一時フォルダに書いた PNG（`AsyncImageDemo`）の file URL を読ませた。読めない URL も選べ、失敗の印が出る
- `matchedTransitionSource`・`navigationTransition`: ナビゲーションが要る。見本の中のボタンから `sheet` を開き、`.zoom` で開くようにした（`ZoomTransitionDemo`）。一覧の行の見本は押せないので開かない

### 試作でわかったこと（Task 6 で収録の手引きに足す）

- **既製のスタイルが `.automatic` だけのものは、自作のスタイルと比べる。** struct の定義は `closing` に空の行をはさんで書く。見本の側は同じ名前の `private struct`
- **アニメーションの見本は、`@State` と動かすボタンを `private struct` に持たせる。** 画像では動きが見えないので、UI テストで押して 0.4〜0.5 秒後に撮った。比べるは左右で見本が重なり途中の形が読みにくいので、チップの「付ける」を切って片方ずつ撮った
- **`geometryGroup` は、はじめの見本（大きくなる箱の中に星が現れる）では iOS 27.0 で違いが出なかった。** 現れた星も箱と一緒に動いた。星に `.transaction { $0.animation = nil }` をかけ、自分ではアニメーションしない子にすると、付けないときは星だけが終わりの場所へ飛び、付けると箱の角に付いたまま動いた
- **iOS 27 の Menu は、`.automatic` と `.button` が同じ枠のあるボタンになる。** 違いが出る `.borderlessButton` を最初の値にした
- **iPhone の `.circular` の ProgressView は、値を渡しても回る印になる。** 最初の値は `.linear` にし、説明に書いた
- **`GlassEffectContainer` の溶け合いはシミュレータでだけ見える。** `spacing: 0` では 2 つの円が離れ、`spacing: 40` では間がつながった。ImageRenderer では両方とも離れて描かれる
- **UI テストで編集パネルの選択肢を押すときは、`label` で探す。** `staticTexts[".automatic"]` では見つからない
- **`List`・`Table` の見本を `.frame(height: 220)` にすると、一覧の行が高くなりすぎた。** 160 にした

---


### Task 1: スタイル 1（GlassEffectContainer・buttonStyle・signInWithAppleButtonStyle・buttonSizing・pickerStyle・datePickerStyle・menuStyle）

view-styles の最初の 7 件。`signInWithAppleButtonStyle` だけ `import AuthenticationServices` が要る（SDK に入っているので、プロジェクトの設定は変えない）。

**Files:**
- Create: `WidgetLab/Catalog/ViewStyles/GlassEffectContainerEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/ButtonStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/ButtonSizingEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/PickerStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/DatePickerStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/MenuStyleEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.glassEffectContainer`、`CatalogEntry.buttonStyle`、`CatalogEntry.signInWithAppleButtonStyle`、`CatalogEntry.buttonSizing`、`CatalogEntry.pickerStyle`、`CatalogEntry.datePickerStyle`、`CatalogEntry.menuStyle`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-styles`
Expected: 終了コード 1。抜けに GlassEffectContainer・buttonStyle・signInWithAppleButtonStyle・buttonSizing・pickerStyle・datePickerStyle・menuStyle がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/ViewStyles/GlassEffectContainerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let glassEffectContainer = CatalogEntry(
        id: "GlassEffectContainer",
        kind: .view,
        topic: .viewStyles,
        summary: "中の Liquid Glass の形をまとめて描き、近い形どうしを 1 つに溶け合わせる入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/glasseffectcontainer")!,
        stage: .card,
        properties: [
            .argument(
                "spacing", .slider(range: 0...60, step: 10, initial: 40), on: true,
                summary: "この距離より近い形を溶け合わせる（省くと既定の距離）")
        ],
        code: CodeTemplate(
            call: "GlassEffectContainer",
            trailing: " {\n    HStack(spacing: 20) {\n        Image(systemName: \"pencil\")\n"
                + "            .frame(width: 56, height: 56)\n            .glassEffect()\n"
                + "        Image(systemName: \"eraser\")\n            .frame(width: 56, height: 56)\n"
                + "            .glassEffect()\n    }\n}"),
        build: { v in
            AnyView(
                GlassEffectContainerDemo.container(spacing: v.number("spacing"))
                    .padding()
                    .background(
                        LinearGradient(colors: [.orange, .pink, .blue], startPoint: .leading, endPoint: .trailing))
            )
        }
    )
}

private enum GlassEffectContainerDemo {
    @ViewBuilder
    static func container(spacing: Double?) -> some View {
        if let spacing {
            GlassEffectContainer(spacing: spacing) { shapes }
        } else {
            GlassEffectContainer { shapes }
        }
    }

    private static var shapes: some View {
        HStack(spacing: 20) {
            Image(systemName: "pencil")
                .frame(width: 56, height: 56)
                .glassEffect()
            Image(systemName: "eraser")
                .frame(width: 56, height: 56)
                .glassEffect()
        }
        .font(.title2)
    }
}
```

`WidgetLab/Catalog/ViewStyles/ButtonStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let buttonStyle = CatalogEntry(
        id: "buttonStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中のボタンの見た目を、まとめて決める modifier。押したときの動きはそのまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/buttonstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".borderless"),
                        Choice(".plain"), Choice(".glass"), Choice(".glassProminent"),
                    ],
                    initial: 2),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier(
                "buttonBorderShape", .choice([Choice(".capsule"), Choice(".roundedRectangle")], initial: 1),
                summary: "枠のあるスタイルでの、枠の形"),
            .modifier(
                "controlSize", .choice([Choice(".small"), Choice(".regular"), Choice(".large")], initial: 2),
                summary: "ボタンの大きさ"),
            .modifier("tint", .color(initial: 3), summary: "ボタンの色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Button(\"保存\") { }\n    Button(\"削除\", role: .destructive) { }\n}"),
        build: { v in
            AnyView(
                VStack {
                    Button("保存") {}
                    Button("削除", role: .destructive) {}
                }
                .apply(v.pick("buttonStyle", from: ButtonStyleDemo.Style.allCases)) { ButtonStyleDemo.styled($0, $1) }
                .apply(v.pick("buttonBorderShape", from: [ButtonBorderShape.capsule, .roundedRectangle])) {
                    $0.buttonBorderShape($1)
                }
                .apply(v.pick("controlSize", from: [ControlSize.small, .regular, .large])) { $0.controlSize($1) }
                .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum ButtonStyleDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, borderless, plain, glass, glassProminent
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        case .borderless: view.buttonStyle(.borderless)
        case .plain: view.buttonStyle(.plain)
        case .glass: view.buttonStyle(.glass)
        case .glassProminent: view.buttonStyle(.glassProminent)
        }
    }
}
```

`WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift`:

```swift
import AuthenticationServices
import SwiftUI

nonisolated extension CatalogEntry {
    static let signInWithAppleButtonStyle = CatalogEntry(
        id: "signInWithAppleButtonStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "「Apple でサインイン」のボタンの色を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/signinwithapplebuttonstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "signInWithAppleButtonStyle",
                .choice([Choice(".black"), Choice(".white"), Choice(".whiteOutline")], initial: 0), on: true,
                summary: "ボタンの色（OFF なら画面の明るさに合わせる）")
        ],
        code: CodeTemplate(
            prefix: ["// import AuthenticationServices が要る"], indent: 0, call: "SignInWithAppleButton",
            fixedArguments: [".signIn"], trailing: " { request in\n} onCompletion: { result in\n}",
            suffix: [".frame(width: 260, height: 48)"]),
        build: { v in
            AnyView(
                SignInWithAppleButton(.signIn) { _ in
                } onCompletion: { _ in
                }
                .apply(
                    v.pick(
                        "signInWithAppleButtonStyle", from: [SignInWithAppleButton.Style.black, .white, .whiteOutline])
                ) { $0.signInWithAppleButtonStyle($1) }
                .frame(width: 260, height: 48)
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewStyles/ButtonSizingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let buttonSizing = CatalogEntry(
        id: "buttonSizing",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中のボタンを、中身に合わせた幅にするか、使える幅いっぱいに広げるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/buttonsizing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonSizing", .choice([Choice(".automatic"), Choice(".fitted"), Choice(".flexible")], initial: 2),
                on: true, summary: "ボタンの幅の決め方")
        ],
        code: CodeTemplate(
            call: "HStack", trailing: " {\n    Button(\"戻る\") { }\n    Button(\"次へ\") { }\n}",
            suffix: [".buttonStyle(.borderedProminent)", ".frame(width: 300)"]),
        build: { v in
            AnyView(
                HStack {
                    Button("戻る") {}
                    Button("次へ") {}
                }
                .apply(v.pick("buttonSizing", from: [ButtonSizing.automatic, .fitted, .flexible])) {
                    $0.buttonSizing($1)
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 300)
                .border(.gray.opacity(0.4))
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewStyles/PickerStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let pickerStyle = CatalogEntry(
        id: "pickerStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Picker の見た目と選び方を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/pickerstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "pickerStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".menu"), Choice(".segmented"), Choice(".wheel"),
                        Choice(".inline"),
                        Choice(".palette"),
                    ],
                    initial: 2),
                on: true, summary: "Picker の見た目のスタイル"),
            .modifier("tint", .color(initial: 6), summary: "強調の色（.menu の文字など）"),
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing:
                " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n    Text(\"ぶどう\").tag(\"ぶどう\")\n}"),
        build: { v in
            AnyView(
                PickerStyleDemo(
                    style: v.pick("pickerStyle", from: PickerStyleDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct PickerStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, menu, segmented, wheel, inline, palette
    }

    let style: Style?
    let tint: Color?
    @State private var fruit = "りんご"

    var body: some View {
        // .wheel・.inline はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
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
            case .palette: view.pickerStyle(.palette)
            }
        }
        .apply(tint) { $0.tint($1) }
        .frame(width: 260)
    }
}
```

`WidgetLab/Catalog/ViewStyles/DatePickerStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let datePickerStyle = CatalogEntry(
        id: "datePickerStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の DatePicker の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/datepickerstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "datePickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".compact"), Choice(".graphical"), Choice(".wheel")], initial: 2),
                on: true, summary: "DatePicker の見た目のスタイル"),
            .modifier("tint", .color(initial: 0), summary: "選んだ日の色"),
        ],
        code: CodeTemplate(
            call: "DatePicker", fixedArguments: ["\"日付\"", "selection: $date", "displayedComponents: .date"]),
        build: { v in
            AnyView(
                DatePickerStyleDemo(
                    style: v.pick("datePickerStyle", from: DatePickerStyleDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct DatePickerStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, compact, graphical, wheel
    }

    let style: Style?
    let tint: Color?
    @State private var date = Date.now

    var body: some View {
        // .graphical・.wheel はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
        DatePicker("日付", selection: $date, displayedComponents: .date)
            .apply(style) { view, style in
                switch style {
                case .automatic: view.datePickerStyle(.automatic)
                case .compact: view.datePickerStyle(.compact)
                case .graphical: view.datePickerStyle(.graphical)
                case .wheel: view.datePickerStyle(.wheel)
                }
            }
            .apply(tint) { $0.tint($1) }
            .frame(maxWidth: 320)
    }
}
```

`WidgetLab/Catalog/ViewStyles/MenuStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let menuStyle = CatalogEntry(
        id: "menuStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Menu の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menustyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuStyle",
                .choice([Choice(".automatic"), Choice(".button"), Choice(".borderlessButton")], initial: 2),
                on: true, summary: "Menu の見た目のスタイル。iOS 27 では .automatic と .button が枠のあるボタン、.borderlessButton が文字だけになる"),
            .modifier(
                "buttonStyle", .choice([Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                summary: "ボタンのスタイル（.automatic・.button の Menu に効く）"),
        ],
        code: CodeTemplate(
            call: "Menu", fixedArguments: ["\"並べ替え\""],
            trailing: " {\n    Button(\"名前順\") { }\n    Button(\"日付順\") { }\n}"),
        build: { v in
            AnyView(
                Menu("並べ替え") {
                    Button("名前順") {}
                    Button("日付順") {}
                }
                .apply(v.pick("menuStyle", from: MenuStyleDemo.Style.allCases)) { MenuStyleDemo.styled($0, $1) }
                .apply(v.pick("buttonStyle", from: [false, true])) { view, prominent in
                    if prominent { view.buttonStyle(.borderedProminent) } else { view.buttonStyle(.bordered) }
                }
            )
        }
    )
}

private enum MenuStyleDemo {
    enum Style: CaseIterable {
        case automatic, button, borderlessButton
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.menuStyle(.automatic)
        case .button: view.menuStyle(.button)
        case .borderlessButton: view.menuStyle(.borderlessButton)
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .glassEffectContainer,
        .buttonStyle,
        .signInWithAppleButtonStyle,
        .buttonSizing,
        .pickerStyle,
        .datePickerStyle,
        .menuStyle,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ViewStyles/GlassEffectContainerEntry.swift \
  WidgetLab/Catalog/ViewStyles/ButtonStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/ButtonSizingEntry.swift \
  WidgetLab/Catalog/ViewStyles/PickerStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/DatePickerStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/MenuStyleEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: GlassEffectContainer・buttonStyle・signInWithAppleButtonStyle・buttonSizing・pickerStyle・datePickerStyle・menuStyle を収録する"
```

---

### Task 2: スタイル 2（toggleStyle・gaugeStyle・progressViewStyle・labelStyle・textFieldStyle・textEditorStyle・listStyle）

`textEditorStyle` は `.note`（build を書かない初期化）。

**Files:**
- Create: `WidgetLab/Catalog/ViewStyles/ToggleStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/GaugeStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/ProgressViewStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/LabelStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/TextFieldStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/TextEditorStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/ListStyleEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.toggleStyle`、`CatalogEntry.gaugeStyle`、`CatalogEntry.progressViewStyle`、`CatalogEntry.labelStyle`、`CatalogEntry.textFieldStyle`、`CatalogEntry.textEditorStyle`、`CatalogEntry.listStyle`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-styles`
Expected: 終了コード 1。抜けに toggleStyle・gaugeStyle・progressViewStyle・labelStyle・textFieldStyle・textEditorStyle・listStyle がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/ViewStyles/ToggleStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toggleStyle = CatalogEntry(
        id: "toggleStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Toggle の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/togglestyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "toggleStyle", .choice([Choice(".automatic"), Choice(".switch"), Choice(".button")], initial: 2),
                on: true, summary: "Toggle の見た目のスタイル。.button は押すたびに色が変わるボタンになる"),
            .modifier("tint", .color(initial: 4), summary: "ON のときの色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Toggle(\"通知\", isOn: $notifies)\n    Toggle(\"音\", isOn: $sounds)\n}"),
        build: { v in
            AnyView(
                ToggleStyleDemo(
                    style: v.pick("toggleStyle", from: ToggleStyleDemo.Style.allCases), tint: v.color("tint"))
            )
        }
    )
}

private struct ToggleStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, `switch`, button
    }

    let style: Style?
    let tint: Color?
    @State private var notifies = true
    @State private var sounds = false

    var body: some View {
        VStack {
            Toggle("通知", isOn: $notifies)
            Toggle("音", isOn: $sounds)
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.toggleStyle(.automatic)
            case .switch: view.toggleStyle(.switch)
            case .button: view.toggleStyle(.button)
            }
        }
        .apply(tint) { $0.tint($1) }
        .frame(width: 220)
    }
}
```

`WidgetLab/Catalog/ViewStyles/GaugeStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let gaugeStyle = CatalogEntry(
        id: "gaugeStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Gauge の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/gaugestyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "gaugeStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".linearCapacity"), Choice(".accessoryLinear"),
                        Choice(".accessoryLinearCapacity"), Choice(".accessoryCircular"),
                        Choice(".accessoryCircularCapacity"),
                    ],
                    initial: 5),
                on: true, summary: "Gauge の見た目のスタイル"),
            .modifier("tint", .color(initial: 3), summary: "目盛りの色"),
        ],
        code: CodeTemplate(
            call: "Gauge", fixedArguments: ["value: 0.6"],
            trailing: " {\n    Text(\"電池\")\n} currentValueLabel: {\n    Text(\"60\")\n}"),
        build: { v in
            AnyView(
                Gauge(value: 0.6) {
                    Text("電池")
                } currentValueLabel: {
                    Text("60")
                }
                .apply(v.pick("gaugeStyle", from: GaugeStyleDemo.Style.allCases)) { GaugeStyleDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(width: 240)
            )
        }
    )
}

private enum GaugeStyleDemo {
    enum Style: CaseIterable {
        case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity, accessoryCircular
        case accessoryCircularCapacity
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

`WidgetLab/Catalog/ViewStyles/ProgressViewStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let progressViewStyle = CatalogEntry(
        id: "progressViewStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の ProgressView の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/progressviewstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "progressViewStyle",
                .choice([Choice(".automatic"), Choice(".linear"), Choice(".circular")], initial: 1),
                on: true, summary: "ProgressView の見た目のスタイル。iPhone の .circular は、値を渡しても回る印になる"),
            .modifier("tint", .color(initial: 5), summary: "棒・印の色"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    ProgressView(value: 0.4)\n    ProgressView()\n}"),
        build: { v in
            AnyView(
                VStack {
                    ProgressView(value: 0.4)
                    ProgressView()
                }
                .apply(v.pick("progressViewStyle", from: ProgressViewStyleDemo.Style.allCases)) {
                    ProgressViewStyleDemo.styled($0, $1)
                }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(width: 240)
            )
        }
    )
}

private enum ProgressViewStyleDemo {
    enum Style: CaseIterable {
        case automatic, linear, circular
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

`WidgetLab/Catalog/ViewStyles/LabelStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let labelStyle = CatalogEntry(
        id: "labelStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Label を、文字と絵のどちらで見せるかをまとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labelStyle",
                .choice(
                    [Choice(".automatic"), Choice(".titleAndIcon"), Choice(".titleOnly"), Choice(".iconOnly")],
                    initial: 3),
                on: true, summary: "Label の見せ方のスタイル"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字と絵の色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            fixedArguments: ["alignment: .leading"],
            trailing:
                " {\n    Label(\"お気に入り\", systemImage: \"star.fill\")\n    Label(\"履歴\", systemImage: \"clock\")\n}",
            suffix: [".font(.title2)"]),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Label("お気に入り", systemImage: "star.fill")
                    Label("履歴", systemImage: "clock")
                }
                .apply(v.pick("labelStyle", from: LabelStyleDemo.Style.allCases)) { LabelStyleDemo.styled($0, $1) }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .font(.title2)
            )
        }
    )
}

private enum LabelStyleDemo {
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

`WidgetLab/Catalog/ViewStyles/TextFieldStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textFieldStyle = CatalogEntry(
        id: "textFieldStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の TextField の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textfieldstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textFieldStyle", .choice([Choice(".automatic"), Choice(".plain"), Choice(".bordered")], initial: 2),
                on: true, summary: "TextField の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    TextField(\"名前\", text: $name)\n    TextField(\"メール\", text: $mail)\n}"),
        build: { v in
            AnyView(TextFieldStyleDemo(style: v.pick("textFieldStyle", from: TextFieldStyleDemo.Style.allCases)))
        }
    )
}

private struct TextFieldStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, plain, bordered
    }

    let style: Style?
    @State private var name = ""
    @State private var mail = ""

    var body: some View {
        VStack {
            TextField("名前", text: $name)
            TextField("メール", text: $mail)
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.textFieldStyle(.automatic)
            case .plain: view.textFieldStyle(.plain)
            case .bordered: view.textFieldStyle(.bordered)
            }
        }
        .frame(width: 260)
    }
}
```

`WidgetLab/Catalog/ViewStyles/TextEditorStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let textEditorStyle = CatalogEntry(
        id: "textEditorStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の TextEditor の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/texteditorstyle(_:)")!,
        noteReason: "iPhone では、選べる .automatic と .plain が同じ見た目になる（iOS 27.0 で試して変わらなかった）。"
            + "枠の付く .roundedBorder は macOS・visionOS で効く",
        properties: [
            .modifier(
                "textEditorStyle", .choice([Choice(".automatic"), Choice(".plain")], initial: 1), on: true,
                summary: "TextEditor の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(width: 260, height: 100)"])
    )
}
```

`WidgetLab/Catalog/ViewStyles/ListStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listStyle = CatalogEntry(
        id: "listStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の List の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/liststyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".plain"), Choice(".grouped"), Choice(".inset"),
                        Choice(".insetGrouped"), Choice(".sidebar"),
                    ],
                    initial: 1),
                on: true, summary: "List の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Section(\"果物\") {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }\n}",
            suffix: [".frame(height: 160)"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                }
                .apply(v.pick("listStyle", from: ListStyleDemo.Style.allCases)) { ListStyleDemo.styled($0, $1) }
                .frame(height: 160)
            )
        }
    )
}

private enum ListStyleDemo {
    enum Style: CaseIterable {
        case automatic, plain, grouped, inset, insetGrouped, sidebar
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.listStyle(.automatic)
        case .plain: view.listStyle(.plain)
        case .grouped: view.listStyle(.grouped)
        case .inset: view.listStyle(.inset)
        case .insetGrouped: view.listStyle(.insetGrouped)
        case .sidebar: view.listStyle(.sidebar)
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .toggleStyle,
        .gaugeStyle,
        .progressViewStyle,
        .labelStyle,
        .textFieldStyle,
        .textEditorStyle,
        .listStyle,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ViewStyles/ToggleStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/GaugeStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/ProgressViewStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/LabelStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/TextFieldStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/TextEditorStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/ListStyleEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: toggleStyle・gaugeStyle・progressViewStyle・labelStyle・textFieldStyle・textEditorStyle・listStyle を収録する"
```

---

### Task 3: スタイル 3（tableStyle・disclosureGroupStyle・controlGroupStyle・formStyle・groupBoxStyle・indexViewStyle・labeledContentStyle）

`tableStyle` は `.note`。`disclosureGroupStyle`・`groupBoxStyle`・`labeledContentStyle` は、自作のスタイルの struct をファイルの中に `private` で置き、同じ定義をコードの `closing` にも書く。

**Files:**
- Create: `WidgetLab/Catalog/ViewStyles/TableStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/DisclosureGroupStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/ControlGroupStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/FormStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/GroupBoxStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/IndexViewStyleEntry.swift`
- Create: `WidgetLab/Catalog/ViewStyles/LabeledContentStyleEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.tableStyle`、`CatalogEntry.disclosureGroupStyle`、`CatalogEntry.controlGroupStyle`、`CatalogEntry.formStyle`、`CatalogEntry.groupBoxStyle`、`CatalogEntry.indexViewStyle`、`CatalogEntry.labeledContentStyle`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-styles`
Expected: 終了コード 1。抜けに tableStyle・disclosureGroupStyle・controlGroupStyle・formStyle・groupBoxStyle・indexViewStyle・labeledContentStyle がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/ViewStyles/TableStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tableStyle = CatalogEntry(
        id: "tableStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Table の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tablestyle(_:)")!,
        noteReason: "iPhone では Table が最初の列だけの一覧になり、.automatic と .inset が同じ見た目になる"
            + "（iOS 27.0 で試して変わらなかった）。列が並ぶ iPad の広い画面と Mac で効く",
        properties: [
            .modifier(
                "tableStyle", .choice([Choice(".automatic"), Choice(".inset")], initial: 1), on: true,
                summary: "Table の見た目のスタイル")
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing:
                " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"値段\", value: \\.price)\n}",
            suffix: [".frame(height: 160)"])
    )
}
```

`WidgetLab/Catalog/ViewStyles/DisclosureGroupStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let disclosureGroupStyle = CatalogEntry(
        id: "disclosureGroupStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の DisclosureGroup の見た目と開き方を、まとめて決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/disclosuregroupstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "disclosureGroupStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "PlusDisclosureGroupStyle()")], initial: 1),
                on: true, summary: "開け閉めの見た目のスタイル。自作のものは DisclosureGroupStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "DisclosureGroup", fixedArguments: ["\"詳細\"", "isExpanded: $isExpanded"],
            trailing: " {\n    Text(\"バージョン 1.0\")\n}",
            closing: [
                "",
                "struct PlusDisclosureGroupStyle: DisclosureGroupStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading) {",
                "            Button {",
                "                withAnimation { configuration.isExpanded.toggle() }",
                "            } label: {",
                "                Label {",
                "                    configuration.label",
                "                } icon: {",
                "                    Image(systemName: configuration.isExpanded ? \"minus.circle\" : \"plus.circle\")",
                "                }",
                "            }",
                "            if configuration.isExpanded {",
                "                configuration.content",
                "                    .padding(.leading, 28)",
                "            }",
                "        }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(DisclosureGroupStyleDemo(isCustom: v.pick("disclosureGroupStyle", from: [false, true])))
        }
    )
}

private struct DisclosureGroupStyleDemo: View {
    /// nil なら modifier をかけない。false は .automatic、true は自作のスタイル
    let isCustom: Bool?
    @State private var isExpanded = true

    var body: some View {
        DisclosureGroup("詳細", isExpanded: $isExpanded) {
            Text("バージョン 1.0")
        }
        .apply(isCustom) { view, isCustom in
            if isCustom {
                view.disclosureGroupStyle(PlusDisclosureGroupStyle())
            } else {
                view.disclosureGroupStyle(.automatic)
            }
        }
        .frame(width: 240)
    }
}

private struct PlusDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation { configuration.isExpanded.toggle() }
            } label: {
                Label {
                    configuration.label
                } icon: {
                    Image(systemName: configuration.isExpanded ? "minus.circle" : "plus.circle")
                }
            }
            if configuration.isExpanded {
                configuration.content
                    .padding(.leading, 28)
            }
        }
    }
}
```

`WidgetLab/Catalog/ViewStyles/ControlGroupStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let controlGroupStyle = CatalogEntry(
        id: "controlGroupStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の ControlGroup の並べ方と見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlgroupstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "controlGroupStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigation"), Choice(".palette"), Choice(".menu"),
                        Choice(".compactMenu"),
                    ],
                    initial: 1),
                on: true, summary: "ControlGroup のスタイル。.menu・.compactMenu は名前のボタンから開く")
        ],
        code: CodeTemplate(
            call: "ControlGroup",
            trailing: " {\n    Button(\"戻る\", systemImage: \"chevron.left\") { }\n"
                + "    Button(\"進む\", systemImage: \"chevron.right\") { }\n} label: {\n"
                + "    Label(\"移動\", systemImage: \"arrow.left.arrow.right\")\n}"),
        build: { v in
            AnyView(
                ControlGroup {
                    Button("戻る", systemImage: "chevron.left") {}
                    Button("進む", systemImage: "chevron.right") {}
                } label: {
                    Label("移動", systemImage: "arrow.left.arrow.right")
                }
                .apply(v.pick("controlGroupStyle", from: ControlGroupStyleDemo.Style.allCases)) {
                    ControlGroupStyleDemo.styled($0, $1)
                }
                .frame(width: 240)
            )
        }
    )
}

private enum ControlGroupStyleDemo {
    enum Style: CaseIterable {
        case automatic, navigation, palette, menu, compactMenu
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.controlGroupStyle(.automatic)
        case .navigation: view.controlGroupStyle(.navigation)
        case .palette: view.controlGroupStyle(.palette)
        case .menu: view.controlGroupStyle(.menu)
        case .compactMenu: view.controlGroupStyle(.compactMenu)
        }
    }
}
```

`WidgetLab/Catalog/ViewStyles/FormStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let formStyle = CatalogEntry(
        id: "formStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Form の並べ方を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/formstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "formStyle", .choice([Choice(".automatic"), Choice(".grouped"), Choice(".columns")], initial: 2),
                on: true, summary: "Form の並べ方のスタイル。.columns は名前と値を列にそろえる")
        ],
        code: CodeTemplate(
            call: "Form",
            trailing: " {\n    Toggle(\"通知\", isOn: $notifies)\n"
                + "    LabeledContent(\"バージョン\", value: \"1.0\")\n}",
            suffix: [".frame(height: 200)"]),
        build: { v in
            AnyView(FormStyleDemo(style: v.pick("formStyle", from: FormStyleDemo.Style.allCases)))
        }
    )
}

private struct FormStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, grouped, columns
    }

    let style: Style?
    @State private var notifies = true

    var body: some View {
        Form {
            Toggle("通知", isOn: $notifies)
            LabeledContent("バージョン", value: "1.0")
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.formStyle(.automatic)
            case .grouped: view.formStyle(.grouped)
            case .columns: view.formStyle(.columns)
            }
        }
        .frame(height: 200)
    }
}
```

`WidgetLab/Catalog/ViewStyles/GroupBoxStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let groupBoxStyle = CatalogEntry(
        id: "groupBoxStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の GroupBox の見た目を、まとめて決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/groupboxstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "groupBoxStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "TintedGroupBoxStyle()")], initial: 1), on: true,
                summary: "箱の見た目のスタイル。自作のものは GroupBoxStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "GroupBox", fixedArguments: ["\"設定\""], trailing: " {\n    Text(\"通知を受け取る\")\n}",
            closing: [
                "",
                "struct TintedGroupBoxStyle: GroupBoxStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading, spacing: 8) {",
                "            configuration.label",
                "                .font(.headline)",
                "            configuration.content",
                "        }",
                "        .padding()",
                "        .background(.yellow.opacity(0.3), in: .rect(cornerRadius: 12))",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                GroupBox("設定") {
                    Text("通知を受け取る")
                }
                .apply(v.pick("groupBoxStyle", from: [false, true])) { view, isCustom in
                    if isCustom {
                        view.groupBoxStyle(TintedGroupBoxStyle())
                    } else {
                        view.groupBoxStyle(.automatic)
                    }
                }
                .padding()
            )
        }
    )
}

private struct TintedGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .padding()
        .background(.yellow.opacity(0.3), in: .rect(cornerRadius: 12))
    }
}
```

`WidgetLab/Catalog/ViewStyles/IndexViewStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let indexViewStyle = CatalogEntry(
        id: "indexViewStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "ページ送りの TabView の、ページの位置を示す点の見た目を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/indexviewstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "indexViewStyle",
                .choice(
                    [
                        Choice(".page"), Choice(".page(backgroundDisplayMode: .always)"),
                        Choice(".page(backgroundDisplayMode: .interactive)"),
                        Choice(".page(backgroundDisplayMode: .never)"),
                    ],
                    initial: 1),
                on: true, summary: "点の見た目。backgroundDisplayMode は点の後ろの帯を出すか")
        ],
        code: CodeTemplate(
            call: "TabView", trailing: " {\n    Color.yellow\n    Color.mint\n    Color.cyan\n}",
            suffix: [".tabViewStyle(.page)", ".frame(width: 240, height: 140)"]),
        build: { v in
            AnyView(
                TabView {
                    Color.yellow
                    Color.mint
                    Color.cyan
                }
                .apply(
                    v.pick(
                        "indexViewStyle",
                        from: [
                            PageIndexViewStyle(), .page(backgroundDisplayMode: .always),
                            .page(backgroundDisplayMode: .interactive), .page(backgroundDisplayMode: .never),
                        ])
                ) { $0.indexViewStyle($1) }
                .tabViewStyle(.page)
                .frame(width: 240, height: 140)
            )
        }
    )
}
```

`WidgetLab/Catalog/ViewStyles/LabeledContentStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let labeledContentStyle = CatalogEntry(
        id: "labeledContentStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の LabeledContent の、名前と値の並べ方を決める modifier。iOS の既製のスタイルは .automatic だけなので、自作のスタイルと比べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labeledcontentstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labeledContentStyle",
                .choice([Choice(".automatic"), Choice("自作", code: "StackedLabeledContentStyle()")], initial: 1),
                on: true, summary: "名前と値の並べ方のスタイル。自作のものは LabeledContentStyle に準拠させて作る")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    LabeledContent(\"バージョン\", value: \"1.0\")\n"
                + "    LabeledContent(\"作った人\", value: \"Widget Lab\")\n}",
            closing: [
                "",
                "struct StackedLabeledContentStyle: LabeledContentStyle {",
                "    func makeBody(configuration: Configuration) -> some View {",
                "        VStack(alignment: .leading) {",
                "            configuration.label",
                "                .font(.caption)",
                "                .foregroundStyle(.secondary)",
                "            configuration.content",
                "        }",
                "        .frame(maxWidth: .infinity, alignment: .leading)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                VStack {
                    LabeledContent("バージョン", value: "1.0")
                    LabeledContent("作った人", value: "Widget Lab")
                }
                .apply(v.pick("labeledContentStyle", from: [false, true])) { view, isCustom in
                    if isCustom {
                        view.labeledContentStyle(StackedLabeledContentStyle())
                    } else {
                        view.labeledContentStyle(.automatic)
                    }
                }
                .frame(width: 240)
            )
        }
    )
}

private struct StackedLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.caption)
                .foregroundStyle(.secondary)
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .tableStyle,
        .disclosureGroupStyle,
        .controlGroupStyle,
        .formStyle,
        .groupBoxStyle,
        .indexViewStyle,
        .labeledContentStyle,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ViewStyles/TableStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/DisclosureGroupStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/ControlGroupStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/FormStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/GroupBoxStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/IndexViewStyleEntry.swift \
  WidgetLab/Catalog/ViewStyles/LabeledContentStyleEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: tableStyle・disclosureGroupStyle・controlGroupStyle・formStyle・groupBoxStyle・indexViewStyle・labeledContentStyle を収録する"
```

---

### Task 4: 画像（Image・imageScale・AsyncImage・symbolVariant・symbolEffect・symbolEffectsRemoved・symbolRenderingMode）

`AsyncImageDemo` は AsyncImage の見本が読む画像を、初めて使うときに端末の一時フォルダへ書き出す補助（アプリはオフラインで動くため）。`Entry` で終わらない名前なので、`catalog_progress.py` は数えない。

**Files:**
- Create: `WidgetLab/Catalog/Images/ImageEntry.swift`
- Create: `WidgetLab/Catalog/Images/ImageScaleEntry.swift`
- Create: `WidgetLab/Catalog/Images/AsyncImageDemo.swift`
- Create: `WidgetLab/Catalog/Images/AsyncImageEntry.swift`
- Create: `WidgetLab/Catalog/Images/SymbolVariantEntry.swift`
- Create: `WidgetLab/Catalog/Images/SymbolEffectEntry.swift`
- Create: `WidgetLab/Catalog/Images/SymbolEffectsRemovedEntry.swift`
- Create: `WidgetLab/Catalog/Images/SymbolRenderingModeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.image`、`CatalogEntry.imageScale`、`CatalogEntry.asyncImage`、`CatalogEntry.symbolVariant`、`CatalogEntry.symbolEffect`、`CatalogEntry.symbolEffectsRemoved`、`CatalogEntry.symbolRenderingMode`、`AsyncImageDemo.readableURL: URL?`（`@MainActor`）、`AsyncImageDemo.missingURL: URL`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py images`
Expected: 終了コード 1。抜けに Image・imageScale・AsyncImage・symbolVariant・symbolEffect・symbolEffectsRemoved・symbolRenderingMode がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/Images/ImageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let image = CatalogEntry(
        id: "Image",
        kind: .view,
        topic: .images,
        summary: "画像を表示する View。SF Symbols の記号は systemName で名前を渡す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/image")!,
        stage: .card,
        properties: [
            .argument(
                "systemName",
                .choice(
                    [Choice("\"wifi\""), Choice("\"speaker.wave.3.fill\""), Choice("\"chart.bar.fill\"")], initial: 0),
                required: true, summary: "SF Symbols の記号の名前"),
            .argument(
                "variableValue", .slider(range: 0...1, step: 0.25, initial: 0.5), on: true,
                summary: "記号の段階の値（0〜1）。対応する記号だけ、値に合わせて一部を薄くする"),
            .modifier("resizable", .fixed(code: ""), on: true, summary: "枠に合わせて大きさを変えられるようにする"),
            .modifier("scaledToFit", .fixed(code: ""), on: true, summary: "縦横の比を保って枠に収める"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "記号の色"),
        ],
        code: CodeTemplate(call: "Image", suffix: [".frame(width: 120, height: 120)"]),
        build: { v in
            AnyView(
                ImageDemo.image(
                    systemName: v.pick("systemName", from: ["wifi", "speaker.wave.3.fill", "chart.bar.fill"]) ?? "wifi",
                    variableValue: v.number("variableValue"), resizable: v["resizable"] != nil
                )
                .apply(v["scaledToFit"] != nil ? () : nil) { view, _ in view.scaledToFit() }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .frame(width: 120, height: 120)
                .border(.gray.opacity(0.4))
            )
        }
    )
}

private enum ImageDemo {
    static func image(systemName: String, variableValue: Double?, resizable: Bool) -> Image {
        let image = Image(systemName: systemName, variableValue: variableValue)
        return resizable ? image.resizable() : image
    }
}
```

`WidgetLab/Catalog/Images/ImageScaleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let imageScale = CatalogEntry(
        id: "imageScale",
        kind: .modifier,
        topic: .images,
        summary: "この View の中の記号の大きさを、まわりの文字に対して小・中・大から選ぶ modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/imagescale(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "imageScale", .choice([Choice(".small"), Choice(".medium"), Choice(".large")], initial: 2), on: true,
                summary: "文字に対する記号の大きさ（OFF なら .medium）"),
            .modifier(
                "font", .choice([Choice(".body"), Choice(".title"), Choice(".largeTitle")], initial: 1), on: true,
                summary: "文字の大きさ。記号もこれに合わせる"),
        ],
        code: CodeTemplate(
            call: "HStack", trailing: " {\n    Image(systemName: \"star.fill\")\n    Text(\"お気に入り\")\n}"),
        build: { v in
            AnyView(
                HStack {
                    Image(systemName: "star.fill")
                    Text("お気に入り")
                }
                .apply(v.pick("imageScale", from: [Image.Scale.small, .medium, .large])) { $0.imageScale($1) }
                .apply(v.pick("font", from: [Font.body, .title, .largeTitle])) { $0.font($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/Images/AsyncImageDemo.swift`:

```swift
import SwiftUI

/// AsyncImage の見本が読む画像。アプリはオフラインで動くので、端末の一時フォルダに PNG を書いて、その file URL を渡す
enum AsyncImageDemo {
    /// 読める画像の URL（初めて使うときに書き出す）
    @MainActor static let readableURL: URL? = {
        let url = URL.temporaryDirectory.appending(path: "widget-lab-async-image.png")
        let renderer = ImageRenderer(
            content: Image(systemName: "photo.artframe")
                .font(.system(size: 120))
                .foregroundStyle(.blue)
                .padding(8))
        renderer.scale = 2
        guard let data = renderer.uiImage?.pngData(), (try? data.write(to: url)) != nil else { return nil }
        return url
    }()

    /// 読めない画像の URL（ないファイル）
    static let missingURL = URL.temporaryDirectory.appending(path: "widget-lab-missing.png")
}
```

`WidgetLab/Catalog/Images/AsyncImageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let asyncImage = CatalogEntry(
        id: "AsyncImage",
        kind: .view,
        topic: .images,
        summary: "URL の画像を裏で読み込み、読み込みの段階（読み込み中・成功・失敗）に合わせて表示する View。見本は、端末の中に書いた画像を読む（アプリがオフラインで動くため）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/asyncimage")!,
        stage: .card,
        properties: [
            .argument(
                "url",
                .choice(
                    [
                        Choice("読める URL", code: "URL(string: \"https://example.com/photo.png\")"),
                        Choice("読めない URL", code: "URL(string: \"https://example.com/missing.png\")"),
                    ],
                    initial: 0),
                required: true, summary: "読み込む画像の URL"),
            .argument(
                "scale", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "画像の 1 点を何ピクセルとみなすか。大きいほど小さく出る（省くと 1）"),
        ],
        code: CodeTemplate(
            call: "AsyncImage",
            trailing:
                " { phase in\n    if let image = phase.image {\n        image\n    } else if phase.error != nil {\n"
                + "        Image(systemName: \"exclamationmark.triangle\")\n    } else {\n        ProgressView()\n    }\n}"
        ),
        build: { v in
            let url = v.pick("url", from: [AsyncImageDemo.readableURL, AsyncImageDemo.missingURL]) ?? nil
            return AnyView(
                AsyncImage(url: url, scale: v.number("scale") ?? 1) { phase in
                    if let image = phase.image {
                        image
                    } else if phase.error != nil {
                        Image(systemName: "exclamationmark.triangle")
                    } else {
                        ProgressView()
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Images/SymbolVariantEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolVariant = CatalogEntry(
        id: "symbolVariant",
        kind: .modifier,
        topic: .images,
        summary: "この View の中の SF Symbols の記号を、塗り・丸囲みなどの別の形で表示する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symbolvariant(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolVariant",
                .choice(
                    [
                        Choice(".none"), Choice(".fill"), Choice(".circle"), Choice(".circle.fill"), Choice(".square"),
                        Choice(".slash"),
                    ],
                    initial: 1),
                on: true, summary: "記号の形の種類。その形がない記号は元のまま"),
            .modifier("foregroundStyle", .color(initial: 0), summary: "記号の色"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Image(systemName: \"heart\")\n    Image(systemName: \"bell\")\n"
                + "    Image(systemName: \"person\")\n}",
            suffix: [".font(.largeTitle)"]),
        build: { v in
            AnyView(
                HStack {
                    Image(systemName: "heart")
                    Image(systemName: "bell")
                    Image(systemName: "person")
                }
                .apply(
                    v.pick("symbolVariant", from: [SymbolVariants.none, .fill, .circle, .circle.fill, .square, .slash])
                ) { $0.symbolVariant($1) }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .font(.largeTitle)
            )
        }
    )
}
```

`WidgetLab/Catalog/Images/SymbolEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolEffect = CatalogEntry(
        id: "symbolEffect",
        kind: .modifier,
        topic: .images,
        summary: "SF Symbols の記号を、記号に合った動き（脈打つ・揺れる・跳ねるなど）で動かす modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:isactive:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolEffect",
                .choice(
                    [
                        Choice(".pulse"), Choice(".variableColor.iterative"), Choice(".breathe"), Choice(".wiggle"),
                        Choice(".bounce"), Choice(".rotate"),
                    ],
                    initial: 1),
                required: true, summary: "動きの種類（options か isActive が ON のときだけ書く）"),
            .modifier(
                "symbolEffect", id: "symbolEffect.options", label: "options",
                .choice([Choice(".repeating"), Choice(".nonRepeating"), Choice(".speed(3)")], initial: 2),
                summary: "繰り返すか・速さ（省くと、動きごとの既定の繰り返し）"),
            .modifier(
                "symbolEffect", id: "symbolEffect.isActive", label: "isActive", .toggle(initial: true), on: true,
                summary: "動かすか（false なら止める）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"speaker.wave.3.fill\")", "    .font(.system(size: 64))"],
            call: ".foregroundStyle", fixedArguments: [".blue"]),
        build: { v in
            AnyView(
                SymbolEffectDemo.styled(
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue),
                    effect: v.pick("symbolEffect", from: SymbolEffectDemo.Effect.allCases) ?? .pulse,
                    options: v.pick(
                        "symbolEffect.options", from: [SymbolEffectOptions.repeating, .nonRepeating, .speed(3)]),
                    isActive: v.flag("symbolEffect.isActive"))
            )
        }
    )
}

private enum SymbolEffectDemo {
    enum Effect: CaseIterable {
        case pulse, variableColor, breathe, wiggle, bounce, rotate
    }

    /// effect は required なので、options と isActive がどちらも OFF なら modifier をかけない（コードもその行を書かない）
    @ViewBuilder
    static func styled(_ view: some View, effect: Effect, options: SymbolEffectOptions?, isActive: Bool?)
        -> some View
    {
        if options == nil && isActive == nil {
            view
        } else {
            effected(view, effect: effect, options: options ?? .default, isActive: isActive ?? true)
        }
    }

    @ViewBuilder
    private static func effected(_ view: some View, effect: Effect, options: SymbolEffectOptions, isActive: Bool)
        -> some View
    {
        switch effect {
        case .pulse: view.symbolEffect(.pulse, options: options, isActive: isActive)
        case .variableColor: view.symbolEffect(.variableColor.iterative, options: options, isActive: isActive)
        case .breathe: view.symbolEffect(.breathe, options: options, isActive: isActive)
        case .wiggle: view.symbolEffect(.wiggle, options: options, isActive: isActive)
        case .bounce: view.symbolEffect(.bounce, options: options, isActive: isActive)
        case .rotate: view.symbolEffect(.rotate, options: options, isActive: isActive)
        }
    }
}
```

`WidgetLab/Catalog/Images/SymbolEffectsRemovedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolEffectsRemoved = CatalogEntry(
        id: "symbolEffectsRemoved",
        kind: .modifier,
        topic: .images,
        summary: "親からかかった記号の動き（symbolEffect）を、この View の中の記号だけ外す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symboleffectsremoved(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolEffectsRemoved", .toggle(initial: true), on: true,
                summary: "true なら星の動きを外す（ベルは動いたまま）")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack(spacing: 24) {", "    Image(systemName: \"bell.fill\")", "    Image(systemName: \"star.fill\")",
            ],
            indent: 8, call: ".foregroundStyle", fixedArguments: [".orange"],
            closing: ["}", ".font(.system(size: 56))", ".symbolEffect(.pulse)"]),
        build: { v in
            AnyView(
                HStack(spacing: 24) {
                    Image(systemName: "bell.fill")
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .apply(v.flag("symbolEffectsRemoved")) { $0.symbolEffectsRemoved($1) }
                }
                .font(.system(size: 56))
                .symbolEffect(.pulse)
            )
        }
    )
}
```

`WidgetLab/Catalog/Images/SymbolRenderingModeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolRenderingMode = CatalogEntry(
        id: "symbolRenderingMode",
        kind: .modifier,
        topic: .images,
        summary: "SF Symbols の記号の層を、1 色・濃淡・指定の色・記号の決まった色のどれで塗るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/symbolrenderingmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolRenderingMode",
                .choice(
                    [Choice(".monochrome"), Choice(".hierarchical"), Choice(".palette"), Choice(".multicolor")],
                    initial: 2),
                on: true, summary: "層の塗り方"),
            .modifier(
                "foregroundStyle",
                .choice(
                    [Choice("1 色", code: ".blue"), Choice("3 色", code: ".blue, .yellow, .gray")], initial: 1),
                on: true, summary: "塗る色。.palette では層ごとに順に使う"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"cloud.sun.rain.fill\""],
            suffix: [".font(.system(size: 72))"]),
        build: { v in
            AnyView(
                Image(systemName: "cloud.sun.rain.fill")
                    .apply(
                        v.pick(
                            "symbolRenderingMode",
                            from: [SymbolRenderingMode.monochrome, .hierarchical, .palette, .multicolor])
                    ) { $0.symbolRenderingMode($1) }
                    .apply(v.pick("foregroundStyle", from: [false, true])) { view, threeColors in
                        if threeColors {
                            view.foregroundStyle(.blue, .yellow, .gray)
                        } else {
                            view.foregroundStyle(.blue)
                        }
                    }
                    .font(.system(size: 72))
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .image,
        .imageScale,
        .asyncImage,
        .symbolVariant,
        .symbolEffect,
        .symbolEffectsRemoved,
        .symbolRenderingMode,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Images/ImageEntry.swift \
  WidgetLab/Catalog/Images/ImageScaleEntry.swift \
  WidgetLab/Catalog/Images/AsyncImageDemo.swift \
  WidgetLab/Catalog/Images/AsyncImageEntry.swift \
  WidgetLab/Catalog/Images/SymbolVariantEntry.swift \
  WidgetLab/Catalog/Images/SymbolEffectEntry.swift \
  WidgetLab/Catalog/Images/SymbolEffectsRemovedEntry.swift \
  WidgetLab/Catalog/Images/SymbolRenderingModeEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: Image・imageScale・AsyncImage・symbolVariant・symbolEffect・symbolEffectsRemoved・symbolRenderingMode を収録する"
```

---

### Task 5: 動き 1（animation・PhaseAnimator・KeyframeAnimator・TimelineView・transition・contentTransition・transaction）

どれも `@State` の値と動かすボタンを、ファイルの中の `private struct` に持たせる（`build` の中では `@State` を持てないため）。

**Files:**
- Create: `WidgetLab/Catalog/Animations/AnimationEntry.swift`
- Create: `WidgetLab/Catalog/Animations/PhaseAnimatorEntry.swift`
- Create: `WidgetLab/Catalog/Animations/KeyframeAnimatorEntry.swift`
- Create: `WidgetLab/Catalog/Animations/TimelineViewEntry.swift`
- Create: `WidgetLab/Catalog/Animations/TransitionEntry.swift`
- Create: `WidgetLab/Catalog/Animations/ContentTransitionEntry.swift`
- Create: `WidgetLab/Catalog/Animations/TransactionEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.animation`、`CatalogEntry.phaseAnimator`、`CatalogEntry.keyframeAnimator`、`CatalogEntry.timelineView`、`CatalogEntry.transition`、`CatalogEntry.contentTransition`、`CatalogEntry.transaction`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py animations`
Expected: 終了コード 1。抜けに animation・PhaseAnimator・KeyframeAnimator・TimelineView・transition・contentTransition・transaction がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/Animations/AnimationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let animation = CatalogEntry(
        id: "animation",
        kind: .modifier,
        topic: .animations,
        summary: "value が変わったときに、この View の変化を指定のアニメーションで動かす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/animation(_:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "animation",
                .choice(
                    [
                        Choice(".default"), Choice(".linear(duration: 1)"), Choice(".easeInOut(duration: 1)"),
                        Choice(".spring(duration: 1, bounce: 0.5)"), Choice(".bouncy"), Choice(".smooth"),
                    ],
                    initial: 3),
                on: true, summary: "動き方（OFF なら一瞬で変わる）"),
            .modifier(
                "animation", id: "animation.value", label: "value", .fixed(code: "moved"), required: true,
                summary: "見張る値。変わったときだけ動かす"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Circle()", "        .fill(.blue)", "        .frame(width: 40, height: 40)"],
            indent: 8, call: ".offset", fixedArguments: ["x: moved ? 80 : -80"],
            closing: ["    Button(\"動かす\") { moved.toggle() }", "}"]),
        build: { v in
            AnyView(
                AnimationDemo(
                    animation: v.pick(
                        "animation",
                        from: [
                            Animation.default, .linear(duration: 1), .easeInOut(duration: 1),
                            .spring(duration: 1, bounce: 0.5), .bouncy, .smooth,
                        ])))
        }
    )
}

private struct AnimationDemo: View {
    /// nil なら modifier をかけない
    let animation: Animation?
    @State private var moved = false

    var body: some View {
        VStack {
            Circle()
                .fill(.blue)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
                .apply(animation) { $0.animation($1, value: moved) }
            Button("動かす") { moved.toggle() }
                .buttonStyle(.bordered)
        }
        .frame(width: 220)
    }
}
```

`WidgetLab/Catalog/Animations/PhaseAnimatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let phaseAnimator = CatalogEntry(
        id: "PhaseAnimator",
        kind: .view,
        topic: .animations,
        summary: "渡した段階（phase）を順に切り替え、段階ごとの見た目のあいだをアニメーションでつなぐ入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/phaseanimator")!,
        stage: .card,
        properties: [
            .argument(
                "phases", unlabeled: true,
                .choice(
                    [Choice("2 段", code: "[1.0, 1.4]"), Choice("3 段", code: "[1.0, 1.4, 0.7]")], initial: 0),
                required: true, summary: "切り替える段階の値（ここでは大きさの倍率）"),
            .argument(
                "trigger", .fixed(code: "count"),
                summary: "見張る値。変わるたびに段階を 1 周する（省くと、ずっと繰り返す）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "PhaseAnimator",
            trailing: " { scale in\n        Image(systemName: \"heart.fill\")\n            .font(.system(size: 48))\n"
                + "            .foregroundStyle(.pink)\n            .scaleEffect(scale)\n    } animation: { _ in\n"
                + "        .bouncy\n    }",
            closing: ["    Button(\"+1\") { count += 1 }", "}"]),
        build: { v in
            AnyView(
                PhaseAnimatorDemo(
                    phases: v.pick("phases", from: [[1.0, 1.4], [1.0, 1.4, 0.7]]) ?? [1.0, 1.4],
                    usesTrigger: v["trigger"] != nil))
        }
    )
}

private struct PhaseAnimatorDemo: View {
    let phases: [Double]
    let usesTrigger: Bool
    @State private var count = 0

    var body: some View {
        VStack {
            if usesTrigger {
                PhaseAnimator(phases, trigger: count) { scale in
                    heart(scale)
                } animation: { _ in
                    .bouncy
                }
            } else {
                PhaseAnimator(phases) { scale in
                    heart(scale)
                } animation: { _ in
                    .bouncy
                }
            }
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
        }
    }

    private func heart(_ scale: Double) -> some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 48))
            .foregroundStyle(.pink)
            .scaleEffect(scale)
    }
}
```

`WidgetLab/Catalog/Animations/KeyframeAnimatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let keyframeAnimator = CatalogEntry(
        id: "KeyframeAnimator",
        kind: .view,
        topic: .animations,
        summary: "キーフレーム（時間と値の組）の並びに沿って値を動かし、その値で中身を描く入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/keyframeanimator")!,
        stage: .card,
        properties: [
            .argument(
                "initialValue", .fixed(code: "1.0"), required: true, summary: "動かす値の最初の値（ここでは大きさの倍率）"),
            .argument(
                "trigger", unlabeled: true,
                .choice(
                    [Choice("trigger", code: "trigger: count"), Choice("repeating", code: "repeating: true")],
                    initial: 0),
                required: true, summary: "いつ動かすか。trigger は値が変わるたび、repeating はずっと繰り返す"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "KeyframeAnimator",
            trailing: " { scale in\n        Image(systemName: \"star.fill\")\n            .font(.system(size: 48))\n"
                + "            .foregroundStyle(.orange)\n            .scaleEffect(scale)\n    } keyframes: { _ in\n"
                + "        KeyframeTrack {\n            CubicKeyframe(1.6, duration: 0.2)\n"
                + "            SpringKeyframe(1.0, duration: 0.6)\n        }\n    }",
            closing: ["    Button(\"+1\") { count += 1 }", "}"]),
        build: { v in
            AnyView(KeyframeAnimatorDemo(repeats: v.pick("trigger", from: [false, true]) ?? false))
        }
    )
}

private struct KeyframeAnimatorDemo: View {
    let repeats: Bool
    @State private var count = 0

    var body: some View {
        VStack {
            if repeats {
                KeyframeAnimator(initialValue: 1.0, repeating: true) { scale in
                    star(scale)
                } keyframes: { _ in
                    track
                }
            } else {
                KeyframeAnimator(initialValue: 1.0, trigger: count) { scale in
                    star(scale)
                } keyframes: { _ in
                    track
                }
            }
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
        }
    }

    private var track: some Keyframes<Double> {
        KeyframeTrack {
            CubicKeyframe(1.6, duration: 0.2)
            SpringKeyframe(1.0, duration: 0.6)
        }
    }

    private func star(_ scale: Double) -> some View {
        Image(systemName: "star.fill")
            .font(.system(size: 48))
            .foregroundStyle(.orange)
            .scaleEffect(scale)
    }
}
```

`WidgetLab/Catalog/Animations/TimelineViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let timelineView = CatalogEntry(
        id: "TimelineView",
        kind: .view,
        topic: .animations,
        summary: "渡した予定（schedule）の時刻ごとに、中身を描き直す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/timelineview")!,
        stage: .card,
        properties: [
            .argument(
                "schedule", unlabeled: true,
                .choice(
                    [
                        Choice(".everyMinute"), Choice(".periodic(from: .now, by: 1)"), Choice(".animation"),
                        Choice(".animation(minimumInterval: 0.5)"),
                    ],
                    initial: 1),
                required: true, summary: "描き直す時刻の予定。.animation は画面の書き換えのたび")
        ],
        code: CodeTemplate(
            call: "TimelineView",
            trailing: " { context in\n"
                + "    let seconds = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)\n"
                + "    VStack {\n        Text(context.date, format: .dateTime.hour().minute().second())\n"
                + "        Capsule()\n            .fill(.blue)\n            .frame(width: 4, height: 40)\n"
                + "            .offset(y: -20)\n            .rotationEffect(.degrees(seconds * 6))\n    }\n}"),
        build: { v in
            AnyView(TimelineViewDemo.view(schedule: v.pick("schedule", from: TimelineViewDemo.Schedule.allCases)))
        }
    )
}

private enum TimelineViewDemo {
    enum Schedule: CaseIterable {
        case everyMinute, periodic, animation, animationHalfSecond
    }

    @ViewBuilder
    static func view(schedule: Schedule?) -> some View {
        switch schedule ?? .periodic {
        case .everyMinute: TimelineView(.everyMinute) { content($0.date) }
        case .periodic: TimelineView(.periodic(from: .now, by: 1)) { content($0.date) }
        case .animation: TimelineView(.animation) { content($0.date) }
        case .animationHalfSecond: TimelineView(.animation(minimumInterval: 0.5)) { content($0.date) }
        }
    }

    private static func content(_ date: Date) -> some View {
        let seconds = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
        return VStack {
            Text(date, format: .dateTime.hour().minute().second())
            Capsule()
                .fill(.blue)
                .frame(width: 4, height: 40)
                .offset(y: -20)
                .rotationEffect(.degrees(seconds * 6))
        }
    }
}
```

`WidgetLab/Catalog/Animations/TransitionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transition = CatalogEntry(
        id: "transition",
        kind: .modifier,
        topic: .animations,
        summary: "View が現れるときと消えるときの動き方を決める modifier。アニメーションの中で出し入れしたときに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transition",
                .choice(
                    [
                        Choice(".opacity"), Choice(".slide"), Choice(".scale"), Choice(".move(edge: .bottom)"),
                        Choice(".push(from: .leading)"), Choice(".blurReplace"),
                    ],
                    initial: 1),
                on: true, summary: "出し入れの動き方（OFF なら .opacity）")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {",
                "    Button(\"出し入れ\") { withAnimation { isShown.toggle() } }",
                "    if isShown {",
                "        Text(\"見本\")",
                "            .padding()",
            ],
            indent: 12, call: ".background", fixedArguments: [".yellow"], closing: ["    }", "}"]),
        build: { v in
            AnyView(TransitionDemo(transition: v.pick("transition", from: TransitionDemo.transitions)))
        }
    )
}

private struct TransitionDemo: View {
    @MainActor static let transitions: [AnyTransition] = [
        .opacity, .slide, .scale, .move(edge: .bottom), .push(from: .leading), AnyTransition(.blurReplace),
    ]

    /// nil なら modifier をかけない
    let transition: AnyTransition?
    @State private var isShown = true

    var body: some View {
        VStack {
            Button("出し入れ") { withAnimation { isShown.toggle() } }
                .buttonStyle(.bordered)
            if isShown {
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .apply(transition) { $0.transition($1) }
            }
        }
        .frame(width: 200, height: 120, alignment: .top)
    }
}
```

`WidgetLab/Catalog/Animations/ContentTransitionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contentTransition = CatalogEntry(
        id: "contentTransition",
        kind: .modifier,
        topic: .animations,
        summary: "View の中身（文字や記号）が変わるときの動き方を決める modifier。アニメーションの中で変えたときに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contenttransition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contentTransition",
                .choice(
                    [
                        Choice(".numericText()"), Choice(".numericText(countsDown: true)"), Choice(".interpolate"),
                        Choice(".opacity"), Choice(".identity"),
                    ],
                    initial: 0),
                on: true, summary: "中身の変わり方。.numericText は数字を桁ごとに送る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"\\(count)\")"], indent: 8, call: ".font",
            fixedArguments: [".system(size: 56, weight: .bold)"],
            closing: ["    Button(\"+1\") { withAnimation { count += 1 } }", "}"]),
        build: { v in
            AnyView(
                ContentTransitionDemo(
                    transition: v.pick(
                        "contentTransition",
                        from: [
                            ContentTransition.numericText(), .numericText(countsDown: true), .interpolate, .opacity,
                            .identity,
                        ])))
        }
    )
}

private struct ContentTransitionDemo: View {
    /// nil なら modifier をかけない
    let transition: ContentTransition?
    @State private var count = 9

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.system(size: 56, weight: .bold))
                .apply(transition) { $0.contentTransition($1) }
            Button("+1") { withAnimation { count += 1 } }
                .buttonStyle(.bordered)
        }
    }
}
```

`WidgetLab/Catalog/Animations/TransactionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transaction = CatalogEntry(
        id: "transaction",
        kind: .modifier,
        topic: .animations,
        summary: "この View の中の変化にかかるアニメーション（Transaction）を、書き換える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transaction",
                .choice(
                    [
                        Choice("動きを消す", code: "{ $0.animation = nil }"),
                        Choice("ゆっくり", code: "{ $0.animation = .linear(duration: 2) }"),
                        Choice("跳ねる", code: "{ $0.animation = .bouncy(extraBounce: 0.3) }"),
                    ],
                    initial: 1),
                on: true, summary: "書き換え方。下の円だけが変わり、上の円は withAnimation のまま動く")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {",
                "    Circle()",
                "        .fill(.blue)",
                "        .frame(width: 40, height: 40)",
                "        .offset(x: moved ? 80 : -80)",
                "    Circle()",
                "        .fill(.orange)",
                "        .frame(width: 40, height: 40)",
            ],
            indent: 8, call: ".offset", fixedArguments: ["x: moved ? 80 : -80"],
            closing: ["    Button(\"動かす\") { withAnimation { moved.toggle() } }", "}"]),
        build: { v in
            AnyView(TransactionDemo(change: v.pick("transaction", from: TransactionDemo.Change.allCases)))
        }
    )
}

private struct TransactionDemo: View {
    enum Change: CaseIterable {
        case removes, slow, bouncy
    }

    /// nil なら modifier をかけない
    let change: Change?
    @State private var moved = false

    var body: some View {
        VStack {
            Circle()
                .fill(.blue)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
            Circle()
                .fill(.orange)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
                .apply(change) { view, change in
                    view.transaction { transaction in
                        switch change {
                        case .removes: transaction.animation = nil
                        case .slow: transaction.animation = .linear(duration: 2)
                        case .bouncy: transaction.animation = .bouncy(extraBounce: 0.3)
                        }
                    }
                }
            Button("動かす") { withAnimation { moved.toggle() } }
                .buttonStyle(.bordered)
        }
        .frame(width: 220)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .animation,
        .phaseAnimator,
        .keyframeAnimator,
        .timelineView,
        .transition,
        .contentTransition,
        .transaction,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Animations/AnimationEntry.swift \
  WidgetLab/Catalog/Animations/PhaseAnimatorEntry.swift \
  WidgetLab/Catalog/Animations/KeyframeAnimatorEntry.swift \
  WidgetLab/Catalog/Animations/TimelineViewEntry.swift \
  WidgetLab/Catalog/Animations/TransitionEntry.swift \
  WidgetLab/Catalog/Animations/ContentTransitionEntry.swift \
  WidgetLab/Catalog/Animations/TransactionEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: animation・PhaseAnimator・KeyframeAnimator・TimelineView・transition・contentTransition・transaction を収録する"
```

---

### Task 6: 動き 2（matchedGeometryEffect・@Namespace・geometryGroup・matchedTransitionSource・navigationTransition）と束の確かめ

`MatchedGeometryDemo` は matchedGeometryEffect と @Namespace の 2 件、`ZoomTransitionDemo` は matchedTransitionSource と navigationTransition の 2 件が使う補助。

**Files:**
- Create: `WidgetLab/Catalog/Animations/MatchedGeometryDemo.swift`
- Create: `WidgetLab/Catalog/Animations/MatchedGeometryEffectEntry.swift`
- Create: `WidgetLab/Catalog/Animations/NamespaceEntry.swift`
- Create: `WidgetLab/Catalog/Animations/GeometryGroupEntry.swift`
- Create: `WidgetLab/Catalog/Animations/ZoomTransitionDemo.swift`
- Create: `WidgetLab/Catalog/Animations/MatchedTransitionSourceEntry.swift`
- Create: `WidgetLab/Catalog/Animations/NavigationTransitionEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（束 5 でわかったこと）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`PropertySpec.wrapper(_:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`WrapperCode(withWrapper:withoutWrapper:)`、`View.apply(_:_:)`、`TextInputDemo`（`Catalog/TextInputAndOutput/TextInputDemo.swift`）
- Produces: `CatalogEntry.matchedGeometryEffect`、`CatalogEntry.namespace`、`CatalogEntry.geometryGroup`、`CatalogEntry.matchedTransitionSource`、`CatalogEntry.navigationTransition`、`MatchedGeometryDemo(usesNamespace: Bool = true, matching: MatchedGeometryDemo.Matching?)`、`MatchedGeometryDemo.Matching(properties:anchor:)`、`ZoomTransitionDemo(source: ZoomTransitionDemo.Source?, zooms: Bool)`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py view-styles images animations`
Expected: 終了コード 1。抜けに matchedGeometryEffect・Namespace・geometryGroup・matchedTransitionSource・navigationTransition がある

- [ ] **Step 2: 収録のファイルを作る**

次のファイルを、書いてあるとおりに作る（試作でテストと画像を通したもの。引用符や `\(` を書き換えない）。

`WidgetLab/Catalog/Animations/MatchedGeometryDemo.swift`:

```swift
import SwiftUI

/// matchedGeometryEffect と @Namespace の見本。押した名前の後ろへ、黄色の帯が動いていく。
/// 帯に matchedGeometryEffect（isSource: false）をかけると、選んだ名前の枠に合わせる。かけないと、並び全体の後ろに出る
struct MatchedGeometryDemo: View {
    /// 帯にかける modifier の引数。nil なら帯に modifier をかけない
    struct Matching {
        var properties: MatchedGeometryProperties = .frame
        var anchor: UnitPoint = .center
    }

    /// false なら @Namespace を使わない（名前にも帯にも matchedGeometryEffect をかけない）
    var usesNamespace = true
    let matching: Matching?
    @Namespace private var namespace
    @State private var selected = "りんご"

    var body: some View {
        HStack {
            ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { name in
                Text(name)
                    .padding(8)
                    .apply(usesNamespace ? () : nil) { view, _ in
                        view.matchedGeometryEffect(id: name, in: namespace)
                    }
                    .onTapGesture { withAnimation { selected = name } }
            }
        }
        .background {
            Capsule()
                .fill(.yellow)
                .apply(usesNamespace ? matching : nil) { view, matching in
                    view.matchedGeometryEffect(
                        id: selected, in: namespace, properties: matching.properties, anchor: matching.anchor,
                        isSource: false)
                }
        }
    }
}
```

`WidgetLab/Catalog/Animations/MatchedGeometryEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let matchedGeometryEffect = CatalogEntry(
        id: "matchedGeometryEffect",
        kind: .modifier,
        topic: .animations,
        summary: "同じ id と名前空間を持つ View どうしで、位置と大きさをそろえる modifier。切り替えると、元の View から動いていく。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.id", label: "id", .fixed(code: "selected"),
                required: true, summary: "そろえる相手の id。選んだ名前の id に合わせる"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.in", label: "in", .fixed(code: "namespace"),
                required: true, summary: "id を探す名前空間（@Namespace）"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.properties", label: "properties",
                .choice([Choice(".frame"), Choice(".position"), Choice(".size")], initial: 0), on: true,
                summary: "そろえるもの。.position は位置だけ、.size は大きさだけ"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.anchor", label: "anchor",
                .choice([Choice(".center"), Choice(".leading"), Choice(".trailing")], initial: 1),
                summary: "位置をそろえる基準の点"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.isSource", label: "isSource",
                .fixed(code: "false"), required: true,
                summary: "false なら、相手（名前の Text）の枠に自分を合わせる側になる"),
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {",
                "    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { name in",
                "        Text(name)",
                "            .padding(8)",
                "            .matchedGeometryEffect(id: name, in: namespace)",
                "            .onTapGesture { withAnimation { selected = name } }",
                "    }",
                "}",
                ".background {",
                "    Capsule()",
            ],
            indent: 8, call: ".fill", fixedArguments: [".yellow"], closing: ["}"]),
        build: { v in
            let hasArguments = v["matchedGeometryEffect.properties"] != nil || v["matchedGeometryEffect.anchor"] != nil
            return AnyView(
                MatchedGeometryDemo(
                    matching: hasArguments
                        ? MatchedGeometryDemo.Matching(
                            properties: v.pick(
                                "matchedGeometryEffect.properties",
                                from: [MatchedGeometryProperties.frame, .position, .size]) ?? .frame,
                            anchor: v.pick(
                                "matchedGeometryEffect.anchor", from: [UnitPoint.center, .leading, .trailing])
                                ?? .center)
                        : nil))
        }
    )
}
```

`WidgetLab/Catalog/Animations/NamespaceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let namespace = CatalogEntry(
        id: "Namespace",
        kind: .propertyWrapper,
        topic: .animations,
        summary: "matchedGeometryEffect などで、View の id を探す範囲（名前空間）を作るプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/namespace")!,
        stage: .card,
        properties: [
            .wrapper("Namespace", summary: "外すと名前空間がないので matchedGeometryEffect が書けず、帯は並び全体の後ろに出たまま動かない")
        ],
        code: CodeTemplate(
            call: "Namespace",
            wrapper: WrapperCode(
                withWrapper: [
                    "@Namespace private var namespace",
                    "",
                    "var body: some View {",
                    "    HStack {",
                    "        ForEach(names, id: \\.self) { name in",
                    "            Text(name)",
                    "                .padding(8)",
                    "                .matchedGeometryEffect(id: name, in: namespace)",
                    "                .onTapGesture { withAnimation { selected = name } }",
                    "        }",
                    "    }",
                    "    .background {",
                    "        Capsule()",
                    "            .fill(.yellow)",
                    "            .matchedGeometryEffect(id: selected, in: namespace, isSource: false)",
                    "    }",
                    "}",
                ],
                withoutWrapper: [
                    "var body: some View {",
                    "    HStack {",
                    "        ForEach(names, id: \\.self) { name in",
                    "            Text(name)",
                    "                .padding(8)",
                    "                .onTapGesture { withAnimation { selected = name } }",
                    "        }",
                    "    }",
                    "    .background {",
                    "        Capsule()",
                    "            .fill(.yellow)",
                    "    }",
                    "}",
                ])),
        build: { v in
            AnyView(
                MatchedGeometryDemo(
                    usesNamespace: v["Namespace"] != nil, matching: MatchedGeometryDemo.Matching()))
        }
    )
}
```

`WidgetLab/Catalog/Animations/GeometryGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let geometryGroup = CatalogEntry(
        id: "geometryGroup",
        kind: .modifier,
        topic: .animations,
        summary: "この View の位置と大きさを親の側でまとめて動かし、決まった位置と大きさを中の View へ渡す modifier。中の View が自分のアニメーションを持っていても、親と一緒に動く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/geometrygroup()")!,
        stage: .card,
        properties: [
            .modifier(
                "geometryGroup", .fixed(code: ""), on: true,
                summary: "外すと、アニメーションを消した星だけが、動きの終わりの場所へいきなり飛ぶ")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "ZStack", fixedArguments: ["alignment: .topLeading"],
            trailing: " {\n        Color.yellow\n        Image(systemName: \"star.fill\")\n            .padding(8)\n"
                + "            .transaction { $0.animation = nil }\n    }",
            suffix: [".frame(width: isLarge ? 200 : 80, height: isLarge ? 100 : 50)"],
            closing: [
                "    Button(\"大きさを変える\") {", "        withAnimation(.easeInOut(duration: 1.5)) { isLarge.toggle() }",
                "    }", "}",
            ]),
        build: { v in
            AnyView(GeometryGroupDemo(groups: v["geometryGroup"] != nil))
        }
    )
}

private struct GeometryGroupDemo: View {
    let groups: Bool
    @State private var isLarge = false

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Color.yellow
                Image(systemName: "star.fill")
                    .padding(8)
                    .transaction { $0.animation = nil }
            }
            .apply(groups ? () : nil) { view, _ in view.geometryGroup() }
            .frame(width: isLarge ? 200 : 80, height: isLarge ? 100 : 50)
            Button("大きさを変える") {
                withAnimation(.easeInOut(duration: 1.5)) { isLarge.toggle() }
            }
            .buttonStyle(.bordered)
        }
        .frame(height: 160)
    }
}
```

`WidgetLab/Catalog/Animations/ZoomTransitionDemo.swift`:

```swift
import SwiftUI

/// matchedTransitionSource と navigationTransition の見本。写真のボタンを押すと sheet が開く。
/// 開く側に .zoom、ボタンに matchedTransitionSource をかけると、ボタンから大きくなって開く
struct ZoomTransitionDemo: View {
    /// ボタンにかける matchedTransitionSource の見た目。nil なら modifier をかけない
    enum Source {
        case plain, rounded, shadow
    }

    let source: Source?
    /// false なら、開く側に navigationTransition(.zoom) をかけない
    let zooms: Bool
    @Namespace private var namespace
    @State private var isShown = false

    var body: some View {
        Button {
            isShown = true
        } label: {
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.yellow, in: .rect(cornerRadius: 16))
        }
        .apply(source) { view, source in
            switch source {
            case .plain: view.matchedTransitionSource(id: "photo", in: namespace)
            case .rounded:
                view.matchedTransitionSource(id: "photo", in: namespace) {
                    $0.background(.yellow).clipShape(.rect(cornerRadius: 16))
                }
            case .shadow: view.matchedTransitionSource(id: "photo", in: namespace) { $0.shadow(radius: 8) }
            }
        }
        .sheet(isPresented: $isShown) {
            Image(systemName: "photo.fill")
                .font(.system(size: 120))
                .apply(zooms ? () : nil) { view, _ in
                    view.navigationTransition(.zoom(sourceID: "photo", in: namespace))
                }
        }
    }
}
```

`WidgetLab/Catalog/Animations/MatchedTransitionSourceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let matchedTransitionSource = CatalogEntry(
        id: "matchedTransitionSource",
        kind: .modifier,
        topic: .animations,
        summary: "この View を、ズームの遷移（navigationTransition(.zoom)）の始まりの場所にする modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:configuration:)")!,
        stage: .card,
        properties: [
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.id", label: "id", .fixed(code: "\"photo\""),
                required: true, summary: "遷移の相手と合わせる id"),
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.in", label: "in", .fixed(code: "namespace"),
                required: true, summary: "id を探す名前空間（@Namespace）"),
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.configuration", label: "configuration",
                .choice(
                    [
                        Choice("そのまま", code: "{ $0 }"),
                        Choice("背景と角", code: "{ $0.background(.yellow).clipShape(.rect(cornerRadius: 16)) }"),
                        Choice("影", code: "{ $0.shadow(radius: 8) }"),
                    ],
                    initial: 1),
                on: true,
                summary: "遷移のあいだの、始まりの View の見た目。OFF にすると modifier ごと外れ、画面の真ん中から開く"),
        ],
        code: CodeTemplate(
            call: "Button",
            trailing:
                " { isShown = true } label: {\n    Image(systemName: \"photo.fill\")\n        .font(.largeTitle)\n"
                + "        .frame(width: 80, height: 80)\n        .background(.yellow, in: .rect(cornerRadius: 16))\n}",
            suffix: [".sheet(isPresented: $isShown) {"],
            closing: [
                "    Image(systemName: \"photo.fill\")", "        .font(.system(size: 120))",
                "        .navigationTransition(.zoom(sourceID: \"photo\", in: namespace))", "}",
            ]),
        build: { v in
            AnyView(
                ZoomTransitionDemo(
                    source: v.pick(
                        "matchedTransitionSource.configuration",
                        from: [ZoomTransitionDemo.Source.plain, .rounded, .shadow]),
                    zooms: true))
        }
    )
}
```

`WidgetLab/Catalog/Animations/NavigationTransitionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationTransition = CatalogEntry(
        id: "navigationTransition",
        kind: .modifier,
        topic: .animations,
        summary: "この View へ移るとき（push・sheet・fullScreenCover）の遷移の動き方を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationtransition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "navigationTransition",
                .choice([Choice(".zoom(sourceID: \"photo\", in: namespace)"), Choice(".automatic")], initial: 0),
                on: true, summary: "遷移の動き方。.zoom は matchedTransitionSource の View から大きくなって開く")
        ],
        code: CodeTemplate(
            prefix: [
                "Button { isShown = true } label: {",
                "    Image(systemName: \"photo.fill\")",
                "        .font(.largeTitle)",
                "        .frame(width: 80, height: 80)",
                "        .background(.yellow, in: .rect(cornerRadius: 16))",
                "}",
                ".matchedTransitionSource(id: \"photo\", in: namespace)",
                ".sheet(isPresented: $isShown) {",
                "    Image(systemName: \"photo.fill\")",
            ],
            indent: 8, call: ".font", fixedArguments: [".system(size: 120)"], closing: ["}"]),
        build: { v in
            AnyView(
                ZoomTransitionDemo(
                    source: .plain, zooms: v.pick("navigationTransition", from: [true, false]) ?? false))
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .matchedGeometryEffect,
        .namespace,
        .geometryGroup,
        .matchedTransitionSource,
        .navigationTransition,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前（空の行を 1 つはさむ）に足す。List の代表（listStyle。ImageRenderer では白くなる）と、端末の中のファイルを読む AsyncImage を撮る:

```swift
    @MainActor
    func testStyleEntriesShowPreview() {
        for (id, title) in [("listStyle", ".listStyle"), ("AsyncImage", "AsyncImage")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }
```

- [ ] **Step 5: 文書を直す**

次の 5 か所を、左の文字列（ファイルの中に 1 つだけある）から右の文字列に置き換える。

`docs/architecture.md` の

```markdown
レイアウト・描画・テキスト・操作の部品の代表 2 件ずつのスクリーンショットの 7 本）
```

を

```markdown
レイアウト・描画・テキスト・操作の部品・スタイルと動きの代表 2 件ずつのスクリーンショットの 8 本）
```

にする。

`docs/cataloging-guide.md` の

```markdown
束 4 では `materialActiveAppearance` を `.note` にした（iOS では `.inactive` が使えず、窓もいつも手前にあるので、見た目が変わらない）。
```

を

```markdown
束 4 では `materialActiveAppearance` を `.note` にした（iOS では `.inactive` が使えず、窓もいつも手前にあるので、見た目が変わらない）。束 5 では `textEditorStyle`・`tableStyle` を `.note` にした（iPhone では選べる既製のスタイルがどれも同じ見た目になり、`TextEditorStyleConfiguration` は中身を渡さないので自作のスタイルも作れない）。
```

にする。

`docs/cataloging-guide.md` の

```markdown
## 用語
```

を

```markdown
**既製のスタイルが `.automatic` だけ → 自作のスタイルと比べる。** `disclosureGroupStyle`・`groupBoxStyle`・`labeledContentStyle` は、iOS の既製のスタイルが `.automatic` しかない。選択肢を `.automatic` と `Choice("自作", code: "TintedGroupBoxStyle()")` にし、自作のスタイルの struct を `closing` に空の行をはさんで書く（コードに定義まで出る）。見本の側では同じ名前の `private struct` を使う。

**アニメーションの見本 → 値と動かすボタンを、見本の `private struct` に持たせる。** `build` の中では `@State` を持てないので、`AnimationDemo` のように struct に `@State` とボタンを置く。コードはボタンまで書く（`closing` に `Button(…)` と `}`）。テストの画像では動きが見えないので、一時的な UI テストでボタンを押して 0.4〜0.5 秒後に撮る。比べるは左右で 2 つの見本が重なり、途中の見た目が読みにくいので、チップの「付ける」を切って片方ずつ撮る。

**ネットから読む見本 → 端末の一時フォルダに書いたファイルの URL を渡す。** アプリはオフラインで動くので、`AsyncImage` は `AsyncImageDemo` が `ImageRenderer` で書き出した PNG の file URL を読む。コードには `https://example.com/…` と書き、要約にそのことを書く。

**UI テストで編集パネルの選択肢を押す → 名前（label）で探す。** 選択肢は `staticTexts[".automatic"]` では見つからない。`app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", ".automatic")).firstMatch` で押す。チップを OFF にするのは、`app.buttons["chip-<id>"]` を押してから `app.switches["editor-on"]` を押す。

## 用語
```

にする。

`docs/cataloging-guide.md` の

```markdown
束 4 は `testDrawingEntriesShowPreview`）。
```

を

```markdown
束 4 は `testDrawingEntriesShowPreview`、束 5 は `testStyleEntriesShowPreview`）。
```

にする。

`docs/cataloging-guide.md` の

```markdown
最終更新: 2026-11-04（束 2・3・4 のあと）
```

を

```markdown
最終更新: 2026-11-04（束 2・3・4・5 のあと）
```

にする。

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テスト（8 本）が全部通る

Run: `python3 tools/catalog_progress.py view-styles images animations`
Expected: 終了コード 0。`合計 40 / 40（抜け 0）`

- [ ] **Step 7: スクリーンショットを見る**

Run: `rm -rf build/shots && xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `build/shots/manifest.json` で名前が `listStyle`・`AsyncImage` の画像を開く。`listStyle` は「果物」の見出しの下に「りんご」「みかん」が地の色のまま区切り線で並ぶ（.plain）。`AsyncImage` は青い額縁の写真の記号が出ている（読み込みに失敗した三角の印や、回る印ではない）

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/Animations/MatchedGeometryDemo.swift \
  WidgetLab/Catalog/Animations/MatchedGeometryEffectEntry.swift \
  WidgetLab/Catalog/Animations/NamespaceEntry.swift \
  WidgetLab/Catalog/Animations/GeometryGroupEntry.swift \
  WidgetLab/Catalog/Animations/ZoomTransitionDemo.swift \
  WidgetLab/Catalog/Animations/MatchedTransitionSourceEntry.swift \
  WidgetLab/Catalog/Animations/NavigationTransitionEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  docs/architecture.md \
  docs/cataloging-guide.md
git commit -m "feat: matchedGeometryEffect・Namespace・geometryGroup・matchedTransitionSource・navigationTransition を収録し、スタイルと動きの代表のスクリーンショットを撮る"
```

---

## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、`~/dev/widget-lab`（main）で `--no-ff` でマージし、main で lint と単体テストを通してから push する（ブランチは消さない）。マージの前に `git -C ~/dev/widget-lab status` がきれいなこと（`.claude/` の未追跡は元からある）と、ほかの束がマージの途中でないことを確かめる。`Catalog.swift`・`LaunchUITests.swift`・`docs/architecture.md`・収録の手引きがぶつかったら、両方の行を残す
