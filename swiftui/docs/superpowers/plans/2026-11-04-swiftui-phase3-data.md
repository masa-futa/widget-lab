# SwiftUI 版 Phase 3 束 9（データとフォーカス）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** model-data・environment-values・preferences・persistent-storage・focus・system-events・clipboard の 41 件を収録して、7 トピックの抜けを 0 にする。

**Architecture:** 1 件 = 1 ファイルの収録データを 5〜8 件ずつ足し、`Catalog.all` に並べる。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator`、詳細画面は変えない。複数の収録で使う補助（`ObservableObjectDemo`・`PreferencesDemo`・`FocusDemo`・`ClipboardDemo`）はトピックのフォルダに置く。stage は `.card` が 18 件、`.behavior` が 12 件、`.full` が 3 件、`.note` が 8 件。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Combine（`ObservableObject`・`Timer.publish`）/ Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 9 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone Air**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` は、この束では `name=iPhone Air` に置き換える（並列で動く束 8・10 とシミュレータを分けるため）
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
       -destination 'platform=iOS Simulator,name=iPhone Air,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests
  ```
  UI テストまで通すのは Task 6 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 大文字と小文字だけ違う id（この束で決めた）

Manifest には、modifier とプロパティラッパーで、頭の文字の大文字と小文字だけが違う id が 4 組ある（`environmentObject` と `EnvironmentObject`、`environment` と `Environment`、`focusedValue` と `FocusedValue`、`focusedObject` と `FocusedObject` の 4 組。束 10 の `simultaneousGesture` と `SimultaneousGesture` も同じ）。手引きの決まり（`static let` の名前は id の頭を小文字にしたもの、ファイルは `<名前>Entry.swift`）のままでは、`static let` の名前がぶつかり、macOS のファイルの名前（大文字と小文字を区別しない）もぶつかる。

- modifier は決まりどおり: `static let environmentObject`、`EnvironmentObjectEntry.swift`
- プロパティラッパーは名前の後ろに `Wrapper` を付ける: `static let environmentObjectWrapper`、`EnvironmentObjectWrapperEntry.swift`

`catalog_progress.py` は、ファイルの中の `id:` で数えるので、ファイルの名前が変わっても数え方は変わらない。Task 6 で手引きに足す。

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）と、プロパティラッパーの「ラッパー」（`.wrapper` のプロパティ 1 つで、付けた形と外した形のコードを持つ）。プロパティはチップの順。* は最初から ON、R は required。

### model-data（6 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| StateObject | .behavior | ラッパー | @StateObject | 親 `Button("親を描き直す")`・子 `@StateObject private var counter = Counter()`。外すと `@ObservedObject private var counter = Counter()  // 親が描き直すたびに作り直す` |
| ObservedObject | .behavior | ラッパー | @ObservedObject | 親 `@State private var counter = Counter()  // 持つだけで見張らない`・子 `@ObservedObject var counter: Counter`。外すと `let counter: Counter  // 見張らない` |
| onChange | .behavior | 付け外し | .onChange(of:) R（`count`）・.onChange(initial:) R（toggle、false）・.onChange.action*（`{ oldValue, newValue in … }`） | `VStack { Button("+1") { count += 1 }; Text("count: \(count)").onChange(of: count, initial: false, { oldValue, newValue in print("\(oldValue) → \(newValue)") }) }` |
| onReceive | .behavior | 付け外し | .onReceive.publisher R（1 秒ごと・2 秒ごと）・.onReceive(perform:)* | `let everySecond = Timer.publish(every: 1, …).autoconnect()` のあと `Text("届いた回数: \(seconds)").onReceive(everySecond, perform: { _ in seconds += 1 })` |
| environmentObject | .card | 付け外し（入れ子） | .environmentObject*（`Theme("夜")`・`Theme("夕方")`） | `VStack { ThemeLabel(); ThemeLabel().environmentObject(Theme("夜")) }.environmentObject(Theme("昼"))` と `struct ThemeLabel`（`@EnvironmentObject var theme: Theme`） |
| EnvironmentObject | .behavior | ラッパー | @EnvironmentObject | 親 `Middle().environmentObject(theme)`・間 `ThemeLabel()`・子 `@EnvironmentObject var theme: Theme`。外すと、間に `let theme: Theme` を足して手で渡し、子は `@ObservedObject var theme: Theme` |

### environment-values（3 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| Environment | .card | ラッパー | @Environment | 親 `StatusLabel().disabled(disabled)`・子 `@Environment(\.isEnabled) private var isEnabled`。外すと `private var isEnabled = true  // 環境を読まない`。見本は使えなくした状態から始まる |
| environment | .card | 付け外し | .environment*（文字を大きく `\.dynamicTypeSize, .xxxLarge`・右から左へ `\.layoutDirection, .rightToLeft`・使えなくする `\.isEnabled, false`） | `HStack { Image(systemName: "bell"); Text("お知らせ"); Toggle(…).labelsHidden() }.environment(\.dynamicTypeSize, .xxxLarge)` |
| transformEnvironment | .card | 付け外し | .transformEnvironment*（太字に・斜体に・大きい文字に） | `VStack { Text("見出し"); Text("本文") }.transformEnvironment(\.font, transform: { font in font = font?.bold() }).font(.title2)` |

### preferences（7 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| preference | .card | 付け外し（入れ子） | .preference(key:) R（`TitleKey.self`）・.preference(value:)*（"りんご"・"ぶどう"） | `VStack { Text("届いた題名: \(title)"); Text("子").preference(key: TitleKey.self, value: "りんご") }.onPreferenceChange(TitleKey.self) { title = $0 }` と `struct TitleKey` |
| transformPreference | .card | 付け外し（入れ子） | .transformPreference*（後ろに足す・置き換える） | 子の `Text("子").preference(key: TitleKey.self, value: "りんご").transformPreference(TitleKey.self, { $0 += "とぶどう" })` |
| anchorPreference | .card | 付け外し（入れ子） | .anchorPreference(key:) R・.anchorPreference(value:) R（`.bounds`）・.anchorPreference(transform:)*（`{ $0 }`） | `HStack { Text("りんご"); Text("ぶどう").anchorPreference(…); Text("もも") }.overlayPreferenceValue(BoundsKey.self) { Marker(anchor: $0) }` と `struct BoundsKey`・`struct Marker` |
| transformAnchorPreference | .card | 付け外し（入れ子） | .transformAnchorPreference(key:) R・(value:) R・(transform:)*（`{ $0.append($1) }`） | `HStack { ForEach([…], id: \.self) { name in Text(name).transformAnchorPreference(…) } }.overlayPreferenceValue(AllBoundsKey.self) { anchors in … }` |
| onPreferenceChange | .behavior | 付け外し | .onPreferenceChange.key R（`TitleKey.self`）・.onPreferenceChange(perform:)* | `VStack { Text("届いた題名: \(title)"); Button("ぶどうにする"); Text(fruit).preference(…) }.onPreferenceChange(TitleKey.self, perform: { title = $0 })` |
| backgroundPreferenceValue | .card | 付け外し | .backgroundPreferenceValue.key R・.backgroundPreferenceValue.transform*（`{ Marker(anchor: $0) }`） | `HStack { …; Text("ぶどう").anchorPreference(…); … }.backgroundPreferenceValue(BoundsKey.self, { Marker(anchor: $0) })`。黄色で塗る |
| overlayPreferenceValue | .card | 付け外し | .overlayPreferenceValue.key R・.overlayPreferenceValue.transform* | 同じ形で `.overlayPreferenceValue(BoundsKey.self, { Marker(anchor: $0) })`。赤い枠を重ねる |

### persistent-storage（5 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| defaultAppStorage | .card | 付け外し | .defaultAppStorage*（`UserDefaults(suiteName: "memo")!`） | `CountButton().defaultAppStorage(UserDefaults(suiteName: "memo")!)` と `struct CountButton`（`@AppStorage("count")`）。見本の memo には 100 を入れてある |
| AppStorage | .behavior | ラッパー | @AppStorage | 親 `Button("子を作り直す") { generation += 1 }; Child().id(generation)`・子 `@AppStorage("count") private var count = 0`。外すと `@State private var count = 0  // 子を作り直すと 0 に戻る` |
| SceneStorage | .behavior | ラッパー | @SceneStorage | 同じ形で `@SceneStorage("count") private var count = 0` |
| FetchRequest | .note | ラッパー | @FetchRequest | `@FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) private var fruits: FetchedResults<Fruit>`。外すと `@State private var fruits: [Fruit] = []` と `.task { fruits = (try? context.fetch(…)) ?? [] }` |
| SectionedFetchRequest | .note | ラッパー | @SectionedFetchRequest | `@SectionedFetchRequest(sectionIdentifier: \.color, sortDescriptors: […])`。外すと `@FetchRequest` と、自分で `Dictionary(grouping:by:)` で分ける |

### focus（13 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| focusable | .card | 付け外し（入れ子） | .focusable.isFocusable*（toggle、true）・.focusable(interactions:)（.activate・.edit・.automatic） | `VStack { Button("札にフォーカス") { isFocused = true }; Text("札").focusable(true).focused($isFocused) }` |
| focused | .card | 付け外し（入れ子） | .focused*（Bool `$isFocused`・どの欄か `$field, equals: .memo`） | `VStack { Button("入力欄へ") { isFocused = true }; TextField("メモ", text: $memo).focused($isFocused) }` |
| FocusState | .behavior | ラッパー | @FocusState | `@FocusState private var isFocused: Bool` と `TextField(…).focused($isFocused)`。外すと `@State private var isFocused = false  // フォーカスとつながらない` で `.focused` も書けない |
| FocusedValue | .card | ラッパー | @FocusedValue | 札 `@FocusedValue(\.noteTitle) private var title`・入力欄 `TextField("メモ A", …).focusedValue(\.noteTitle, "メモ A")`。外すと `private var title: String? = nil  // フォーカスを見ない` |
| FocusedBinding | .card | ラッパー | @FocusedBinding | ボタン `@FocusedBinding(\.noteText) private var text` と `Button("フォーカスのあるメモを消す") { text = "" }`。外すと `@FocusedValue(\.noteText)` で受け、`text?.wrappedValue = ""` |
| searchFocused | .full | 付け外し（入れ子） | .searchFocused*（`$isSearching`） | `NavigationStack { List(fruits, id: \.self) { Text($0) }.searchable(text: $query).searchFocused($isSearching).toolbar { Button("検索する") { isSearching = true } }.navigationTitle("果物") }` |
| focusedValue | .card | 付け外し（入れ子） | .focusedValue*（`\.noteTitle, "メモ A"`） | `VStack { NoteTitleLabel(); TextField("メモ A", text: $memoA).focusedValue(\.noteTitle, "メモ A"); TextField("メモ B", …).focusedValue(\.noteTitle, "メモ B") }` と `extension FocusedValues { @Entry var noteTitle: String? }` |
| focusedSceneValue | .full | 付け外し | .focusedSceneValue*（`\.noteTitle, "メモ帳"`） | `VStack { NoteTitleLabel(); TextField("メモ", text: $memo) }.focusedSceneValue(\.noteTitle, "メモ帳")` |
| focusedObject | .card | 付け外し（入れ子） | .focusedObject*（`noteA`） | `VStack { NoteLabel(); TextField("メモ A", text: $noteA.title).focusedObject(noteA); … }` |
| focusedSceneObject | .full | 付け外し | .focusedSceneObject*（`notebook`） | `VStack { NoteLabel(); TextField("題名", text: $notebook.title) }.focusedSceneObject(notebook)` |
| FocusedObject | .card | ラッパー | @FocusedObject | 札 `@FocusedObject private var note: Note?`。外すと `private var note: Note? = nil  // フォーカスを見ない` |
| defaultFocus | .note | 付け外し | .defaultFocus.binding R（`$field`）・.defaultFocus.value*（.mail・.name）・.defaultFocus(priority:) R（.automatic・.userInitiated） | `VStack { TextField("名前", …).focused($field, equals: .name); TextField("メール", …).focused($field, equals: .mail) }.defaultFocus($field, .mail, priority: .automatic)` |
| focusEffectDisabled | .note | 付け外し | .focusEffectDisabled*（toggle、true） | `Text("札").focusable().focusEffectDisabled(true)` |

### system-events（4 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| userActivity | .note | 付け外し | .userActivity.type R・.userActivity(isActive:) R（toggle、true）・.userActivity.update* | `MemoScreen(memo: memo).userActivity("com.example.memo.viewing", isActive: true, { activity in activity.title = memo.title })` |
| onContinueUserActivity | .note | 付け外し | .onContinueUserActivity.type R・.onContinueUserActivity(perform:)* | `ContentView().onContinueUserActivity("com.example.memo.viewing", perform: { activity in openMemo(titled: activity.title) })` |
| onOpenURL | .note | 付け外し | .onOpenURL*（perform） | `ContentView().onOpenURL(perform: { url in openMemo(at: url) })` |
| handlesExternalEvents | .note | 付け外し | .handlesExternalEvents(preferring:)*（`["memo"]`）・.handlesExternalEvents(allowing:) R（`["*"]`） | `MemoScreen().handlesExternalEvents(preferring: ["memo"], allowing: ["*"])` |

### clipboard（3 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| copyable | .behavior | 付け外し | .copyable*（`fruits`） | `Text(fruits.joined(separator: "・")).focusable().copyable(fruits)` |
| cuttable | .behavior | 付け外し | .cuttable(for:) R（`String.self`）・.cuttable(action:)*（`{ let cut = fruits; fruits = []; return cut }`） | `Text(…).focusable().cuttable(for: String.self, action: { … })` |
| pasteDestination | .behavior | 付け外し | .pasteDestination(for:) R・.pasteDestination(action:)*（`{ fruits += $0 }`） | `Text(…).focusable().pasteDestination(for: String.self, action: { fruits += $0 })` |

### `.behavior` にするもの（12 件）と理由

見た目より、描き直しの回数・値の残り方・処理が呼ばれたことが要点のもの。記録（描き直しの回数とログ）で違いを見せる。

- 持ち方の違い: StateObject・ObservedObject・EnvironmentObject・AppStorage・SceneStorage・FocusState。StateObject は「親を描き直す」で子の数が 0 に戻るか、AppStorage・SceneStorage は「子を作り直す」で数が残るかを見る
- 処理が呼ばれたこと: onChange・onReceive・onPreferenceChange
- clipboard の 3 件: 札にフォーカスを当て、キーボードの ⌘C・⌘X・⌘V で試す。iOS 27.0 の iPhone Air（シミュレータは Mac のキーボード）で、コピー・切り取り・貼り付けの処理が呼ばれた。長押しでは編集メニューが出なかったので、要約に「iPhone ではハードウェアキーボードをつなぐ」と書く

### `.full` にするもの（3 件）と理由

- searchFocused: `.searchable` の検索欄はナビゲーションバーに出るので、枠の中では詳細の NavigationStack の入れ子になる（束 7 の決まり）
- focusedSceneValue・focusedSceneObject: シーンぜんたいに値を出すので、`.card` にすると、比べるの左（付けない側）の札にも値が出て、違いが見えなかった（試作で確かめた）。一覧の行で組み立てても、同じシーンのほかの見本に値が届く。全画面で開けば、「付けない」に切り替えたときに札が「なし」になる

### `.note` にするもの（8 件、20%）と理由

| id | 理由（`noteReason`） |
|---|---|
| FetchRequest | Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、保存先から一覧を取り出すときに使う |
| SectionedFetchRequest | Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、取り出したものをセクションに分けて一覧にするときに使う |
| defaultFocus | iPhone では、はじめのフォーカスが決まらなかった（入力欄は選ばれず、キーボードも出ない）。iPad・Mac のキーボード操作や Apple TV で、はじめにフォーカスを置く先が決まる |
| focusEffectDisabled | iPhone では、フォーカスの輪や浮き上がりが出ない。iPad や Mac でキーボードやポインタを使うときと、Apple TV で効く |
| userActivity | アプリの外で効く。Handoff で Mac や iPad に続きを渡すとき、Spotlight やSiri の提案に出すときに使う |
| onContinueUserActivity | アプリの外から呼ばれる。Handoff で別の端末から続けるときや、Spotlight の結果からアプリを開いたときに効く |
| onOpenURL | アプリの外から呼ばれる。ほかのアプリ・ウィジェット・Safari から、アプリの URL を開いたときに効く（URL の scheme を Info.plist に登録する） |
| handlesExternalEvents | 窓（シーン）を 2 つ以上開けるときに効く。iPhone はいつも窓が 1 つなので変わらない。iPad と Mac で、どの窓で受けるかを選ぶ |

手引きの数え方（iPhone で見せる工夫が足りずに `.note` にしたものだけ数える）では、FetchRequest・SectionedFetchRequest・userActivity・onContinueUserActivity・onOpenURL の 5 件を数える。defaultFocus（試作で確かめた）・focusEffectDisabled・handlesExternalEvents（公式で iPad・Mac・Apple TV の機能）は数えない。束 9 のあとの全体（試作で 344 件）でも、数えるものは 1 割に届かない。

選ばなかった案:

| 案 | 選ばなかった理由 |
|---|---|
| Core Data の保存先を、見本のファイルの中で組み立てる（モデルをコードで作り、メモリの保存先にする） | spec で「本物を作る（Core Data の土台）」を選ばなかった。見本の型が 1 件のために大きくなる |
| onOpenURL のために、アプリに URL の scheme を登録し、見本から自分を開く | project の設定（Info.plist の項目）を変える。並列の束とぶつかり、収録の型の外の変更になる |

### 試作でわかったこと（Task 6 で収録の手引きに足す）

- **比べるは、左半分が「付けない」側、右半分が「付けた」側の合成になる。** 印などを真ん中の子に付けると、仕切りで印が半分に切れて違いが見える（anchorPreference の「ぶどう」）。付けた側の値を出すなら、右に寄せる（defaultAppStorage の数、environmentObject の「テーマ: 夜」）
- **シーンぜんたいに効くもの（focusedSceneValue・focusedSceneObject）は `.full` にする。** `.card` では比べるの左にも値が届き、一覧の行からも届く
- **見本の init で記録の窓口に書かない。** StateObject の試作で、子を作るたびに記録を書いたら、記録の表示の描き直しが続いて UI テストが止まった。記録はボタンを押したときに書く
- **`UserDefaults.register(defaults:)` の値は、どの保存先からも見える。** 保存先ごとに値を変えたいときは `set(_:forKey:)` で書く（defaultAppStorage）
- **clipboard の modifier は、iPhone でもハードウェアキーボードの ⌘C・⌘X・⌘V で効く。** 長押しでは編集メニューは出ない。UI テストでは `typeKey("c", modifierFlags: .command)` で試せる
- **defaultFocus は、iPhone でははじめのフォーカスを決めない。** 入力欄は選ばれず、`@FocusState` も nil のままだった
- **大文字と小文字だけ違う id は、プロパティラッパーの側に `Wrapper` を付ける**（上の節）

---

### Task 1: StateObject・ObservedObject・onChange・onReceive・environmentObject・EnvironmentObject

**Files:**
- Create: `WidgetLab/Catalog/ModelData/ObservableObjectDemo.swift`
- Create: `WidgetLab/Catalog/ModelData/StateObjectEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/ObservedObjectEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/OnChangeEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/OnReceiveEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/EnvironmentObjectEntry.swift`
- Create: `WidgetLab/Catalog/ModelData/EnvironmentObjectWrapperEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`reportBody`・`DemoRecorder`（どれも変えない）
- Produces: `CatalogEntry.stateObject`、`CatalogEntry.observedObject`、`CatalogEntry.onChange`、`CatalogEntry.onReceive`、`CatalogEntry.environmentObject`、`CatalogEntry.environmentObjectWrapper`、補助 `DemoCounter`・`DemoTheme`・`CounterRow(title:count:increment:)`（Task 2 の AppStorage・SceneStorage が `CounterRow` を使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py model-data`
Expected: 終了コード 1。抜けに StateObject・ObservedObject・onChange・onReceive・environmentObject・EnvironmentObject がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/ModelData/ObservableObjectDemo.swift`:

```swift
import SwiftUI

/// model-data の収録で使う、数を持つ ObservableObject
final class DemoCounter: ObservableObject {
    @Published var count = 0
}

/// model-data の収録で使う、テーマの名前を持つ ObservableObject
final class DemoTheme: ObservableObject {
    @Published var name: String

    init(_ name: String) {
        self.name = name
    }
}

/// 数と +1 のボタン（model-data の見本で共通の見た目）
struct CounterRow: View {
    let title: String
    let count: Int
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(title): \(count)")
                .monospacedDigit()
            Button("+1", action: increment)
                .buttonStyle(.bordered)
        }
    }
}
```

`WidgetLab/Catalog/ModelData/StateObjectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let stateObject = CatalogEntry(
        id: "StateObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "View が作って持ち続ける ObservableObject。親が描き直しても作り直さず、中身が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/stateobject")!,
        stage: .behavior,
        properties: [
            .wrapper("StateObject", summary: "@ObservedObject にすると、親が描き直すたびに Counter を作り直し、数が 0 に戻る")
        ],
        code: CodeTemplate(
            call: "StateObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var redraws = 0",
                    "var body: some View {",
                    "    Button(\"親を描き直す: \\(redraws)\") { redraws += 1 }",
                    "    Child()",
                    "}",
                    "",
                    "// 子（Child）",
                    "@StateObject private var counter = Counter()",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var redraws = 0",
                    "var body: some View {",
                    "    Button(\"親を描き直す: \\(redraws)\") { redraws += 1 }",
                    "    Child()",
                    "}",
                    "",
                    "// 子（Child）",
                    "@ObservedObject private var counter = Counter()  // 親が描き直すたびに作り直す",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(StateObjectDemo.Parent(ownsObject: v["StateObject"] != nil))
        }
    )
}

private enum StateObjectDemo {
    struct Parent: View {
        let ownsObject: Bool
        @State private var redraws = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                CounterRow(title: "親を描き直す", count: redraws) {
                    redraws += 1
                    recorder?.log("親を描き直した")
                }
                if ownsObject {
                    OwningChild()
                } else {
                    ObservingChild()
                }
            }
        }
    }

    struct OwningChild: View {
        @StateObject private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("子の count を \(counter.count) にした")
            }
        }
    }

    struct ObservingChild: View {
        /// 親が描き直すたびに作り直す
        @ObservedObject private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("子の count を \(counter.count) にした")
            }
        }
    }
}
```

`WidgetLab/Catalog/ModelData/ObservedObjectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let observedObject = CatalogEntry(
        id: "ObservedObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "親から受け取った ObservableObject を見張る。中身が変わると、受け取った View を描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/observedobject")!,
        stage: .behavior,
        properties: [
            .wrapper("ObservedObject", summary: "外すと、子で数を増やしても、子は描き直されず表示が変わらない")
        ],
        code: CodeTemplate(
            call: "ObservedObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var counter = Counter()  // 持つだけで見張らない",
                    "var body: some View {",
                    "    Child(counter: counter)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@ObservedObject var counter: Counter",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var counter = Counter()  // 持つだけで見張らない",
                    "var body: some View {",
                    "    Child(counter: counter)",
                    "}",
                    "",
                    "// 子（Child）",
                    "let counter: Counter  // 見張らない",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(ObservedObjectDemo.Parent(observes: v["ObservedObject"] != nil))
        }
    )
}

private enum ObservedObjectDemo {
    struct Parent: View {
        let observes: Bool
        /// 持つだけで見張らない（ObservableObject の中身が変わっても、親は描き直さない）
        @State private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            if observes {
                ObservingChild(counter: counter)
            } else {
                PlainChild(counter: counter)
            }
        }
    }

    struct ObservingChild: View {
        @ObservedObject var counter: DemoCounter
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("count を \(counter.count) にした")
            }
        }
    }

    struct PlainChild: View {
        /// 見張らない
        let counter: DemoCounter
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("count を \(counter.count) にした（表示は変わらない）")
            }
        }
    }
}
```

`WidgetLab/Catalog/ModelData/OnChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onChange = CatalogEntry(
        id: "onChange",
        kind: .modifier,
        topic: .modelData,
        summary: "見張る値が変わったときに、処理を行う modifier。処理には前の値と新しい値が渡る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onChange", id: "onChange.of", label: "of", .fixed(code: "count"), required: true,
                summary: "見張る値（Equatable）"),
            .modifier(
                "onChange", id: "onChange.initial", label: "initial", .toggle(initial: false), required: true,
                summary: "true なら、現れたときにも 1 回行う"),
            .modifier(
                "onChange", id: "onChange.action", label: nil,
                .fixed(code: "{ oldValue, newValue in print(\"\\(oldValue) → \\(newValue)\") }"), on: true,
                summary: "変わったときの処理。+1 を押すたびに記録に出る"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Text",
            fixedArguments: ["\"count: \\(count)\""], closing: ["}"]),
        build: { v in
            AnyView(
                OnChangeDemo(
                    watches: v["onChange.action"] != nil, initial: v.flag("onChange.initial") ?? false))
        }
    )
}

private struct OnChangeDemo: View {
    let watches: Bool
    let initial: Bool
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
                .controlSize(.large)
            Text("count: \(count)")
                .monospacedDigit()
                .apply(watches ? () : nil) { view, _ in
                    view.onChange(of: count, initial: initial) { oldValue, newValue in
                        recorder?.log("count が \(oldValue) → \(newValue)")
                    }
                }
        }
    }
}
```

`WidgetLab/Catalog/ModelData/OnReceiveEntry.swift`:

```swift
import Combine
import SwiftUI

nonisolated extension CatalogEntry {
    static let onReceive = CatalogEntry(
        id: "onReceive",
        kind: .modifier,
        topic: .modelData,
        summary: "Combine の publisher が値を出したときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onreceive(_:perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onReceive", id: "onReceive.publisher", label: nil,
                .choice(
                    [Choice("1 秒ごと", code: "everySecond"), Choice("2 秒ごと", code: "everyTwoSeconds")], initial: 0),
                required: true, summary: "見張る publisher。ここでは Timer.publish の 2 つ"),
            .modifier(
                "onReceive", id: "onReceive.perform", label: "perform", .fixed(code: "{ _ in seconds += 1 }"),
                on: true, summary: "値が届いたときの処理。届くたびに記録に出る"),
        ],
        code: CodeTemplate(
            prefix: [
                "let everySecond = Timer.publish(every: 1, on: .main, in: .common).autoconnect()",
                "let everyTwoSeconds = Timer.publish(every: 2, on: .main, in: .common).autoconnect()",
                "",
            ],
            indent: 0, call: "Text", fixedArguments: ["\"届いた回数: \\(seconds)\""]),
        build: { v in
            AnyView(
                OnReceiveDemo(
                    interval: v["onReceive.perform"] != nil ? v.pick("onReceive.publisher", from: [1.0, 2.0]) : nil))
        }
    )
}

private struct OnReceiveDemo: View {
    /// nil なら onReceive をかけない
    let interval: Double?
    @State private var seconds = 0
    /// 見本ごとに 1 つだけ作る（body のたびに作ると、届くまでの時間が数え直しになる）
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Environment(\.demoRecorder) private var recorder

    init(interval: Double?) {
        self.interval = interval
        _timer = State(initialValue: Timer.publish(every: interval ?? 1, on: .main, in: .common).autoconnect())
    }

    var body: some View {
        let _ = reportBody(recorder, "見本")
        Text("届いた回数: \(seconds)")
            .monospacedDigit()
            .font(.title3)
            .apply(interval) { view, _ in
                view.onReceive(timer) { _ in
                    seconds += 1
                    recorder?.log("Timer から値が届いた（\(seconds) 回目）")
                }
            }
    }
}
```

`WidgetLab/Catalog/ModelData/EnvironmentObjectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentObject = CatalogEntry(
        id: "environmentObject",
        kind: .modifier,
        topic: .modelData,
        summary: "ObservableObject を、かけた View の下の View すべてに渡す modifier。受け取る側は @EnvironmentObject で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/environmentobject(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "environmentObject",
                .choice(
                    [Choice("夜", code: "Theme(\"夜\")"), Choice("夕方", code: "Theme(\"夕方\")")], initial: 0),
                on: true, summary: "下の View に渡す物。外側で渡した「昼」より近いので、2 行目だけこちらが届く")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    ThemeLabel()"], call: "ThemeLabel",
            closing: [
                "}",
                ".environmentObject(Theme(\"昼\"))",
                "",
                "struct ThemeLabel: View {",
                "    @EnvironmentObject var theme: Theme",
                "    var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                "}",
            ]),
        build: { v in
            AnyView(EnvironmentObjectModifierDemo(innerName: v.pick("environmentObject", from: ["夜", "夕方"])))
        }
    )
}

private struct EnvironmentObjectModifierDemo: View {
    /// nil なら 2 行目に environmentObject をかけない
    let innerName: String?
    @StateObject private var outer = DemoTheme("昼")

    var body: some View {
        VStack(spacing: 8) {
            ThemeLabel()
            ThemeLabel()
                .apply(innerName) { $0.environmentObject(DemoTheme($1)) }
        }
        .environmentObject(outer)
    }
}

private struct ThemeLabel: View {
    @EnvironmentObject var theme: DemoTheme

    var body: some View {
        Text("テーマ: \(theme.name)")
            .padding(8)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
    }
}
```

`WidgetLab/Catalog/ModelData/EnvironmentObjectWrapperEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentObjectWrapper = CatalogEntry(
        id: "EnvironmentObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "親や先祖の View が .environmentObject で渡した ObservableObject を読む。間の View に引数を足さなくてよい。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/environmentobject")!,
        stage: .behavior,
        properties: [
            .wrapper(
                "EnvironmentObject",
                summary: "外すと、間の View（Middle）にも引数を足して、手で渡していくことになる。渡す物が見つからないと、@EnvironmentObject は止まる")
        ],
        code: CodeTemplate(
            call: "EnvironmentObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@StateObject private var theme = Theme(\"昼\")",
                    "var body: some View {",
                    "    Button(\"夜にする\") { theme.name = \"夜\" }",
                    "    Middle()",
                    "        .environmentObject(theme)",
                    "}",
                    "",
                    "// 間（Middle）",
                    "var body: some View { ThemeLabel() }",
                    "",
                    "// 子（ThemeLabel）",
                    "@EnvironmentObject var theme: Theme",
                    "var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                ],
                withoutWrapper: [
                    "// 親",
                    "@StateObject private var theme = Theme(\"昼\")",
                    "var body: some View {",
                    "    Button(\"夜にする\") { theme.name = \"夜\" }",
                    "    Middle(theme: theme)",
                    "}",
                    "",
                    "// 間（Middle）",
                    "let theme: Theme",
                    "var body: some View { ThemeLabel(theme: theme) }",
                    "",
                    "// 子（ThemeLabel）",
                    "@ObservedObject var theme: Theme",
                    "var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                ])),
        build: { v in
            AnyView(EnvironmentObjectDemo.Parent(usesEnvironment: v["EnvironmentObject"] != nil))
        }
    )
}

private enum EnvironmentObjectDemo {
    struct Parent: View {
        let usesEnvironment: Bool
        @StateObject private var theme = DemoTheme("昼")
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button(theme.name == "昼" ? "夜にする" : "昼にする") {
                    theme.name = theme.name == "昼" ? "夜" : "昼"
                    recorder?.log("テーマを \(theme.name) にした")
                }
                .buttonStyle(.bordered)
                if usesEnvironment {
                    EnvironmentMiddle()
                        .environmentObject(theme)
                } else {
                    PassingMiddle(theme: theme)
                }
            }
        }
    }

    struct EnvironmentMiddle: View {
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "間")
            EnvironmentLabel()
        }
    }

    struct EnvironmentLabel: View {
        @EnvironmentObject var theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("テーマ: \(theme.name)")
        }
    }

    struct PassingMiddle: View {
        let theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "間")
            PassedLabel(theme: theme)
        }
    }

    struct PassedLabel: View {
        @ObservedObject var theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("テーマ: \(theme.name)")
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .stateObject,
        .observedObject,
        .onChange,
        .onReceive,
        .environmentObject,
        .environmentObjectWrapper,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

Run: `python3 tools/catalog_progress.py model-data`
Expected: 合計 8 / 8（抜け 0）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/ModelData/ObservableObjectDemo.swift WidgetLab/Catalog/ModelData/StateObjectEntry.swift WidgetLab/Catalog/ModelData/ObservedObjectEntry.swift WidgetLab/Catalog/ModelData/OnChangeEntry.swift WidgetLab/Catalog/ModelData/OnReceiveEntry.swift WidgetLab/Catalog/ModelData/EnvironmentObjectEntry.swift WidgetLab/Catalog/ModelData/EnvironmentObjectWrapperEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: データの流れの収録 StateObject・ObservedObject・onChange・onReceive・environmentObject・EnvironmentObject

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 2: Environment・environment・transformEnvironment・defaultAppStorage・AppStorage・SceneStorage・FetchRequest・SectionedFetchRequest

**Files:**
- Create: `WidgetLab/Catalog/EnvironmentValues/EnvironmentWrapperEntry.swift`
- Create: `WidgetLab/Catalog/EnvironmentValues/EnvironmentEntry.swift`
- Create: `WidgetLab/Catalog/EnvironmentValues/TransformEnvironmentEntry.swift`
- Create: `WidgetLab/Catalog/PersistentStorage/DefaultAppStorageEntry.swift`
- Create: `WidgetLab/Catalog/PersistentStorage/AppStorageEntry.swift`
- Create: `WidgetLab/Catalog/PersistentStorage/SceneStorageEntry.swift`
- Create: `WidgetLab/Catalog/PersistentStorage/FetchRequestEntry.swift`
- Create: `WidgetLab/Catalog/PersistentStorage/SectionedFetchRequestEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の収録の型（変えない）。Task 1 の `CounterRow(title:count:increment:)`
- Produces: `CatalogEntry.environmentWrapper`、`CatalogEntry.environment`、`CatalogEntry.transformEnvironment`、`CatalogEntry.defaultAppStorage`、`CatalogEntry.appStorage`、`CatalogEntry.sceneStorage`、`CatalogEntry.fetchRequest`、`CatalogEntry.sectionedFetchRequest`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py environment-values persistent-storage`
Expected: 終了コード 1。抜けに Environment・environment・transformEnvironment・defaultAppStorage・AppStorage・SceneStorage・FetchRequest・SectionedFetchRequest がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/EnvironmentValues/EnvironmentWrapperEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentWrapper = CatalogEntry(
        id: "Environment",
        kind: .propertyWrapper,
        topic: .environmentValues,
        summary: "View の環境（EnvironmentValues）から値を読む。親が値を変えると、読んでいる View が描き直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/environment")!,
        stage: .card,
        properties: [
            .wrapper("Environment", summary: "外すと、親が .disabled(true) をかけても、子は「使える」のまま変わらない。見本は使えなくした状態から始まる")
        ],
        code: CodeTemplate(
            call: "Environment",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"親で使えなくする\") { disabled.toggle() }",
                    "StatusLabel()",
                    "    .disabled(disabled)",
                    "",
                    "// 子（StatusLabel）",
                    "@Environment(\\.isEnabled) private var isEnabled",
                    "var body: some View {",
                    "    Text(isEnabled ? \"使える\" : \"使えない\")",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "Button(\"親で使えなくする\") { disabled.toggle() }",
                    "StatusLabel()",
                    "    .disabled(disabled)",
                    "",
                    "// 子（StatusLabel）",
                    "private var isEnabled = true  // 環境を読まない",
                    "var body: some View {",
                    "    Text(isEnabled ? \"使える\" : \"使えない\")",
                    "}",
                ])),
        build: { v in
            AnyView(EnvironmentWrapperDemo(readsEnvironment: v["Environment"] != nil))
        }
    )
}

private struct EnvironmentWrapperDemo: View {
    let readsEnvironment: Bool
    /// 最初から使えなくしておく（付けない側との違いが、開いたときから見える）
    @State private var disabled = true

    var body: some View {
        VStack(spacing: 12) {
            Button(disabled ? "親で使えるようにする" : "親で使えなくする") { disabled.toggle() }
                .buttonStyle(.bordered)
            Group {
                if readsEnvironment {
                    ReadingLabel()
                } else {
                    FixedLabel()
                }
            }
            .disabled(disabled)
        }
    }

    struct ReadingLabel: View {
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            StatusText(isEnabled: isEnabled)
        }
    }

    struct FixedLabel: View {
        /// 環境を読まない
        private var isEnabled = true

        var body: some View {
            StatusText(isEnabled: isEnabled)
        }
    }

    struct StatusText: View {
        let isEnabled: Bool

        var body: some View {
            Label(isEnabled ? "使える" : "使えない", systemImage: isEnabled ? "checkmark.circle" : "xmark.circle")
                .padding(8)
                .background(isEnabled ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
        }
    }
}
```

`WidgetLab/Catalog/EnvironmentValues/EnvironmentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let environment = CatalogEntry(
        id: "environment",
        kind: .modifier,
        topic: .environmentValues,
        summary: "環境の値（key path で選ぶ）を、かけた View とその下の View で書き換える modifier。Observable の物を渡す形もある。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/environment(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "environment",
                .choice(
                    [
                        Choice("文字を大きく", code: "\\.dynamicTypeSize, .xxxLarge"),
                        Choice("右から左へ", code: "\\.layoutDirection, .rightToLeft"),
                        Choice("使えなくする", code: "\\.isEnabled, false"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の key path と、その値")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Image(systemName: \"bell\")\n    Text(\"お知らせ\")\n    Toggle(\"受け取る\", isOn: $isOn).labelsHidden()\n}"
        ),
        build: { v in
            AnyView(EnvironmentModifierDemo(choice: v.pick("environment", from: [0, 1, 2])))
        }
    )
}

private struct EnvironmentModifierDemo: View {
    /// nil なら environment をかけない
    let choice: Int?
    @State private var isOn = true

    var body: some View {
        let row = HStack {
            Image(systemName: "bell")
            Text("お知らせ")
            Toggle("受け取る", isOn: $isOn).labelsHidden()
        }
        switch choice {
        case 0?: row.environment(\.dynamicTypeSize, .xxxLarge)
        case 1?: row.environment(\.layoutDirection, .rightToLeft)
        case 2?: row.environment(\.isEnabled, false)
        default: row
        }
    }
}
```

`WidgetLab/Catalog/EnvironmentValues/TransformEnvironmentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transformEnvironment = CatalogEntry(
        id: "transformEnvironment",
        kind: .modifier,
        topic: .environmentValues,
        summary: "親から届いた環境の値を、関数で書き換えてから下の View に渡す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/transformenvironment(_:transform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformEnvironment",
                .choice(
                    [
                        Choice("太字に", code: "\\.font, transform: { font in font = font?.bold() }"),
                        Choice("斜体に", code: "\\.font, transform: { font in font = font?.italic() }"),
                        Choice("大きい文字に", code: "\\.font, transform: { font in font = .largeTitle }"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の key path と、書き換える関数。親の .font(.title2) を元に変える")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Text(\"見出し\")\n    Text(\"本文\")\n}",
            suffix: [".font(.title2)"]),
        build: { v in
            AnyView(TransformEnvironmentDemo(choice: v.pick("transformEnvironment", from: [0, 1, 2])))
        }
    )
}

private struct TransformEnvironmentDemo: View {
    /// nil なら transformEnvironment をかけない
    let choice: Int?

    var body: some View {
        let stack = VStack {
            Text("見出し")
            Text("本文")
        }
        Group {
            switch choice {
            case 0?: stack.transformEnvironment(\.font) { font in font = font?.bold() }
            case 1?: stack.transformEnvironment(\.font) { font in font = font?.italic() }
            case 2?: stack.transformEnvironment(\.font) { font in font = .largeTitle }
            default: stack
            }
        }
        .font(.title2)
    }
}
```

`WidgetLab/Catalog/PersistentStorage/DefaultAppStorageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultAppStorage = CatalogEntry(
        id: "defaultAppStorage",
        kind: .modifier,
        topic: .persistentStorage,
        summary: "下の View の @AppStorage が使う保存先（UserDefaults）を決める modifier。付けなければ UserDefaults.standard を使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultappstorage(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "defaultAppStorage", .fixed(code: "UserDefaults(suiteName: \"memo\")!"), on: true,
                summary: "@AppStorage の保存先。見本の memo には count の初めの値を 100 にしてあるので、付けると 100 から数える")
        ],
        code: CodeTemplate(
            call: "CountButton",
            closing: [
                "",
                "struct CountButton: View {",
                "    @AppStorage(\"count\") private var count = 0",
                "    var body: some View {",
                "        Button(\"count: \\(count)\") { count += 1 }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                DefaultAppStorageDemo().apply(v["defaultAppStorage"]) { view, _ in
                    view.defaultAppStorage(DefaultAppStorageDemo.memoStore)
                })
        }
    )
}

private struct DefaultAppStorageDemo: View {
    @AppStorage("widgetLab.demo.defaultAppStorage.count") private var count = 0

    /// 見本の保存先。count の初めの値を 100 にしてある（standard と見分けるため。
    /// register(defaults:) の値はどの保存先からも見えるので、この保存先にだけ書く）
    static let memoStore: UserDefaults = {
        let store = UserDefaults(suiteName: "WidgetLab.demo.memo")!
        let key = "widgetLab.demo.defaultAppStorage.count"
        if store.object(forKey: key) == nil {
            store.set(100, forKey: key)
        }
        return store
    }()

    var body: some View {
        // 比べるの右半分（付けた側）に数が出るよう、右に寄せる
        HStack(spacing: 12) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
            Text("\(count)")
                .font(.largeTitle)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 24)
    }
}
```

`WidgetLab/Catalog/PersistentStorage/AppStorageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let appStorage = CatalogEntry(
        id: "AppStorage",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "UserDefaults の値を読み書きする。値が変わると描き直し、アプリを閉じても値が残る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/appstorage")!,
        stage: .behavior,
        properties: [
            .wrapper("AppStorage", summary: "外すと @State になり、子を作り直すたびに 0 に戻る")
        ],
        code: CodeTemplate(
            call: "AppStorage",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@AppStorage(\"count\") private var count = 0",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@State private var count = 0  // 子を作り直すと 0 に戻る",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(AppStorageDemo.Parent(stores: v["AppStorage"] != nil))
        }
    )
}

private enum AppStorageDemo {
    struct Parent: View {
        let stores: Bool
        @State private var generation = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("子を作り直す") {
                    generation += 1
                    recorder?.log("子を作り直した")
                }
                .buttonStyle(.bordered)
                Group {
                    if stores {
                        StoringChild()
                    } else {
                        StateChild()
                    }
                }
                .id(generation)
            }
        }
    }

    struct StoringChild: View {
        @AppStorage("widgetLab.demo.appStorage.count") private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした（UserDefaults に保存）")
            }
        }
    }

    struct StateChild: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした")
            }
        }
    }
}
```

`WidgetLab/Catalog/PersistentStorage/SceneStorageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sceneStorage = CatalogEntry(
        id: "SceneStorage",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "シーン（窓）ごとに保存する値を読み書きする。システムがシーンを復元するときにも値が戻る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scenestorage")!,
        stage: .behavior,
        properties: [
            .wrapper("SceneStorage", summary: "外すと @State になり、子を作り直すたびに 0 に戻る")
        ],
        code: CodeTemplate(
            call: "SceneStorage",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@SceneStorage(\"count\") private var count = 0",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@State private var count = 0  // 子を作り直すと 0 に戻る",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(SceneStorageDemo.Parent(stores: v["SceneStorage"] != nil))
        }
    )
}

private enum SceneStorageDemo {
    struct Parent: View {
        let stores: Bool
        @State private var generation = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("子を作り直す") {
                    generation += 1
                    recorder?.log("子を作り直した")
                }
                .buttonStyle(.bordered)
                Group {
                    if stores {
                        StoringChild()
                    } else {
                        StateChild()
                    }
                }
                .id(generation)
            }
        }
    }

    struct StoringChild: View {
        @SceneStorage("widgetLab.demo.sceneStorage.count") private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした（シーンに保存）")
            }
        }
    }

    struct StateChild: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした")
            }
        }
    }
}
```

`WidgetLab/Catalog/PersistentStorage/FetchRequestEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fetchRequest = CatalogEntry(
        id: "FetchRequest",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "Core Data の保存先から、条件と並びに合うものを取り出す。保存先が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/fetchrequest")!,
        noteReason: "Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、保存先から一覧を取り出すときに使う",
        properties: [
            .wrapper("FetchRequest", summary: "外すと、保存先から自分で読み込むことになり、保存先が変わっても描き直さない")
        ],
        code: CodeTemplate(
            call: "FetchRequest",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 保存先は親で .environment(\\.managedObjectContext, container.viewContext) で渡す",
                    "@FetchRequest(sortDescriptors: [SortDescriptor(\\.name)]) private var fruits: FetchedResults<Fruit>",
                    "var body: some View {",
                    "    List(fruits) { Text($0.name ?? \"\") }",
                    "}",
                ],
                withoutWrapper: [
                    "@Environment(\\.managedObjectContext) private var context",
                    "@State private var fruits: [Fruit] = []  // 保存先が変わっても描き直さない",
                    "var body: some View {",
                    "    List(fruits) { Text($0.name ?? \"\") }",
                    "        .task { fruits = (try? context.fetch(Fruit.fetchRequest())) ?? [] }",
                    "}",
                ]))
    )
}
```

`WidgetLab/Catalog/PersistentStorage/SectionedFetchRequestEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionedFetchRequest = CatalogEntry(
        id: "SectionedFetchRequest",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "Core Data の保存先から取り出したものを、セクションに分けて持つ。保存先が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sectionedfetchrequest")!,
        noteReason:
            "Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、取り出したものをセクションに分けて一覧にするときに使う",
        properties: [
            .wrapper("SectionedFetchRequest", summary: "外すと @FetchRequest で取り出し、セクションに分けるのを自分で書く")
        ],
        code: CodeTemplate(
            call: "SectionedFetchRequest",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 保存先は親で .environment(\\.managedObjectContext, container.viewContext) で渡す",
                    "@SectionedFetchRequest(sectionIdentifier: \\.color, sortDescriptors: [SortDescriptor(\\.color), SortDescriptor(\\.name)]) private var sections: SectionedFetchResults<String?, Fruit>",
                    "var body: some View {",
                    "    List(sections) { section in Section(section.id ?? \"\") { ForEach(section) { Text($0.name ?? \"\") } } }",
                    "}",
                ],
                withoutWrapper: [
                    "@FetchRequest(sortDescriptors: [SortDescriptor(\\.color), SortDescriptor(\\.name)]) private var fruits: FetchedResults<Fruit>",
                    "var body: some View {",
                    "    // セクションに分けるのは自分で行う",
                    "    List(Dictionary(grouping: fruits, by: \\.color).sorted { ($0.key ?? \"\") < ($1.key ?? \"\") }, id: \\.key) { color, items in",
                    "        Section(color ?? \"\") { ForEach(items) { Text($0.name ?? \"\") } }",
                    "    }",
                    "}",
                ]))
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .environmentWrapper,
        .environment,
        .transformEnvironment,
        .defaultAppStorage,
        .appStorage,
        .sceneStorage,
        .fetchRequest,
        .sectionedFetchRequest,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

Run: `python3 tools/catalog_progress.py environment-values persistent-storage`
Expected: 合計 8 / 8（抜け 0）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/EnvironmentValues/EnvironmentWrapperEntry.swift WidgetLab/Catalog/EnvironmentValues/EnvironmentEntry.swift WidgetLab/Catalog/EnvironmentValues/TransformEnvironmentEntry.swift WidgetLab/Catalog/PersistentStorage/DefaultAppStorageEntry.swift WidgetLab/Catalog/PersistentStorage/AppStorageEntry.swift WidgetLab/Catalog/PersistentStorage/SceneStorageEntry.swift WidgetLab/Catalog/PersistentStorage/FetchRequestEntry.swift WidgetLab/Catalog/PersistentStorage/SectionedFetchRequestEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 環境の値と保存の収録 Environment・environment・transformEnvironment・defaultAppStorage・AppStorage・SceneStorage・FetchRequest・SectionedFetchRequest

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 3: preference・transformPreference・anchorPreference・transformAnchorPreference・onPreferenceChange・backgroundPreferenceValue・overlayPreferenceValue

**Files:**
- Create: `WidgetLab/Catalog/Preferences/PreferencesDemo.swift`
- Create: `WidgetLab/Catalog/Preferences/PreferenceEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/TransformPreferenceEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/AnchorPreferenceEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/TransformAnchorPreferenceEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/OnPreferenceChangeEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/BackgroundPreferenceValueEntry.swift`
- Create: `WidgetLab/Catalog/Preferences/OverlayPreferenceValueEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の収録の型（変えない）
- Produces: 7 件の `CatalogEntry`、補助 `DemoTitleKey`・`DemoBoundsKey`・`DemoAllBoundsKey`・`PreferenceMarker(anchor:fills:)`・`FruitTag(_:)`・`PreferenceCode`（`titleKey`・`boundsKey`・`marker(fills:)`）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py preferences`
Expected: 終了コード 1。抜けに preference・transformPreference・anchorPreference・transformAnchorPreference・onPreferenceChange・backgroundPreferenceValue・overlayPreferenceValue がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/Preferences/PreferencesDemo.swift`:

```swift
import SwiftUI

/// preferences の収録で使う、子が親に知らせる題名。兄弟の値は後のものを使う
nonisolated struct DemoTitleKey: PreferenceKey {
    static let defaultValue = ""

    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

/// preferences の収録で使う、印を付ける子の枠。兄弟の値は先のものを使う
nonisolated struct DemoBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? { nil }

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

/// preferences の収録で使う、子の枠をすべて集めたもの
nonisolated struct DemoAllBoundsKey: PreferenceKey {
    static var defaultValue: [Anchor<CGRect>] { [] }

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value += nextValue()
    }
}

/// 子の枠（anchor）の位置に描く印。塗る（背景向け）か、枠を描く（重ねる向け）
struct PreferenceMarker: View {
    let anchor: Anchor<CGRect>?
    var fills = false

    var body: some View {
        GeometryReader { proxy in
            if let anchor {
                let rect = proxy[anchor]
                Group {
                    if fills {
                        RoundedRectangle(cornerRadius: 8).fill(.yellow)
                    } else {
                        RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3)
                    }
                }
                .frame(width: rect.width, height: rect.height)
                .offset(x: rect.minX, y: rect.minY)
            }
        }
    }
}

/// 果物の札を 1 つ（anchor の見本で並べる）
struct FruitTag: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        Text(name)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }
}

/// preferences の見本のコードに書く、キーと印の定義
nonisolated enum PreferenceCode {
    static let titleKey = [
        "",
        "struct TitleKey: PreferenceKey {",
        "    static let defaultValue = \"\"",
        "    static func reduce(value: inout String, nextValue: () -> String) { value = nextValue() }",
        "}",
    ]

    static let boundsKey = [
        "",
        "struct BoundsKey: PreferenceKey {",
        "    static var defaultValue: Anchor<CGRect>? { nil }",
        "    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {",
        "        value = value ?? nextValue()",
        "    }",
        "}",
    ]

    /// anchor の位置に印を描く View
    static func marker(fills: Bool) -> [String] {
        [
            "",
            "struct Marker: View {",
            "    let anchor: Anchor<CGRect>?",
            "    var body: some View {",
            "        GeometryReader { proxy in",
            "            if let anchor {",
            "                let rect = proxy[anchor]",
            fills
                ? "                RoundedRectangle(cornerRadius: 8).fill(.yellow)"
                : "                RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3)",
            "                    .frame(width: rect.width, height: rect.height)",
            "                    .offset(x: rect.minX, y: rect.minY)",
            "            }",
            "        }",
            "    }",
            "}",
        ]
    }
}
```

`WidgetLab/Catalog/Preferences/PreferenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let preference = CatalogEntry(
        id: "preference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の View から、親の View へ値を知らせる modifier。親は onPreferenceChange などで受け取る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/preference(key:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "preference", id: "preference.key", label: "key", .fixed(code: "TitleKey.self"), required: true,
                summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "preference", id: "preference.value", label: "value",
                .choice([Choice("\"りんご\""), Choice("\"ぶどう\"")], initial: 0), on: true,
                summary: "知らせる値。外すと、親には何も届かない"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"届いた題名: \\(title)\")"], call: "Text", fixedArguments: ["\"子\""],
            closing: ["}", ".onPreferenceChange(TitleKey.self) { title = $0 }"] + PreferenceCode.titleKey),
        build: { v in
            AnyView(PreferenceDemo(value: v.pick("preference.value", from: ["りんご", "ぶどう"])))
        }
    )
}

private struct PreferenceDemo: View {
    /// nil なら preference をかけない
    let value: String?
    @State private var title = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("届いた題名: \(title.isEmpty ? "なし" : title)")
            Text("子")
                .padding(8)
                .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
                .apply(value) { $0.preference(key: DemoTitleKey.self, value: $1) }
        }
        .onPreferenceChange(DemoTitleKey.self) { title = $0 }
    }
}
```

`WidgetLab/Catalog/Preferences/TransformPreferenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transformPreference = CatalogEntry(
        id: "transformPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子から上がってきた値を、関数で書き換えてから親へ渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transformpreference(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformPreference",
                .choice(
                    [
                        Choice("後ろに足す", code: "TitleKey.self, { $0 += \"とぶどう\" }"),
                        Choice("置き換える", code: "TitleKey.self, { $0 = \"もも\" }"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の種類と、書き換える関数。子が知らせた「りんご」を元に変える")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"届いた題名: \\(title)\")", "    Text(\"子\")"], indent: 8,
            call: ".preference", fixedArguments: ["key: TitleKey.self", "value: \"りんご\""],
            closing: ["}", ".onPreferenceChange(TitleKey.self) { title = $0 }"] + PreferenceCode.titleKey),
        build: { v in
            AnyView(TransformPreferenceDemo(choice: v.pick("transformPreference", from: [0, 1])))
        }
    )
}

private struct TransformPreferenceDemo: View {
    /// nil なら transformPreference をかけない
    let choice: Int?
    @State private var title = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("届いた題名: \(title)")
            child
        }
        .onPreferenceChange(DemoTitleKey.self) { title = $0 }
    }

    @ViewBuilder
    private var child: some View {
        let text = Text("子")
            .padding(8)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
            .preference(key: DemoTitleKey.self, value: "りんご")
        switch choice {
        case 0?: text.transformPreference(DemoTitleKey.self) { $0 += "とぶどう" }
        case 1?: text.transformPreference(DemoTitleKey.self) { $0 = "もも" }
        default: text
        }
    }
}
```

`WidgetLab/Catalog/Preferences/AnchorPreferenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let anchorPreference = CatalogEntry(
        id: "anchorPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の枠や位置（anchor）を、親へ知らせる modifier。親は自分の座標に直して、印などを描ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/anchorpreference(key:value:transform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "anchorPreference", id: "anchorPreference.key", label: "key", .fixed(code: "BoundsKey.self"),
                required: true, summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "anchorPreference", id: "anchorPreference.value", label: "value", .fixed(code: ".bounds"),
                required: true, summary: "知らせる形。.bounds は枠ぜんたい"),
            .modifier(
                "anchorPreference", id: "anchorPreference.transform", label: "transform", .fixed(code: "{ $0 }"),
                on: true, summary: "anchor を知らせる値に変える関数。外すと、親は印を描けない"),
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"りんご\")"], call: "Text", fixedArguments: ["\"ぶどう\""],
            closing: [
                "    Text(\"もも\")", "}",
                ".overlayPreferenceValue(BoundsKey.self) { Marker(anchor: $0) }",
            ]
                + PreferenceCode.boundsKey + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(AnchorPreferenceDemo(marks: v["anchorPreference.transform"] != nil))
        }
    )
}

private struct AnchorPreferenceDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .apply(marks ? () : nil) { view, _ in
                    view.anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
                }
            FruitTag("もも")
        }
        .overlayPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0) }
    }
}
```

`WidgetLab/Catalog/Preferences/TransformAnchorPreferenceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transformAnchorPreference = CatalogEntry(
        id: "transformAnchorPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の枠や位置（anchor）で、すでにある値を書き換えて親へ知らせる modifier。いくつもの子の枠を 1 つの配列に集められる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/transformanchorpreference(key:value:transform:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.key", label: "key",
                .fixed(code: "AllBoundsKey.self"), required: true, summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.value", label: "value",
                .fixed(code: ".bounds"), required: true, summary: "知らせる形。.bounds は枠ぜんたい"),
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.transform", label: "transform",
                .fixed(code: "{ $0.append($1) }"), on: true,
                summary: "すでにある値（配列）に、この子の anchor を足す関数。外すと、親は印を描けない"),
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    ForEach([\"りんご\", \"ぶどう\", \"もも\"], id: \\.self) { name in"], indent: 8,
            call: "Text", fixedArguments: ["name"],
            closing: [
                "    }",
                "}",
                ".overlayPreferenceValue(AllBoundsKey.self) { anchors in",
                "    ForEach(anchors.indices, id: \\.self) { Marker(anchor: anchors[$0]) }",
                "}",
                "",
                "struct AllBoundsKey: PreferenceKey {",
                "    static var defaultValue: [Anchor<CGRect>] { [] }",
                "    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {",
                "        value += nextValue()",
                "    }",
                "}",
            ] + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(TransformAnchorPreferenceDemo(marks: v["transformAnchorPreference.transform"] != nil))
        }
    )
}

private struct TransformAnchorPreferenceDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            ForEach(["りんご", "ぶどう", "もも"], id: \.self) { name in
                FruitTag(name)
                    .apply(marks ? () : nil) { view, _ in
                        view.transformAnchorPreference(key: DemoAllBoundsKey.self, value: .bounds) { $0.append($1) }
                    }
            }
        }
        .overlayPreferenceValue(DemoAllBoundsKey.self) { anchors in
            ForEach(anchors.indices, id: \.self) { PreferenceMarker(anchor: anchors[$0]) }
        }
    }
}
```

`WidgetLab/Catalog/Preferences/OnPreferenceChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onPreferenceChange = CatalogEntry(
        id: "onPreferenceChange",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせる値（preference）が変わったときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpreferencechange(_:perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onPreferenceChange", id: "onPreferenceChange.key", label: nil, .fixed(code: "TitleKey.self"),
                required: true, summary: "見張る値の種類（PreferenceKey）。値は Equatable"),
            .modifier(
                "onPreferenceChange", id: "onPreferenceChange.perform", label: "perform",
                .fixed(code: "{ title = $0 }"),
                on: true, summary: "値が変わったときの処理。果物を変えるたびに記録に出る"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Text(\"届いた題名: \\(title)\")\n    Button(\"ぶどうにする\") { fruit = \"ぶどう\" }\n    Text(fruit)\n        .preference(key: TitleKey.self, value: fruit)\n}",
            closing: PreferenceCode.titleKey),
        build: { v in
            AnyView(OnPreferenceChangeDemo(watches: v["onPreferenceChange.perform"] != nil))
        }
    )
}

private struct OnPreferenceChangeDemo: View {
    let watches: Bool
    @State private var fruit = "りんご"
    @State private var title = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Text("届いた題名: \(title.isEmpty ? "なし" : title)")
            Button(fruit == "りんご" ? "ぶどうにする" : "りんごにする") {
                fruit = fruit == "りんご" ? "ぶどう" : "りんご"
            }
            .buttonStyle(.bordered)
            Text(fruit)
                .preference(key: DemoTitleKey.self, value: fruit)
        }
        .apply(watches ? () : nil) { view, _ in
            view.onPreferenceChange(DemoTitleKey.self) { value in
                title = value
                recorder?.log("題名「\(value)」が届いた")
            }
        }
    }
}
```

`WidgetLab/Catalog/Preferences/BackgroundPreferenceValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let backgroundPreferenceValue = CatalogEntry(
        id: "backgroundPreferenceValue",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせた値を読み、元の View の後ろに別の View を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/backgroundpreferencevalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "backgroundPreferenceValue", id: "backgroundPreferenceValue.key", label: nil,
                .fixed(code: "BoundsKey.self"),
                required: true, summary: "読む値の種類（PreferenceKey）"),
            .modifier(
                "backgroundPreferenceValue", id: "backgroundPreferenceValue.transform", label: nil,
                .fixed(code: "{ Marker(anchor: $0) }"), on: true,
                summary: "読んだ値から、後ろに描く View を作る。ここでは「ぶどう」の枠に印を描く"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Text(\"りんご\")\n    Text(\"ぶどう\")\n        .anchorPreference(key: BoundsKey.self, value: .bounds, transform: { $0 })\n    Text(\"もも\")\n}",
            closing: PreferenceCode.boundsKey + PreferenceCode.marker(fills: true)),
        build: { v in
            AnyView(BackgroundPreferenceValueDemo(marks: v["backgroundPreferenceValue.transform"] != nil))
        }
    )
}

private struct BackgroundPreferenceValueDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
            FruitTag("もも")
        }
        .apply(marks ? () : nil) { view, _ in
            view.backgroundPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0, fills: true) }
        }
    }
}
```

`WidgetLab/Catalog/Preferences/OverlayPreferenceValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let overlayPreferenceValue = CatalogEntry(
        id: "overlayPreferenceValue",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせた値を読み、元の View の上に別の View を重ねる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/overlaypreferencevalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "overlayPreferenceValue", id: "overlayPreferenceValue.key", label: nil, .fixed(code: "BoundsKey.self"),
                required: true, summary: "読む値の種類（PreferenceKey）"),
            .modifier(
                "overlayPreferenceValue", id: "overlayPreferenceValue.transform", label: nil,
                .fixed(code: "{ Marker(anchor: $0) }"), on: true,
                summary: "読んだ値から、上に描く View を作る。ここでは「ぶどう」の枠に印を描く"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Text(\"りんご\")\n    Text(\"ぶどう\")\n        .anchorPreference(key: BoundsKey.self, value: .bounds, transform: { $0 })\n    Text(\"もも\")\n}",
            closing: PreferenceCode.boundsKey + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(OverlayPreferenceValueDemo(marks: v["overlayPreferenceValue.transform"] != nil))
        }
    )
}

private struct OverlayPreferenceValueDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
            FruitTag("もも")
        }
        .apply(marks ? () : nil) { view, _ in
            view.overlayPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0, fills: false) }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .preference,
        .transformPreference,
        .anchorPreference,
        .transformAnchorPreference,
        .onPreferenceChange,
        .backgroundPreferenceValue,
        .overlayPreferenceValue,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

Run: `python3 tools/catalog_progress.py preferences`
Expected: 合計 7 / 7（抜け 0）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Preferences/PreferencesDemo.swift WidgetLab/Catalog/Preferences/PreferenceEntry.swift WidgetLab/Catalog/Preferences/TransformPreferenceEntry.swift WidgetLab/Catalog/Preferences/AnchorPreferenceEntry.swift WidgetLab/Catalog/Preferences/TransformAnchorPreferenceEntry.swift WidgetLab/Catalog/Preferences/OnPreferenceChangeEntry.swift WidgetLab/Catalog/Preferences/BackgroundPreferenceValueEntry.swift WidgetLab/Catalog/Preferences/OverlayPreferenceValueEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 子から親へ知らせる値の収録 preference・transformPreference・anchorPreference・transformAnchorPreference・onPreferenceChange・backgroundPreferenceValue・overlayPreferenceValue

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 4: FocusState・focused・focusable・searchFocused・defaultFocus・focusEffectDisabled

**Files:**
- Create: `WidgetLab/Catalog/Focus/FocusDemo.swift`
- Create: `WidgetLab/Catalog/Focus/FocusStateEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusableEntry.swift`
- Create: `WidgetLab/Catalog/Focus/SearchFocusedEntry.swift`
- Create: `WidgetLab/Catalog/Focus/DefaultFocusEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusEffectDisabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の収録の型（変えない）
- Produces: 6 件の `CatalogEntry`、補助 `FocusedValues.demoNoteTitle`・`FocusedValues.demoNoteText`・`DemoNote`・`FocusReadout(title:value:)`・`NoteField(title:text:)`（Task 5 が使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py focus`
Expected: 終了コード 1。抜けに FocusState・focused・focusable・searchFocused・defaultFocus・focusEffectDisabled がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/Focus/FocusDemo.swift`:

```swift
import SwiftUI

extension FocusedValues {
    /// focus の収録で使う、フォーカスのあるメモの題名
    @Entry var demoNoteTitle: String?
    /// focus の収録で使う、フォーカスのあるメモの本文
    @Entry var demoNoteText: Binding<String>?
}

/// focus の収録で使う、題名を持つメモ（ObservableObject）
final class DemoNote: ObservableObject {
    @Published var title: String

    init(_ title: String) {
        self.title = title
    }
}

/// 読んだ値を出す札（focus の見本で共通の見た目）
struct FocusReadout: View {
    let title: String
    let value: String?

    var body: some View {
        Text("\(title): \(value ?? "なし")")
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
    }
}

/// メモの入力欄（focus の見本で共通の見た目）
struct NoteField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.bordered)
    }
}
```

`WidgetLab/Catalog/Focus/FocusStateEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusState = CatalogEntry(
        id: "FocusState",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスがどこにあるかを持つ値。.focused でつないだ View にフォーカスが来ると変わり、書き換えるとフォーカスを動かせる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusstate")!,
        stage: .behavior,
        properties: [
            .wrapper("FocusState", summary: "外すと @State の Bool になり、.focused につなげない。ボタンで true にしても、入力欄にフォーカスが来ない")
        ],
        code: CodeTemplate(
            call: "FocusState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@FocusState private var isFocused: Bool",
                    "",
                    "var body: some View {",
                    "    Button(\"入力欄へ\") { isFocused = true }",
                    "    TextField(\"メモ\", text: $memo)",
                    "        .focused($isFocused)",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var isFocused = false  // フォーカスとつながらない",
                    "",
                    "var body: some View {",
                    "    Button(\"入力欄へ\") { isFocused = true }",
                    "    TextField(\"メモ\", text: $memo)",
                    "}",
                ])),
        build: { v in
            v["FocusState"] != nil ? AnyView(FocusStateDemo.WithFocusState()) : AnyView(FocusStateDemo.WithState())
        }
    )
}

private enum FocusStateDemo {
    struct WithFocusState: View {
        @FocusState private var isFocused: Bool
        @State private var memo = ""
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("入力欄へ") { isFocused = true }
                    .buttonStyle(.bordered)
                NoteField(title: "メモ", text: $memo)
                    .focused($isFocused)
                Text("isFocused: \(isFocused)")
            }
            .onChange(of: isFocused) { recorder?.log("isFocused を \(isFocused) にした") }
        }
    }

    struct WithState: View {
        /// フォーカスとつながらない
        @State private var isFocused = false
        @State private var memo = ""
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("入力欄へ") { isFocused = true }
                    .buttonStyle(.bordered)
                NoteField(title: "メモ", text: $memo)
                Text("isFocused: \(isFocused)")
            }
            .onChange(of: isFocused) { recorder?.log("isFocused を \(isFocused) にした（フォーカスは動かない）") }
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focused = CatalogEntry(
        id: "focused",
        kind: .modifier,
        topic: .focus,
        summary: "この View のフォーカスを、@FocusState の値とつなぐ modifier。値を書き換えるとフォーカスが動き、フォーカスが動くと値が変わる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focused(_:equals:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focused",
                .choice(
                    [Choice("Bool", code: "$isFocused"), Choice("どの欄か", code: "$field, equals: .memo")], initial: 0),
                on: true, summary: "つなぐ @FocusState。Bool か、どの欄かを表す値（equals）。外すと、ボタンを押してもフォーカスが来ない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"入力欄へ\") { isFocused = true }"], call: "TextField",
            fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["}"]),
        build: { v in
            AnyView(FocusedDemo(choice: v.pick("focused", from: [0, 1])))
        }
    )
}

private struct FocusedDemo: View {
    enum Field: Hashable { case memo }

    /// nil なら focused をかけない
    let choice: Int?
    @FocusState private var isFocused: Bool
    @FocusState private var field: Field?
    @State private var memo = ""

    var body: some View {
        VStack(spacing: 8) {
            Button("入力欄へ") {
                if choice == 1 { field = .memo } else { isFocused = true }
            }
            .buttonStyle(.bordered)
            fieldView
            Text(choice == 1 ? "field: \(field == .memo ? ".memo" : "nil")" : "isFocused: \(isFocused)")
                .monospaced()
        }
    }

    @ViewBuilder
    private var fieldView: some View {
        let base = NoteField(title: "メモ", text: $memo)
        switch choice {
        case 0?: base.focused($isFocused)
        case 1?: base.focused($field, equals: .memo)
        default: base
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusable = CatalogEntry(
        id: "focusable",
        kind: .modifier,
        topic: .focus,
        summary: "入力欄でない View を、フォーカスを受けられるようにする modifier。受けられると、@FocusState でフォーカスを当てられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusable(_:interactions:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusable", id: "focusable.isFocusable", label: nil, .toggle(initial: true), on: true,
                summary: "フォーカスを受けられるか。外すか false にすると、ボタンを押してもフォーカスが来ない"),
            .modifier(
                "focusable", id: "focusable.interactions", label: "interactions",
                .choice([Choice(".activate"), Choice(".edit"), Choice(".automatic")], initial: 0),
                summary: "フォーカスで受ける操作の種類（キーボードやリモコンで使う）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"札にフォーカス\") { isFocused = true }"], call: "Text",
            fixedArguments: ["\"札\""], suffix: [".focused($isFocused)"], closing: ["}"]),
        build: { v in
            AnyView(
                FocusableDemo(
                    isFocusable: v["focusable.isFocusable"] == nil ? nil : v.flag("focusable.isFocusable") ?? true,
                    interactions: v.pick(
                        "focusable.interactions", from: [FocusInteractions.activate, .edit, .automatic])))
        }
    )
}

private struct FocusableDemo: View {
    /// nil なら focusable をかけない（interactions だけ ON なら、既定の true でかける）
    let isFocusable: Bool?
    let interactions: FocusInteractions?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button("札にフォーカス") { isFocused = true }
                .buttonStyle(.bordered)
            tag
                .focused($isFocused)
            Text("isFocused: \(isFocused)")
                .monospaced()
        }
    }

    @ViewBuilder
    private var tag: some View {
        let text = Text("札")
            .padding(8)
            .background(isFocused ? Color.yellow : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
        switch (isFocusable, interactions) {
        case (let flag?, let interactions?): text.focusable(flag, interactions: interactions)
        case (let flag?, nil): text.focusable(flag)
        case (nil, let interactions?): text.focusable(interactions: interactions)
        case (nil, nil): text
        }
    }
}
```

`WidgetLab/Catalog/Focus/SearchFocusedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let searchFocused = CatalogEntry(
        id: "searchFocused",
        kind: .modifier,
        topic: .focus,
        summary: "いちばん近い .searchable の検索欄のフォーカスを、@FocusState の値とつなぐ modifier。コードから検索欄を選べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/searchfocused(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "searchFocused", .fixed(code: "$isSearching"), on: true,
                summary: "つなぐ @FocusState の Bool。外すと、「検索する」を押しても検索欄が選ばれない")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(fruits, id: \\.self) { Text($0) }"], indent: 8, call: ".searchable",
            fixedArguments: ["text: $query"],
            suffix: [".toolbar { Button(\"検索する\") { isSearching = true } }", ".navigationTitle(\"果物\")"],
            closing: ["}"]),
        build: { v in
            AnyView(SearchFocusedDemo(binds: v["searchFocused"] != nil))
        }
    )
}

private struct SearchFocusedDemo: View {
    let binds: Bool
    @State private var query = ""
    @FocusState private var isSearching: Bool

    private let fruits = ["りんご", "ぶどう", "もも", "みかん", "なし"]

    var body: some View {
        NavigationStack {
            List(fruits.filter { query.isEmpty || $0.contains(query) }, id: \.self) { Text($0) }
                .searchable(text: $query)
                .apply(binds ? () : nil) { view, _ in view.searchFocused($isSearching) }
                .toolbar { Button("検索する") { isSearching = true } }
                .navigationTitle("果物")
        }
    }
}
```

`WidgetLab/Catalog/Focus/DefaultFocusEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultFocus = CatalogEntry(
        id: "defaultFocus",
        kind: .modifier,
        topic: .focus,
        summary: "この View の中で、はじめにフォーカスを置く先を決める modifier。@FocusState にその値を入れる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultfocus(_:_:priority:)")!,
        noteReason: "iPhone では、はじめのフォーカスが決まらなかった（入力欄は選ばれず、キーボードも出ない）。iPad・Mac のキーボード操作や Apple TV で、はじめにフォーカスを置く先が決まる",
        properties: [
            .modifier(
                "defaultFocus", id: "defaultFocus.binding", label: nil, .fixed(code: "$field"), required: true,
                summary: "フォーカスを持つ @FocusState"),
            .modifier(
                "defaultFocus", id: "defaultFocus.value", label: nil,
                .choice([Choice(".mail"), Choice(".name")], initial: 0), on: true, summary: "はじめにフォーカスを置く欄"),
            .modifier(
                "defaultFocus", id: "defaultFocus.priority", label: "priority",
                .choice([Choice(".automatic"), Choice(".userInitiated")], initial: 0), required: true,
                summary: "いつ効かせるか。.userInitiated は、使う人の操作でフォーカスを決めるときにも効く"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    TextField(\"名前\", text: $name).focused($field, equals: .name)\n    TextField(\"メール\", text: $mail).focused($field, equals: .mail)\n}"
        )
    )
}
```

`WidgetLab/Catalog/Focus/FocusEffectDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusEffectDisabled = CatalogEntry(
        id: "focusEffectDisabled",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスの輪（フォーカスリング）や、ポインタを重ねたときの浮き上がりを出さないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focuseffectdisabled(_:)")!,
        noteReason: "iPhone では、フォーカスの輪や浮き上がりが出ない。iPad や Mac でキーボードやポインタを使うときと、Apple TV で効く",
        properties: [
            .modifier("focusEffectDisabled", .toggle(initial: true), on: true, summary: "フォーカスの効果を出さないか")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"札\")"], indent: 4, call: ".focusable")
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .focusState,
        .focused,
        .focusable,
        .searchFocused,
        .defaultFocus,
        .focusEffectDisabled,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

Run: `python3 tools/catalog_progress.py focus`
Expected: 抜けは Task 5 の 7 件（focusedValue・FocusedValue・FocusedBinding・focusedSceneValue・focusedObject・focusedSceneObject・FocusedObject）だけ。終了コードは 1 のまま

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Focus/FocusDemo.swift WidgetLab/Catalog/Focus/FocusStateEntry.swift WidgetLab/Catalog/Focus/FocusedEntry.swift WidgetLab/Catalog/Focus/FocusableEntry.swift WidgetLab/Catalog/Focus/SearchFocusedEntry.swift WidgetLab/Catalog/Focus/DefaultFocusEntry.swift WidgetLab/Catalog/Focus/FocusEffectDisabledEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: フォーカスの収録 FocusState・focused・focusable・searchFocused・defaultFocus・focusEffectDisabled

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 5: focusedValue・FocusedValue・FocusedBinding・focusedSceneValue・focusedObject・focusedSceneObject・FocusedObject

**Files:**
- Create: `WidgetLab/Catalog/Focus/FocusedValueEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedValueWrapperEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedBindingEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedSceneValueEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedObjectEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedSceneObjectEntry.swift`
- Create: `WidgetLab/Catalog/Focus/FocusedObjectWrapperEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の収録の型（変えない）。Task 4 の `FocusedValues.demoNoteTitle`・`FocusedValues.demoNoteText`・`DemoNote`・`FocusReadout`・`NoteField`
- Produces: 7 件の `CatalogEntry`、補助 `FocusedNoteReader`（`FocusedObjectEntry.swift` に置き、focusedSceneObject・FocusedObject でも使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py focus`
Expected: 終了コード 1。抜けに focusedValue・FocusedValue・FocusedBinding・focusedSceneValue・focusedObject・focusedSceneObject・FocusedObject がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/Focus/FocusedValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedValue = CatalogEntry(
        id: "focusedValue",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスがこの View（か、その中）にあるあいだ、値を FocusedValues に出す modifier。ほかの View は @FocusedValue で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedvalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusedValue", .fixed(code: "\\.noteTitle, \"メモ A\""), on: true,
                summary: "出す値の key path と値。外すと、メモ A を選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    NoteTitleLabel()  // @FocusedValue(\\.noteTitle) を出す"], call: "TextField",
            fixedArguments: ["\"メモ A\"", "text: $memoA"],
            closing: [
                "    TextField(\"メモ B\", text: $memoB)",
                "        .focusedValue(\\.noteTitle, \"メモ B\")",
                "}",
                "",
                "extension FocusedValues {",
                "    @Entry var noteTitle: String?",
                "}",
            ]),
        build: { v in
            AnyView(FocusedValueDemo(exposesA: v["focusedValue"] != nil))
        }
    )
}

private struct FocusedValueDemo: View {
    let exposesA: Bool
    @State private var memoA = ""
    @State private var memoB = ""

    var body: some View {
        VStack(spacing: 8) {
            TitleReader()
            NoteField(title: "メモ A", text: $memoA)
                .apply(exposesA ? () : nil) { view, _ in view.focusedValue(\.demoNoteTitle, "メモ A") }
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteTitle, "メモ B")
        }
    }

    struct TitleReader: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedValueWrapperEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedValueWrapper = CatalogEntry(
        id: "FocusedValue",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が .focusedValue で出した値を読む。フォーカスが動くと描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedvalue")!,
        stage: .card,
        properties: [
            .wrapper("FocusedValue", summary: "外すと、どのメモを選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            call: "FocusedValue",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 札（NoteTitleLabel）",
                    "@FocusedValue(\\.noteTitle) private var title",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteTitleLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteTitle, \"メモ A\")",
                ],
                withoutWrapper: [
                    "// 札（NoteTitleLabel）",
                    "private var title: String? = nil  // フォーカスを見ない",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteTitleLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteTitle, \"メモ A\")",
                ])),
        build: { v in
            AnyView(FocusedValueWrapperDemo(reads: v["FocusedValue"] != nil))
        }
    )
}

private struct FocusedValueWrapperDemo: View {
    let reads: Bool
    @State private var memoA = ""
    @State private var memoB = ""

    var body: some View {
        VStack(spacing: 8) {
            if reads {
                ReadingLabel()
            } else {
                FixedLabel()
            }
            NoteField(title: "メモ A", text: $memoA)
                .focusedValue(\.demoNoteTitle, "メモ A")
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteTitle, "メモ B")
        }
    }

    struct ReadingLabel: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }

    struct FixedLabel: View {
        /// フォーカスを見ない
        private var title: String? = nil

        var body: some View {
            FocusReadout(title: "フォーカスのあるメモ", value: title)
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedBindingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedBinding = CatalogEntry(
        id: "FocusedBinding",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が出した Binding を、ほどいて読み書きする。フォーカスのあるメモを、外のボタンから書き換えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedbinding")!,
        stage: .card,
        properties: [
            .wrapper("FocusedBinding", summary: "外すと @FocusedValue で Binding のまま受け取り、wrappedValue を書き換える")
        ],
        code: CodeTemplate(
            call: "FocusedBinding",
            wrapper: WrapperCode(
                withWrapper: [
                    "// ボタン（ClearButton）",
                    "@FocusedBinding(\\.noteText) private var text",
                    "var body: some View {",
                    "    Button(\"フォーカスのあるメモを消す\") { text = \"\" }",
                    "        .disabled(text == nil)",
                    "}",
                    "",
                    "// 入力欄（ClearButton と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteText, $memoA)",
                ],
                withoutWrapper: [
                    "// ボタン（ClearButton）",
                    "@FocusedValue(\\.noteText) private var text  // Binding<String>?",
                    "var body: some View {",
                    "    Button(\"フォーカスのあるメモを消す\") { text?.wrappedValue = \"\" }",
                    "        .disabled(text == nil)",
                    "}",
                    "",
                    "// 入力欄（ClearButton と同じ画面）",
                    "TextField(\"メモ A\", text: $memoA)",
                    "    .focusedValue(\\.noteText, $memoA)",
                ])),
        build: { v in
            AnyView(FocusedBindingDemo(unwraps: v["FocusedBinding"] != nil))
        }
    )
}

private struct FocusedBindingDemo: View {
    let unwraps: Bool
    @State private var memoA = "りんごを買う"
    @State private var memoB = "ぶどうを買う"

    var body: some View {
        VStack(spacing: 8) {
            if unwraps {
                BindingButton()
            } else {
                ValueButton()
            }
            NoteField(title: "メモ A", text: $memoA)
                .focusedValue(\.demoNoteText, $memoA)
            NoteField(title: "メモ B", text: $memoB)
                .focusedValue(\.demoNoteText, $memoB)
        }
    }

    struct BindingButton: View {
        @FocusedBinding(\.demoNoteText) private var text

        var body: some View {
            Button("フォーカスのあるメモを消す") { text = "" }
                .buttonStyle(.bordered)
                .disabled(text == nil)
        }
    }

    struct ValueButton: View {
        /// Binding<String>?
        @FocusedValue(\.demoNoteText) private var text

        var body: some View {
            Button("フォーカスのあるメモを消す") { text?.wrappedValue = "" }
                .buttonStyle(.bordered)
                .disabled(text == nil)
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedSceneValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedSceneValue = CatalogEntry(
        id: "focusedSceneValue",
        kind: .modifier,
        topic: .focus,
        summary: "かけた View がシーン（窓）の中にあるあいだ、値を FocusedValues に出す modifier。フォーカスがどこにあっても（なくても）読める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedscenevalue(_:_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "focusedSceneValue", .fixed(code: "\\.noteTitle, \"メモ帳\""), on: true,
                summary: "出す値の key path と値。入力欄を選ばなくても、上の札に出る。シーンぜんたいに効くので、全画面で試す")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    NoteTitleLabel()  // @FocusedValue(\\.noteTitle) を出す\n    TextField(\"メモ\", text: $memo)\n}",
            closing: ["", "extension FocusedValues {", "    @Entry var noteTitle: String?", "}"]),
        build: { v in
            AnyView(
                FocusedSceneValueDemo().apply(v["focusedSceneValue"]) { view, _ in
                    view.focusedSceneValue(\.demoNoteTitle, "メモ帳")
                })
        }
    )
}

private struct FocusedSceneValueDemo: View {
    @State private var memo = ""

    var body: some View {
        VStack(spacing: 8) {
            TitleReader()
            NoteField(title: "メモ", text: $memo)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }

    struct TitleReader: View {
        @FocusedValue(\.demoNoteTitle) private var title

        var body: some View {
            FocusReadout(title: "読めた題名", value: title)
        }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedObjectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedObject = CatalogEntry(
        id: "focusedObject",
        kind: .modifier,
        topic: .focus,
        summary: "フォーカスがこの View（か、その中）にあるあいだ、ObservableObject を出す modifier。ほかの View は @FocusedObject で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedobject(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusedObject", .fixed(code: "noteA"), on: true,
                summary: "出す物（ObservableObject）。外すと、メモ A を選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    NoteLabel()  // @FocusedObject var note: Note? を出す"], call: "TextField",
            fixedArguments: ["\"メモ A\"", "text: $noteA.title"],
            closing: ["    TextField(\"メモ B\", text: $noteB.title)", "        .focusedObject(noteB)", "}"]),
        build: { v in
            AnyView(FocusedObjectDemo(exposesA: v["focusedObject"] != nil))
        }
    )
}

private struct FocusedObjectDemo: View {
    let exposesA: Bool
    @StateObject private var noteA = DemoNote("")
    @StateObject private var noteB = DemoNote("")

    var body: some View {
        VStack(spacing: 8) {
            FocusedNoteReader()
            NoteField(title: "メモ A", text: $noteA.title)
                .apply(exposesA ? () : nil) { view, _ in view.focusedObject(noteA) }
            NoteField(title: "メモ B", text: $noteB.title)
                .focusedObject(noteB)
        }
    }
}

/// @FocusedObject で読んだメモの題名を出す札
struct FocusedNoteReader: View {
    @FocusedObject private var note: DemoNote?

    var body: some View {
        FocusReadout(title: "フォーカスのあるメモ", value: note.map { $0.title.isEmpty ? "（空）" : $0.title })
    }
}
```

`WidgetLab/Catalog/Focus/FocusedSceneObjectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedSceneObject = CatalogEntry(
        id: "focusedSceneObject",
        kind: .modifier,
        topic: .focus,
        summary: "かけた View がシーン（窓）の中にあるあいだ、ObservableObject を出す modifier。フォーカスがどこにあっても（なくても）読める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedsceneobject(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "focusedSceneObject", .fixed(code: "notebook"), on: true,
                summary: "出す物（ObservableObject）。入力欄を選ばなくても、上の札に出る。シーンぜんたいに効くので、全画面で試す")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    NoteLabel()  // @FocusedObject var note: Note? を出す\n    TextField(\"題名\", text: $notebook.title)\n}"
        ),
        build: { v in
            AnyView(FocusedSceneObjectDemo(exposes: v["focusedSceneObject"] != nil))
        }
    )
}

private struct FocusedSceneObjectDemo: View {
    let exposes: Bool
    @StateObject private var notebook = DemoNote("メモ帳")

    var body: some View {
        VStack(spacing: 8) {
            FocusedNoteReader()
            NoteField(title: "題名", text: $notebook.title)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .apply(exposes ? () : nil) { view, _ in view.focusedSceneObject(notebook) }
    }
}
```

`WidgetLab/Catalog/Focus/FocusedObjectWrapperEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedObjectWrapper = CatalogEntry(
        id: "FocusedObject",
        kind: .propertyWrapper,
        topic: .focus,
        summary: "フォーカスのある View（か、その親）が .focusedObject で出した ObservableObject を読む。中身が変わっても描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/focusedobject")!,
        stage: .card,
        properties: [
            .wrapper("FocusedObject", summary: "外すと、どのメモを選んでも上の札は「なし」のまま")
        ],
        code: CodeTemplate(
            call: "FocusedObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 札（NoteLabel）",
                    "@FocusedObject private var note: Note?",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(note?.title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $noteA.title)",
                    "    .focusedObject(noteA)",
                ],
                withoutWrapper: [
                    "// 札（NoteLabel）",
                    "private var note: Note? = nil  // フォーカスを見ない",
                    "var body: some View {",
                    "    Text(\"フォーカスのあるメモ: \\(note?.title ?? \"なし\")\")",
                    "}",
                    "",
                    "// 入力欄（NoteLabel と同じ画面）",
                    "TextField(\"メモ A\", text: $noteA.title)",
                    "    .focusedObject(noteA)",
                ])),
        build: { v in
            AnyView(FocusedObjectWrapperDemo(reads: v["FocusedObject"] != nil))
        }
    )
}

private struct FocusedObjectWrapperDemo: View {
    let reads: Bool
    @StateObject private var noteA = DemoNote("")
    @StateObject private var noteB = DemoNote("")

    var body: some View {
        VStack(spacing: 8) {
            if reads {
                FocusedNoteReader()
            } else {
                FocusReadout(title: "フォーカスのあるメモ", value: nil)
            }
            NoteField(title: "メモ A", text: $noteA.title)
                .focusedObject(noteA)
            NoteField(title: "メモ B", text: $noteB.title)
                .focusedObject(noteB)
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .focusedValue,
        .focusedValueWrapper,
        .focusedBinding,
        .focusedSceneValue,
        .focusedObject,
        .focusedSceneObject,
        .focusedObjectWrapper,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

Run: `python3 tools/catalog_progress.py focus`
Expected: 合計 13 / 13（抜け 0）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Focus/FocusedValueEntry.swift WidgetLab/Catalog/Focus/FocusedValueWrapperEntry.swift WidgetLab/Catalog/Focus/FocusedBindingEntry.swift WidgetLab/Catalog/Focus/FocusedSceneValueEntry.swift WidgetLab/Catalog/Focus/FocusedObjectEntry.swift WidgetLab/Catalog/Focus/FocusedSceneObjectEntry.swift WidgetLab/Catalog/Focus/FocusedObjectWrapperEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: フォーカスの収録 focusedValue・FocusedValue・FocusedBinding・focusedSceneValue・focusedObject・focusedSceneObject・FocusedObject

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 6: userActivity・onContinueUserActivity・onOpenURL・handlesExternalEvents・copyable・cuttable・pasteDestination と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/SystemEvents/UserActivityEntry.swift`
- Create: `WidgetLab/Catalog/SystemEvents/OnContinueUserActivityEntry.swift`
- Create: `WidgetLab/Catalog/SystemEvents/OnOpenURLEntry.swift`
- Create: `WidgetLab/Catalog/SystemEvents/HandlesExternalEventsEntry.swift`
- Create: `WidgetLab/Catalog/Clipboard/ClipboardDemo.swift`
- Create: `WidgetLab/Catalog/Clipboard/CopyableEntry.swift`
- Create: `WidgetLab/Catalog/Clipboard/CuttableEntry.swift`
- Create: `WidgetLab/Catalog/Clipboard/PasteDestinationEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（1 本足す）
- Modify: `docs/architecture.md`・`docs/cataloging-guide.md`

**Interfaces:**
- Consumes: 今の収録の型（変えない）
- Produces: 7 件の `CatalogEntry`、補助 `ClipboardDemo(command:)`。UI テスト `testDataEntriesShowPreview`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py system-events clipboard`
Expected: 終了コード 1。抜けに userActivity・onContinueUserActivity・onOpenURL・handlesExternalEvents・copyable・cuttable・pasteDestination がある

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/SystemEvents/UserActivityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let userActivity = CatalogEntry(
        id: "userActivity",
        kind: .modifier,
        topic: .systemEvents,
        summary: "この画面でしていること（NSUserActivity）を、システムに知らせる modifier。Handoff で別の端末から続けたり、Spotlight に出したりできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/useractivity(_:isactive:_:)")!,
        noteReason: "アプリの外で効く。Handoff で Mac や iPad に続きを渡すとき、Spotlight やSiri の提案に出すときに使う",
        properties: [
            .modifier(
                "userActivity", id: "userActivity.type", label: nil, .fixed(code: "\"com.example.memo.viewing\""),
                required: true, summary: "していることの種類（Info.plist の NSUserActivityTypes に書く）"),
            .modifier(
                "userActivity", id: "userActivity.isActive", label: "isActive", .toggle(initial: true), required: true,
                summary: "知らせるか"),
            .modifier(
                "userActivity", id: "userActivity.update", label: nil,
                .fixed(code: "{ activity in activity.title = memo.title }"), on: true,
                summary: "知らせる中身を書く関数"),
        ],
        code: CodeTemplate(call: "MemoScreen", fixedArguments: ["memo: memo"])
    )
}
```

`WidgetLab/Catalog/SystemEvents/OnContinueUserActivityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onContinueUserActivity = CatalogEntry(
        id: "onContinueUserActivity",
        kind: .modifier,
        topic: .systemEvents,
        summary: "アプリが受け取った「していること」（NSUserActivity）を受けて、処理を行う modifier。Handoff や Spotlight から開かれたときに呼ばれる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncontinueuseractivity(_:perform:)")!,
        noteReason: "アプリの外から呼ばれる。Handoff で別の端末から続けるときや、Spotlight の結果からアプリを開いたときに効く",
        properties: [
            .modifier(
                "onContinueUserActivity", id: "onContinueUserActivity.type", label: nil,
                .fixed(code: "\"com.example.memo.viewing\""), required: true, summary: "受け取る、していることの種類"),
            .modifier(
                "onContinueUserActivity", id: "onContinueUserActivity.perform", label: "perform",
                .fixed(code: "{ activity in openMemo(titled: activity.title) }"), on: true, summary: "受け取ったときの処理"),
        ],
        code: CodeTemplate(call: "ContentView")
    )
}
```

`WidgetLab/Catalog/SystemEvents/OnOpenURLEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onOpenURL = CatalogEntry(
        id: "onOpenURL",
        kind: .modifier,
        topic: .systemEvents,
        summary: "アプリが受け取った URL（独自の scheme・ユニバーサルリンク）を受けて、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onopenurl(perform:)")!,
        noteReason: "アプリの外から呼ばれる。ほかのアプリ・ウィジェット・Safari から、アプリの URL を開いたときに効く（URL の scheme を Info.plist に登録する）",
        properties: [
            .modifier(
                "onOpenURL", label: "perform", .fixed(code: "{ url in openMemo(at: url) }"), on: true,
                summary: "URL を受け取ったときの処理")
        ],
        code: CodeTemplate(call: "ContentView")
    )
}
```

`WidgetLab/Catalog/SystemEvents/HandlesExternalEventsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let handlesExternalEvents = CatalogEntry(
        id: "handlesExternalEvents",
        kind: .modifier,
        topic: .systemEvents,
        summary: "外からの URL や NSUserActivity を、すでに開いているどのシーン（窓）で受けるかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/handlesexternalevents(preferring:allowing:)"
        )!,
        noteReason: "窓（シーン）を 2 つ以上開けるときに効く。iPhone はいつも窓が 1 つなので変わらない。iPad と Mac で、どの窓で受けるかを選ぶ",
        properties: [
            .modifier(
                "handlesExternalEvents", id: "handlesExternalEvents.preferring", label: "preferring",
                .fixed(code: "[\"memo\"]"), on: true, summary: "この窓で受けたいもの（URL や種類の文字列の一部）"),
            .modifier(
                "handlesExternalEvents", id: "handlesExternalEvents.allowing", label: "allowing",
                .fixed(code: "[\"*\"]"),
                required: true, summary: "この窓で受けてよいもの"),
        ],
        code: CodeTemplate(call: "MemoScreen")
    )
}
```

`WidgetLab/Catalog/Clipboard/ClipboardDemo.swift`:

```swift
import SwiftUI

/// clipboard の収録で使う見本。果物の札にフォーカスを当て、キーボードの ⌘C・⌘X・⌘V で試す
struct ClipboardDemo: View {
    enum Command { case copy, cut, paste }

    /// nil なら modifier をかけない
    let command: Command?
    @State private var fruits = ["りんご", "ぶどう"]
    @FocusState private var isFocused: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        VStack(spacing: 8) {
            Button("札にフォーカス") { isFocused = true }
                .buttonStyle(.bordered)
            Text(fruits.isEmpty ? "（空）" : fruits.joined(separator: "・"))
                .padding(8)
                .background(isFocused ? Color.yellow : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
                .focusable()
                .focused($isFocused)
                .apply(command) { view, command in
                    switch command {
                    case .copy:
                        view.copyable(copied())
                    case .cut:
                        view.cuttable(for: String.self) {
                            let cut = fruits
                            fruits = []
                            recorder?.log("\(cut.joined(separator: "・")) を切り取った")
                            return cut
                        }
                    case .paste:
                        view.pasteDestination(for: String.self) { items in
                            fruits += items
                            recorder?.log("\(items.joined(separator: "・")) を貼り付けた")
                        }
                    }
                }
        }
    }

    /// コピーされるときに呼ばれる（copyable は値を後から作る）
    private func copied() -> [String] {
        recorder?.log("\(fruits.joined(separator: "・")) をコピーした")
        return fruits
    }
}
```

`WidgetLab/Catalog/Clipboard/CopyableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let copyable = CatalogEntry(
        id: "copyable",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「コピー」の操作で、クリップボードに入れる物を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/copyable(_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "copyable", .fixed(code: "fruits"), on: true,
                summary: "コピーする物（Transferable の配列）。札にフォーカスを当て、キーボードの ⌘C でコピーする（iPhone ではハードウェアキーボードをつなぐ）")
        ],
        code: CodeTemplate(
            prefix: ["Text(fruits.joined(separator: \"・\"))"], indent: 4, call: ".focusable"),
        build: { v in
            AnyView(ClipboardDemo(command: v["copyable"] != nil ? .copy : nil))
        }
    )
}
```

`WidgetLab/Catalog/Clipboard/CuttableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let cuttable = CatalogEntry(
        id: "cuttable",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「切り取り」の操作で、クリップボードに移す物を返す処理を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/cuttable(for:action:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "cuttable", id: "cuttable.for", label: "for", .fixed(code: "String.self"), required: true,
                summary: "移す物の型（Transferable）"),
            .modifier(
                "cuttable", id: "cuttable.action", label: "action",
                .fixed(code: "{ let cut = fruits; fruits = []; return cut }"), on: true,
                summary: "移す物を返し、元から消す処理。札にフォーカスを当て、キーボードの ⌘X で切り取る（iPhone ではハードウェアキーボードをつなぐ）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(fruits.joined(separator: \"・\"))"], indent: 4, call: ".focusable"),
        build: { v in
            AnyView(ClipboardDemo(command: v["cuttable.action"] != nil ? .cut : nil))
        }
    )
}
```

`WidgetLab/Catalog/Clipboard/PasteDestinationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let pasteDestination = CatalogEntry(
        id: "pasteDestination",
        kind: .modifier,
        topic: .clipboard,
        summary: "システムの「貼り付け」の操作で、クリップボードの物を受け取る処理を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/pastedestination(for:action:validator:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "pasteDestination", id: "pasteDestination.for", label: "for", .fixed(code: "String.self"),
                required: true, summary: "受け取る物の型（Transferable）"),
            .modifier(
                "pasteDestination", id: "pasteDestination.action", label: "action", .fixed(code: "{ fruits += $0 }"),
                on: true, summary: "受け取ったときの処理。札にフォーカスを当て、キーボードの ⌘V で貼り付ける（iPhone ではハードウェアキーボードをつなぐ）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(fruits.joined(separator: \"・\"))"], indent: 4, call: ".focusable"),
        build: { v in
            AnyView(ClipboardDemo(command: v["pasteDestination.action"] != nil ? .paste : nil))
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .userActivity,
        .onContinueUserActivity,
        .onOpenURL,
        .handlesExternalEvents,
        .copyable,
        .cuttable,
        .pasteDestination,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す。フォーカスで値が届く focusedValue と、印を描く anchorPreference を撮る:

```swift
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
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「レイアウト・描画・テキスト・操作の部品・スタイルと動き・一覧とスクロール・画面の行き来の代表 2 件ずつのスクリーンショットの 11 本」を、「レイアウト・描画・テキスト・操作の部品・スタイルと動き・一覧とスクロール・画面の行き来・データとフォーカスの代表 2 件ずつのスクリーンショットの 12 本」に置き換える（ほかの束が先に本数を変えていたら、その並びに「データとフォーカス」を足し、本数に 1 を足す）

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 3 か所だけ直す（ほかの行は変えない）。ほかの束が先に同じ行を直していたら、その行に束 9 の分を足す。

1. 5 章の「束 7 は `testNavigationEntriesShowPreview`）。」を「束 7 は `testNavigationEntriesShowPreview`、束 9 は `testDataEntriesShowPreview`）。」に置き換える
2. 7 章の最後の段落（`## 用語` の前）のあとに、空行を挟んで次の段落を足す:

```markdown
**大文字と小文字だけ違う id がある → プロパティラッパーの側に `Wrapper` を付ける。** `environmentObject` と `EnvironmentObject` のように、modifier とプロパティラッパーの id が頭の文字だけ違うと、`static let` の名前がぶつかり、macOS のファイルの名前（大文字と小文字を区別しない）もぶつかる。modifier は決まりどおり（`environmentObject`・`EnvironmentObjectEntry.swift`）にし、プロパティラッパーは `environmentObjectWrapper`・`EnvironmentObjectWrapperEntry.swift` にする（束 9）。

**比べるの画像は、左半分が「付けない」、右半分が「付けた」の合成になる → 違いを仕切りにまたがせる。** 印を付ける子を真ん中に置くと、仕切りで印が半分に切れて違いが見える（束 9 の `anchorPreference` の「ぶどう」）。付けた側だけに出る値は右に寄せる（`defaultAppStorage` の数、`environmentObject` の「テーマ: 夜」）。

**シーンぜんたいに値を出すもの → `.full` にする。** `focusedSceneValue`・`focusedSceneObject` を `.card` にすると、比べるの左（付けない側）の札にも値が届き、一覧の行からも届いた。全画面で開けば、「付けない」に切り替えたときに値が消える（束 9）。

**見本の init で記録の窓口に書かない。** 子を作るたびに `recorder?.log` を書いたら、記録の表示の描き直しが続いて UI テストが止まった。記録はボタンを押したときなど、操作のときに書く（束 9 の `StateObject`）。

**保存先ごとに初めの値を変えたい → `set(_:forKey:)` で書く。** `UserDefaults.register(defaults:)` の値は、どの保存先（`standard` も）からも見えるので、付けない側も同じ値になった（束 9 の `defaultAppStorage`）。

**クリップボードの modifier → キーボードの ⌘C・⌘X・⌘V で試す。** `copyable`・`cuttable`・`pasteDestination` は、iOS 27.0 の iPhone でも、フォーカスのある View でハードウェアキーボードの操作に応える（シミュレータは Mac のキーボード）。長押しでは編集メニューは出ない。UI テストでは `typeKey("c", modifierFlags: .command)` で試せる。見本は `.focusable()` の札に `@FocusState` でフォーカスを当てる（束 9）。

**iPhone では効かなかったフォーカスの modifier（束 9 で `.note` にした）:** `defaultFocus`（はじめのフォーカスが決まらず、`@FocusState` は nil のまま）、`focusEffectDisabled`（iPhone にはフォーカスの輪が出ない）。`focusable` は、ボタンから `@FocusState` でフォーカスを当てられることで見せられたので `.card` にした。
```

3. 最後の行「最終更新: 2026-11-04（束 2〜7 のあと）」を「最終更新: 2026-11-04（束 2〜7・9 のあと）」に置き換える

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テストが全部通る

Run: `python3 tools/catalog_progress.py model-data environment-values preferences persistent-storage focus system-events clipboard`
Expected: 終了コード 0。`合計 43 / 43（抜け 0）`（収録済みの State・Binding を含む）

- [ ] **Step 7: コミットする**

```bash
git add WidgetLab/Catalog/SystemEvents/UserActivityEntry.swift WidgetLab/Catalog/SystemEvents/OnContinueUserActivityEntry.swift WidgetLab/Catalog/SystemEvents/OnOpenURLEntry.swift WidgetLab/Catalog/SystemEvents/HandlesExternalEventsEntry.swift WidgetLab/Catalog/Clipboard/ClipboardDemo.swift WidgetLab/Catalog/Clipboard/CopyableEntry.swift WidgetLab/Catalog/Clipboard/CuttableEntry.swift WidgetLab/Catalog/Clipboard/PasteDestinationEntry.swift WidgetLab/Catalog/Catalog.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md
git commit -m "feat: システムのイベントとクリップボードの収録 userActivity・onContinueUserActivity・onOpenURL・handlesExternalEvents・copyable・cuttable・pasteDestination と束の確かめ

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

## 終わったら

- 束の最終レビュー（opus）を通す
- `~/dev/widget-lab`（main）で、`git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からある）で、ほかの束がマージの途中でないことを確かめてから、`git merge --no-ff feat/swiftui-p3-data` する。`Catalog.swift`・`docs/architecture.md`・`docs/cataloging-guide.md`・`WidgetLabUITests/LaunchUITests.swift` がぶつかったら両方の行を残す
- マージのあと、main の `swiftui/` で lint と単体テスト（Global Constraints の確かめのコマンド）を通してから push する。ブランチは消さない
