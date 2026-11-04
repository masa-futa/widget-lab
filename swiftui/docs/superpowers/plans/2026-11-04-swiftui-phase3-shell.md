# SwiftUI 版 Phase 3 束 8（アプリの骨組み）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** toolbars・search・app-organization・scenes・windows・documents・app-extensions の 32 件を収録して、7 トピックの抜けを 0 にする。

**Architecture:** 1 件 = 1 ファイルの収録データを 5〜8 件ずつ足し、`Catalog.all` に並べる。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。複数の収録で使う補助（`ToolbarDemo`・`SearchDemo`・`FindDemo`）はトピックのフォルダに置く。stage は `.full` が 18 件、`.card` が 4 件、`.note` が 10 件。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 8 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone 17**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドのまま（`name=iPhone 17`）。並列で動く束 9・10 も同じ名前を使うが、置き換えない
- `WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない。変えたくなったら、変える前にコントローラーに知らせて止まる（並列の束とぶつかるため）
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）
- この計画に書いたコードは、試作でテストとスクリーンショットを通したもの。そのまま写す。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける。コントローラーが試作のファイルと `cmp` で比べる
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
  UI テストまで通すのは Task 5 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。プロパティはチップの順。* は最初から ON、R は required。

### toolbars（12 件）

ツールバーに効く modifier は、詳細の NavigationStack のバーに混ざらないよう `.full` にする（束 7 の `navigationTitle` と同じ理由）。見本は `ToolbarStack`（40 行のメモの一覧・右上の「足す」・下のバーの「並べ替え」・題名「メモ」）に modifier をかけ、コードは `CodeTemplate.inToolbarStack()`（`.navigationTitle("メモ")` を call にし、modifier はその下に並ぶ）。

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| toolbar | .full | 付け外し | .toolbar*（4 つ、最初は .topBarTrailing） | `NavigationStack { List(1...40) { … }.navigationTitle("メモ").toolbar(content: { ToolbarItem(placement: .topBarTrailing) { Button("足す", systemImage: "plus") { } } }) }` |
| toolbarOverflowMenu | .full | 付け外し | .toolbarOverflowMenu*（固定） | `ToolbarStack` の形で `.toolbarOverflowMenu(content: { Button("書き出す", …) { }; Button("印刷", …) { } })`。右上に「…」が出る |
| toolbarVisibility | .full | 付け外し | .toolbarVisibility*（3 つ、最初は .hidden）・.toolbarVisibility(for:) R（.navigationBar・.bottomBar） | `….toolbarVisibility(.hidden, for: .navigationBar)` |
| toolbarBackgroundVisibility | .full | 付け外し | .toolbarBackgroundVisibility*（3 つ、最初は .visible）・(for:) R | `….toolbarBackgroundVisibility(.visible, for: .navigationBar)`、suffix に `.toolbarBackground(.yellow, for: .navigationBar, .bottomBar)`・`.toolbarTitleDisplayMode(.inline)` |
| toolbarRole | .note | 付け外し | .toolbarRole*（4 つ、最初は .editor） | `NavigationStack { List(fruits…) { NavigationLink }.navigationTitle("果物").toolbarRole(.editor).navigationDestination(…) }` |
| toolbarColorScheme | .full | 付け外し | .toolbarColorScheme*（.dark・.light）・(for:) R | `….toolbarColorScheme(.dark, for: .navigationBar)`、suffix に `.toolbarBackground(.indigo, …)`・`.toolbarBackgroundVisibility(.visible, …)`・`.toolbarTitleDisplayMode(.inline)` |
| toolbarBackground | .full | 付け外し | .toolbarBackground*（色、最初は yellow）・(for:) R | `….toolbarBackground(.yellow, for: .navigationBar)`、suffix に `.toolbarBackgroundVisibility(.visible, …)`・`.toolbarTitleDisplayMode(.inline)` |
| toolbarTitleDisplayMode | .full | 付け外し | .toolbarTitleDisplayMode*（4 つ、最初は .inlineLarge） | `….toolbarTitleDisplayMode(.inlineLarge)` |
| toolbarTitleMenu | .full | 付け外し | .toolbarTitleMenu*（固定） | `….toolbarTitleMenu(content: { Button("名前を変える", …) { }; Button("複製", …) { } })`、suffix に `.toolbarTitleDisplayMode(.inline)` |
| toolbarMinimizationBehavior | .full | 付け外し | .toolbarMinimizationBehavior*（4 つ、最初は .onScrollDown）・(for:) R（.navigationBar・.bottomBar） | `….toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)` |
| toolbarMinimizationRestoration | .full | 付け外し | .toolbarMinimizationRestoration*（.automatic・.atScrollEdge、最初は .atScrollEdge）・(for:) R | `….toolbarMinimizationRestoration(.atScrollEdge, for: .navigationBar)`、suffix に `.toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)` |
| toolbarMinimizationSafeAreaAdjustment | .full | 付け外し | .toolbarMinimizationSafeAreaAdjustment*（3 つ、最初は .disabled）・(for:) R | `….toolbarMinimizationSafeAreaAdjustment(.disabled, for: .navigationBar)`、suffix に `.toolbarMinimizationBehavior(…)` と `.overlay(alignment: .top) { Text("安全な領域の上の端").background(.yellow, ignoresSafeAreaEdges: []) }` |

`for:` を持つ modifier は、手引き 7 章の「1 行にまとめる引数が複数ある」の決まりで、中身の引数（見せ方・色）を ON / OFF にし、`for:` を required にする。

### search（8 件）

検索の欄は詳細の NavigationStack のバーに入るので、`searchable` の仲間は `.full` にする。見本は `SearchStack`（8 つの品物の一覧。打った文字と範囲で絞る）に modifier をかけ、コードは `CodeTemplate.inSearchStack()`（`.searchable(text: $query)` を call にし、modifier はその下に並ぶ）。find の 3 件は TextEditor の中の帯なので `.card`。

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| searchable | .full | 付け外し | .searchable*（text: `$query`）・.searchable(placement:) R（3 つ）・.searchable(prompt:) R（文字） | `NavigationStack { List(names…) { Text($0) }.navigationTitle("品物").searchable(text: $query, placement: .automatic, prompt: "品物の名前") }` |
| searchSuggestions | .full | 付け外し | .searchSuggestions*（固定） | `….searchable(text: $query).searchSuggestions({ ForEach(["りんご", "トマト"]…) { Label(…).searchCompletion($0) } })` |
| searchCompletion | .full | 付け外し（入れ子） | .searchCompletion*（`name`） | `….searchSuggestions { ForEach(…) { name in Label(name, systemImage: "magnifyingglass").searchCompletion(name) } }`。候補を押すと欄に入る |
| searchScopes | .full | 付け外し | .searchScopes.scope R（`$scope`）・.searchScopes(activation:) R（3 つ、最初は .onSearchPresentation）・.searchScopes*（中身） | `….searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always)).searchScopes($scope, activation: .onSearchPresentation, { Text("すべて").tag(0); … })` |
| searchPresentationToolbarBehavior | .full | 付け外し | .searchPresentationToolbarBehavior*（2 つ、最初は .avoidHidingContent） | `….searchable(text: $query).searchPresentationToolbarBehavior(.avoidHidingContent)` |
| findNavigator | .card | 付け外し | .findNavigator*（isPresented: `$shows`） | `Button("検索の帯を出す") { shows.toggle() }` と `TextEditor(text: $memo).findNavigator(isPresented: $shows)` |
| findDisabled | .card | 付け外し | .findDisabled*（true） | 同じ形で `TextEditor(text: $memo).findDisabled(true).findNavigator(isPresented: $shows)` |
| replaceDisabled | .card | 付け外し | .replaceDisabled*（true） | 同じ形で `.replaceDisabled(true)` |

### app-organization・scenes・windows・documents（7 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| UIApplicationDelegateAdaptor | .note | プロパティラッパー | @UIApplicationDelegateAdaptor | `@main struct MemoApp: App { @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate … }` と `final class AppDelegate`。外すと宣言の行が「AppDelegate は作られない」のコメントになる |
| sceneAccessory | .note | 付け外し | .sceneAccessory*（固定） | `Text("本体の画面").sceneAccessory(content: { ExternalNonInteractiveAccessory { Text("つないだ画面に出す") } })` |
| windowToolbarFullScreenVisibility | .note | 付け外し | .windowToolbarFullScreenVisibility*（3 つ、最初は .onHover） | `Text("本文").windowToolbarFullScreenVisibility(.onHover)` |
| allowsWindowActivationEvents | .note | 付け外し | .allowsWindowActivationEvents*（true） | `Circle().frame(width: 80, height: 80).gesture(DragGesture()).allowsWindowActivationEvents(true)` |
| DocumentLaunchView | .full | View | title R（文字）・for R（`[.plainText]`） | `DocumentLaunchView("メモ", for: [.plainText]) { NewDocumentButton("新しいメモ") } onDocumentOpen: { url in Text(url.lastPathComponent) }` |
| NewDocumentButton | .full | View | title R（文字）・contentType（`.plainText`） | `DocumentLaunchView("メモ", for: [.plainText]) { NewDocumentButton("新しいメモ") } onDocumentOpen: { … }` |
| RenameButton | .card | View | .renameAction*（`$isFocused`）・.labelStyle（3 つ）・.buttonStyle*（2 つ） | `VStack { TextField("名前", text: $name).focused($isFocused); RenameButton() }.renameAction($isFocused).buttonStyle(.bordered)` |

### app-extensions（5 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| controlWidgetActionHint | .note | 付け外し | .controlWidgetActionHint*（文字） | `// ControlWidgetToggle の label の中` と `Label("明かり", systemImage: "lightbulb").controlWidgetActionHint("つける")` |
| controlWidgetStatus | .note | 付け外し | .controlWidgetStatus*（文字） | 同じ形で `.controlWidgetStatus("ついている")` |
| widgetLabel | .note | 付け外し | .widgetLabel*（文字） | `// accessoryCircular のウィジェットの中` と `Gauge(value: 0.7) { Text("気温") }.widgetLabel("東京 21°").gaugeStyle(.accessoryCircular)` |
| widgetAccentable | .note | 付け外し | .widgetAccentable*（true） | `// ウィジェットの中` と `VStack { Text("21°").widgetAccentable(true).font(.largeTitle); Text("東京") }` |
| dynamicIsland | .note | 付け外し | .dynamicIsland*（verticalPlacement: `.belowIfTooWide`） | `// DynamicIslandExpandedRegion(.leading) の中` と `Text("到着まで 5 分").dynamicIsland(verticalPlacement: .belowIfTooWide)` |

### `.full` にするもの（18 件）と理由

- ツールバーに効く modifier（toolbars の 11 件）: 枠の中に描くと、詳細の NavigationStack の中にもう 1 つ入れ子になり、ボタンや題名が詳細のバーと混ざる。全画面で開けば、バーがひとつになる
- 検索の欄を出すもの（search の 5 件）: 検索の欄はナビゲーションバー（iPhone では下）に入るので、詳細の画面の検索と混ざる
- 書類の起動の画面（DocumentLaunchView・NewDocumentButton）: 画面いっぱいの起動の画面で、下に書類の一覧（ファイルの画面）が出る。枠に収まらない

### `.note` にするもの（10 件、31%）と理由

| id | 理由（`noteReason`） |
|---|---|
| toolbarRole | iOS 27.0 の iPhone 17 で .browser・.editor にしても、題名と戻るボタンの出し方は変わらなかった。iPad で、題名を左に寄せるなどの違いが出る |
| UIApplicationDelegateAdaptor | アプリの入口（@main の App）に書くもの。デリゲートはアプリが起動するときに 1 回だけ作られるので、アプリの画面の中では試せない |
| sceneAccessory | iPhone に外のディスプレイをつないだときに、そのディスプレイに出る。アプリの画面の中には出ない |
| windowToolbarFullScreenVisibility | Mac だけで効く（iOS で選べるのは .automatic だけ）。Mac で窓をフルスクリーンにしたときに、ツールバーの出し方が変わる |
| allowsWindowActivationEvents | 窓を並べられる iPad と Mac で効く。iPhone では窓がいつも 1 つで手前にあるので、違いが出ない |
| controlWidgetActionHint | アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンター・ロック画面・アクションボタンに置いたときに出る |
| controlWidgetStatus | アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンターで押したときに、状態の文が出る |
| widgetLabel | アプリ拡張のウィジェットの中で効く。ロック画面や Apple Watch の小さなウィジェット（accessory の大きさ）に置いたときに出る |
| widgetAccentable | アプリ拡張のウィジェットの中で効く。ロック画面・Apple Watch・色付きのホーム画面など、ウィジェットを 2 色で描くときに出る |
| dynamicIsland | アプリ拡張のライブアクティビティの中で効く。Dynamic Island を長押しして広げたときに出る |

手引きの数え方（iPhone で見せる工夫が足りずに `.note` にしたものだけを数える）では、10 件のうち 8 件は数えない（iPad・Mac だけで効くもの 3 件と、アプリ拡張の中で効くもの 5 件。toolbarRole は試作で iPhone では変わらないと確かめた）。残りの 2 件（UIApplicationDelegateAdaptor・sceneAccessory）は iPhone でも効くが、アプリの入口と外のディスプレイなので、アプリの画面を足しても見せられない。念のため数えに入れても多くて 2 件で、全体（335 件）の 1 割に届かない。

### 試作でわかったこと（Task 5 で収録の手引きに足す）

- **ツールバーの地は、色を付けないと見えない。** iOS 27 のバーは地がなく（中身が透けて見える）、`toolbarBackgroundVisibility(.visible)` だけでは見た目が変わらなかった。`toolbarBackground(.yellow, …)` と組にした。大きな題名は、地の色を出すと消えたので、`toolbarTitleDisplayMode(.inline)` でバーの中に出した
- **畳むのはナビゲーションバー。** `toolbarMinimizationBehavior(.onScrollDown, for: .bottomBar)` は、下のバーのボタンが 1 つだけだと見た目が変わらなかった。`for: .navigationBar` なら、下へスクロールするとバーが消える。`toolbarMinimizationRestoration(.atScrollEdge)` は、少し上へ戻してもバーが消えたまま（付けないと戻る）
- **安全な領域の違いは、上の端に印を置いて見る。** `toolbarMinimizationSafeAreaAdjustment` は一覧だけでは違いが見えない。`.overlay(alignment: .top)` で文字を置くと、`.disabled` なら畳んだあとも印が元の位置に残る。印の地は `background(_:ignoresSafeAreaEdges: [])` にする（ふつうの `background` は安全な領域の外まで伸びて、位置がわからない）
- **検索の範囲は、`activation: .onSearchPresentation` を渡すと出る。** `searchScopes(_:scopes:)` のままでは、iOS 27.0 の iPhone 17 で欄を押しても切り替えが出なかった
- **find の帯は、TextEditor に入力の印があるときだけ出る。** 文を押してからボタンで `findNavigator(isPresented:)` を true にすると、キーボードの上に帯が出る。`FocusState` で印を入れながら true にしても出なかった
- **`DocumentLaunchView` は DocumentGroup の外でも描ける。** ただし下の書類の一覧が出るまで数秒かかり、`NewDocumentButton` を押しても書類は開かない
- **iOS 26 から、戻るボタンはいつも矢印だけ。** `toolbarRole(.editor)` で戻るボタンの文を消す違いは、iPhone では出ない

---
### Task 1: toolbar・toolbarOverflowMenu・toolbarVisibility・toolbarBackgroundVisibility・toolbarRole・toolbarColorScheme・toolbarBackground

**Files:**
- Create: `WidgetLab/Catalog/Toolbars/ToolbarDemo.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarOverflowMenuEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarBackgroundVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarRoleEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarColorSchemeEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarBackgroundEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: `CatalogEntry.toolbar`、`CatalogEntry.toolbarOverflowMenu`、`CatalogEntry.toolbarVisibility`、`CatalogEntry.toolbarBackgroundVisibility`、`CatalogEntry.toolbarRole`、`CatalogEntry.toolbarColorScheme`、`CatalogEntry.toolbarBackground`、補助 `ToolbarStack<Root: View>`（`init(modify: (AnyView) -> Root)`）・`CodeTemplate.inToolbarStack(suffix: [String] = []) -> CodeTemplate`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py toolbars`
Expected: 終了コード 1。抜けに toolbar・toolbarOverflowMenu・toolbarVisibility・toolbarBackgroundVisibility・toolbarRole・toolbarColorScheme・toolbarBackground がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は直さない）。

`WidgetLab/Catalog/Toolbars/ToolbarDemo.swift`:

```swift
import SwiftUI

/// ツールバーの見本の入れ物。長いメモの一覧（スクロールで変わる modifier のため）を NavigationStack に出し、
/// 右上と下のバーのボタンと、題名「メモ」を付ける。一覧にかける modifier を modify で渡す
struct ToolbarStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView) -> Root

    var body: some View {
        NavigationStack {
            modify(
                AnyView(
                    List(1...40, id: \.self) { Text("メモ \($0)") }
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) { Button("足す", systemImage: "plus") {} }
                            ToolbarItem(placement: .bottomBar) {
                                Button("並べ替え", systemImage: "arrow.up.arrow.down") {}
                            }
                        }
                        .navigationTitle("メモ")
                ))
        }
    }
}

nonisolated extension CodeTemplate {
    /// ToolbarStack の一覧にかける modifier の収録のコード。call が .navigationTitle で、modifier はその下に並ぶ
    static func inToolbarStack(suffix: [String] = []) -> CodeTemplate {
        CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(1...40, id: \\.self) { Text(\"メモ \\($0)\") }", "        .toolbar {",
                "            ToolbarItem(placement: .topBarTrailing) { Button(\"足す\", systemImage: \"plus\") { } }",
                "            ToolbarItem(placement: .bottomBar) { Button(\"並べ替え\", systemImage: \"arrow.up.arrow.down\") { } }",
                "        }",
            ], indent: 8, call: ".navigationTitle", fixedArguments: ["\"メモ\""], suffix: suffix, closing: ["}"])
    }
}
```

`WidgetLab/Catalog/Toolbars/ToolbarEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbar = CatalogEntry(
        id: "toolbar",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバー（ツールバー）に、ボタンなどの項目を置く modifier。置く場所は ToolbarItem の placement で決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbar(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbar",
                .choice(
                    [
                        Choice(
                            ".topBarTrailing",
                            code:
                                "content: { ToolbarItem(placement: .topBarTrailing) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".topBarLeading",
                            code:
                                "content: { ToolbarItem(placement: .topBarLeading) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".bottomBar",
                            code:
                                "content: { ToolbarItem(placement: .bottomBar) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                        Choice(
                            ".principal",
                            code:
                                "content: { ToolbarItem(placement: .principal) { Button(\"足す\", systemImage: \"plus\") { } } }"
                        ),
                    ], initial: 0), on: true,
                summary: "置く項目。ToolbarItem の placement で、右上・左上・下のバー・真ん中（題名の場所）に置く")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(1...40, id: \\.self) { Text(\"メモ \\($0)\") }"], indent: 8,
            call: ".navigationTitle", fixedArguments: ["\"メモ\""], closing: ["}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    List(1...40, id: \.self) { Text("メモ \($0)") }
                        .navigationTitle("メモ")
                        .apply(
                            v.pick(
                                "toolbar",
                                from: [
                                    ToolbarItemPlacement.topBarTrailing, .topBarLeading, .bottomBar, .principal,
                                ])
                        ) { view, placement in
                            view.toolbar {
                                ToolbarItem(placement: placement) { Button("足す", systemImage: "plus") {} }
                            }
                        }
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarOverflowMenuEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarOverflowMenu = CatalogEntry(
        id: "toolbarOverflowMenu",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの「…」のメニュー（収まらない項目を入れる所）に、項目を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbaroverflowmenu(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarOverflowMenu",
                .fixed(
                    code:
                        "content: { Button(\"書き出す\", systemImage: \"square.and.arrow.up\") { }; Button(\"印刷\", systemImage: \"printer\") { } }"
                ), on: true, summary: "メニューに足す項目。右上の「…」を押すと出る")
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(v["toolbarOverflowMenu"]) { view, _ in
                        view.toolbarOverflowMenu {
                            Button("書き出す", systemImage: "square.and.arrow.up") {}
                            Button("印刷", systemImage: "printer") {}
                        }
                    }
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarVisibility = CatalogEntry(
        id: "toolbarVisibility",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーを、出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarvisibility(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "出すか。.hidden なら、バーごと隠れる（題名やボタンも）"),
            .modifier(
                "toolbarVisibility", id: "toolbarVisibility.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.pick("toolbarVisibility", from: [Visibility.automatic, .visible, .hidden])) {
                        $0.toolbarVisibility(
                            $1,
                            for: v.pick("toolbarVisibility.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarBackgroundVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarBackgroundVisibility = CatalogEntry(
        id: "toolbarBackgroundVisibility",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーの地を、出すか隠すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarbackgroundvisibility(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarBackgroundVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "地を出すか。.visible なら、スクロールしていなくても地の色が出る"),
            .modifier(
                "toolbarBackgroundVisibility", id: "toolbarBackgroundVisibility.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackground(.yellow, for: .navigationBar, .bottomBar)", ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick("toolbarBackgroundVisibility", from: [Visibility.automatic, .visible, .hidden])
                    ) {
                        $0.toolbarBackgroundVisibility(
                            $1,
                            for: v.pick(
                                "toolbarBackgroundVisibility.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackground(.yellow, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarRoleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarRole = CatalogEntry(
        id: "toolbarRole",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの役割（ふつうの画面・ブラウザ・編集の画面）を決める modifier。役割に合わせて、題名や戻るボタンの出し方が変わる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarrole(_:)")!,
        noteReason: "iOS 27.0 の iPhone 17 で .browser・.editor にしても、題名と戻るボタンの出し方は変わらなかった。iPad で、題名を左に寄せるなどの違いが出る",
        properties: [
            .modifier(
                "toolbarRole",
                .choice(
                    [Choice(".automatic"), Choice(".navigationStack"), Choice(".browser"), Choice(".editor")],
                    initial: 3), on: true,
                summary: "役割。.editor は書類を編集する画面、.browser は中を見て回る画面")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }"],
            indent: 8, call: ".navigationTitle", fixedArguments: ["\"果物\""],
            suffix: [".navigationDestination(for: String.self) { Text($0) }"], closing: ["}"])
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarColorSchemeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarColorScheme = CatalogEntry(
        id: "toolbarColorScheme",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーを、明るい見た目と暗い見た目のどちらで描くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarcolorscheme(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarColorScheme", .choice([Choice(".dark"), Choice(".light")], initial: 0), on: true,
                summary: "バーの見た目。.dark なら、濃い地の上で題名やボタンが白くなる"),
            .modifier(
                "toolbarColorScheme", id: "toolbarColorScheme.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackground(.indigo, for: .navigationBar, .bottomBar)",
            ".toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)",
            ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.pick("toolbarColorScheme", from: [ColorScheme.dark, .light])) {
                        $0.toolbarColorScheme(
                            $1,
                            for: v.pick("toolbarColorScheme.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackground(.indigo, for: .navigationBar, .bottomBar)
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarBackgroundEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarBackground = CatalogEntry(
        id: "toolbarBackground",
        kind: .modifier,
        topic: .toolbars,
        summary: "ナビゲーションバーや下のバーの地の色（ShapeStyle）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarbackground(_:for:)")!,
        stage: .full,
        properties: [
            .modifier("toolbarBackground", .color(initial: 2), on: true, summary: "地の色"),
            .modifier(
                "toolbarBackground", id: "toolbarBackground.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)",
            ".toolbarTitleDisplayMode(.inline)",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(v.color("toolbarBackground")) {
                        $0.toolbarBackground(
                            $1,
                            for: v.pick("toolbarBackground.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar, .bottomBar)
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .toolbar,
        .toolbarOverflowMenu,
        .toolbarVisibility,
        .toolbarBackgroundVisibility,
        .toolbarRole,
        .toolbarColorScheme,
        .toolbarBackground,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Toolbars/ToolbarDemo.swift WidgetLab/Catalog/Toolbars/ToolbarEntry.swift WidgetLab/Catalog/Toolbars/ToolbarOverflowMenuEntry.swift WidgetLab/Catalog/Toolbars/ToolbarVisibilityEntry.swift WidgetLab/Catalog/Toolbars/ToolbarBackgroundVisibilityEntry.swift WidgetLab/Catalog/Toolbars/ToolbarRoleEntry.swift WidgetLab/Catalog/Toolbars/ToolbarColorSchemeEntry.swift WidgetLab/Catalog/Toolbars/ToolbarBackgroundEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: アプリの骨組みの収録 toolbar・toolbarOverflowMenu・toolbarVisibility・toolbarBackgroundVisibility・toolbarRole・toolbarColorScheme・toolbarBackground

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

### Task 2: toolbarTitleDisplayMode・toolbarTitleMenu・toolbarMinimizationBehavior・toolbarMinimizationRestoration・toolbarMinimizationSafeAreaAdjustment

**Files:**
- Create: `WidgetLab/Catalog/Toolbars/ToolbarTitleDisplayModeEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarTitleMenuEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarMinimizationBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarMinimizationRestorationEntry.swift`
- Create: `WidgetLab/Catalog/Toolbars/ToolbarMinimizationSafeAreaAdjustmentEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。Task 1 の `ToolbarStack`・`CodeTemplate.inToolbarStack(suffix:)`
- Produces: `CatalogEntry.toolbarTitleDisplayMode`、`CatalogEntry.toolbarTitleMenu`、`CatalogEntry.toolbarMinimizationBehavior`、`CatalogEntry.toolbarMinimizationRestoration`、`CatalogEntry.toolbarMinimizationSafeAreaAdjustment`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py toolbars`
Expected: 終了コード 1。抜けに toolbarTitleDisplayMode・toolbarTitleMenu・toolbarMinimizationBehavior・toolbarMinimizationRestoration・toolbarMinimizationSafeAreaAdjustment がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は直さない）。

`WidgetLab/Catalog/Toolbars/ToolbarTitleDisplayModeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarTitleDisplayMode = CatalogEntry(
        id: "toolbarTitleDisplayMode",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの題名を、大きく出すか、バーの中に小さく出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbartitledisplaymode(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarTitleDisplayMode",
                .choice(
                    [Choice(".automatic"), Choice(".inline"), Choice(".inlineLarge"), Choice(".large")], initial: 2),
                on: true, summary: "題名の出し方。.inlineLarge は、バーの左に大きめの文字で出す")
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(
                        v.pick(
                            "toolbarTitleDisplayMode",
                            from: [ToolbarTitleDisplayMode.automatic, .inline, .inlineLarge, .large])
                    ) { $0.toolbarTitleDisplayMode($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarTitleMenuEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarTitleMenu = CatalogEntry(
        id: "toolbarTitleMenu",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの題名を押すと出るメニューを決める modifier。題名の横に下向きの印が付く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbartitlemenu(content:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarTitleMenu",
                .fixed(
                    code:
                        "content: { Button(\"名前を変える\", systemImage: \"pencil\") { }; Button(\"複製\", systemImage: \"plus.square.on.square\") { } }"
                ), on: true, summary: "メニューの項目。題名を押すと出る")
        ],
        code: .inToolbarStack(suffix: [".toolbarTitleDisplayMode(.inline)"]),
        build: { v in
            AnyView(
                ToolbarStack {
                    $0.apply(v["toolbarTitleMenu"]) { view, _ in
                        view.toolbarTitleMenu {
                            Button("名前を変える", systemImage: "pencil") {}
                            Button("複製", systemImage: "plus.square.on.square") {}
                        }
                    }
                    .toolbarTitleDisplayMode(.inline)
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarMinimizationBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationBehavior = CatalogEntry(
        id: "toolbarMinimizationBehavior",
        kind: .modifier,
        topic: .toolbars,
        summary: "中身をスクロールしたとき、ナビゲーションバーや下のバーを小さく畳むかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationbehavior(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".onScrollDown"), Choice(".onScrollUp"), Choice(".never")], initial: 1
                ), on: true, summary: "畳むきっかけ。一覧をスクロールして見る"),
            .modifier(
                "toolbarMinimizationBehavior", id: "toolbarMinimizationBehavior.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationBehavior",
                            from: [ToolbarMinimizationBehavior.automatic, .onScrollDown, .onScrollUp, .never])
                    ) {
                        $0.toolbarMinimizationBehavior(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationBehavior.for", from: [ToolbarPlacement.navigationBar, .bottomBar])
                                ?? .navigationBar)
                    }
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarMinimizationRestorationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationRestoration = CatalogEntry(
        id: "toolbarMinimizationRestoration",
        kind: .modifier,
        topic: .toolbars,
        summary: "スクロールで畳んだバーを、いつ元の大きさに戻すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationrestoration(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationRestoration", .choice([Choice(".automatic"), Choice(".atScrollEdge")], initial: 1),
                on: true, summary: "戻すきっかけ。.atScrollEdge なら、いちばん上（端）までスクロールしたときだけ戻す"),
            .modifier(
                "toolbarMinimizationRestoration", id: "toolbarMinimizationRestoration.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [".toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)"]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationRestoration",
                            from: [ToolbarMinimizationRestoration.automatic, .atScrollEdge])
                    ) {
                        $0.toolbarMinimizationRestoration(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationRestoration.for",
                                from: [ToolbarPlacement.navigationBar, .bottomBar]) ?? .navigationBar)
                    }
                    .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
                })
        }
    )
}
```

`WidgetLab/Catalog/Toolbars/ToolbarMinimizationSafeAreaAdjustmentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarMinimizationSafeAreaAdjustment = CatalogEntry(
        id: "toolbarMinimizationSafeAreaAdjustment",
        kind: .modifier,
        topic: .toolbars,
        summary: "スクロールでバーを畳んだとき、空いた分だけ中身の安全な領域を広げるかを決める modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/toolbarminimizationsafeareaadjustment(_:for:)")!,
        stage: .full,
        properties: [
            .modifier(
                "toolbarMinimizationSafeAreaAdjustment",
                .choice([Choice(".automatic"), Choice(".enabled"), Choice(".disabled")], initial: 2), on: true,
                summary: "広げるか。.disabled なら、畳んでも安全な領域が広がらず、黄色の印が元の位置に残る。一覧をスクロールして見る"),
            .modifier(
                "toolbarMinimizationSafeAreaAdjustment", id: "toolbarMinimizationSafeAreaAdjustment.for", label: "for",
                .choice([Choice(".navigationBar"), Choice(".bottomBar")], initial: 0), required: true,
                summary: "どのバーに効かせるか"),
        ],
        code: .inToolbarStack(suffix: [
            ".toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)",
            ".overlay(alignment: .top) { Text(\"安全な領域の上の端\").background(.yellow, ignoresSafeAreaEdges: []) }",
        ]),
        build: { v in
            AnyView(
                ToolbarStack { view in
                    view.apply(
                        v.pick(
                            "toolbarMinimizationSafeAreaAdjustment",
                            from: [ToolbarMinimizationSafeAreaAdjustment.automatic, .enabled, .disabled])
                    ) {
                        $0.toolbarMinimizationSafeAreaAdjustment(
                            $1,
                            for: v.pick(
                                "toolbarMinimizationSafeAreaAdjustment.for",
                                from: [ToolbarPlacement.navigationBar, .bottomBar]) ?? .navigationBar)
                    }
                    .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
                    .overlay(alignment: .top) { Text("安全な領域の上の端").background(.yellow, ignoresSafeAreaEdges: []) }
                })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .toolbarTitleDisplayMode,
        .toolbarTitleMenu,
        .toolbarMinimizationBehavior,
        .toolbarMinimizationRestoration,
        .toolbarMinimizationSafeAreaAdjustment,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Toolbars/ToolbarTitleDisplayModeEntry.swift WidgetLab/Catalog/Toolbars/ToolbarTitleMenuEntry.swift WidgetLab/Catalog/Toolbars/ToolbarMinimizationBehaviorEntry.swift WidgetLab/Catalog/Toolbars/ToolbarMinimizationRestorationEntry.swift WidgetLab/Catalog/Toolbars/ToolbarMinimizationSafeAreaAdjustmentEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: アプリの骨組みの収録 toolbarTitleDisplayMode・toolbarTitleMenu・toolbarMinimizationBehavior・toolbarMinimizationRestoration・toolbarMinimizationSafeAreaAdjustment

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

### Task 3: searchable・searchSuggestions・searchCompletion・searchScopes・searchPresentationToolbarBehavior・findNavigator・findDisabled・replaceDisabled

**Files:**
- Create: `WidgetLab/Catalog/Search/SearchDemo.swift`
- Create: `WidgetLab/Catalog/Search/FindDemo.swift`
- Create: `WidgetLab/Catalog/Search/SearchableEntry.swift`
- Create: `WidgetLab/Catalog/Search/SearchSuggestionsEntry.swift`
- Create: `WidgetLab/Catalog/Search/SearchCompletionEntry.swift`
- Create: `WidgetLab/Catalog/Search/SearchScopesEntry.swift`
- Create: `WidgetLab/Catalog/Search/SearchPresentationToolbarBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/Search/FindNavigatorEntry.swift`
- Create: `WidgetLab/Catalog/Search/FindDisabledEntry.swift`
- Create: `WidgetLab/Catalog/Search/ReplaceDisabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: `CatalogEntry.searchable`、`CatalogEntry.searchSuggestions`、`CatalogEntry.searchCompletion`、`CatalogEntry.searchScopes`、`CatalogEntry.searchPresentationToolbarBehavior`、`CatalogEntry.findNavigator`、`CatalogEntry.findDisabled`、`CatalogEntry.replaceDisabled`、補助 `searchGoods`・`SearchStack<Root: View>`（`init(modify: (AnyView, Binding<String>, Binding<Int>) -> Root)`）・`SearchSuggestionRows`・`CodeTemplate.inSearchStack(placement: String? = nil, suffix: [String] = [])`・`FindDemo<Editor: View>`（`init(navigator: Bool = true, modify: (AnyView) -> Editor)`）・`CodeTemplate.inFindDemo`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py search`
Expected: 終了コード 1。抜けに searchable・searchSuggestions・searchCompletion・searchScopes・searchPresentationToolbarBehavior・findNavigator・findDisabled・replaceDisabled がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は直さない）。

`WidgetLab/Catalog/Search/SearchDemo.swift`:

```swift
import SwiftUI

/// 検索の見本で使う品物。名前と、果物か野菜か（searchScopes で絞る）
let searchGoods: [(name: String, isFruit: Bool)] = [
    ("りんご", true), ("みかん", true), ("ぶどう", true), ("いちご", true),
    ("にんじん", false), ("トマト", false), ("キャベツ", false), ("たまねぎ", false),
]

/// 検索の見本の入れ物。打った文字（query）と、絞り込みの範囲（scope。0 がすべて・1 が果物・2 が野菜）を持ち、
/// 文字と範囲で絞った品物の一覧を NavigationStack に出す。一覧にかける modifier を modify で渡す
struct SearchStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView, Binding<String>, Binding<Int>) -> Root
    @State private var query = ""
    @State private var scope = 0

    var body: some View {
        NavigationStack {
            modify(AnyView(List(names, id: \.self) { Text($0) }.navigationTitle("品物")), $query, $scope)
        }
    }

    private var names: [String] {
        searchGoods
            .filter { scope == 0 || $0.isFruit == (scope == 1) }
            .map(\.name)
            .filter { query.isEmpty || $0.contains(query) }
    }
}

/// 検索の候補の行。押すと、検索の欄にその名前が入る（searchCompletion）
struct SearchSuggestionRows: View {
    var completes = true

    var body: some View {
        ForEach(["りんご", "トマト"], id: \.self) { name in
            Label(name, systemImage: "magnifyingglass")
                .apply(completes ? name : nil) { $0.searchCompletion($1) }
        }
    }
}

nonisolated extension CodeTemplate {
    /// SearchStack の一覧に searchable をかけた収録のコード。call が .searchable で、modifier はその下に並ぶ
    static func inSearchStack(placement: String? = nil, suffix: [String] = []) -> CodeTemplate {
        CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(names, id: \\.self) { Text($0) }",
                "        .navigationTitle(\"品物\")",
            ], indent: 8, call: ".searchable",
            fixedArguments: ["text: $query"] + (placement.map { ["placement: \($0)"] } ?? []),
            suffix: suffix, closing: ["}"])
    }
}
```

`WidgetLab/Catalog/Search/FindDemo.swift`:

```swift
import SwiftUI

/// 文の中を探す（find）見本の入れ物。TextEditor と、検索の帯（findNavigator）を出すボタンを置く。
/// TextEditor にかける modifier を modify で、findNavigator をかけるかを navigator で渡す。
/// 帯は TextEditor に入力の印があるときだけ出るので、文を押してからボタンを押す
struct FindDemo<Editor: View>: View {
    var navigator = true
    @ViewBuilder let modify: (AnyView) -> Editor
    @State private var text = "りんごを 3 つ買う\nみかんを 2 つ買う\nりんごのジャムを作る"
    @State private var shows = false

    var body: some View {
        VStack(spacing: 12) {
            Button("検索の帯を出す") { shows.toggle() }
                .buttonStyle(.bordered)
            modify(AnyView(TextEditor(text: $text)))
                .apply(navigator ? () : nil) { view, _ in view.findNavigator(isPresented: $shows) }
                .frame(height: 120)
        }
        .padding()
    }
}

nonisolated extension CodeTemplate {
    /// FindDemo の TextEditor にかける modifier の収録のコード。modifier は TextEditor の下に並ぶ
    static let inFindDemo = CodeTemplate(
        prefix: ["Button(\"検索の帯を出す\") { shows.toggle() }"], indent: 0, call: "TextEditor",
        fixedArguments: ["text: $memo"], suffix: [".findNavigator(isPresented: $shows)"])
}
```

`WidgetLab/Catalog/Search/SearchableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchable = CatalogEntry(
        id: "searchable",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を出す modifier。打った文字は text の Binding に入るので、それで一覧を絞る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/searchable(text:placement:prompt:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchable", label: "text", .fixed(code: "$query"), on: true,
                summary: "打った文字の Binding。検索の欄に文字を打つと、一覧が絞られる"),
            .modifier(
                "searchable", id: "searchable.placement", label: "placement",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigationBarDrawer(displayMode: .always)"),
                        Choice(".toolbar"),
                    ], initial: 0), required: true,
                summary: "欄を置く場所。.navigationBarDrawer(displayMode: .always) なら、題名の下にいつも出す"),
            .modifier(
                "searchable", id: "searchable.prompt", label: "prompt", .text(initial: "品物の名前"), required: true,
                summary: "空の欄に薄く出す文"),
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(names, id: \\.self) { Text($0) }"], indent: 8,
            call: ".navigationTitle", fixedArguments: ["\"品物\""], closing: ["}"]),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.apply(v["searchable"]) { view, _ in
                        view.searchable(
                            text: query,
                            placement: v.pick(
                                "searchable.placement",
                                from: [
                                    SearchFieldPlacement.automatic, .navigationBarDrawer(displayMode: .always),
                                    .toolbar,
                                ]) ?? .automatic,
                            prompt: v.text("searchable.prompt") ?? "")
                    }
                })
        }
    )
}
```

`WidgetLab/Catalog/Search/SearchSuggestionsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchSuggestions = CatalogEntry(
        id: "searchSuggestions",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を押したときに出す候補を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchsuggestions(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchSuggestions",
                .fixed(
                    code:
                        "{ ForEach([\"りんご\", \"トマト\"], id: \\.self) { Label($0, systemImage: \"magnifyingglass\").searchCompletion($0) } }"
                ), on: true, summary: "候補の行。検索の欄を押すと、一覧の代わりに出る")
        ],
        code: .inSearchStack(),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .apply(v["searchSuggestions"]) { view, _ in
                            view.searchSuggestions { SearchSuggestionRows() }
                        }
                })
        }
    )
}
```

`WidgetLab/Catalog/Search/SearchCompletionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchCompletion = CatalogEntry(
        id: "searchCompletion",
        kind: .modifier,
        topic: .search,
        summary: "検索の候補の行に、押したときに検索の欄へ入れる文字を結び付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchcompletion(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchCompletion", .fixed(code: "name"), on: true,
                summary: "候補を押したときに入れる文字。付けないと、候補を押しても何も起きない")
        ],
        code: CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(names, id: \\.self) { Text($0) }",
                "        .navigationTitle(\"品物\")", "        .searchable(text: $query)",
                "        .searchSuggestions {",
                "            ForEach([\"りんご\", \"トマト\"], id: \\.self) { name in",
            ], indent: 16, call: "Label", fixedArguments: ["name", "systemImage: \"magnifyingglass\""],
            closing: ["            }", "        }", "}"]),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .searchSuggestions { SearchSuggestionRows(completes: v["searchCompletion"] != nil) }
                })
        }
    )
}
```

`WidgetLab/Catalog/Search/SearchScopesEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchScopes = CatalogEntry(
        id: "searchScopes",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄の下に、絞り込む範囲の切り替え（すべて・果物・野菜など）を出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchscopes(_:activation:_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchScopes", id: "searchScopes.scope", .fixed(code: "$scope"), required: true,
                summary: "選んだ範囲の Binding。範囲は tag の値で見分ける"),
            .modifier(
                "searchScopes", id: "searchScopes.activation", label: "activation",
                .choice([Choice(".automatic"), Choice(".onSearchPresentation"), Choice(".onTextEntry")], initial: 1),
                required: true, summary: "切り替えを出すきっかけ。.onSearchPresentation なら、検索の欄を押したときに出す"),
            .modifier(
                "searchScopes",
                .fixed(code: "{ Text(\"すべて\").tag(0); Text(\"果物\").tag(1); Text(\"野菜\").tag(2) }"), on: true,
                summary: "範囲の切り替え。検索の欄を押すと、欄の下に出る"),
        ],
        code: .inSearchStack(placement: ".navigationBarDrawer(displayMode: .always)"),
        build: { v in
            AnyView(
                SearchStack { view, query, scope in
                    view.searchable(text: query, placement: .navigationBarDrawer(displayMode: .always))
                        .apply(v["searchScopes"]) { view, _ in
                            view.searchScopes(
                                scope,
                                activation: v.pick(
                                    "searchScopes.activation",
                                    from: [SearchScopeActivation.automatic, .onSearchPresentation, .onTextEntry])
                                    ?? .automatic
                            ) {
                                Text("すべて").tag(0)
                                Text("果物").tag(1)
                                Text("野菜").tag(2)
                            }
                        }
                })
        }
    )
}
```

`WidgetLab/Catalog/Search/SearchPresentationToolbarBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchPresentationToolbarBehavior = CatalogEntry(
        id: "searchPresentationToolbarBehavior",
        kind: .modifier,
        topic: .search,
        summary: "検索の欄を押して検索を始めたとき、ツールバー（題名など）を隠すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/searchpresentationtoolbarbehavior(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchPresentationToolbarBehavior",
                .choice([Choice(".automatic"), Choice(".avoidHidingContent")], initial: 1), on: true,
                summary: "隠すか。.avoidHidingContent なら、検索を始めても題名が残る。検索の欄を押して見る")
        ],
        code: .inSearchStack(),
        build: { v in
            AnyView(
                SearchStack { view, query, _ in
                    view.searchable(text: query)
                        .apply(
                            v.pick(
                                "searchPresentationToolbarBehavior",
                                from: [SearchPresentationToolbarBehavior.automatic, .avoidHidingContent])
                        ) { $0.searchPresentationToolbarBehavior($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/Search/FindNavigatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let findNavigator = CatalogEntry(
        id: "findNavigator",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す・置き換える帯を、コードから出したり閉じたりする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/findnavigator(ispresented:)")!,
        stage: .card,
        properties: [
            .modifier(
                "findNavigator", label: "isPresented", .fixed(code: "$shows"), on: true,
                summary: "帯を出すかの Binding。true にすると、キーボードの上に帯が出る。文を押して入力の印を入れてから、ボタンを押す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"検索の帯を出す\") { shows.toggle() }"], indent: 0, call: "TextEditor",
            fixedArguments: ["text: $memo"]),
        build: { v in
            AnyView(FindDemo(navigator: v["findNavigator"] != nil) { $0 })
        }
    )
}
```

`WidgetLab/Catalog/Search/FindDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let findDisabled = CatalogEntry(
        id: "findDisabled",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す・置き換える操作を、できなくする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/finddisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "findDisabled", .toggle(initial: true), on: true,
                summary: "true なら、文を押してからボタンを押しても、検索の帯が出ない")
        ],
        code: .inFindDemo,
        build: { v in
            AnyView(FindDemo { $0.apply(v.flag("findDisabled")) { $0.findDisabled($1) } })
        }
    )
}
```

`WidgetLab/Catalog/Search/ReplaceDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let replaceDisabled = CatalogEntry(
        id: "replaceDisabled",
        kind: .modifier,
        topic: .search,
        summary: "TextEditor の中を探す帯から、置き換える操作だけをできなくする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/replacedisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "replaceDisabled", .toggle(initial: true), on: true,
                summary: "true なら、検索の帯に置き換えの欄が出ない（探すだけになる）。文を押してからボタンを押して見る")
        ],
        code: .inFindDemo,
        build: { v in
            AnyView(FindDemo { $0.apply(v.flag("replaceDisabled")) { $0.replaceDisabled($1) } })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .searchable,
        .searchSuggestions,
        .searchCompletion,
        .searchScopes,
        .searchPresentationToolbarBehavior,
        .findNavigator,
        .findDisabled,
        .replaceDisabled,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Search/SearchDemo.swift WidgetLab/Catalog/Search/FindDemo.swift WidgetLab/Catalog/Search/SearchableEntry.swift WidgetLab/Catalog/Search/SearchSuggestionsEntry.swift WidgetLab/Catalog/Search/SearchCompletionEntry.swift WidgetLab/Catalog/Search/SearchScopesEntry.swift WidgetLab/Catalog/Search/SearchPresentationToolbarBehaviorEntry.swift WidgetLab/Catalog/Search/FindNavigatorEntry.swift WidgetLab/Catalog/Search/FindDisabledEntry.swift WidgetLab/Catalog/Search/ReplaceDisabledEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: アプリの骨組みの収録 searchable・searchSuggestions・searchCompletion・searchScopes・searchPresentationToolbarBehavior・findNavigator・findDisabled・replaceDisabled

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

### Task 4: UIApplicationDelegateAdaptor・sceneAccessory・windowToolbarFullScreenVisibility・allowsWindowActivationEvents・DocumentLaunchView・NewDocumentButton・RenameButton

**Files:**
- Create: `WidgetLab/Catalog/AppOrganization/UIApplicationDelegateAdaptorEntry.swift`
- Create: `WidgetLab/Catalog/Scenes/SceneAccessoryEntry.swift`
- Create: `WidgetLab/Catalog/Windows/WindowToolbarFullScreenVisibilityEntry.swift`
- Create: `WidgetLab/Catalog/Windows/AllowsWindowActivationEventsEntry.swift`
- Create: `WidgetLab/Catalog/Documents/DocumentLaunchViewEntry.swift`
- Create: `WidgetLab/Catalog/Documents/NewDocumentButtonEntry.swift`
- Create: `WidgetLab/Catalog/Documents/RenameButtonEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`WrapperCode`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: `CatalogEntry.uiApplicationDelegateAdaptor`、`CatalogEntry.sceneAccessory`、`CatalogEntry.windowToolbarFullScreenVisibility`、`CatalogEntry.allowsWindowActivationEvents`、`CatalogEntry.documentLaunchView`、`CatalogEntry.newDocumentButton`、`CatalogEntry.renameButton`
- 名前: `static let` の名前は id の頭を小文字にしたもの。`UIApplicationDelegateAdaptor` は、Swift の名前の決まり（頭の略語は全部小文字）に合わせて `uiApplicationDelegateAdaptor` にする（`uIApplication…` にしない）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py app-organization scenes windows documents`
Expected: 終了コード 1。抜けに UIApplicationDelegateAdaptor・sceneAccessory・windowToolbarFullScreenVisibility・allowsWindowActivationEvents・DocumentLaunchView・NewDocumentButton・RenameButton がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は直さない）。

`WidgetLab/Catalog/AppOrganization/UIApplicationDelegateAdaptorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let uiApplicationDelegateAdaptor = CatalogEntry(
        id: "UIApplicationDelegateAdaptor",
        kind: .propertyWrapper,
        topic: .appOrganization,
        summary: "SwiftUI のアプリに、UIKit のアプリのデリゲート（UIApplicationDelegate）を作って結び付けるプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor")!,
        noteReason: "アプリの入口（@main の App）に書くもの。デリゲートはアプリが起動するときに 1 回だけ作られるので、アプリの画面の中では試せない",
        properties: [
            .wrapper(
                "UIApplicationDelegateAdaptor",
                summary: "外すと、AppDelegate が作られず、起動のときの準備（通知の登録など）が呼ばれない")
        ],
        code: CodeTemplate(
            call: "UIApplicationDelegateAdaptor",
            wrapper: WrapperCode(
                withWrapper: [
                    "@main",
                    "struct MemoApp: App {",
                    "    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate",
                    "",
                    "    var body: some Scene {",
                    "        WindowGroup { ContentView() }",
                    "    }",
                    "}",
                    "",
                    "final class AppDelegate: NSObject, UIApplicationDelegate {",
                    "    func application(",
                    "        _ application: UIApplication,",
                    "        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil",
                    "    ) -> Bool {",
                    "        // 起動のときの準備（通知の登録など）",
                    "        return true",
                    "    }",
                    "}",
                ],
                withoutWrapper: [
                    "@main",
                    "struct MemoApp: App {",
                    "    // AppDelegate は作られない",
                    "",
                    "    var body: some Scene {",
                    "        WindowGroup { ContentView() }",
                    "    }",
                    "}",
                ]))
    )
}
```

`WidgetLab/Catalog/Scenes/SceneAccessoryEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sceneAccessory = CatalogEntry(
        id: "sceneAccessory",
        kind: .modifier,
        topic: .scenes,
        summary: "窓（シーン）に、付属の画面を結び付ける modifier。iPhone では、つないだ外のディスプレイに、操作できない画面を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sceneaccessory(content:)")!,
        noteReason: "iPhone に外のディスプレイをつないだときに、そのディスプレイに出る。アプリの画面の中には出ない",
        properties: [
            .modifier(
                "sceneAccessory",
                .fixed(code: "content: { ExternalNonInteractiveAccessory { Text(\"つないだ画面に出す\") } }"), on: true,
                summary: "付属の画面。ExternalNonInteractiveAccessory は、外のディスプレイに操作できない画面を出す")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"本体の画面\""])
    )
}
```

`WidgetLab/Catalog/Windows/WindowToolbarFullScreenVisibilityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let windowToolbarFullScreenVisibility = CatalogEntry(
        id: "windowToolbarFullScreenVisibility",
        kind: .modifier,
        topic: .windows,
        summary: "窓をフルスクリーンにしたとき、窓のツールバーを出したままにするか、ポインタを上に寄せたときだけ出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/windowtoolbarfullscreenvisibility(_:)")!,
        noteReason: "Mac だけで効く（iOS で選べるのは .automatic だけ）。Mac で窓をフルスクリーンにしたときに、ツールバーの出し方が変わる",
        properties: [
            .modifier(
                "windowToolbarFullScreenVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".onHover")], initial: 2), on: true,
                summary: "ツールバーの出し方。.onHover なら、ポインタを画面の上に寄せたときだけ出す")
        ],
        code: CodeTemplate(prefix: ["// Mac のアプリの窓の中"], indent: 0, call: "Text", fixedArguments: ["\"本文\""])
    )
}
```

`WidgetLab/Catalog/Windows/AllowsWindowActivationEventsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let allowsWindowActivationEvents = CatalogEntry(
        id: "allowsWindowActivationEvents",
        kind: .modifier,
        topic: .windows,
        summary: "後ろの窓を押したとき、窓を手前に出すのと同時に、中のジェスチャーも動かすかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/allowswindowactivationevents(_:)")!,
        noteReason: "窓を並べられる iPad と Mac で効く。iPhone では窓がいつも 1 つで手前にあるので、違いが出ない",
        properties: [
            .modifier(
                "allowsWindowActivationEvents", .toggle(initial: true), on: true,
                summary: "true なら、後ろの窓の上でなぞっても、窓が手前に出ると同時にジェスチャーが動く")
        ],
        code: CodeTemplate(
            prefix: ["Circle()", "    .frame(width: 80, height: 80)"], call: ".gesture",
            fixedArguments: ["DragGesture()"])
    )
}
```

`WidgetLab/Catalog/Documents/DocumentLaunchViewEntry.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let documentLaunchView = CatalogEntry(
        id: "DocumentLaunchView",
        kind: .view,
        topic: .documents,
        summary: "書類を扱うアプリの、起動のときの画面。題名と、書類を作る・開くボタンを出し、下に書類の一覧を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/documentlaunchview")!,
        stage: .full,
        properties: [
            .argument(
                "title", unlabeled: true, .text(initial: "メモ"), required: true, summary: "上に出す題名。下の書類の一覧は、出るまで数秒かかる"),
            .argument("for", .fixed(code: "[.plainText]"), required: true, summary: "開ける書類の種類"),
        ],
        code: CodeTemplate(
            call: "DocumentLaunchView",
            trailing:
                " {\n    NewDocumentButton(\"新しいメモ\")\n} onDocumentOpen: { url in\n    Text(url.lastPathComponent)\n}"),
        build: { v in
            AnyView(
                DocumentLaunchView(LocalizedStringKey(v.text("title") ?? ""), for: [.plainText]) {
                    NewDocumentButton("新しいメモ")
                } onDocumentOpen: { url in
                    Text(url.lastPathComponent)
                })
        }
    )
}
```

`WidgetLab/Catalog/Documents/NewDocumentButtonEntry.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let newDocumentButton = CatalogEntry(
        id: "NewDocumentButton",
        kind: .view,
        topic: .documents,
        summary: "押すと、新しい書類を作って開くボタン。DocumentLaunchView の中などに置く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/newdocumentbutton")!,
        stage: .full,
        properties: [
            .argument(
                "title", unlabeled: true, .text(initial: "新しいメモ"), required: true,
                summary: "ボタンの文。DocumentGroup のアプリでは、押すと新しい書類を作って開く（この見本は DocumentGroup の外なので、押しても開かない）"),
            .argument("contentType", .fixed(code: ".plainText"), summary: "作る書類の種類。省くと、アプリの最初の種類"),
        ],
        code: CodeTemplate(
            prefix: ["DocumentLaunchView(\"メモ\", for: [.plainText]) {"], call: "NewDocumentButton",
            closing: ["} onDocumentOpen: { url in", "    Text(url.lastPathComponent)", "}"]),
        build: { v in
            AnyView(
                DocumentLaunchView("メモ", for: [.plainText]) {
                    if v["contentType"] != nil {
                        NewDocumentButton(LocalizedStringKey(v.text("title") ?? ""), contentType: .plainText)
                    } else {
                        NewDocumentButton(LocalizedStringKey(v.text("title") ?? ""))
                    }
                } onDocumentOpen: { url in
                    Text(url.lastPathComponent)
                })
        }
    )
}
```

`WidgetLab/Catalog/Documents/RenameButtonEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let renameButton = CatalogEntry(
        id: "RenameButton",
        kind: .view,
        topic: .documents,
        summary: "名前を変える操作を始める、決まった見た目のボタン。押すと、まわりの renameAction で決めた動きが起きる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/renamebutton")!,
        stage: .card,
        properties: [
            .modifier(
                "renameAction", .fixed(code: "$isFocused"), on: true,
                summary: "押したときの動き。FocusState を渡すと、名前の欄に入力の印が入る。付けないと押せない"),
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 0),
                summary: "ボタンの文と絵の出し方"),
            .modifier(
                "buttonStyle", .choice([Choice(".bordered"), Choice(".borderedProminent")], initial: 0), on: true,
                summary: "ボタンの見た目"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    TextField(\"名前\", text: $name)\n        .focused($isFocused)\n    RenameButton()\n}"),
        build: { v in
            AnyView(
                RenameDemo(
                    renames: v["renameAction"] != nil,
                    labelStyle: v.pick("labelStyle", from: [0, 1, 2]),
                    prominent: v.pick("buttonStyle", from: [false, true])))
        }
    )
}

private struct RenameDemo: View {
    let renames: Bool
    let labelStyle: Int?
    let prominent: Bool?
    @State private var name = "買い物メモ"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            TextField("名前", text: $name)
                .focused($isFocused)
                .textFieldStyle(.bordered)
            RenameButton()
        }
        .apply(renames ? () : nil) { view, _ in view.renameAction($isFocused) }
        .apply(labelStyle) { view, style in
            switch style {
            case 1: view.labelStyle(.iconOnly)
            case 2: view.labelStyle(.titleOnly)
            default: view.labelStyle(.titleAndIcon)
            }
        }
        .apply(prominent) { view, prominent in
            if prominent {
                view.buttonStyle(.borderedProminent)
            } else {
                view.buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .uiApplicationDelegateAdaptor,
        .sceneAccessory,
        .windowToolbarFullScreenVisibility,
        .allowsWindowActivationEvents,
        .documentLaunchView,
        .newDocumentButton,
        .renameButton,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AppOrganization/UIApplicationDelegateAdaptorEntry.swift WidgetLab/Catalog/Scenes/SceneAccessoryEntry.swift WidgetLab/Catalog/Windows/WindowToolbarFullScreenVisibilityEntry.swift WidgetLab/Catalog/Windows/AllowsWindowActivationEventsEntry.swift WidgetLab/Catalog/Documents/DocumentLaunchViewEntry.swift WidgetLab/Catalog/Documents/NewDocumentButtonEntry.swift WidgetLab/Catalog/Documents/RenameButtonEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: アプリの骨組みの収録 UIApplicationDelegateAdaptor・sceneAccessory・windowToolbarFullScreenVisibility・allowsWindowActivationEvents・DocumentLaunchView・NewDocumentButton・RenameButton

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

### Task 5: controlWidgetActionHint・controlWidgetStatus・widgetLabel・widgetAccentable・dynamicIsland と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/AppExtensions/ControlWidgetActionHintEntry.swift`
- Create: `WidgetLab/Catalog/AppExtensions/ControlWidgetStatusEntry.swift`
- Create: `WidgetLab/Catalog/AppExtensions/WidgetLabelEntry.swift`
- Create: `WidgetLab/Catalog/AppExtensions/WidgetAccentableEntry.swift`
- Create: `WidgetLab/Catalog/AppExtensions/DynamicIslandEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（試作でわかったこと）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`（どれも変えない）。Task 3 の `CatalogEntry.searchScopes`、Task 4 の `CatalogEntry.renameButton`
- Produces: `CatalogEntry.controlWidgetActionHint`、`CatalogEntry.controlWidgetStatus`、`CatalogEntry.widgetLabel`、`CatalogEntry.widgetAccentable`、`CatalogEntry.dynamicIsland`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py app-extensions`
Expected: 終了コード 1。抜けに controlWidgetActionHint・controlWidgetStatus・widgetLabel・widgetAccentable・dynamicIsland がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は直さない）。

`WidgetLab/Catalog/AppExtensions/ControlWidgetActionHintEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let controlWidgetActionHint = CatalogEntry(
        id: "controlWidgetActionHint",
        kind: .modifier,
        topic: .appExtensions,
        summary: "コントロール（コントロールセンターなどに置くボタン）のラベルに、押すと何が起きるかの短い説明を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlwidgetactionhint(_:)")!,
        noteReason: "アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンター・ロック画面・アクションボタンに置いたときに出る",
        properties: [
            .modifier(
                "controlWidgetActionHint", .text(initial: "つける"), on: true,
                summary: "押すと起きることの説明。アクションボタンに置いたときなどに出る")
        ],
        code: CodeTemplate(
            prefix: ["// ControlWidgetToggle の label の中"], indent: 0, call: "Label",
            fixedArguments: ["\"明かり\"", "systemImage: \"lightbulb\""])
    )
}
```

`WidgetLab/Catalog/AppExtensions/ControlWidgetStatusEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let controlWidgetStatus = CatalogEntry(
        id: "controlWidgetStatus",
        kind: .modifier,
        topic: .appExtensions,
        summary: "コントロール（コントロールセンターなどに置くボタン）のラベルに、今の状態の短い文を付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlwidgetstatus(_:)")!,
        noteReason: "アプリ拡張のコントロール（ControlWidget）の中で効く。コントロールセンターで押したときに、状態の文が出る",
        properties: [
            .modifier(
                "controlWidgetStatus", .text(initial: "ついている"), on: true, summary: "今の状態の文。押して状態が変わったときに出る")
        ],
        code: CodeTemplate(
            prefix: ["// ControlWidgetToggle の label の中"], indent: 0, call: "Label",
            fixedArguments: ["\"明かり\"", "systemImage: \"lightbulb\""])
    )
}
```

`WidgetLab/Catalog/AppExtensions/WidgetLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let widgetLabel = CatalogEntry(
        id: "widgetLabel",
        kind: .modifier,
        topic: .appExtensions,
        summary: "ロック画面などの小さなウィジェットで、本体の外（まわりや下）に添える文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/widgetlabel(_:)")!,
        noteReason: "アプリ拡張のウィジェットの中で効く。ロック画面や Apple Watch の小さなウィジェット（accessory の大きさ）に置いたときに出る",
        properties: [
            .modifier("widgetLabel", .text(initial: "東京 21°"), on: true, summary: "添える文。丸いウィジェットなら、まわりに沿って出る")
        ],
        code: CodeTemplate(
            prefix: ["// accessoryCircular のウィジェットの中"], indent: 0, call: "Gauge",
            fixedArguments: ["value: 0.7"], trailing: " { Text(\"気温\") }", suffix: [".gaugeStyle(.accessoryCircular)"])
    )
}
```

`WidgetLab/Catalog/AppExtensions/WidgetAccentableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let widgetAccentable = CatalogEntry(
        id: "widgetAccentable",
        kind: .modifier,
        topic: .appExtensions,
        summary: "ウィジェットの中の View を、目立たせる色（アクセントの色）で描く組に入れる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/widgetaccentable(_:)")!,
        noteReason: "アプリ拡張のウィジェットの中で効く。ロック画面・Apple Watch・色付きのホーム画面など、ウィジェットを 2 色で描くときに出る",
        properties: [
            .modifier("widgetAccentable", .toggle(initial: true), on: true, summary: "true なら、アクセントの色で描く。ほかは白っぽい色になる")
        ],
        code: CodeTemplate(
            prefix: ["// ウィジェットの中", "VStack {"], indent: 4, call: "Text", fixedArguments: ["\"21°\""],
            suffix: [".font(.largeTitle)"], closing: ["    Text(\"東京\")", "}"])
    )
}
```

`WidgetLab/Catalog/AppExtensions/DynamicIslandEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dynamicIsland = CatalogEntry(
        id: "dynamicIsland",
        kind: .modifier,
        topic: .appExtensions,
        summary: "Dynamic Island で広げたライブアクティビティの中で、View を縦のどこに置くかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/dynamicisland(verticalplacement:)")!,
        noteReason: "アプリ拡張のライブアクティビティの中で効く。Dynamic Island を長押しして広げたときに出る",
        properties: [
            .modifier(
                "dynamicIsland", label: "verticalPlacement", .fixed(code: ".belowIfTooWide"), on: true,
                summary: "縦の置き場所。.belowIfTooWide なら、横に収まらないときにカメラの下へ回す")
        ],
        code: CodeTemplate(
            prefix: ["// DynamicIslandExpandedRegion(.leading) の中"], indent: 0, call: "Text",
            fixedArguments: ["\"到着まで 5 分\""])
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .controlWidgetActionHint,
        .controlWidgetStatus,
        .widgetLabel,
        .widgetAccentable,
        .dynamicIsland,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す。全画面で開く検索の範囲と、名前を変えるボタンの代表を 1 件ずつ撮る:

```swift
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
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「レイアウト・描画・テキスト・操作の部品・スタイルと動き・一覧とスクロール・画面の行き来の代表 2 件ずつのスクリーンショットの 11 本」を、「レイアウト・描画・テキスト・操作の部品・スタイルと動き・一覧とスクロール・画面の行き来・アプリの骨組みの代表 2 件ずつのスクリーンショットの 12 本」に置き換える（ほかの束が先に本数を変えていたら、その本数に 1 を足す）

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 3 か所だけ直す（ほかの行は変えない）。

1. 5 章の「束 7 は `testNavigationEntriesShowPreview`）。」を「束 7 は `testNavigationEntriesShowPreview`、束 8 は `testShellEntriesShowPreview`）。」に置き換える
2. 7 章の `**`preferredColorScheme` を全画面で試す → 「付けない」に切り替えても暗いまま。**` の段落のあと（`## 用語` の前）に、空行を挟んで次の段落を足す:

```markdown
**ツールバーと検索の欄に効く modifier → `.full` にする。** 枠の中に描くと、詳細の NavigationStack のバーと混ざる。見本は `Catalog/Toolbars/ToolbarDemo.swift` の `ToolbarStack`・`Catalog/Search/SearchDemo.swift` の `SearchStack` に modifier をかけ、コードは `CodeTemplate.inToolbarStack()`・`.inSearchStack()` の形にする（束 8）。

**ツールバーの地 → 色と組にする。** iOS 27 のバーは地がなく、`toolbarBackgroundVisibility(.visible)` だけでは見た目が変わらない。`toolbarBackground(.yellow, for:)` と組にし、大きな題名が消えるので `toolbarTitleDisplayMode(.inline)` でバーの中に出す（束 8）。

**スクロールでバーを畳むもの → `for: .navigationBar` で見る。** 下のバーのボタンが 1 つだけだと、`.bottomBar` を畳んでも見た目が変わらない。安全な領域が広がるか（`toolbarMinimizationSafeAreaAdjustment`）は、`.overlay(alignment: .top)` で上の端に文字の印を置いて見る。印の地は `background(_:ignoresSafeAreaEdges: [])` にする（ふつうの `background` は安全な領域の外まで伸びる）（束 8）。

**検索の範囲の切り替え → `activation: .onSearchPresentation` を渡す。** `searchScopes(_:scopes:)` のままでは、iOS 27.0 の iPhone 17 で欄を押しても出なかった（束 8）。

**TextEditor の find の帯 → 文を押してから出す。** `findNavigator(isPresented:)` は、TextEditor に入力の印があるときだけ帯を出す。UI テストでは `app.textViews.firstMatch` を押してから、帯を出すボタンを押す（束 8）。

**iPhone では変わらないもの（束 8 で `.note` にした）:** `toolbarRole`（iOS 26 から戻るボタンはいつも矢印だけで、.browser・.editor でも題名と戻るボタンが変わらない）、窓の modifier（`windowToolbarFullScreenVisibility` は Mac だけ、`allowsWindowActivationEvents` は窓を並べられる iPad と Mac）。アプリの入口（`UIApplicationDelegateAdaptor`）と外のディスプレイ（`sceneAccessory`）も、アプリの画面の中では見せられない。
```

3. 最後の行「最終更新: 2026-11-04（束 2〜7 のあと）」を「最終更新: 2026-11-04（束 2〜8 のあと）」に置き換える

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テストが全部通る

Run: `python3 tools/catalog_progress.py toolbars search app-organization scenes windows documents app-extensions`
Expected: 終了コード 0。`合計 32 / 32（抜け 0）`

- [ ] **Step 7: コミットする**

```bash
git add WidgetLab/Catalog/AppExtensions/ControlWidgetActionHintEntry.swift WidgetLab/Catalog/AppExtensions/ControlWidgetStatusEntry.swift WidgetLab/Catalog/AppExtensions/WidgetLabelEntry.swift WidgetLab/Catalog/AppExtensions/WidgetAccentableEntry.swift WidgetLab/Catalog/AppExtensions/DynamicIslandEntry.swift WidgetLab/Catalog/Catalog.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md
git commit -m "feat: アプリの骨組みの収録 controlWidgetActionHint・controlWidgetStatus・widgetLabel・widgetAccentable・dynamicIsland と束の確かめ

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


## 終わったら

- 束の最終レビュー（opus）を通す
- `~/dev/widget-lab`（main）で、`git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からある）で、ほかの束がマージの途中でないことを確かめてから、`git merge --no-ff feat/swiftui-p3-shell` する。`Catalog.swift`・`docs/architecture.md`・`docs/cataloging-guide.md`・`WidgetLabUITests/LaunchUITests.swift` がぶつかったら両方の行を残す
- マージのあと、main の `swiftui/` で lint と単体テスト（Global Constraints の確かめのコマンド）を通してから push する。ブランチは消さない
