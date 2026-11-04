# SwiftUI 版 Phase 3 束 6（一覧とスクロール）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** lists・tables・scroll-views の 46 件を収録し、3 トピックの抜けを 0 にする。

**Architecture:** 収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。Task 1〜7 で、1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/<トピック>/<名前>Entry.swift`）を 5〜7 件ずつ足し、`Catalog.all` に並べる。新しいフォルダは `Lists`・`Tables`・`ScrollViews`。複数の収録で使う見本の部品は `<名前>Demo.swift`（`SectionIndexDemo`・`ScrollCardsDemo`・`EdgeEffectDemo`）に置く。stage は `.card` が 43 件、`.behavior` が 1 件、`.note` が 2 件。Task 7 で代表 2 件のスクリーンショットの UI テストと、試作でわかったことを収録の手引きに足す。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 6 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone Air**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` は、この束ではすべて `name=iPhone Air` に置き換える（並列で動く束とシミュレータを分けるため）
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
  UI テストまで通すのは Task 7 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。プロパティはチップの順。* は最初から ON、R は required。stage は書いていなければ `.card`。List・ScrollView・Table の見本は `ImageRenderer` では白く描かれるので、見た目は試作のシミュレータのスクリーンショットで確かめた（46 件の詳細画面・比べる・トピック画面、操作してからの 11 枚）。

### lists（23 件）

| id | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|
| List | View | selection*（`$selected`）・.listStyle*（5 つ）・.tint | `List(selection: $selected) { ForEach(果物) { Text($0) } }.listStyle(.insetGrouped)` |
| OutlineGroup | View（入れ子） | children R（`\.children`） | `List { OutlineGroup(tree, children: \.children) { item in Text(item.name) } }` |
| DisclosureGroup | View（入れ子） | title R・isExpanded*（`$isExpanded`、最初は開く）・.tint | `List { DisclosureGroup("詳しい設定", isExpanded: $isExpanded) { Toggle; Text } }` |
| listRowInsets | 付け外し（入れ子） | .listRowInsets edges R（3 つ）・length*（0〜60） | `List { Text("行 1").frame(…).background(.yellow).listRowInsets(.leading, 48); Text("行 2") }` |
| listRowSpacing | 付け外し | .listRowSpacing*（0〜24）・.listStyle（2 つ） | `List { ForEach(果物) }.listRowSpacing(12)` |
| listSectionSpacing | 付け外し | .listSectionSpacing*（.compact・.default・.custom(60)） | `List { Section × 3 }.listSectionSpacing(.compact)` |
| listSectionMargins | 付け外し（入れ子） | .listSectionMargins edges R（3 つ）・length*（0〜60） | `List { Section("果物") { … }.listSectionMargins(.horizontal, 48); Section("野菜") }` |
| listItemTint | 付け外し（入れ子） | .listItemTint*（.fixed・.preferred・.monochrome） | `List { ForEach { Label(name, systemImage: "tray") }.listItemTint(.fixed(.orange)) }.listStyle(.sidebar)` |
| headerProminence | 付け外し（入れ子） | .headerProminence*（.increased・.standard） | `List { Section("果物") { … }.headerProminence(.increased); Section("野菜") }` |
| listRowSeparatorTint | 付け外し（入れ子） | 色*・edges R（3 つ） | `List { ForEach(果物) { Text($0) }.listRowSeparatorTint(.red, edges: .all) }` |
| listSectionSeparatorTint | 付け外し（入れ子） | 色*・edges R（3 つ） | `List { Section("果物") { … }.listSectionSeparatorTint(.red, edges: .all); … }.listStyle(.plain)` |
| listRowSeparator | 付け外し（入れ子） | visibility*（3 つ）・edges R（3 つ） | `List { ForEach(果物) { Text($0) }.listRowSeparator(.hidden, edges: .all) }` |
| listSectionSeparator | 付け外し（入れ子） | visibility*（3 つ）・edges R（3 つ） | `List { Section("果物") { … }.listSectionSeparator(.hidden, edges: .all); … }.listStyle(.plain)` |
| listRowBackground | 付け外し（入れ子） | .listRowBackground*（Color.yellow・Color.mint.opacity(0.4)・Capsule().fill(.orange)） | `List { Text("りんご").listRowBackground(Color.yellow); Text("みかん") }` |
| badge | 付け外し（入れ子） | .badge*（3・"新着"・0）・.badgeProminence | `List { Text("受信").badge(3); Text("送信済み") }` |
| badgeProminence | 付け外し | .badgeProminence*（.increased・.decreased・.standard） | `List { Text("受信").badge(3); Text("下書き").badge("新着") }.badgeProminence(.increased)` |
| swipeActions | 付け外し（入れ子） | edge R（2 つ）・allowsFullSwipe R・content*（削除のボタン） | `List { ForEach(items) { item in Text(item).swipeActions(edge: .trailing, allowsFullSwipe: false, content: { … }) } }` |
| selectionDisabled | 付け外し（入れ子） | .selectionDisabled*（`item == "みかん"`） | `List(selection: $selected) { ForEach { item in Text(item).selectionDisabled(item == "みかん") } }` |
| refreshable | 付け外し | .refreshable(action:)*（`{ await reload() }`） | `List { Text("更新した回数: \(count)"); Text("下に引っ張る") }.refreshable(action: { await reload() })` |
| moveDisabled | 付け外し（入れ子） | .moveDisabled*（`item == "りんご"`） | `List { ForEach(items) { item in Text(item).moveDisabled(item == "りんご") }.onMove { … } }.environment(\.editMode, .constant(.active))` |
| deleteDisabled | 付け外し（入れ子） | .deleteDisabled*（`item == "りんご"`） | 同じ形で `.deleteDisabled` と `.onDelete` |
| listSectionIndexVisibility | 付け外し | .listSectionIndexVisibility*（.hidden・.visible・.automatic） | `List { ForEach(groups) { Section(group.letter) { … }.sectionIndexLabel(group.letter) } }.listSectionIndexVisibility(.hidden)` |
| sectionIndexLabel | 付け外し（入れ子） | .sectionIndexLabel*（`group.letter`） | `List { ForEach(groups) { group in Section(group.letter) { … }.sectionIndexLabel(group.letter) } }.listSectionIndexVisibility(.visible)` |

### tables（2 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| Table | .card | View | selection*（`$selected`）・.tint | `Table(fruits, selection: $selected) { TableColumn("名前", value: \.name); 産地; 値段 }` |
| tableColumnHeaders | .note | 付け外し | .tableColumnHeaders*（.hidden・.visible・.automatic） | `Table(fruits) { … }.tableColumnHeaders(.hidden)` |

### scroll-views（21 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| ScrollView | .card | View | axes*（3 つ、最初は両方）・.contentMargins | `ScrollView([.horizontal, .vertical]) { 12 行 × 8 列のタイル }` |
| ScrollViewReader | .card | View（入れ子） | anchor*（scrollTo の引数、3 つ） | `ScrollViewReader { proxy in Button("行 30 へ") { withAnimation { proxy.scrollTo(30, anchor: .center) } }; ScrollView { … .id(i) } }` |
| scrollPosition | .card | 付け外し | id*（`$current`）・anchor R（3 つ） | `ScrollView { LazyVStack { … }.scrollTargetLayout() }.scrollPosition(id: $current, anchor: .top)` |
| defaultScrollAnchor | .card | 付け外し | .defaultScrollAnchor*（.bottom・.center・.top） | `ScrollView { 30 行 }.defaultScrollAnchor(.bottom)` |
| scrollTargetBehavior | .card | 付け外し | .scrollTargetBehavior*（.viewAligned・.paging） | `ScrollView(.horizontal) { LazyHStack { カード }.scrollTargetLayout() }.scrollTargetBehavior(.viewAligned)` |
| scrollTargetLayout | .card | 付け外し（入れ子） | .scrollTargetLayout* | `ScrollView(.horizontal) { LazyHStack { カード }.scrollTargetLayout() }.scrollTargetBehavior(.viewAligned)` |
| scrollTransition | .card | 付け外し（入れ子） | configuration R（2 つ）・transition*（3 つ） | `… Text("行 \(i)").frame(…).background(.yellow).scrollTransition(.interactive, transition: { content, phase in … })` |
| onScrollGeometryChange | .card | 付け外し | for R・of R（3 つ）・action* | `ScrollView { 30 行 }.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { value = $1 })` |
| onScrollTargetVisibilityChange | .card | 付け外し | idType R・threshold R（0.1〜1）・action* | `ScrollView { LazyVStack { … }.scrollTargetLayout() }.onScrollTargetVisibilityChange(idType: Int.self, threshold: 0.5, { visible = $0 })` |
| onScrollVisibilityChange | .card | 付け外し（入れ子） | threshold R・action* | `ScrollView { 12 行; Text("目印").background(.orange).onScrollVisibilityChange(threshold: 0.5, { isVisible = $0 }); 12 行 }` |
| onScrollPhaseChange | .behavior | 付け外し | .onScrollPhaseChange* | `ScrollView { 30 行 }.onScrollPhaseChange({ old, new in print(…) })`。記録に「idle → interacting」など |
| scrollIndicatorsFlash | .card | 付け外し（入れ子） | .scrollIndicatorsFlash*（`trigger: count`・`onAppear: true`） | `VStack { Button("+1"); ScrollView { … }.scrollIndicatorsFlash(trigger: count) }` |
| scrollIndicators | .card | 付け外し | .scrollIndicators*（4 つ） | `ScrollView { 30 行 }.scrollIndicators(.hidden)` |
| scrollContentBackground | .card | 付け外し | .scrollContentBackground*（3 つ） | `List { … }.scrollContentBackground(.hidden).background(.mint)` |
| scrollClipDisabled | .card | 付け外し | .scrollClipDisabled*（true） | `ScrollView(.horizontal) { 影の付いたカード }.scrollClipDisabled(true).padding(.horizontal, 48)` |
| scrollDisabled | .card | 付け外し | .scrollDisabled*（true） | `ScrollView { 30 行 }.scrollDisabled(true)` |
| scrollBounceBehavior | .card | 付け外し | .scrollBounceBehavior*（3 つ） | `ScrollView { 2 行 }.scrollBounceBehavior(.basedOnSize)` |
| scrollEdgeEffectStyle | .card | 付け外し | style*（3 つ）・for R（3 つ） | `ScrollView { 色の行 }.defaultScrollAnchor(.center).safeAreaBar(edge: .top, content: { … }).scrollEdgeEffectStyle(.hard, for: .top)` |
| scrollEdgeEffectHidden | .card | 付け外し | hidden*（true）・for R（3 つ） | 同じ形で `.scrollEdgeEffectHidden(true, for: .top)` |
| safeAreaBar | .card | 付け外し | edge R（2 つ）・content* | `ScrollView { 色の行 }.safeAreaBar(edge: .top, content: { Text("見出しのバー").padding(8) }).defaultScrollAnchor(.center)` |
| scrollInputBehavior | .note | 付け外し | behavior*（3 つ）・for R（.look・.handGestureShortcut） | `ScrollView { 30 行 }.scrollInputBehavior(.disabled, for: .look)` |

### `.note` にするもの（2 件、4%）と理由

| id | 理由（`noteReason`） |
|---|---|
| tableColumnHeaders | iPhone（幅が compact）の Table は、最初の列だけを出し、列の見出しを出さない。iPad の幅の広い画面と Mac で効く |
| scrollInputBehavior | 入力の種類が、visionOS の見ることでのスクロール（.look）と、watchOS の指や手首の動き（.handGestureShortcut）だけで、iPhone では効かない |

`tableColumnHeaders` は、はじめ `.card` で、見本の Table に `.environment(\.horizontalSizeClass, .regular)` をかけて列と見出しを出すつもりだった。試作のシミュレータでは、幅の区分を regular にしても最初の列だけが出て、見出しは出なかった。`scrollInputBehavior` の入力の種類（`ScrollInputKind`）は `.handGestureShortcut`・`.look`・`.look(axes:)` だけ（リファレンスの JSON で確かめた）。

### 試作でわかったこと（Task 7 で収録の手引きに足す）

- **省けない引数と既定の値がある引数の組**: `listRowSeparatorTint(_:edges:)` の色は省けず、`edges` は省ける。`edges` を ON / OFF できると、色が OFF で `edges` が ON のとき `.listRowSeparatorTint(edges: .top)` という書けないコードになる。省けない引数を required でない ON にし、既定の値がある引数を required にした（`listRowSeparator`・`listRowInsets`・`listSectionMargins`・`swipeActions`・`scrollPosition`・`scrollTransition`・`onScroll…Change`・`scrollEdgeEffect…`・`safeAreaBar` も同じ）
- **iPhone の Table**: 最初の列だけを 1 列の一覧として出す。`.environment(\.horizontalSizeClass, .regular)` をかけても、列も見出しも出なかった
- **スクロールしないと見えない効き目**: `scrollEdgeEffectStyle` などの端の効果は、バーの下に中身が入らないと見えない。`.defaultScrollAnchor(.center)` で、開いたときから中身がバーの下に入るようにした
- **右端に出る効き目**: List の索引やバッジは右端に出るので、比べるの左半分（付けない側）では見えない。索引は付けないと出る（`.automatic`）ので、`listSectionIndexVisibility` の最初の値を `.hidden` にし、編集パネルの ON / OFF で違いが出るようにした
- **ScrollGeometry の contentOffset**: 上の余白（`safeAreaInset` で置いた表示など）の分だけ負から始まった（試作で -162）。`contentInsets.top` を足して、0 から数えるようにした
- **iPhone の List の選択**: `List(selection:)` に Optional の値を渡すと、編集モードでなくても、タップで行を選べた（`selectionDisabled` の見本はこれを使う）
- **操作してからの見た目**: 一時的な UI テストで、チップ（`chip-<プロパティの id>`）を押し、編集パネルの `editor-on` のスイッチの右端（`coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))`）を押して OFF にした。スイッチの真ん中を押すと切り替わらなかった。引っ張って更新は、行の座標から `press(forDuration:thenDragTo:)` で下へ引いた
- **DisclosureGroup の tint**: 開け閉めの印ではなく、中の Toggle の色にかかった。List の外に置くと、一覧の行の見本が縦に伸びて崩れたので、List の中に置いた

---

### Task 1: 一覧 1（List・OutlineGroup・DisclosureGroup・listRowInsets・listRowSpacing・listSectionSpacing・listSectionMargins）

**Files:**
- Create: `WidgetLab/Catalog/Lists/ListEntry.swift`
- Create: `WidgetLab/Catalog/Lists/OutlineGroupEntry.swift`
- Create: `WidgetLab/Catalog/Lists/DisclosureGroupEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListRowInsetsEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListRowSpacingEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListSectionSpacingEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListSectionMarginsEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.list`、`CatalogEntry.outlineGroup`、`CatalogEntry.disclosureGroup`、`CatalogEntry.listRowInsets`、`CatalogEntry.listRowSpacing`、`CatalogEntry.listSectionSpacing`、`CatalogEntry.listSectionMargins`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1。抜けに List・OutlineGroup・DisclosureGroup・listRowInsets・listRowSpacing・listSectionSpacing・listSectionMargins がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Lists/` のフォルダを作る（Xcode のフォルダの同期で project.pbxproj は変わらない）。

`WidgetLab/Catalog/Lists/ListEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let list = CatalogEntry(
        id: "List",
        kind: .view,
        topic: .lists,
        summary: "データの行を 1 列に並べる入れ物。行を選べるようにもできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/list")!,
        stage: .card,
        properties: [
            .argument("selection", .fixed(code: "$selected"), on: true, summary: "選んだ行を入れる値（タップで行を選ぶ）"),
            .modifier(
                "listStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".insetGrouped"), Choice(".inset"), Choice(".plain"),
                        Choice(".grouped"),
                    ],
                    initial: 1),
                on: true, summary: "一覧の見た目のスタイル"),
            .modifier("tint", .color(initial: 3), summary: "選んだ行の色"),
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { Text($0) }\n}"),
        build: { v in
            AnyView(
                ListDemo(
                    selects: v["selection"] != nil,
                    style: v.pick("listStyle", from: ListDemo.Style.allCases),
                    tint: v.color("tint"))
            )
        }
    )
}

private struct ListDemo: View {
    enum Style: CaseIterable {
        case automatic, insetGrouped, inset, plain, grouped
    }

    let selects: Bool
    let style: Style?
    let tint: Color?
    @State private var selected: String? = "みかん"

    var body: some View {
        list
            .apply(style) { view, style in
                switch style {
                case .automatic: view.listStyle(.automatic)
                case .insetGrouped: view.listStyle(.insetGrouped)
                case .inset: view.listStyle(.inset)
                case .plain: view.listStyle(.plain)
                case .grouped: view.listStyle(.grouped)
                }
            }
            .apply(tint) { $0.tint($1) }
    }

    @ViewBuilder
    private var list: some View {
        if selects {
            List(selection: $selected) { rows }
        } else {
            List { rows }
        }
    }

    private var rows: some View {
        ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
    }
}
```

`WidgetLab/Catalog/Lists/OutlineGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let outlineGroup = CatalogEntry(
        id: "OutlineGroup",
        kind: .view,
        topic: .lists,
        summary: "木の形のデータから、開け閉めできる入れ子の行を作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/outlinegroup")!,
        stage: .card,
        properties: [
            .argument("children", .fixed(code: "\\.children"), required: true, summary: "子の配列を取り出すキーパス（nil なら葉）")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "OutlineGroup", fixedArguments: ["tree"],
            trailing: " { item in\n        Text(item.name)\n    }", closing: ["}"]),
        build: { _ in
            AnyView(
                List {
                    OutlineGroup(OutlineGroupDemo.tree, children: \.children) { item in
                        Text(item.name)
                    }
                }
            )
        }
    )
}

nonisolated private struct OutlineGroupDemo: Identifiable, Sendable {
    let name: String
    var children: [OutlineGroupDemo]? = nil
    var id: String { name }

    static let tree = [
        OutlineGroupDemo(
            name: "果物",
            children: [
                OutlineGroupDemo(name: "りんご"),
                OutlineGroupDemo(
                    name: "かんきつ", children: [OutlineGroupDemo(name: "みかん"), OutlineGroupDemo(name: "ゆず")]),
            ]),
        OutlineGroupDemo(name: "野菜", children: [OutlineGroupDemo(name: "にんじん")]),
    ]
}
```

`WidgetLab/Catalog/Lists/DisclosureGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let disclosureGroup = CatalogEntry(
        id: "DisclosureGroup",
        kind: .view,
        topic: .lists,
        summary: "開け閉めの印で、中身を見せたり隠したりする View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/disclosuregroup")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "詳しい設定"), required: true, summary: "見出し"),
            .argument("isExpanded", .fixed(code: "$isExpanded"), on: true, summary: "開いているかを外から持つ（最初は開いている）"),
            .modifier("tint", .color(initial: 1), summary: "強調の色（中の Toggle などにかかる）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "DisclosureGroup",
            trailing: " {\n        Toggle(\"通知\", isOn: $notifies)\n        Text(\"音量: 中\")\n    }", closing: ["}"]),
        build: { v in
            AnyView(
                DisclosureGroupDemo(
                    title: v.text("title") ?? "", ownsState: v["isExpanded"] != nil, tint: v.color("tint"))
            )
        }
    )
}

private struct DisclosureGroupDemo: View {
    let title: String
    let ownsState: Bool
    let tint: Color?
    @State private var isExpanded = true
    @State private var notifies = true

    var body: some View {
        List {
            group
                .apply(tint) { $0.tint($1) }
        }
    }

    @ViewBuilder
    private var group: some View {
        if ownsState {
            DisclosureGroup(title, isExpanded: $isExpanded) { content }
        } else {
            DisclosureGroup(title) { content }
        }
    }

    @ViewBuilder
    private var content: some View {
        Toggle("通知", isOn: $notifies)
        Text("音量: 中")
    }
}
```

`WidgetLab/Catalog/Lists/ListRowInsetsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowInsets = CatalogEntry(
        id: "listRowInsets",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の中身のまわりの余白を、辺を選んで決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowinsets(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowInsets", id: "listRowInsets.edges",
                .choice([Choice(".leading"), Choice(".vertical"), Choice(".all")], initial: 0), required: true,
                summary: "余白を変える辺"),
            .modifier(
                "listRowInsets", id: "listRowInsets.length", .slider(range: 0...60, step: 4, initial: 48), on: true,
                summary: "余白の幅"),
        ],
        code: CodeTemplate(
            prefix: ["List {", "    Text(\"行 1\")", "        .frame(maxWidth: .infinity, alignment: .leading)"],
            indent: 8, call: ".background", fixedArguments: [".yellow"], closing: ["    Text(\"行 2\")", "}"]),
        build: { v in
            let edges = v.pick("listRowInsets.edges", from: [Edge.Set.leading, .vertical, .all]) ?? .all
            return AnyView(
                List {
                    Text("行 1")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.yellow)
                        .apply(v.number("listRowInsets.length")) { $0.listRowInsets(edges, CGFloat($1)) }
                    Text("行 2")
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListRowSpacingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSpacing = CatalogEntry(
        id: "listRowSpacing",
        kind: .modifier,
        topic: .lists,
        summary: "List の隣り合う行の、縦の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowspacing(_:)")!,
        stage: .card,
        properties: [
            .modifier("listRowSpacing", .slider(range: 0...24, step: 2, initial: 12), on: true, summary: "行の間"),
            .modifier(
                "listStyle", .choice([Choice(".insetGrouped"), Choice(".plain")], initial: 0),
                summary: "一覧の見た目のスタイル"),
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { Text($0) }\n}"),
        build: { v in
            AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                }
                .apply(v.number("listRowSpacing")) { $0.listRowSpacing(CGFloat($1)) }
                .apply(v.pick("listStyle", from: [0, 1])) { view, style in
                    if style == 0 { view.listStyle(.insetGrouped) } else { view.listStyle(.plain) }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListSectionSpacingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSpacing = CatalogEntry(
        id: "listSectionSpacing",
        kind: .modifier,
        topic: .lists,
        summary: "List の隣り合う節（Section）の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionspacing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSpacing",
                .choice([Choice(".compact"), Choice(".default"), Choice(".custom(60)")], initial: 0), on: true,
                summary: "節の間")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Section(\"果物\") { Text(\"りんご\") }\n    Section(\"野菜\") { Text(\"にんじん\") }\n"
                + "    Section(\"魚\") { Text(\"さば\") }\n}"),
        build: { v in
            AnyView(
                List {
                    Section("果物") { Text("りんご") }
                    Section("野菜") { Text("にんじん") }
                    Section("魚") { Text("さば") }
                }
                .apply(
                    v.pick("listSectionSpacing", from: [ListSectionSpacing.compact, .default, .custom(60)])
                ) { $0.listSectionSpacing($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListSectionMarginsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionMargins = CatalogEntry(
        id: "listSectionMargins",
        kind: .modifier,
        topic: .lists,
        summary: "List の節のまわりの余白を、辺を選んで決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionmargins(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionMargins", id: "listSectionMargins.edges",
                .choice([Choice(".horizontal"), Choice(".top"), Choice(".all")], initial: 0), required: true,
                summary: "余白を変える辺"),
            .modifier(
                "listSectionMargins", id: "listSectionMargins.length", .slider(range: 0...60, step: 4, initial: 48),
                on: true, summary: "余白の幅"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}"]),
        build: { v in
            let edges = v.pick("listSectionMargins.edges", from: [Edge.Set.horizontal, .top, .all]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.number("listSectionMargins.length")) { $0.listSectionMargins(edges, CGFloat($1)) }
                    Section("野菜") { Text("にんじん") }
                }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .list,
        .outlineGroup,
        .disclosureGroup,
        .listRowInsets,
        .listRowSpacing,
        .listSectionSpacing,
        .listSectionMargins,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`lists` の行が `7 / 23`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Lists/ListEntry.swift \
  WidgetLab/Catalog/Lists/OutlineGroupEntry.swift \
  WidgetLab/Catalog/Lists/DisclosureGroupEntry.swift \
  WidgetLab/Catalog/Lists/ListRowInsetsEntry.swift \
  WidgetLab/Catalog/Lists/ListRowSpacingEntry.swift \
  WidgetLab/Catalog/Lists/ListSectionSpacingEntry.swift \
  WidgetLab/Catalog/Lists/ListSectionMarginsEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: list・outlineGroup・disclosureGroup・listRowInsets・listRowSpacing・listSectionSpacing・listSectionMargins を収録する"
```

---

### Task 2: 一覧 2（listItemTint・headerProminence・listRowSeparatorTint・listSectionSeparatorTint・listRowSeparator・listSectionSeparator・listRowBackground）

**Files:**
- Create: `WidgetLab/Catalog/Lists/ListItemTintEntry.swift`
- Create: `WidgetLab/Catalog/Lists/HeaderProminenceEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListRowSeparatorTintEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListSectionSeparatorTintEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListRowSeparatorEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListSectionSeparatorEntry.swift`
- Create: `WidgetLab/Catalog/Lists/ListRowBackgroundEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.listItemTint`、`CatalogEntry.headerProminence`、`CatalogEntry.listRowSeparatorTint`、`CatalogEntry.listSectionSeparatorTint`、`CatalogEntry.listRowSeparator`、`CatalogEntry.listSectionSeparator`、`CatalogEntry.listRowBackground`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1。抜けに listItemTint・headerProminence・listRowSeparatorTint・listSectionSeparatorTint・listRowSeparator・listSectionSeparator・listRowBackground がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Lists/ListItemTintEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listItemTint = CatalogEntry(
        id: "listItemTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の中身に決まった色を付ける modifier。iOS ではサイドバーの Label のアイコンに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listitemtint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listItemTint",
                .choice([Choice(".fixed(.orange)"), Choice(".preferred(.orange)"), Choice(".monochrome")], initial: 0),
                on: true, summary: "色の付け方（.preferred は、ほかに指定がなければこの色）")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach",
            fixedArguments: ["[\"受信\", \"送信済み\"]", "id: \\.self"],
            trailing: " { name in\n        Label(name, systemImage: \"tray\")\n    }",
            closing: ["}", ".listStyle(.sidebar)"]),
        build: { v in
            AnyView(
                List {
                    ForEach(["受信", "送信済み"], id: \.self) { name in
                        Label(name, systemImage: "tray")
                    }
                    .apply(
                        v.pick("listItemTint", from: [ListItemTint.fixed(.orange), .preferred(.orange), .monochrome])
                    ) { $0.listItemTint($1) }
                }
                .listStyle(.sidebar)
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/HeaderProminenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let headerProminence = CatalogEntry(
        id: "headerProminence",
        kind: .modifier,
        topic: .lists,
        summary: "節（Section）の見出しの目立たせ方を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/headerprominence(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "headerProminence", .choice([Choice(".increased"), Choice(".standard")], initial: 0), on: true,
                summary: "見出しの目立たせ方")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n    }", closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") { Text("りんご") }
                        .apply(v.pick("headerProminence", from: [Prominence.increased, .standard])) {
                            $0.headerProminence($1)
                        }
                    Section("野菜") { Text("にんじん") }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListRowSeparatorTintEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSeparatorTint = CatalogEntry(
        id: "listRowSeparatorTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の区切り線の色を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowseparatortint(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowSeparatorTint", id: "listRowSeparatorTint.color", .color(initial: 0), on: true, summary: "線の色"),
            .modifier(
                "listRowSeparatorTint", id: "listRowSeparatorTint.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "色を変える線（行の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach", fixedArguments: ["[\"りんご\", \"みかん\", \"ぶどう\"]", "id: \\.self"],
            trailing: " { Text($0) }", closing: ["}"]),
        build: { v in
            let edges = v.pick("listRowSeparatorTint.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                        .apply(v.color("listRowSeparatorTint.color")) { $0.listRowSeparatorTint($1, edges: edges) }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListSectionSeparatorTintEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSeparatorTint = CatalogEntry(
        id: "listSectionSeparatorTint",
        kind: .modifier,
        topic: .lists,
        summary: "List の節（Section）の上下の区切り線の色を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/listsectionseparatortint(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSeparatorTint", id: "listSectionSeparatorTint.color", .color(initial: 0), on: true,
                summary: "線の色"),
            .modifier(
                "listSectionSeparatorTint", id: "listSectionSeparatorTint.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "色を変える線（節の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}", ".listStyle(.plain)"]),
        build: { v in
            let edges = v.pick("listSectionSeparatorTint.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.color("listSectionSeparatorTint.color")) { $0.listSectionSeparatorTint($1, edges: edges) }
                    Section("野菜") { Text("にんじん") }
                }
                .listStyle(.plain)
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListRowSeparatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowSeparator = CatalogEntry(
        id: "listRowSeparator",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の区切り線を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowseparator(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowSeparator", id: "listRowSeparator.visibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "線を出すか"),
            .modifier(
                "listRowSeparator", id: "listRowSeparator.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "変える線（行の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "ForEach", fixedArguments: ["[\"りんご\", \"みかん\", \"ぶどう\"]", "id: \\.self"],
            trailing: " { Text($0) }", closing: ["}"]),
        build: { v in
            let edges = v.pick("listRowSeparator.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { Text($0) }
                        .apply(
                            v.pick("listRowSeparator.visibility", from: [Visibility.hidden, .visible, .automatic])
                        ) { $0.listRowSeparator($1, edges: edges) }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListSectionSeparatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionSeparator = CatalogEntry(
        id: "listSectionSeparator",
        kind: .modifier,
        topic: .lists,
        summary: "List の節（Section）の上下の区切り線を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionseparator(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionSeparator", id: "listSectionSeparator.visibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "線を出すか"),
            .modifier(
                "listSectionSeparator", id: "listSectionSeparator.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 0), required: true,
                summary: "変える線（節の上・下）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }",
            closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}", ".listStyle(.plain)"]),
        build: { v in
            let edges = v.pick("listSectionSeparator.edges", from: [VerticalEdge.Set.all, .top, .bottom]) ?? .all
            return AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v.pick("listSectionSeparator.visibility", from: [Visibility.hidden, .visible, .automatic])) {
                        $0.listSectionSeparator($1, edges: edges)
                    }
                    Section("野菜") { Text("にんじん") }
                }
                .listStyle(.plain)
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/ListRowBackgroundEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowBackground = CatalogEntry(
        id: "listRowBackground",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の後ろに、好きな View を背景として置く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowBackground",
                .choice(
                    [Choice("Color.yellow"), Choice("Color.mint.opacity(0.4)"), Choice("Capsule().fill(.orange)")],
                    initial: 0),
                on: true, summary: "背景に置く View")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Text", fixedArguments: ["\"りんご\""], closing: ["    Text(\"みかん\")", "}"]),
        build: { v in
            AnyView(
                List {
                    Text("りんご")
                        .apply(v.pick("listRowBackground", from: [0, 1, 2])) { view, i in
                            switch i {
                            case 0: view.listRowBackground(Color.yellow)
                            case 1: view.listRowBackground(Color.mint.opacity(0.4))
                            default: view.listRowBackground(Capsule().fill(.orange))
                            }
                        }
                    Text("みかん")
                }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .listItemTint,
        .headerProminence,
        .listRowSeparatorTint,
        .listSectionSeparatorTint,
        .listRowSeparator,
        .listSectionSeparator,
        .listRowBackground,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`lists` の行が `14 / 23`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Lists/ListItemTintEntry.swift \
  WidgetLab/Catalog/Lists/HeaderProminenceEntry.swift \
  WidgetLab/Catalog/Lists/ListRowSeparatorTintEntry.swift \
  WidgetLab/Catalog/Lists/ListSectionSeparatorTintEntry.swift \
  WidgetLab/Catalog/Lists/ListRowSeparatorEntry.swift \
  WidgetLab/Catalog/Lists/ListSectionSeparatorEntry.swift \
  WidgetLab/Catalog/Lists/ListRowBackgroundEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: listItemTint・headerProminence・listRowSeparatorTint・listSectionSeparatorTint・listRowSeparator・listSectionSeparator・listRowBackground を収録する"
```

---

### Task 3: 一覧 3（badge・badgeProminence・swipeActions・selectionDisabled・refreshable・moveDisabled・deleteDisabled）

**Files:**
- Create: `WidgetLab/Catalog/Lists/BadgeEntry.swift`
- Create: `WidgetLab/Catalog/Lists/BadgeProminenceEntry.swift`
- Create: `WidgetLab/Catalog/Lists/SwipeActionsEntry.swift`
- Create: `WidgetLab/Catalog/Lists/SelectionDisabledEntry.swift`
- Create: `WidgetLab/Catalog/Lists/RefreshableEntry.swift`
- Create: `WidgetLab/Catalog/Lists/MoveDisabledEntry.swift`
- Create: `WidgetLab/Catalog/Lists/DeleteDisabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.badge`、`CatalogEntry.badgeProminence`、`CatalogEntry.swipeActions`、`CatalogEntry.selectionDisabled`、`CatalogEntry.refreshable`、`CatalogEntry.moveDisabled`、`CatalogEntry.deleteDisabled`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1。抜けに badge・badgeProminence・swipeActions・selectionDisabled・refreshable・moveDisabled・deleteDisabled がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Lists/BadgeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let badge = CatalogEntry(
        id: "badge",
        kind: .modifier,
        topic: .lists,
        summary: "List の行やタブの項目に、数や短い文字のバッジを付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/badge(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "badge", .choice([Choice("3"), Choice("\"新着\""), Choice("0")], initial: 0), on: true,
                summary: "バッジの中身（数の 0 は出さない）"),
            .modifier(
                "badgeProminence",
                .choice([Choice(".standard"), Choice(".increased"), Choice(".decreased")], initial: 1),
                summary: "バッジの目立たせ方"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Text", fixedArguments: ["\"受信\""], closing: ["    Text(\"送信済み\")", "}"]),
        build: { v in
            AnyView(
                List {
                    Text("受信")
                        .apply(v.pick("badge", from: [0, 1, 2])) { view, i in
                            switch i {
                            case 0: view.badge(3)
                            case 1: view.badge("新着")
                            default: view.badge(0)
                            }
                        }
                        .apply(v.pick("badgeProminence", from: [BadgeProminence.standard, .increased, .decreased])) {
                            $0.badgeProminence($1)
                        }
                    Text("送信済み")
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/BadgeProminenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let badgeProminence = CatalogEntry(
        id: "badgeProminence",
        kind: .modifier,
        topic: .lists,
        summary: "バッジの目立たせ方（.increased は色の付いた丸）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/badgeprominence(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "badgeProminence",
                .choice([Choice(".increased"), Choice(".decreased"), Choice(".standard")], initial: 0), on: true,
                summary: "バッジの目立たせ方")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Text(\"受信\").badge(3)\n    Text(\"下書き\").badge(\"新着\")\n}"),
        build: { v in
            AnyView(
                List {
                    Text("受信").badge(3)
                    Text("下書き").badge("新着")
                }
                .apply(v.pick("badgeProminence", from: [BadgeProminence.increased, .decreased, .standard])) {
                    $0.badgeProminence($1)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/SwipeActionsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let swipeActions = CatalogEntry(
        id: "swipeActions",
        kind: .modifier,
        topic: .lists,
        summary: "List の行を横にずらしたときに出るボタンを足す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/swipeactions(edge:allowsfullswipe:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "swipeActions", id: "swipeActions.edge", label: "edge",
                .choice([Choice(".trailing"), Choice(".leading")], initial: 0), required: true,
                summary: "ボタンを出す側（.trailing は左へずらす）"),
            .modifier(
                "swipeActions", id: "swipeActions.allowsFullSwipe", label: "allowsFullSwipe", .toggle(initial: false),
                required: true, summary: "端までずらすと最初のボタンを押したことにする"),
            .modifier(
                "swipeActions", id: "swipeActions.content", label: "content",
                .fixed(code: "{ Button(\"削除\", role: .destructive) { items.removeAll { $0 == item } } }"), on: true,
                summary: "出すボタン"),
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"], closing: ["    }", "}"]),
        build: { v in
            AnyView(
                SwipeActionsDemo(
                    adds: v["swipeActions.content"] != nil,
                    edge: v.pick("swipeActions.edge", from: [HorizontalEdge.trailing, .leading]) ?? .trailing,
                    allowsFullSwipe: v.flag("swipeActions.allowsFullSwipe") ?? true)
            )
        }
    )
}

private struct SwipeActionsDemo: View {
    let adds: Bool
    let edge: HorizontalEdge
    let allowsFullSwipe: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(adds ? () : nil) { view, _ in
                        view.swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
                            Button("削除", role: .destructive) { items.removeAll { $0 == item } }
                        }
                    }
            }
        }
    }
}
```

`WidgetLab/Catalog/Lists/SelectionDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let selectionDisabled = CatalogEntry(
        id: "selectionDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List で、その行を選べないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/selectiondisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "selectionDisabled", .fixed(code: "item == \"みかん\""), on: true, summary: "選べなくする条件（みかんの行）")
        ],
        code: CodeTemplate(
            prefix: [
                "List(selection: $selected) {", "    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { item in",
            ],
            indent: 8, call: "Text", fixedArguments: ["item"], closing: ["    }", "}"]),
        build: { v in
            AnyView(SelectionDisabledDemo(disables: v["selectionDisabled"] != nil))
        }
    )
}

private struct SelectionDisabledDemo: View {
    let disables: Bool
    @State private var selected: String?

    var body: some View {
        List(selection: $selected) {
            ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.selectionDisabled(item == "みかん")
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text("選んだ行: \(selected ?? "なし")")
                .font(.caption)
                .padding(.bottom, 8)
        }
    }
}
```

`WidgetLab/Catalog/Lists/RefreshableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let refreshable = CatalogEntry(
        id: "refreshable",
        kind: .modifier,
        topic: .lists,
        summary: "下に引っ張って更新する操作を足し、そのときに行う非同期の処理を渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/refreshable(action:)")!,
        stage: .card,
        properties: [
            .modifier(
                "refreshable", label: "action", .fixed(code: "{ await reload() }"), on: true,
                summary: "更新の処理（一覧を下に引っ張ると、終わるまで回る印が出る）")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Text(\"更新した回数: \\(count)\")\n    Text(\"下に引っ張る\")\n}"),
        build: { v in
            AnyView(RefreshableDemo(refreshes: v["refreshable"] != nil))
        }
    )
}

private struct RefreshableDemo: View {
    let refreshes: Bool
    @State private var count = 0

    var body: some View {
        List {
            Text("更新した回数: \(count)")
            Text("下に引っ張る")
        }
        .apply(refreshes ? () : nil) { view, _ in
            view.refreshable {
                try? await Task.sleep(for: .seconds(1))
                count += 1
            }
        }
    }
}
```

`WidgetLab/Catalog/Lists/MoveDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let moveDisabled = CatalogEntry(
        id: "moveDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List の編集モードで、その行を並べ替えられないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/movedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "moveDisabled", .fixed(code: "item == \"りんご\""), on: true,
                summary: "並べ替えられなくする条件（りんごの行は、つまみが出ない）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"],
            closing: [
                "    }", "    .onMove { items.move(fromOffsets: $0, toOffset: $1) }", "}",
                ".environment(\\.editMode, .constant(.active))",
            ]),
        build: { v in
            AnyView(MoveDisabledDemo(disables: v["moveDisabled"] != nil))
        }
    )
}

private struct MoveDisabledDemo: View {
    let disables: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]
    /// 編集モードをこの見本の中だけに持つ（詳細画面の NavigationStack の編集モードを切り替えないように）
    @State private var editMode = EditMode.active

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.moveDisabled(item == "りんご")
                    }
            }
            .onMove { items.move(fromOffsets: $0, toOffset: $1) }
        }
        .environment(\.editMode, $editMode)
    }
}
```

`WidgetLab/Catalog/Lists/DeleteDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let deleteDisabled = CatalogEntry(
        id: "deleteDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List で、その行を消せないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/deletedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "deleteDisabled", .fixed(code: "item == \"りんご\""), on: true,
                summary: "消せなくする条件（りんごの行は、削除の印が出ない）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(items, id: \\.self) { item in"], indent: 8, call: "Text",
            fixedArguments: ["item"],
            closing: [
                "    }", "    .onDelete { items.remove(atOffsets: $0) }", "}",
                ".environment(\\.editMode, .constant(.active))",
            ]),
        build: { v in
            AnyView(DeleteDisabledDemo(disables: v["deleteDisabled"] != nil))
        }
    )
}

private struct DeleteDisabledDemo: View {
    let disables: Bool
    @State private var items = ["りんご", "みかん", "ぶどう"]
    /// 編集モードをこの見本の中だけに持つ（詳細画面の NavigationStack の編集モードを切り替えないように）
    @State private var editMode = EditMode.active

    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.deleteDisabled(item == "りんご")
                    }
            }
            .onDelete { items.remove(atOffsets: $0) }
        }
        .environment(\.editMode, $editMode)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .badge,
        .badgeProminence,
        .swipeActions,
        .selectionDisabled,
        .refreshable,
        .moveDisabled,
        .deleteDisabled,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py lists`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`lists` の行が `21 / 23`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Lists/BadgeEntry.swift \
  WidgetLab/Catalog/Lists/BadgeProminenceEntry.swift \
  WidgetLab/Catalog/Lists/SwipeActionsEntry.swift \
  WidgetLab/Catalog/Lists/SelectionDisabledEntry.swift \
  WidgetLab/Catalog/Lists/RefreshableEntry.swift \
  WidgetLab/Catalog/Lists/MoveDisabledEntry.swift \
  WidgetLab/Catalog/Lists/DeleteDisabledEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: badge・badgeProminence・swipeActions・selectionDisabled・refreshable・moveDisabled・deleteDisabled を収録する"
```

---

### Task 4: 一覧 4 と表（listSectionIndexVisibility・sectionIndexLabel・Table・tableColumnHeaders・ScrollView・ScrollViewReader）

**Files:**
- Create: `WidgetLab/Catalog/Lists/SectionIndexDemo.swift`
- Create: `WidgetLab/Catalog/Lists/ListSectionIndexVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/Lists/SectionIndexLabelEntry.swift`
- Create: `WidgetLab/Catalog/Tables/TableEntry.swift`
- Create: `WidgetLab/Catalog/Tables/TableColumnHeadersEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollViewEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollViewReaderEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.listSectionIndexVisibility`、`CatalogEntry.sectionIndexLabel`、`CatalogEntry.table`、`CatalogEntry.tableColumnHeaders`、`CatalogEntry.scrollView`、`CatalogEntry.scrollViewReader`、`SectionIndexDemo(labels: Bool, visibility: Visibility?)`（Task 4 の 2 件で使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py lists tables scroll-views`
Expected: 終了コード 1。抜けに listSectionIndexVisibility・sectionIndexLabel・Table・tableColumnHeaders・ScrollView・ScrollViewReader がある

- [ ] **Step 2: 収録のファイルを作る**

`Lists`・`Tables`・`ScrollViews` のフォルダがなければ作る（Xcode のフォルダの同期で project.pbxproj は変わらない）。

`WidgetLab/Catalog/Lists/SectionIndexDemo.swift`:

```swift
import SwiftUI

/// 節の索引（listSectionIndexVisibility・sectionIndexLabel）の見本。頭の文字ごとの節を並べた List
struct SectionIndexDemo: View {
    nonisolated struct Group: Sendable {
        let letter: String
        let names: [String]
    }

    nonisolated static let groups = [
        Group(letter: "あ", names: ["あんず", "アボカド"]),
        Group(letter: "い", names: ["いちご", "いちじく"]),
        Group(letter: "か", names: ["かき", "かぼす"]),
        Group(letter: "さ", names: ["さくらんぼ"]),
        Group(letter: "す", names: ["すいか", "すだち"]),
        Group(letter: "な", names: ["なし"]),
        Group(letter: "ぶ", names: ["ぶどう"]),
        Group(letter: "み", names: ["みかん"]),
    ]

    /// 節に索引の文字を付けるか
    let labels: Bool
    /// 索引を出すか。nil なら付けない
    let visibility: Visibility?

    var body: some View {
        List {
            ForEach(Self.groups, id: \.letter) { group in
                Section(group.letter) {
                    ForEach(group.names, id: \.self) { Text($0) }
                }
                .apply(labels ? () : nil) { view, _ in view.sectionIndexLabel(group.letter) }
            }
        }
        .apply(visibility) { $0.listSectionIndexVisibility($1) }
    }
}
```

`WidgetLab/Catalog/Lists/ListSectionIndexVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let listSectionIndexVisibility = CatalogEntry(
        id: "listSectionIndexVisibility",
        kind: .modifier,
        topic: .lists,
        summary: "List の右端に、節へ飛ぶ索引（sectionIndexLabel の文字）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listsectionindexvisibility(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listSectionIndexVisibility",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0), on: true,
                summary: "索引を出すか（付けないときは出る。右端の文字を押すと、その節へ飛ぶ）")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    ForEach(groups, id: \\.letter) { group in\n        Section(group.letter) {\n"
                + "            ForEach(group.names, id: \\.self) { Text($0) }\n        }\n"
                + "        .sectionIndexLabel(group.letter)\n    }\n}"),
        build: { v in
            AnyView(
                SectionIndexDemo(
                    labels: true,
                    visibility: v.pick("listSectionIndexVisibility", from: [Visibility.hidden, .visible, .automatic]))
            )
        }
    )
}
```

`WidgetLab/Catalog/Lists/SectionIndexLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionIndexLabel = CatalogEntry(
        id: "sectionIndexLabel",
        kind: .modifier,
        topic: .lists,
        summary: "List の節の索引に出す文字（ふつうは 1 文字）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sectionindexlabel(_:)")!,
        stage: .card,
        properties: [
            .modifier("sectionIndexLabel", .fixed(code: "group.letter"), on: true, summary: "索引に出す文字（節の頭の文字）")
        ],
        code: CodeTemplate(
            prefix: ["List {", "    ForEach(groups, id: \\.letter) { group in"], indent: 8, call: "Section",
            fixedArguments: ["group.letter"],
            trailing: " {\n            ForEach(group.names, id: \\.self) { Text($0) }\n        }",
            closing: ["    }", "}", ".listSectionIndexVisibility(.visible)"]),
        build: { v in
            AnyView(SectionIndexDemo(labels: v["sectionIndexLabel"] != nil, visibility: .visible))
        }
    )
}
```

`WidgetLab/Catalog/Tables/TableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let table = CatalogEntry(
        id: "Table",
        kind: .view,
        topic: .tables,
        summary: "データの行を、列に分けて並べる入れ物。iPhone（幅が compact）では、最初の列だけを 1 列の一覧として出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/table")!,
        stage: .card,
        properties: [
            .argument("selection", .fixed(code: "$selected"), on: true, summary: "選んだ行の id を入れる値（タップで行を選ぶ）"),
            .modifier("tint", .color(initial: 3), summary: "選んだ行の色"),
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing: " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"産地\", value: \\.origin)\n"
                + "    TableColumn(\"値段\") { Text(\"\\($0.price) 円\") }\n}"),
        build: { v in
            AnyView(TableDemo(selects: v["selection"] != nil, tint: v.color("tint")))
        }
    )
}

private struct TableDemo: View {
    nonisolated struct Fruit: Identifiable, Sendable {
        let name: String
        let origin: String
        let price: Int
        var id: String { name }
    }

    static let fruits = [
        Fruit(name: "りんご", origin: "青森", price: 150),
        Fruit(name: "みかん", origin: "愛媛", price: 80),
        Fruit(name: "ぶどう", origin: "山梨", price: 400),
    ]

    let selects: Bool
    let tint: Color?
    @State private var selected: Fruit.ID? = "みかん"

    var body: some View {
        table
            .apply(tint) { $0.tint($1) }
    }

    @ViewBuilder
    private var table: some View {
        if selects {
            Table(Self.fruits, selection: $selected) { columns }
        } else {
            Table(Self.fruits) { columns }
        }
    }

    @TableColumnBuilder<Fruit, Never>
    private var columns: some TableColumnContent<Fruit, Never> {
        TableColumn("名前", value: \.name)
        TableColumn("産地", value: \.origin)
        TableColumn("値段") { Text("\($0.price) 円") }
    }
}
```

`WidgetLab/Catalog/Tables/TableColumnHeadersEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tableColumnHeaders = CatalogEntry(
        id: "tableColumnHeaders",
        kind: .modifier,
        topic: .tables,
        summary: "Table の列の見出しを出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tablecolumnheaders(_:)")!,
        noteReason: "iPhone（幅が compact）の Table は、最初の列だけを出し、列の見出しを出さない。iPad の幅の広い画面と Mac で効く",
        properties: [
            .modifier(
                "tableColumnHeaders",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0),
                on: true, summary: "見出しを出すか")
        ],
        code: CodeTemplate(
            call: "Table", fixedArguments: ["fruits"],
            trailing: " {\n    TableColumn(\"名前\", value: \\.name)\n    TableColumn(\"産地\", value: \\.origin)\n"
                + "    TableColumn(\"値段\") { Text(\"\\($0.price) 円\") }\n}")
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollView = CatalogEntry(
        id: "ScrollView",
        kind: .view,
        topic: .scrollViews,
        summary: "中身を、決めた向きにスクロールして見せる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scrollview")!,
        stage: .card,
        properties: [
            .argument(
                "axes", unlabeled: true,
                .choice([Choice(".vertical"), Choice(".horizontal"), Choice("[.horizontal, .vertical]")], initial: 2),
                on: true, summary: "スクロールする向き（OFF なら縦）"),
            .modifier("contentMargins", .slider(range: 0...40, step: 4, initial: 16), summary: "中身のまわりの余白"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    VStack {\n        ForEach(1...12, id: \\.self) { row in\n            HStack {\n"
                + "                ForEach(1...8, id: \\.self) { column in\n"
                + "                    Text(\"\\(row)-\\(column)\")\n"
                + "                        .frame(width: 60, height: 40)\n"
                + "                        .background(.yellow)\n"
                + "                }\n            }\n        }\n    }\n}"),
        build: { v in
            let axes = v.pick("axes", from: [Axis.Set.vertical, .horizontal, [.horizontal, .vertical]]) ?? .vertical
            return AnyView(
                ScrollView(axes) {
                    VStack {
                        ForEach(1...12, id: \.self) { row in
                            HStack {
                                ForEach(1...8, id: \.self) { column in
                                    Text("\(row)-\(column)")
                                        .frame(width: 60, height: 40)
                                        .background(.yellow)
                                }
                            }
                        }
                    }
                }
                .apply(v.number("contentMargins")) { $0.contentMargins(CGFloat($1)) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollViewReaderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollViewReader = CatalogEntry(
        id: "ScrollViewReader",
        kind: .view,
        topic: .scrollViews,
        summary: "中の ScrollView を、id を付けた子の場所までコードでスクロールさせる窓口（proxy）を渡す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scrollviewreader")!,
        stage: .card,
        properties: [
            .argument(
                "anchor", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 1), on: true,
                summary: "scrollTo で、子を枠のどこに合わせるか（OFF なら見えるところまで）")
        ],
        code: CodeTemplate(
            prefix: ["ScrollViewReader { proxy in", "    Button(\"行 30 へ\") {", "        withAnimation {"], indent: 12,
            call: "proxy.scrollTo", fixedArguments: ["30"],
            closing: [
                "        }", "    }", "    ScrollView {", "        ForEach(1...50, id: \\.self) { i in",
                "            Text(\"行 \\(i)\").id(i)", "        }", "    }", "}",
            ]),
        build: { v in
            AnyView(ScrollViewReaderDemo(anchor: v.pick("anchor", from: [UnitPoint.top, .center, .bottom])))
        }
    )
}

private struct ScrollViewReaderDemo: View {
    let anchor: UnitPoint?

    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    Button("行 30 へ") {
                        withAnimation { proxy.scrollTo(30, anchor: anchor) }
                    }
                    Button("行 1 へ") {
                        withAnimation { proxy.scrollTo(1, anchor: anchor) }
                    }
                }
                .buttonStyle(.bordered)
                ScrollView {
                    ForEach(1...50, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(i == 30 ? .yellow : .clear)
                            .id(i)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .listSectionIndexVisibility,
        .sectionIndexLabel,
        .table,
        .tableColumnHeaders,
        .scrollView,
        .scrollViewReader,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py lists tables scroll-views`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`lists` が `23 / 23`、`tables` が `2 / 2`、`scroll-views` が `2 / 21`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Lists/SectionIndexDemo.swift \
  WidgetLab/Catalog/Lists/ListSectionIndexVisibilityEntry.swift \
  WidgetLab/Catalog/Lists/SectionIndexLabelEntry.swift \
  WidgetLab/Catalog/Tables/TableEntry.swift \
  WidgetLab/Catalog/Tables/TableColumnHeadersEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollViewEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollViewReaderEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: listSectionIndexVisibility・sectionIndexLabel・table・tableColumnHeaders・scrollView・scrollViewReader を収録する"
```

---

### Task 5: スクロール 1（scrollPosition・defaultScrollAnchor・scrollTargetBehavior・scrollTargetLayout・scrollTransition・onScrollGeometryChange・onScrollTargetVisibilityChange）

**Files:**
- Create: `WidgetLab/Catalog/ScrollViews/ScrollPositionEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/DefaultScrollAnchorEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollCardsDemo.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollTargetBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollTargetLayoutEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollTransitionEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/OnScrollGeometryChangeEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/OnScrollTargetVisibilityChangeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.scrollPosition`、`CatalogEntry.defaultScrollAnchor`、`CatalogEntry.scrollTargetBehavior`、`CatalogEntry.scrollTargetLayout`、`CatalogEntry.scrollTransition`、`CatalogEntry.onScrollGeometryChange`、`CatalogEntry.onScrollTargetVisibilityChange`、`ScrollCardsDemo()`（Task 5 の 2 件で使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py scroll-views`
Expected: 終了コード 1。抜けに scrollPosition・defaultScrollAnchor・scrollTargetBehavior・scrollTargetLayout・scrollTransition・onScrollGeometryChange・onScrollTargetVisibilityChange がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ScrollViews/ScrollPositionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollPosition = CatalogEntry(
        id: "scrollPosition",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のいまの位置（いちばん上に見えている子の id）を値に結び付ける modifier。値を変えるとスクロールする。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollposition(id:anchor:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollPosition", id: "scrollPosition.id", label: "id", .fixed(code: "$current"), on: true,
                summary: "位置を入れる値（スクロールすると変わり、変えるとスクロールする）"),
            .modifier(
                "scrollPosition", id: "scrollPosition.anchor", label: "anchor",
                .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), required: true,
                summary: "どこに見えている子を位置とするか"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    LazyVStack {\n        ForEach(1...50, id: \\.self) { Text(\"行 \\($0)\") }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                ScrollPositionDemo(
                    binds: v["scrollPosition.id"] != nil,
                    anchor: v.pick("scrollPosition.anchor", from: [UnitPoint.top, .center, .bottom]) ?? .top)
            )
        }
    )
}

private struct ScrollPositionDemo: View {
    let binds: Bool
    let anchor: UnitPoint
    @State private var current: Int?

    var body: some View {
        VStack {
            HStack {
                Button("行 1 へ") { current = 1 }
                Button("行 25 へ") { current = 25 }
                Text("位置: \(current.map { "行 \($0)" } ?? "なし")")
                    .monospacedDigit()
            }
            .buttonStyle(.bordered)
            ScrollView {
                LazyVStack {
                    ForEach(1...50, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .scrollTargetLayout()
            }
            .apply(binds ? () : nil) { view, _ in view.scrollPosition(id: $current, anchor: anchor) }
        }
        .padding(.top, 8)
    }
}
```

`WidgetLab/Catalog/ScrollViews/DefaultScrollAnchorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultScrollAnchor = CatalogEntry(
        id: "defaultScrollAnchor",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が最初にどこを見せるか（中身のどの点を合わせるか）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultscrollanchor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "defaultScrollAnchor", .choice([Choice(".bottom"), Choice(".center"), Choice(".top")], initial: 0),
                on: true, summary: "最初に見せるところ（.bottom はチャットのように末尾から）")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...30, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .apply(v.pick("defaultScrollAnchor", from: [UnitPoint.bottom, .center, .top])) {
                    $0.defaultScrollAnchor($1)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollCardsDemo.swift`:

```swift
import SwiftUI

/// 横にスクロールするカードの並び（scrollTargetBehavior・scrollTargetLayout の見本）
struct ScrollCardsDemo: View {
    var body: some View {
        LazyHStack {
            ForEach(1...10, id: \.self) { i in
                Text("\(i)")
                    .frame(width: 160, height: 100)
                    .background(.yellow, in: .rect(cornerRadius: 12))
            }
        }
    }
}
```

`WidgetLab/Catalog/ScrollViews/ScrollTargetBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTargetBehavior = CatalogEntry(
        id: "scrollTargetBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView を指で動かしたあとに止まる位置の決め方（ページごと・子ごと）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolltargetbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTargetBehavior", .choice([Choice(".viewAligned"), Choice(".paging")], initial: 0), on: true,
                summary: "止まる位置（.viewAligned は子の頭、.paging は枠の幅ごと）")
        ],
        code: CodeTemplate(
            call: "ScrollView", fixedArguments: [".horizontal"],
            trailing: " {\n    LazyHStack {\n        ForEach(1...10, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 160, height: 100)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n        }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    ScrollCardsDemo()
                        .scrollTargetLayout()
                }
                .apply(v.pick("scrollTargetBehavior", from: [0, 1])) { view, i in
                    if i == 0 { view.scrollTargetBehavior(.viewAligned) } else { view.scrollTargetBehavior(.paging) }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollTargetLayoutEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTargetLayout = CatalogEntry(
        id: "scrollTargetLayout",
        kind: .modifier,
        topic: .scrollViews,
        summary: "並びの入れ物の子を、スクロールが止まる目印（scroll target）にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolltargetlayout(isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTargetLayout", .fixed(code: ""), on: true,
                summary: "子を止まる目印にする（OFF なら .viewAligned でもカードの途中で止まる）")
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHStack",
            trailing: " {\n        ForEach(1...10, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 160, height: 100)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n        }\n    }",
            closing: ["}", ".scrollTargetBehavior(.viewAligned)"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    ScrollCardsDemo()
                        .apply(v["scrollTargetLayout"] != nil ? () : nil) { view, _ in view.scrollTargetLayout() }
                }
                .scrollTargetBehavior(.viewAligned)
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollTransitionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTransition = CatalogEntry(
        id: "scrollTransition",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の見える範囲に出入りする子に、その途中の段階に合わせた効果をかける modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/scrolltransition(_:axis:transition:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTransition", id: "scrollTransition.configuration",
                .choice([Choice(".interactive"), Choice(".animated")], initial: 0), required: true,
                summary: "効果の動き（.interactive は指に合わせ、.animated はアニメーションで切り替える）"),
            .modifier(
                "scrollTransition", id: "scrollTransition.transition", label: "transition",
                .choice(
                    [
                        Choice(
                            "薄く・小さく",
                            code:
                                "{ content, phase in content.opacity(phase.isIdentity ? 1 : 0.2).scaleEffect(phase.isIdentity ? 1 : 0.7) }"
                        ),
                        Choice("横にずらす", code: "{ content, phase in content.offset(x: phase.value * 120) }"),
                        Choice("回す", code: "{ content, phase in content.rotationEffect(.degrees(phase.value * 30)) }"),
                    ],
                    initial: 0),
                on: true, summary: "出入りの途中でかける効果"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    VStack {", "        ForEach(1...20, id: \\.self) { i in",
                "            Text(\"行 \\(i)\")",
                "                .frame(maxWidth: .infinity, minHeight: 44)",
            ],
            indent: 16, call: ".background", fixedArguments: [".yellow"], closing: ["        }", "    }", "}"]),
        build: { v in
            let configuration =
                v.pick("scrollTransition.configuration", from: [ScrollTransitionConfiguration.interactive, .animated])
                ?? .interactive
            let transition = v.pick("scrollTransition.transition", from: [0, 1, 2])
            return AnyView(
                ScrollView {
                    VStack {
                        ForEach(1...20, id: \.self) { i in
                            Text("行 \(i)")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(.yellow)
                                .apply(transition) { view, kind in
                                    switch kind {
                                    case 0:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.opacity(phase.isIdentity ? 1 : 0.2).scaleEffect(
                                                phase.isIdentity ? 1 : 0.7)
                                        }
                                    case 1:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.offset(x: phase.value * 120)
                                        }
                                    default:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.rotationEffect(.degrees(phase.value * 30))
                                        }
                                    }
                                }
                        }
                    }
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/OnScrollGeometryChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollGeometryChange = CatalogEntry(
        id: "onScrollGeometryChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の大きさや位置（ScrollGeometry）から取り出した値が変わったときに、処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.for", label: "for", .fixed(code: "CGFloat.self"),
                required: true, summary: "取り出す値の型"),
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.of", label: "of",
                .choice(
                    [
                        Choice("ずらした量", code: "{ $0.contentOffset.y + $0.contentInsets.top }"),
                        Choice("visibleRect.maxY", code: "{ $0.visibleRect.maxY }"),
                        Choice("contentSize.height", code: "{ $0.contentSize.height }"),
                    ],
                    initial: 0),
                required: true, summary: "取り出す値（ずらした量・見えている下端・中身の高さ）"),
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.action", label: "action",
                .fixed(code: "{ value = $1 }"), on: true, summary: "変わったときの処理（上の数が変わる）"),
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                OnScrollGeometryChangeDemo(
                    watches: v["onScrollGeometryChange.action"] != nil,
                    kind: v.pick("onScrollGeometryChange.of", from: [0, 1, 2]) ?? 0)
            )
        }
    )
}

private struct OnScrollGeometryChangeDemo: View {
    let watches: Bool
    let kind: Int
    @State private var value: CGFloat?

    var body: some View {
        ScrollView {
            ForEach(1...30, id: \.self) { i in
                Text("行 \(i)")
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollGeometryChange(for: CGFloat.self) { geometry in
                switch kind {
                case 0: geometry.contentOffset.y + geometry.contentInsets.top
                case 1: geometry.visibleRect.maxY
                default: geometry.contentSize.height
                }
            } action: { _, new in
                value = new
            }
        }
        .safeAreaInset(edge: .top) {
            Text("value: \(value.map { "\(Int($0))" } ?? "なし")")
                .monospacedDigit()
                .padding(6)
                .background(.yellow, in: .capsule)
        }
    }
}
```

`WidgetLab/Catalog/ScrollViews/OnScrollTargetVisibilityChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollTargetVisibilityChange = CatalogEntry(
        id: "onScrollTargetVisibilityChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の止まる目印（scrollTargetLayout の子）のうち、見えているものの id が変わったときに処理を行う modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/onscrolltargetvisibilitychange(idtype:threshold:_:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.idType", label: "idType",
                .fixed(code: "Int.self"), required: true, summary: "子の id の型"),
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.threshold", label: "threshold",
                .slider(range: 0.1...1, step: 0.1, initial: 0.5), required: true,
                summary: "見えているとする割合（1 なら子の全体が見えているとき）"),
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.action",
                .fixed(code: "{ visible = $0 }"), on: true, summary: "変わったときの処理（上の行の範囲が変わる）"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    LazyVStack {\n        ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                OnScrollTargetVisibilityChangeDemo(
                    watches: v["onScrollTargetVisibilityChange.action"] != nil,
                    threshold: v.number("onScrollTargetVisibilityChange.threshold") ?? 0.5)
            )
        }
    )
}

private struct OnScrollTargetVisibilityChangeDemo: View {
    let watches: Bool
    let threshold: Double
    @State private var visible: [Int] = []

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(1...30, id: \.self) { i in
                    Text("行 \(i)")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.yellow.opacity(0.4))
                }
            }
            .scrollTargetLayout()
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollTargetVisibilityChange(idType: Int.self, threshold: threshold) { visible = $0 }
        }
        .safeAreaInset(edge: .top) {
            Text(label)
                .monospacedDigit()
                .padding(6)
                .background(.yellow, in: .capsule)
        }
    }

    private var label: String {
        guard let first = visible.min(), let last = visible.max() else { return "見えている行: なし" }
        return "見えている行: \(first)〜\(last)"
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .scrollPosition,
        .defaultScrollAnchor,
        .scrollTargetBehavior,
        .scrollTargetLayout,
        .scrollTransition,
        .onScrollGeometryChange,
        .onScrollTargetVisibilityChange,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py scroll-views`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`scroll-views` の行が `9 / 21`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ScrollViews/ScrollPositionEntry.swift \
  WidgetLab/Catalog/ScrollViews/DefaultScrollAnchorEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollCardsDemo.swift \
  WidgetLab/Catalog/ScrollViews/ScrollTargetBehaviorEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollTargetLayoutEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollTransitionEntry.swift \
  WidgetLab/Catalog/ScrollViews/OnScrollGeometryChangeEntry.swift \
  WidgetLab/Catalog/ScrollViews/OnScrollTargetVisibilityChangeEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: scrollPosition・defaultScrollAnchor・scrollTargetBehavior・scrollTargetLayout・scrollTransition・onScrollGeometryChange・onScrollTargetVisibilityChange を収録する"
```

---

### Task 6: スクロール 2（onScrollVisibilityChange・onScrollPhaseChange・scrollIndicatorsFlash・scrollIndicators・scrollContentBackground・scrollClipDisabled・scrollDisabled）

**Files:**
- Create: `WidgetLab/Catalog/ScrollViews/OnScrollVisibilityChangeEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/OnScrollPhaseChangeEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollIndicatorsFlashEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollIndicatorsEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollContentBackgroundEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollClipDisabledEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollDisabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.onScrollVisibilityChange`、`CatalogEntry.onScrollPhaseChange`、`CatalogEntry.scrollIndicatorsFlash`、`CatalogEntry.scrollIndicators`、`CatalogEntry.scrollContentBackground`、`CatalogEntry.scrollClipDisabled`、`CatalogEntry.scrollDisabled`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py scroll-views`
Expected: 終了コード 1。抜けに onScrollVisibilityChange・onScrollPhaseChange・scrollIndicatorsFlash・scrollIndicators・scrollContentBackground・scrollClipDisabled・scrollDisabled がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ScrollViews/OnScrollVisibilityChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollVisibilityChange = CatalogEntry(
        id: "onScrollVisibilityChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "View が ScrollView の見える範囲に入った・出たときに、処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/onscrollvisibilitychange(threshold:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollVisibilityChange", id: "onScrollVisibilityChange.threshold", label: "threshold",
                .slider(range: 0.1...1, step: 0.1, initial: 0.5), required: true, summary: "見えているとする割合"),
            .modifier(
                "onScrollVisibilityChange", id: "onScrollVisibilityChange.action", .fixed(code: "{ isVisible = $0 }"),
                on: true, summary: "入った・出たときの処理（上の表示が変わる）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...12, id: \\.self) { Text(\"行 \\($0)\").frame(height: 44) }",
                "    Text(\"目印\")",
            ],
            indent: 8, call: ".background", fixedArguments: [".orange"],
            closing: ["    ForEach(13...24, id: \\.self) { Text(\"行 \\($0)\").frame(height: 44) }", "}"]),
        build: { v in
            AnyView(
                OnScrollVisibilityChangeDemo(
                    watches: v["onScrollVisibilityChange.action"] != nil,
                    threshold: v.number("onScrollVisibilityChange.threshold") ?? 0.5)
            )
        }
    )
}

private struct OnScrollVisibilityChangeDemo: View {
    let watches: Bool
    let threshold: Double
    @State private var isVisible: Bool?

    var body: some View {
        ScrollView {
            ForEach(1...12, id: \.self) { Text("行 \($0)").frame(height: 44) }
            Text("目印")
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(.orange)
                .apply(watches ? () : nil) { view, _ in
                    view.onScrollVisibilityChange(threshold: threshold) { isVisible = $0 }
                }
            ForEach(13...24, id: \.self) { Text("行 \($0)").frame(height: 44) }
        }
        .safeAreaInset(edge: .top) {
            Text(label)
                .padding(6)
                .background(.orange.opacity(0.4), in: .capsule)
        }
    }

    private var label: String {
        switch isVisible {
        case true?: "目印: 見えている"
        case false?: "目印: 見えていない"
        case nil: "目印: なし"
        }
    }
}
```

`WidgetLab/Catalog/ScrollViews/OnScrollPhaseChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollPhaseChange = CatalogEntry(
        id: "onScrollPhaseChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のスクロールの段階（止まっている・指で動かしている・惰性で動いているなど）が変わったときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onscrollphasechange(_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onScrollPhaseChange", .fixed(code: "{ old, new in print(\"\\(old) → \\(new)\") }"), on: true,
                summary: "変わったときの処理。スクロールするたびに記録に段階が出る")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(OnScrollPhaseChangeDemo(watches: v["onScrollPhaseChange"] != nil))
        }
    )
}

private struct OnScrollPhaseChangeDemo: View {
    let watches: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        ScrollView {
            ForEach(1...30, id: \.self) { i in
                Text("行 \(i)")
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollPhaseChange { old, new in
                recorder?.log("\(Self.name(old)) → \(Self.name(new))")
            }
        }
    }

    private static func name(_ phase: ScrollPhase) -> String {
        switch phase {
        case .idle: "idle"
        case .tracking: "tracking"
        case .interacting: "interacting"
        case .decelerating: "decelerating"
        case .animating: "animating"
        @unknown default: "?"
        }
    }
}
```

`WidgetLab/Catalog/ScrollViews/ScrollIndicatorsFlashEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollIndicatorsFlash = CatalogEntry(
        id: "scrollIndicatorsFlash",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のスクロールバーを、現れたときや値が変わったときに一瞬だけ出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollindicatorsflash(trigger:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollIndicatorsFlash",
                .choice(
                    [Choice("count が変わるたび", code: "trigger: count"), Choice("現れたとき", code: "onAppear: true")],
                    initial: 0),
                on: true, summary: "バーを出すきっかけ（+1 を押す・見本が現れる）")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "ScrollView",
            trailing: " {\n        ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n    }", closing: ["}"]),
        build: { v in
            AnyView(ScrollIndicatorsFlashDemo(trigger: v.pick("scrollIndicatorsFlash", from: [true, false])))
        }
    )
}

private struct ScrollIndicatorsFlashDemo: View {
    /// true なら count が変わるたび、false なら現れたとき。nil なら付けない
    let trigger: Bool?
    @State private var count = 0

    var body: some View {
        VStack {
            Button("+1（\(count)）") { count += 1 }
                .buttonStyle(.bordered)
            ScrollView {
                ForEach(1...30, id: \.self) { i in
                    Text("行 \(i)")
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
            }
            .apply(trigger) { view, byCount in
                if byCount {
                    view.scrollIndicatorsFlash(trigger: count)
                } else {
                    view.scrollIndicatorsFlash(onAppear: true)
                }
            }
        }
        .padding(.top, 8)
    }
}
```

`WidgetLab/Catalog/ScrollViews/ScrollIndicatorsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollIndicators = CatalogEntry(
        id: "scrollIndicators",
        kind: .modifier,
        topic: .scrollViews,
        summary: "中の ScrollView のスクロールバーを出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollindicators(_:axes:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollIndicators",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".never"), Choice(".automatic")], initial: 0),
                on: true, summary: "バーを出すか（スクロールしている間に見る）")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...30, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .apply(
                    v.pick("scrollIndicators", from: [ScrollIndicatorVisibility.hidden, .visible, .never, .automatic])
                ) { $0.scrollIndicators($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollContentBackgroundEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollContentBackground = CatalogEntry(
        id: "scrollContentBackground",
        kind: .modifier,
        topic: .scrollViews,
        summary: "List・Form・TextEditor などのスクロールする View の、決まった地の色を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollcontentbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollContentBackground",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0),
                on: true, summary: "決まった地を出すか（隠すと、後ろの .background が見える）")
        ],
        code: CodeTemplate(
            call: "List", trailing: " {\n    Text(\"りんご\")\n    Text(\"みかん\")\n}", suffix: [".background(.mint)"]),
        build: { v in
            AnyView(
                List {
                    Text("りんご")
                    Text("みかん")
                }
                .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible, .automatic])) {
                    $0.scrollContentBackground($1)
                }
                .background(.mint)
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollClipDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollClipDisabled = CatalogEntry(
        id: "scrollClipDisabled",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が、中身を自分の枠で切り取らないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollclipdisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollClipDisabled", .toggle(initial: true), on: true, summary: "切り取らない（影と、枠の左右の外が見える）")
        ],
        code: CodeTemplate(
            call: "ScrollView", fixedArguments: [".horizontal"],
            trailing: " {\n    HStack {\n        ForEach(1...6, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 80, height: 80)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n"
                + "                .shadow(radius: 8)\n        }\n    }\n}",
            suffix: [".padding(.horizontal, 48)"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(1...6, id: \.self) { i in
                            Text("\(i)")
                                .frame(width: 80, height: 80)
                                .background(.yellow, in: .rect(cornerRadius: 12))
                                .shadow(radius: 8)
                        }
                    }
                }
                .apply(v.flag("scrollClipDisabled")) { $0.scrollClipDisabled($1) }
                .padding(.horizontal, 48)
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollDisabled = CatalogEntry(
        id: "scrollDisabled",
        kind: .modifier,
        topic: .scrollViews,
        summary: "中の ScrollView を、指でスクロールできないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolldisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier("scrollDisabled", .toggle(initial: true), on: true, summary: "スクロールできなくする")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...30, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .apply(v.flag("scrollDisabled")) { $0.scrollDisabled($1) }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .onScrollVisibilityChange,
        .onScrollPhaseChange,
        .scrollIndicatorsFlash,
        .scrollIndicators,
        .scrollContentBackground,
        .scrollClipDisabled,
        .scrollDisabled,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`CatalogTests.buildsAllCombinations` に新しい id が並ぶ）

Run: `python3 tools/catalog_progress.py scroll-views`
Expected: 終了コード 1 のままでよい（残りはあとのタスク）。`scroll-views` の行が `16 / 21`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/ScrollViews/OnScrollVisibilityChangeEntry.swift \
  WidgetLab/Catalog/ScrollViews/OnScrollPhaseChangeEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollIndicatorsFlashEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollIndicatorsEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollContentBackgroundEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollClipDisabledEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollDisabledEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: onScrollVisibilityChange・onScrollPhaseChange・scrollIndicatorsFlash・scrollIndicators・scrollContentBackground・scrollClipDisabled・scrollDisabled を収録する"
```

---

### Task 7: スクロール 3（scrollBounceBehavior・scrollEdgeEffectStyle・scrollEdgeEffectHidden・safeAreaBar・scrollInputBehavior）と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/ScrollViews/ScrollBounceBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/EdgeEffectDemo.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectStyleEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectHiddenEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/SafeAreaBarEntry.swift`
- Create: `WidgetLab/Catalog/ScrollViews/ScrollInputBehaviorEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表 2 件のスクリーンショット）
- Modify: `docs/architecture.md`（UI テストの行）
- Modify: `docs/cataloging-guide.md`（試作でわかったこと）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`EnvironmentValues.demoRecorder`（どれも変えない）
- Produces: `CatalogEntry.scrollBounceBehavior`、`CatalogEntry.scrollEdgeEffectStyle`、`CatalogEntry.scrollEdgeEffectHidden`、`CatalogEntry.safeAreaBar`、`CatalogEntry.scrollInputBehavior`、`EdgeEffectDemo.rows`・`EdgeEffectDemo.bar`（Task 7 の 3 件で使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py lists tables scroll-views`
Expected: 終了コード 1。抜けに scrollBounceBehavior・scrollEdgeEffectStyle・scrollEdgeEffectHidden・safeAreaBar・scrollInputBehavior がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ScrollViews/ScrollBounceBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollBounceBehavior = CatalogEntry(
        id: "scrollBounceBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が端に着いたときに跳ね返るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollbouncebehavior(_:axes:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollBounceBehavior",
                .choice([Choice(".basedOnSize"), Choice(".always"), Choice(".automatic")], initial: 0), on: true,
                summary: "跳ね返り方（.basedOnSize は、中身が枠より小さいと跳ね返らない）")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    Text(\"行 1\")\n    Text(\"行 2\")\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    Text("行 1")
                    Text("行 2")
                }
                .frame(maxWidth: .infinity)
                .apply(v.pick("scrollBounceBehavior", from: [ScrollBounceBehavior.basedOnSize, .always, .automatic])) {
                    $0.scrollBounceBehavior($1)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/EdgeEffectDemo.swift`:

```swift
import SwiftUI

/// スクロールの端の効果（scrollEdgeEffectStyle・scrollEdgeEffectHidden・safeAreaBar）の見本の中身。
/// 色の違う行を並べる。端の効果は、上のバーの下に入った中身をぼかす
enum EdgeEffectDemo {
    static var rows: some View {
        ForEach(1...30, id: \.self) { i in
            Text("行 \(i)")
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))
        }
    }

    /// 上に置く見出しのバー
    static var bar: some View {
        Text("見出しのバー")
            .font(.headline)
            .padding(8)
    }
}
```

`WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectStyleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollEdgeEffectStyle = CatalogEntry(
        id: "scrollEdgeEffectStyle",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の端で、上に重なるバー（ツールバーや safeAreaBar）の下の中身をぼかす効果の形を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolledgeeffectstyle(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollEdgeEffectStyle", id: "scrollEdgeEffectStyle.style",
                .choice([Choice(".hard"), Choice(".soft"), Choice(".automatic")], initial: 0), on: true,
                summary: "効果の形（.hard はくっきりした境目、.soft はなだらか）"),
            .modifier(
                "scrollEdgeEffectStyle", id: "scrollEdgeEffectStyle.edges", label: "for",
                .choice([Choice(".top"), Choice(".bottom"), Choice(".all")], initial: 0), required: true,
                summary: "効果を変える端"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...30, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity, minHeight: 44)",
                "            .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))", "    }",
                "}", ".defaultScrollAnchor(.center)",
            ],
            indent: 0, call: ".safeAreaBar", fixedArguments: ["edge: .top", "content: { Text(\"見出しのバー\").padding(8) }"]),
        build: { v in
            let edges = v.pick("scrollEdgeEffectStyle.edges", from: [Edge.Set.top, .bottom, .all]) ?? .all
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .defaultScrollAnchor(.center)
                    .safeAreaBar(edge: .top) { EdgeEffectDemo.bar }
                    .apply(
                        v.pick("scrollEdgeEffectStyle.style", from: [ScrollEdgeEffectStyle.hard, .soft, .automatic])
                    ) { $0.scrollEdgeEffectStyle($1, for: edges) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectHiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollEdgeEffectHidden = CatalogEntry(
        id: "scrollEdgeEffectHidden",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の端で、上に重なるバーの下の中身をぼかす効果を消す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolledgeeffecthidden(_:for:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollEdgeEffectHidden", id: "scrollEdgeEffectHidden.hidden", .toggle(initial: true), on: true,
                summary: "効果を消す"),
            .modifier(
                "scrollEdgeEffectHidden", id: "scrollEdgeEffectHidden.edges", label: "for",
                .choice([Choice(".top"), Choice(".bottom"), Choice(".all")], initial: 0), required: true,
                summary: "効果を消す端"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...30, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity, minHeight: 44)",
                "            .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))", "    }",
                "}", ".defaultScrollAnchor(.center)",
            ],
            indent: 0, call: ".safeAreaBar", fixedArguments: ["edge: .top", "content: { Text(\"見出しのバー\").padding(8) }"]),
        build: { v in
            let edges = v.pick("scrollEdgeEffectHidden.edges", from: [Edge.Set.top, .bottom, .all]) ?? .all
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .defaultScrollAnchor(.center)
                    .safeAreaBar(edge: .top) { EdgeEffectDemo.bar }
                    .apply(v.flag("scrollEdgeEffectHidden.hidden")) { $0.scrollEdgeEffectHidden($1, for: edges) }
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/SafeAreaBarEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaBar = CatalogEntry(
        id: "safeAreaBar",
        kind: .modifier,
        topic: .scrollViews,
        summary: "View の端に、自前のバーを置く modifier。safeAreaInset と違い、下に入ったスクロールの中身にぼかしの効果がかかる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "safeAreaBar", id: "safeAreaBar.edge", label: "edge",
                .choice([Choice(".top"), Choice(".bottom")], initial: 0),
                required: true, summary: "バーを置く端"),
            .modifier(
                "safeAreaBar", id: "safeAreaBar.content", label: "content",
                .fixed(code: "{ Text(\"見出しのバー\").padding(8) }"), on: true, summary: "バーの中身"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    ForEach(1...30, id: \\.self) { i in\n        Text(\"行 \\(i)\")\n"
                + "            .frame(maxWidth: .infinity, minHeight: 44)\n"
                + "            .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))\n    }\n}",
            suffix: [".defaultScrollAnchor(.center)"]),
        build: { v in
            let edge = v.pick("safeAreaBar.edge", from: [VerticalEdge.top, .bottom]) ?? .top
            return AnyView(
                ScrollView { EdgeEffectDemo.rows }
                    .apply(v["safeAreaBar.content"] != nil ? () : nil) { view, _ in
                        view.safeAreaBar(edge: edge) { EdgeEffectDemo.bar }
                    }
                    .defaultScrollAnchor(.center)
            )
        }
    )
}
```

`WidgetLab/Catalog/ScrollViews/ScrollInputBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollInputBehavior = CatalogEntry(
        id: "scrollInputBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "決まった種類の入力で、ScrollView をスクロールできるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollinputbehavior(_:for:)")!,
        noteReason: "入力の種類が、visionOS の見ることでのスクロール（.look）と、watchOS の指や手首の動き（.handGestureShortcut）だけで、iPhone では効かない",
        properties: [
            .modifier(
                "scrollInputBehavior", id: "scrollInputBehavior.behavior",
                .choice([Choice(".disabled"), Choice(".enabled"), Choice(".automatic")], initial: 0), on: true,
                summary: "その入力でスクロールできるか"),
            .modifier(
                "scrollInputBehavior", id: "scrollInputBehavior.kind", label: "for",
                .choice([Choice(".look"), Choice(".handGestureShortcut")], initial: 0), required: true,
                summary: "入力の種類"),
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}")
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .scrollBounceBehavior,
        .scrollEdgeEffectStyle,
        .scrollEdgeEffectHidden,
        .safeAreaBar,
        .scrollInputBehavior,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `testTextEntriesShowPreview` の前（`@MainActor` の行から）に足す。編集モードの List（`ImageRenderer` では白く描かれる）と、スクロールの端の効果の代表を 1 件ずつ撮る:

```swift
    @MainActor
    func testListEntriesShowPreview() {
        for (id, title) in [("deleteDisabled", ".deleteDisabled"), ("safeAreaBar", ".safeAreaBar")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }

```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「レイアウト・描画・テキスト・操作の部品の代表 2 件ずつのスクリーンショットの 7 本」を、「レイアウト・描画・テキスト・操作の部品・一覧とスクロールの代表 2 件ずつのスクリーンショットの 8 本」に置き換える（ほかの束が先に本数を変えていたら、その数に 1 を足し、「一覧とスクロール」を並びに足す）。

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 3 か所だけ直す（ほかの行は変えない）。

1. 5 章の「束 4 は `testDrawingEntriesShowPreview`）」を「束 4 は `testDrawingEntriesShowPreview`、束 6 は `testListEntriesShowPreview`）」に置き換える

2. 7 章の最後の段落（`**違いが幅に左右されるもの → 幅を刻んで描き比べる。**` で始まる段落）のあと、`## 用語` の前に、空行を挟んで次の段落を足す:

```markdown
**省けない引数と、既定の値がある引数を 1 行にまとめる → 省けない引数を ON / OFF にし、既定の値がある引数を required にする。** `listRowSeparatorTint(_:edges:)` の色は省けず、`edges` は省ける。`edges` を ON / OFF できると、色が OFF で `edges` が ON のとき `.listRowSeparatorTint(edges: .top)` という書けないコードになる。色を required でない ON のプロパティにし、`edges` を required にすると、色が OFF なら行ごと消え、ON なら `edges` も書かれる（束 6 の `listRowSeparator`・`listRowInsets`・`swipeActions`・`scrollPosition`・`scrollTransition`・`onScrollGeometryChange` ほか）。

**iPhone で形が変わる View → 幅の区分では戻らないことがある。** `Table` は iPhone（幅が compact）で、最初の列だけを 1 列の一覧として出す。`.environment(\.horizontalSizeClass, .regular)` をかけても、列も見出しも出なかった。束 6 では `tableColumnHeaders` を `.note` にした。

**スクロールしないと見えない効き目 → 開いたときから見える位置にする。** `scrollEdgeEffectStyle` などの端の効果は、バーの下に中身が入らないと見えない。`.defaultScrollAnchor(.center)` で、最初から中身がバーの下に入るようにした（コードにも書く）。

**右端に出る効き目は、比べるで見えない → 最初の値を、付けないときと違う見た目にする。** 比べるの左半分は「付けない」側なので、List の索引やバッジのように右端に出るものは違いが見えない。索引は付けないと出る（`.automatic`）ので、`listSectionIndexVisibility` の最初の値を `.hidden` にし、編集パネルの ON / OFF で違いが出るようにした。

**ScrollGeometry の値が負から始まる → `contentInsets.top` を足す。** `contentOffset.y` は、上の余白（`safeAreaInset` で置いた表示など）の分だけ負から始まる。`onScrollGeometryChange` の見本は、`$0.contentOffset.y + $0.contentInsets.top` で 0 から数える。

**操作してから見る効き目 → 一時的な UI テストで操作してから撮る。** チップは `app.buttons["chip-<プロパティの id>"]`、編集パネルの ON / OFF は `app.switches["editor-on"]` で、スイッチの右端（`coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))`）を押す（真ん中を押しても切り替わらない）。引っ張って更新は、行の座標から `press(forDuration:thenDragTo:)` で下へ引く。
```

3. 最後の行「最終更新: 2026-11-04（束 2・3・4 のあと）」を「最終更新: 2026-11-04（束 2・3・4・6 のあと）」に置き換える（ほかの束が先に変えていたら、その並びに「6」を足す）

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テスト 8 本が全部通る

Run: `python3 tools/catalog_progress.py lists tables scroll-views`
Expected: 終了コード 0。`合計 46 / 46（抜け 0）`

- [ ] **Step 7: スクリーンショットを見る**

Run: `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `deleteDisabled` の画像で、編集モードの List の みかん・ぶどう の行に赤い削除の印が出て、りんご の行には出ない。`safeAreaBar` の画像で、色の行の上に「見出しのバー」が出て、行 14 あたりから見えている（どちらも `ImageRenderer` では白く描かれるので、ここで見る）

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/ScrollViews/ScrollBounceBehaviorEntry.swift \
  WidgetLab/Catalog/ScrollViews/EdgeEffectDemo.swift \
  WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectStyleEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollEdgeEffectHiddenEntry.swift \
  WidgetLab/Catalog/ScrollViews/SafeAreaBarEntry.swift \
  WidgetLab/Catalog/ScrollViews/ScrollInputBehaviorEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  docs/architecture.md \
  docs/cataloging-guide.md
git commit -m "feat: scrollBounceBehavior・scrollEdgeEffectStyle・scrollEdgeEffectHidden・safeAreaBar・scrollInputBehavior を収録し、束 6 の代表のスクリーンショットと手引きを足す"
```

---

## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、`~/dev/widget-lab`（main）で `--no-ff` でマージする。マージの前に `git -C ~/dev/widget-lab status` がきれいなこと（`.claude/` の未追跡は元からある）と、ほかの束がマージの途中でないことを確かめる。`Catalog.swift` がぶつかったら両方の行を残す（`cataloging-guide.md`・`architecture.md`・`LaunchUITests.swift` がぶつかったら、両方の束の追記を残す）
- マージのあとで main の lint と単体テストを流し、通ってから push する。ブランチは消さない
