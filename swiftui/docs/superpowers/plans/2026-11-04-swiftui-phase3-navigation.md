# SwiftUI 版 Phase 3 束 7（画面の行き来）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 詳細画面の「試す」から全画面で開く `.full` の仕組みを作り、modal-presentations・navigation の 49 件を収録して、2 トピックの抜けを 0 にする。

**Architecture:** Task 1 で、`.full` の収録を全画面で試す仕組みを詳細画面（`Features/Detail/`）に足す。状態は `DetailViewModel` に持ち、収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。Task 2〜8 で、1 件 = 1 ファイルの収録データを 5〜8 件ずつ足し、`Catalog.all` に並べる。複数の収録で使う補助（`NavigationDemo`・`ModalDemo`）はトピックのフォルダに置く。stage は `.card` が 19 件、`.full` が 11 件、`.note` が 19 件。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 7 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）。`.full` の仕組みは全体の spec（`2026-10-31-swiftui-app-design.md`）の「詳細」の節（「`.full` のものは、プレビューの「試す」から全画面で開く」）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone 18 Pro**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` は、この束では `name=iPhone 18 Pro` に置き換える（並列で動く束 5・6 とシミュレータを分けるため）
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
       -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests
  ```
  UI テストまで通すのは Task 1 と Task 8 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## `.full` の仕組み（Task 1。2026-11-04 オーナーが了承）

詳細画面は束をまたぐ共通の画面なので、作り方をここに書き、オーナーの了承を得た（2026-11-04）。`preferredColorScheme` の癖は直さず、手引きに書いて残す。

### 動き

1. 詳細のプレビューの枠に、`.full` の収録だけ見本を描かず、縦長の画面の印・「画面ぜんたいで動くので、全画面で開いて試します」・「試す」のボタンを出す。枠の右下の「比べる」は出さない
2. 「試す」を押すと、`fullScreenCover` で見本を画面いっぱいに出す。見本は今のプロパティの値（ON のものだけ）で組み立てる
3. 全画面の下に帯を 1 本置く。左に、選んでいるプロパティの「付けない｜付けた」の切り替え（セグメント）、右に「閉じる」。選んでいるプロパティが required なら切り替えは出さない（比べるのと同じ決まり）
4. 開くたびに「付けた」から始める。切り替えるたびに見本を作り直す（`demoGeneration` を見本の id にする）
5. 「閉じる」で詳細に戻る。値を変えたいときは、詳細でチップと編集パネルを使い、もう一度「試す」を押す
6. 一覧の行は今までどおり絵（`rectangle.portrait`）にする。チップ・編集パネル・コードは `.card` と同じに動く

試作（iPhone 18 Pro）で見たこと:

- `NavigationStack`・`TabView`・`NavigationSplitView` の見本は、詳細の NavigationStack の入れ子にならず、ナビゲーションバーとタブバーがふつうに出た
- 束 3 で `.full` にした `statusBarHidden` は、全画面ではステータスバーが消えた（押し込んだ詳細画面では消えなかった）
- `preferredColorScheme(.dark)` は全画面だけが暗くなり、閉じると詳細は明るいまま戻った。ただし、全画面のまま「付けない」に切り替えても暗いままになる（表示の単位が最後の値を覚えている）。この 1 件だけの癖として、手引きに書いて残す

### 作り

| ファイル | 変えること |
|---|---|
| `Features/Detail/ViewModel/DetailViewModel.swift` | `isTryingFull`（全画面で開いているか。開くたびに `trialShowsWith = true` にし、見本を作り直す）・`trialShowsWith`（付けた側か）・`trialValues`（付けない側なら選んでいるプロパティだけ外した値）を足す。`reset()` で `trialShowsWith` を戻す |
| `Features/Detail/UI/PreviewArea.swift` | `.full` のとき `FullLauncher`（「試す」）を出し、比べるの切り替えを隠す。`fullScreenCover` で `FullTrialScreen`（上に見本、下に帯）を出す |
| `WidgetLabTests/Features/Detail/DetailViewModelTests.swift` | 3 本足す（付けない側は選んだプロパティだけ外れる・開き直すと付けた側から・required は外れない） |
| `WidgetLabUITests/LaunchUITests.swift` | 1 本足す（`statusBarHidden` を「試す」で開き、付けないに切り替え、閉じると詳細に戻る） |
| `docs/architecture.md`・`docs/cataloging-guide.md` | `.full` の説明を「動く」に直す |

状態を ViewModel に持つのは、比べる（`isComparing`）と同じく、プレビュー・チップ・コードの値と同じ所から全画面の値を作るため。全画面の画面は `PreviewArea` の中だけで使うので、`private` の型にする。

### 選ばなかった案

| 案 | 選ばなかった理由 |
|---|---|
| 枠の中に見本を描いたまま、「試す」も足す | NavigationStack の入れ子（詳細の中にもう 1 つ）になり、`preferredColorScheme` は詳細を開いただけで効く。束 3 で `.full` にした理由がそのまま残る |
| 閉じる・切り替えのボタンを見本の上に浮かせる | 下はタブバー、上はナビゲーションバーとステータスバーに重なり、見本の効き目を隠す |
| 全画面の中に編集パネルも出す | 見本が狭くなり、画面ぜんたいに効くものを試す意味が薄れる。値は詳細で変えれば足りる |
| 全画面で、左右に「付けない」「付けた」を並べる | 画面ぜんたいに効くもの（タブバー・ステータスバー）は、半分の幅では再現できない |

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。プロパティはチップの順。* は最初から ON、R は required。

### navigation（18 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| NavigationStack | .full | View | path*（`$path`）・.tint | `NavigationStack(path: $path) { List … .navigationDestination(for: String.self) … .toolbar { Button("ぶどうの先まで") { path = […] } } }` |
| NavigationLink | .full | View | title R・value R（`"りんご"`）・.disabled・.tint | `NavigationStack { VStack { NavigationLink("りんごを見る", value: "りんご") } .navigationDestination(…) }` |
| NavigationView | .full | View | .navigationViewStyle*（.automatic・.stack） | `NavigationView { List { NavigationLink(name) { Text(name) } }.navigationTitle("果物") }.navigationViewStyle(.stack)` |
| NavigationSplitView | .full | View | preferredCompactColumn*（.sidebar・.detail）・.navigationSplitViewStyle | `NavigationSplitView(preferredCompactColumn: .constant(.detail)) { List(…, selection:) } detail: { … }` |
| navigationTitle | .full | 付け外し | .navigationTitle*（文字） | `NavigationStack { List(fruits…) { NavigationLink }.navigationTitle("果物") }` |
| navigationSubtitle | .full | 付け外し | .navigationSubtitle*（文字） | 同じ形で `.navigationSubtitle("3 件")` と `.navigationTitle("果物")`（suffix） |
| navigationDocument | .full | 付け外し | .navigationDocument*（URL 固定） | `NavigationStack { Text("題名を押す").navigationDocument(URL(…)!) .navigationTitle .toolbarTitleMenu { … } }` |
| navigationBarBackButtonHidden | .full | 付け外し（入れ子） | .navigationBarBackButtonHidden* | 進んだ先の `FruitScreen(name: name).navigationBarBackButtonHidden(true)`。見本は代わりの「一覧に戻る」ボタンを置く |
| navigationBarTitleDisplayMode | .full | 付け外し | .navigationBarTitleDisplayMode*（3 つ） | `….navigationBarTitleDisplayMode(.inline)` と `.navigationTitle("果物")` |
| TabView | .full | View | .tabViewStyle*（.automatic・.sidebarAdaptable・.page）・.tint | `TabView { Tab("ホーム") … Tab("一覧") … Tab("設定") … }.tabViewStyle(.automatic)` |
| defaultAdaptableTabBarPlacement | .note | 付け外し | .defaultAdaptableTabBarPlacement*（3 つ） | `TabView { … }.tabViewStyle(.sidebarAdaptable).defaultAdaptableTabBarPlacement(.sidebar)` |
| defaultTabBarPlacement | .note | 付け外し | .defaultTabBarPlacement*（3 つ） | `TabView { … }.tabViewStyle(.sidebarAdaptable).defaultTabBarPlacement(.sidebar)` |
| tabViewSidebarHeader | .note | 付け外し | .tabViewSidebarHeader(content:)* | `TabView { Tab; TabSection { … } }.tabViewStyle(.sidebarAdaptable).tabViewSidebarHeader(content: { Text("ようこそ") … })` |
| tabViewSidebarFooter | .note | 付け外し | .tabViewSidebarFooter(content:)* | 同じ形で `Text("v1.0")` |
| tabViewSidebarBottomBar | .note | 付け外し | .tabViewSidebarBottomBar(content:)* | 同じ形で `Button("アカウント", systemImage: "person.circle")` |
| tabBarMinimizeBehavior | .full | 付け外し | .tabBarMinimizeBehavior*（4 つ、最初は .onScrollDown） | `TabView { … }.tabBarMinimizeBehavior(.onScrollDown)`。「一覧」のタブでスクロールして見る |
| sectionActions | .card | 付け外し（入れ子） | .sectionActions(content:)* | `List { Section("果物") { Text…; Text… }.sectionActions(content: { Button("果物を足す", systemImage: "plus") { } }) }` |
| tabViewCustomization | .note | 付け外し | .tabViewCustomization*（`$customization`） | `TabView { Tab.customizationID("home"); TabSection { … }.customizationID("fruits") }.tabViewStyle(.sidebarAdaptable).tabViewCustomization($customization)` |

### modal-presentations（31 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| sheet | .card | 付け外し | .sheet*（isPresented・onDismiss も渡す） | `Button("シートを開く") { shows = true }.sheet(isPresented: $shows, onDismiss: { closed += 1 }, content: { … })` |
| fullScreenCover | .card | 付け外し | .fullScreenCover*（isPresented・onDismiss も渡す） | `Button("全画面で開く") { … }.fullScreenCover(isPresented: $shows, content: { CoverContent() })` と `struct CoverContent`（閉じるボタン） |
| popover | .card | 付け外し | .popover*（isPresented・arrowEdge: .top・.bottom） | `Button("吹き出しを出す") { … }.popover(isPresented: $shows, content: { PopoverContent() })` と `struct PopoverContent`（`.presentationCompactAdaptation(.popover)` 込み） |
| presentationCompactAdaptation | .card | 付け外し（入れ子） | .presentationCompactAdaptation*（5 つ、最初は .popover） | `Button.popover(isPresented: $shows) { Text("吹き出しの中身").presentationCompactAdaptation(.popover) }` |
| presentationSizing | .note | 付け外し（入れ子） | .presentationSizing*（4 つ、最初は .fitted） | `Button.sheet(isPresented: $shows) { Text("シートの中身").presentationSizing(.fitted) }` |
| presentationDetents | .card | 付け外し（入れ子） | .presentationDetents*（4 つ、最初は [.medium, .large]） | 同じ形で `.presentationDetents([.medium, .large])` |
| presentationContentInteraction | .card | 付け外し（入れ子） | .presentationContentInteraction*（3 つ、最初は .scrolls） | `….sheet { List(1...30) { … }.presentationContentInteraction(.scrolls).presentationDetents([.medium, .large]) }` |
| presentationDragIndicator | .card | 付け外し（入れ子） | .presentationDragIndicator*（3 つ、最初は .visible） | `….sheet { Text.presentationDragIndicator(.visible).presentationDetents([.medium]) }` |
| presentationPlacement | .note | 付け外し（入れ子） | .presentationPlacement*（4 つ、最初は .leading） | 同じ形で `.presentationPlacement(.leading)` |
| presentationCornerRadius | .card | 付け外し（入れ子） | .presentationCornerRadius*（0〜60、最初は 0） | 同じ形で `.presentationCornerRadius(0)` |
| presentationBackground | .card | 付け外し（入れ子） | .presentationBackground*（.yellow・.ultraThinMaterial・.blue.gradient・.clear） | 同じ形で `.presentationBackground(.yellow)` |
| presentationBackgroundInteraction | .card | 付け外し（入れ子） | .presentationBackgroundInteraction*（4 つ、最初は .enabled） | `VStack { Button("+1: \(count)"); Button("シートを開く").sheet { Text.presentationBackgroundInteraction(.enabled).presentationDetents([.height(200), .large]) } }`。シートを出したまま +1 を押せる |
| alert | .card | 付け外し | .alert*（OK だけ・削除と取り消し） | `Button("アラートを出す") { … }.alert("削除しますか？", isPresented: $shows, actions: { … }, message: { … })` |
| confirmationDialog | .card | 付け外し | .confirmationDialog の 5 つの引数（title R・isPresented R・titleVisibility*・actions R・message*） | `Button("写真を変える") { … }.confirmationDialog("写真を変える", isPresented: $shows, titleVisibility: .visible, actions: { … }, message: { … })` |
| dismissalConfirmationDialog | .note | 付け外し（入れ子） | .dismissalConfirmationDialog*（固定） | `….sheet { TextField("メモ", text: $memo).dismissalConfirmationDialog("書きかけを捨てますか？", shouldPresent: !memo.isEmpty, actions: { … }) }` |
| dialogIcon | .note | 付け外し | .dialogIcon*（`Image(systemName: "trash")`） | `Button("削除").confirmationDialog(…) { … }.dialogIcon(Image(systemName: "trash"))` |
| dialogSuppressionToggle | .note | 付け外し | .dialogSuppressionToggle*（固定） | `Button("削除").alert(…) { … }.dialogSuppressionToggle("今後は確かめない", isSuppressed: $suppressed)` |
| fileExporter | .card | 付け外し | .fileExporter の 6 つの引数（isPresented R・item R・contentTypes*・defaultFilename*・onCompletion R・onCancellation R） | `Button("書き出す") { … }.fileExporter(isPresented: $shows, item: "買い物: 牛乳・卵", contentTypes: [.plainText], defaultFilename: "買い物メモ", onCompletion: { … }, onCancellation: { … })` |
| fileExporterFilenameLabel | .note | 付け外し | .fileExporterFilenameLabel*（固定） | `Button("書き出す").fileExporter(…) { _ in }.fileExporterFilenameLabel(Text("メモの名前"))` |
| fileImporter | .card | 付け外し | .fileImporter の 4 つの引数（isPresented R・allowedContentTypes*（3 つ）・allowsMultipleSelection・onCompletion R） | `Button("ファイルを選ぶ") { … }.fileImporter(isPresented: $shows, allowedContentTypes: [.image], onCompletion: { … })` |
| fileMover | .card | 付け外し | .fileMover*（固定） | `Button("メモを動かす") { … }.fileMover(isPresented: $shows, file: memoURL, onCompletion: { … })`。押すたびに一時フォルダにファイルを作る |
| fileDialogBrowserOptions | .note | 付け外し | .fileDialogBrowserOptions*（3 つ） | `Button("ファイルを選ぶ").fileImporter(…) { _ in }.fileDialogBrowserOptions(.includeHiddenFiles)` |
| fileDialogConfirmationLabel | .note | 付け外し | .fileDialogConfirmationLabel*（文字） | 同じ形で `.fileDialogConfirmationLabel("読み込む")` |
| fileDialogCustomizationID | .note | 付け外し | .fileDialogCustomizationID*（文字） | 同じ形で `.fileDialogCustomizationID("memoImport")` |
| fileDialogDefaultDirectory | .card | 付け外し | .fileDialogDefaultDirectory*（`URL.documentsDirectory`） | `Button("ファイルを選ぶ") { … }.fileImporter(…) { _ in }.fileDialogDefaultDirectory(URL.documentsDirectory)`。付けると「この iPhone 内」から、付けないと「最近使った項目」から開く |
| fileDialogImportsUnresolvedAliases | .note | 付け外し | .fileDialogImportsUnresolvedAliases* | 同じ形で `.fileDialogImportsUnresolvedAliases(true)` |
| fileDialogMessage | .note | 付け外し | .fileDialogMessage*（固定） | 同じ形で `.fileDialogMessage(Text("読み込むメモを選んでください"))` |
| fileDialogURLEnabled | .note | 付け外し | .fileDialogURLEnabled*（固定） | 同じ形で `.fileDialogURLEnabled(#Predicate<URL> { … })` |
| inspector | .card | 付け外し | .inspector*（固定） | `Button("インスペクタを出す") { shows.toggle() }.inspector(isPresented: $shows, content: { … })`。iPhone ではシートで出る |
| inspectorColumnWidth | .note | 付け外し（入れ子） | .inspectorColumnWidth*（200〜400） | `Text("本文").inspector(isPresented: $shows) { Text("詳しい設定").inspectorColumnWidth(300) }` |
| interactiveDismissDisabled | .card | 付け外し（入れ子） | .interactiveDismissDisabled* | `….sheet { Text("閉じるボタンでだけ閉じる").interactiveDismissDisabled(true) }` |

### `.full` にするもの（11 件）と理由

画面の行き来の入れ物（NavigationStack・NavigationView・NavigationSplitView・TabView）と、その中の画面にかける modifier（ナビゲーションバー・タブバーに効くもの）。枠の中に描くと、詳細の NavigationStack の中にもう 1 つ入れ子になり、題名やバーが詳細のものと混ざる。全画面で開けば、表示の単位がひとつになり、バーもふつうに出る。

NavigationStack・NavigationLink・NavigationView・NavigationSplitView・navigationTitle・navigationSubtitle・navigationDocument・navigationBarBackButtonHidden・navigationBarTitleDisplayMode・TabView・tabBarMinimizeBehavior

画面を重ねて出すもの（sheet・alert など）は `.card` にした。ボタンを押すと、詳細の画面の上にシートなどが出る。比べるでは、仕切りの右（付けた側）のボタンを押したときだけ出るので、違いが見える。

### `.note` にするもの（19 件、39%）と理由

| id | 理由（`noteReason`） |
|---|---|
| defaultAdaptableTabBarPlacement | iPad だけで効く（タブバーとサイドバーを切り替えられるのが iPad だけのため）。iPhone では defaultTabBarPlacement を使う |
| tabViewSidebarHeader | iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る |
| tabViewSidebarFooter | iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る |
| tabViewSidebarBottomBar | iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る |
| tabViewCustomization | iPhone ではタブを並べ替えたり隠したりできない。iPad と Mac のサイドバーで、タブを並べ替えた結果を覚える |
| presentationSizing | iPhone ではシートがいつも幅いっぱいに出るので、大きさは変わらない。iPad と Mac で、シートの大きさが変わる |
| presentationPlacement | iPhone ではシートがいつも幅いっぱいに出るので、置く場所は変わらない。iPad など幅の広い画面で、シートを端に寄せる |
| dismissalConfirmationDialog | iOS では窓（シーン）を閉じる操作で出る。iPhone でシートを指で下げても出なかった。iPad で窓を閉じるときや、Mac で効く |
| dialogIcon | iPhone では見た目が変わらない。Mac ではアプリのアイコンの代わりに、Apple Watch ではダイアログの中に出る |
| dialogSuppressionToggle | iPhone ではチェックが出ない。Mac のダイアログで効く |
| fileExporterFilenameLabel | iPhone では見た目が変わらない。Mac の保存のダイアログで、名前の欄の見出しが変わる |
| fileDialogBrowserOptions | iPhone では効かない。Mac のファイルのダイアログで、隠しファイルなどの出し方が変わる |
| fileDialogConfirmationLabel | iPhone では見た目が変わらない。Mac のファイルのダイアログで、決めるボタンの文が変わる |
| fileDialogCustomizationID | iPhone では効かない。Mac のファイルのダイアログで、大きさや開いていたフォルダを覚える |
| fileDialogImportsUnresolvedAliases | iPhone では効かない。Mac のファイルのダイアログで、エイリアス（別名）を選んだときに効く |
| fileDialogMessage | iPhone では見た目が変わらない。Mac のファイルのダイアログで、上に説明の文が出る |
| fileDialogURLEnabled | iPhone では効かない。Mac のファイルのダイアログで、条件に合わないファイルが選べなくなる |
| inspectorColumnWidth | iPhone ではインスペクタがシートで出るので、幅は効かない。iPad と Mac で、右の列として出るときに効く |

この束で `.note` が 19 件になり、収録の全体（main の 168 件と、この束の 49 件）で 28 / 217 = 13% になる。手引きの約束（`.note` が全体の 1 割を超えたら ADR-0002 を見直す）に当たるので、オーナーに確かめ、このまま `.note` で収録し、ADR-0002 に数え方の見直しを足すことにした（2026-11-04 オーナーが決定。Task 8）。19 件は、iPad・Mac だけで出る列やサイドバー（9 件）と、Mac のファイルのダイアログ（7 件）と、iPhone では効かないダイアログ（3 件）で、アプリの画面を足しても iPhone では見せられない。見直しでは、1 割の数え方から「iPhone では効かないと公式か試作で確かめたもの」を外し、iPhone で見せる工夫が足りずに `.note` にしたものだけを数える。

### 試作でわかったこと（Task 8 で収録の手引きに足す）

- **画面を重ねて出すもの（sheet・alert・popover・fileImporter など）は `.card` で見せられる。** 見本はボタンにし、押すと詳細の画面の上に出る。シートの中身にかける modifier（`presentationDetents` など）は、`ModalDemo.swift` の `SheetModifierDemo` で開き、コードは `CodeTemplate.inSheet()` の形（`Button` → `.sheet {` → 中身の `Text` に modifier）にした
- **画面の行き来の入れ物は `.full` にする。** 枠の中では NavigationStack の入れ子になる。全画面で開けば、題名・戻るボタン・タブバーがふつうに出る
- **iPhone では出ないもの:** TabView のサイドバー（`defaultTabBarPlacement(.sidebar)` でも、iOS 27.0 の iPhone 18 Pro ではタブバーのまま）、シートの大きさと置き場所（`presentationSizing`・`presentationPlacement`。iPhone のシートはいつも幅いっぱい）、`dismissalConfirmationDialog`（シートを下げても出なかった）
- **システムのファイルの画面は、出るまで数秒かかる。** UI テストで撮るときは、押してから 5 秒ほど待つ
- **`sectionActions` は、TabView のサイドバーでなく、List の Section でも効く。** iOS では Section の中身の後ろにボタンの行が足される
- **`preferredColorScheme` は、全画面のまま「付けない」に切り替えても暗いまま。** 表示の単位が最後の値を覚えている。閉じると詳細は元の見た目に戻る

---
### Task 1: `.full` を全画面で試す仕組み

**Files:**
- Modify: `WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`
- Modify: `WidgetLab/Features/Detail/UI/PreviewArea.swift`
- Test: `WidgetLabTests/Features/Detail/DetailViewModelTests.swift`（3 本足す）
- Test: `WidgetLabUITests/LaunchUITests.swift`（1 本足す）
- Modify: `docs/architecture.md`・`docs/cataloging-guide.md`（`.full` の説明）

**Interfaces:**
- Consumes: `DetailViewModel` の `current`・`canCompare`・`selectedID`・`selected`・`restartDemo()`・`demoGeneration`、`CatalogEntry.build`、束 3 の `CatalogEntry.statusBarHidden`、束 3 の `CatalogEntry.link`（`title` が required）
- Produces: `DetailViewModel.isTryingFull: Bool`（読み書き）、`DetailViewModel.trialShowsWith: Bool`（読み書き）、`DetailViewModel.trialValues: PropertyValues`（読むだけ）。UI の印 `try-full`（試すのボタン）・`close-full`（閉じる）・`trial-side`（付けない／付けたの切り替え）

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Features/Detail/DetailViewModelTests.swift` の最後のテスト（`stateEntrySelectsWrapperAndComparesWithAndWithout`）のあと、型を閉じる `}` の前に、空行を挟んで足す:

```swift
    @Test func fullTrialShowsWithSideFirstAndDropsOnlySelectedPropertyOnWithoutSide() {
        let viewModel = DetailViewModel(entry: .statusBarHidden, clipboard: clipboard)
        viewModel.isTryingFull = true
        #expect(viewModel.trialShowsWith)
        #expect(viewModel.trialValues == viewModel.current)
        viewModel.trialShowsWith = false
        #expect(viewModel.trialValues["statusBarHidden"] == nil)
        #expect(viewModel.current["statusBarHidden"] != nil)
    }

    @Test func reopeningFullTrialStartsFromWithSideAndRestartsDemo() {
        let viewModel = DetailViewModel(entry: .statusBarHidden, clipboard: clipboard)
        viewModel.isTryingFull = true
        viewModel.trialShowsWith = false
        viewModel.isTryingFull = false
        let start = viewModel.demoGeneration
        viewModel.isTryingFull = true
        #expect(viewModel.trialShowsWith)
        #expect(viewModel.demoGeneration > start)
    }

    @Test func fullTrialKeepsRequiredPropertyOnWithoutSide() {
        let viewModel = DetailViewModel(entry: .link, clipboard: clipboard)
        viewModel.selectedID = "title"
        viewModel.trialShowsWith = false
        #expect(viewModel.trialValues == viewModel.current)
    }
```

- [ ] **Step 2: 失敗することを確かめる**

Run: Global Constraints の確かめのコマンドの `xcodebuild test` だけ（`-only-testing:WidgetLabTests/DetailViewModelTests`）
Expected: ビルドが失敗する（`isTryingFull`・`trialShowsWith`・`trialValues` がない）

- [ ] **Step 3: ViewModel に全画面の状態を足す**

`WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift` を、次に置き換える（足したのは `isTryingFull`・`trialShowsWith`・`trialValues` と、`reset()` の `trialShowsWith = true` の 1 行）:

```swift
import Foundation
import Observation

/// 詳細画面の状態（プロパティの値・選んでいるプロパティ・比べる）
@Observable
final class DetailViewModel {
    let entry: CatalogEntry
    /// 選んでいるプロパティの id
    var selectedID: String? {
        didSet { if oldValue != selectedID { restartDemo() } }
    }
    var isComparing = false {
        didSet { if oldValue != isComparing { restartDemo() } }
    }
    /// 全画面で試しているか（stage が .full の収録だけ）。開くたびに付けた側から始める
    var isTryingFull = false {
        didSet {
            guard oldValue != isTryingFull else { return }
            trialShowsWith = true
            restartDemo()
        }
    }
    /// 全画面で、選んでいるプロパティを付けた側を出すか（false なら付けない側）
    var trialShowsWith = true {
        didSet { if oldValue != trialShowsWith { restartDemo() } }
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
        trialShowsWith = true
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

    /// 選んでいるプロパティを比べられるか（required は付けない状態がないので比べられない。説明だけの収録は見本がない）
    var canCompare: Bool {
        if case .note = entry.stage { return false }
        return selected.map { !$0.isRequired } ?? false
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

    /// 全画面で試すときに渡す値。付けない側なら、選んでいるプロパティだけ外す
    var trialValues: PropertyValues {
        guard !trialShowsWith, canCompare, let id = selectedID else { return current }
        var values = current
        values[id] = nil
        return values
    }

    /// チップに出す今の値（OFF なら "OFF"）
    func valueLabel(_ id: String) -> String {
        guard let spec = entry.properties.first(where: { $0.id == id }), enabled.contains(id), let value = values[id]
        else { return "OFF" }
        if spec.placement == .wrapper { return "ON" }
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

- [ ] **Step 4: プレビューに「試す」と全画面を足す**

`WidgetLab/Features/Detail/UI/PreviewArea.swift` を、次に置き換える（足したのは、型の説明の 1 行・`.fullScreenCover`・比べるの条件の `viewModel.entry.stage != .full`・`content` の `.full` の分かれ・`FullLauncher`・`FullTrialScreen`）:

```swift
import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出す
/// 見た目のもの（.card）は重ねて仕切りで見比べ、見た目を持たないもの（.behavior）は左右に並べて下に記録を出す
/// 説明だけのもの（.note）は、見本の代わりに試せない理由を出す
/// 全画面のもの（.full）は、枠に「試す」のボタンだけを出し、押すと見本を全画面で開く（比べるは全画面の中で切り替える）
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
        .fullScreenCover(
            isPresented: Binding(get: { viewModel.isTryingFull }, set: { viewModel.isTryingFull = $0 })
        ) {
            FullTrialScreen(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var compareToggle: some View {
        if viewModel.canCompare, viewModel.entry.stage != .full {
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
        if case .note(let reason) = viewModel.entry.stage {
            NoteView(reason: reason)
        } else if viewModel.entry.stage == .full {
            FullLauncher { viewModel.isTryingFull = true }
        } else if viewModel.entry.stage == .behavior {
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

/// 全画面の収録で、見本の代わりに出す。押すと全画面で開く
private struct FullLauncher: View {
    let onTry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.portrait")
                .font(.title)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("画面ぜんたいで動くので、全画面で開いて試します")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("試す", systemImage: "arrow.up.left.and.arrow.down.right", action: onTry)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("try-full")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 全画面で試す。上に見本、下に比べるの切り替えと閉じるのボタン
/// （見本に重ねると、TabView のタブバーやナビゲーションバーを隠すので、下に並べる）
private struct FullTrialScreen: View {
    let viewModel: DetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            viewModel.entry.build(viewModel.trialValues)
                .id(viewModel.demoGeneration)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            HStack(spacing: 12) {
                if viewModel.canCompare, let selected = viewModel.selected {
                    Picker(
                        selected.displayName,
                        selection: Binding(get: { viewModel.trialShowsWith }, set: { viewModel.trialShowsWith = $0 })
                    ) {
                        Text("付けない").tag(false)
                        Text("付けた").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("trial-side")
                }
                Spacer(minLength: 0)
                Button("閉じる") { viewModel.isTryingFull = false }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("close-full")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
}

/// 説明だけの収録で、見本の代わりに出す。ここで試せない理由
private struct NoteView: View {
    let reason: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.page")
                .font(.title)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("ここでは試せません")
                .font(.headline)
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("note")
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

- [ ] **Step 5: UI テストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す:

```swift
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
```

- [ ] **Step 6: 説明を直す**

`docs/architecture.md` を 3 か所だけ直す。

1. 構成の `Detail/{UI,ViewModel}` の行の「比べる・」のあとに「全画面で試す（.full）・」を足す
2. `WidgetLabUITests/` の行の「`@State` を比べて付けた側だけ表示が変わること、」のあとに「全画面の収録を試すで開いて閉じること、」を足し、最後の「7 本」を「8 本」にする
3. 「プレビューの出し方は `DemoStage` で決める。」の段落の「`.full` は全画面で開くもの」を、次に置き換える:

```markdown
`.full` は画面の行き来の入れ物や表示の単位に効くもの（枠には「試す」だけを出し、押すと見本を `fullScreenCover` で全画面に出す。下の帯で、選んでいるプロパティの付けない／付けたを切り替える。状態は `DetailViewModel` の `isTryingFull`・`trialShowsWith`・`trialValues`）
```

`docs/cataloging-guide.md` を 2 か所だけ直す。

1. 3 章の表の `.full` の行を、次に置き換える:

```markdown
| `.full` | 画面の行き来の入れ物（NavigationStack・TabView）と、表示の単位ぜんたいに効くもの。詳細の「試す」から全画面で開く | なし |
```

2. 3 章の `**`.full` はまだ動かない（2026-11-03 時点）。**` で始まる段落を、次に置き換える:

```markdown
**`.full` は、詳細の「試す」から全画面で開く（束 7 で作った）。** 枠には見本を描かず「試す」のボタンだけを出し、押すと見本を画面いっぱいに出す。下の帯の「付けない｜付けた」で、選んでいるプロパティを外した見本に切り替え、「閉じる」で詳細に戻る。値を変えるときは、詳細のチップと編集パネルで変えてから、もう一度「試す」を押す。一覧の行は絵にする。束 3 では、表示の単位（presentation）ぜんたいに効く modifier（`preferredColorScheme`・`statusBarHidden`・`persistentSystemOverlays`）を `.full` にした（2026-11-03 オーナーが決定）。`.card` にすると一覧の行の見本からも効いてしまい（行が見えただけでアプリ全体が暗くなる）、押し込んだ詳細画面からではステータスバーが消えないため。全画面で開けば、その表示の単位でだけ効く。
```

- [ ] **Step 7: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テストが全部通る。`testFullEntryOpensFullScreenAndCloses` のスクリーンショットで、ステータスバー（時刻）が消えている

- [ ] **Step 8: コミットする**

```bash
git add WidgetLab/Features/Detail WidgetLabTests/Features/Detail/DetailViewModelTests.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md
git commit -m "feat: 詳細の「試す」から .full の収録を全画面で開く

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 2: NavigationStack・NavigationLink・NavigationView・NavigationSplitView・navigationTitle・navigationSubtitle・navigationDocument

**Files:**
- Create: `WidgetLab/Catalog/Navigation/NavigationDemo.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationStackEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationLinkEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationViewEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationSplitViewEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationTitleEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationSubtitleEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationDocumentEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。補助: `FruitScreen`・`FruitStack`・`navigationFruits`
- Produces: `CatalogEntry.navigationStack`、`CatalogEntry.navigationLink`、`CatalogEntry.navigationView`、`CatalogEntry.navigationSplitView`、`CatalogEntry.navigationTitle`、`CatalogEntry.navigationSubtitle`、`CatalogEntry.navigationDocument`、補助 `navigationFruits`・`FruitScreen`・`FruitStack`・`FruitTabs`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py navigation`
Expected: 終了コード 1。抜けに NavigationStack・NavigationLink・NavigationView・NavigationSplitView・navigationTitle・navigationSubtitle・navigationDocument がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Navigation/NavigationDemo.swift`:

```swift
import SwiftUI

/// 画面の行き来の見本で使う果物の名前
let navigationFruits = ["りんご", "みかん", "ぶどう"]

/// 果物 1 つの画面（一覧から進んだ先）
struct FruitScreen: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
    }
}

/// 果物の一覧から、押した果物の画面へ進む NavigationStack。root にかける modifier を modify で渡す
/// （navigationTitle など、スタックの中の画面にかける modifier の収録で使う）
struct FruitStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView) -> Root

    var body: some View {
        NavigationStack {
            modify(
                AnyView(
                    List(navigationFruits, id: \.self) { name in
                        NavigationLink(name, value: name)
                    })
            )
            .navigationDestination(for: String.self) { FruitScreen(name: $0) }
        }
    }
}

/// タブの見本で使う 3 つのタブ。2 つ目は長い一覧（スクロールで変わる modifier のため）
struct FruitTabs: TabContent {
    typealias TabValue = Never

    var body: some TabContent<Never> {
        Tab("ホーム", systemImage: "house") { FruitScreen(name: "ホーム") }
        Tab("一覧", systemImage: "list.bullet") {
            List(1...40, id: \.self) { Text("行 \($0)") }
        }
        Tab("設定", systemImage: "gear") { FruitScreen(name: "設定") }
    }
}
```

`WidgetLab/Catalog/Navigation/NavigationStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationStack = CatalogEntry(
        id: "NavigationStack",
        kind: .view,
        topic: .navigation,
        summary: "最初の画面の上に、進んだ先の画面を積み重ねて出す View。戻ると上から 1 つずつ外れる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationstack")!,
        stage: .full,
        properties: [
            .argument(
                "path", .fixed(code: "$path"), on: true,
                summary: "積んだ画面の値の配列の Binding。書き換えると、コードから進んだり戻ったりできる"),
            .modifier("tint", .color(initial: 3), summary: "戻るボタンなどの色"),
        ],
        code: CodeTemplate(
            call: "NavigationStack",
            trailing:
                " {\n    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }\n        .navigationDestination(for: String.self) { Text($0) }\n        .toolbar { Button(\"ぶどうの先まで\") { path = [\"ぶどう\", \"ぶどうの先\"] } }\n}"
        ),
        build: { v in
            AnyView(NavigationStackDemo(usesPath: v["path"] != nil, tint: v.color("tint")))
        }
    )
}

private struct NavigationStackDemo: View {
    let usesPath: Bool
    let tint: Color?
    @State private var path: [String] = []

    var body: some View {
        Group {
            if usesPath {
                NavigationStack(path: $path) { root }
            } else {
                NavigationStack { root }
            }
        }
        .apply(tint) { $0.tint($1) }
    }

    private var root: some View {
        List(navigationFruits, id: \.self) { NavigationLink($0, value: $0) }
            .navigationDestination(for: String.self) { FruitScreen(name: $0) }
            .navigationTitle("果物")
            .toolbar {
                if usesPath {
                    Button("ぶどうの先まで") { path = ["ぶどう", "ぶどうの先"] }
                }
            }
    }
}
```

`WidgetLab/Catalog/Navigation/NavigationLinkEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationLink = CatalogEntry(
        id: "NavigationLink",
        kind: .view,
        topic: .navigation,
        summary: "押すと、NavigationStack に次の画面を積んで進む View。値を渡し、行き先は navigationDestination で決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationlink")!,
        stage: .full,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "りんごを見る"), required: true, summary: "リンクの文"),
            .argument(
                "value", .fixed(code: "\"りんご\""), required: true, summary: "積む値。navigationDestination(for:) の型で行き先が決まる"),
            .modifier("disabled", .toggle(initial: true), summary: "true なら押せない"),
            .modifier("tint", .color(initial: 5), summary: "リンクの文の色（List の外のとき）"),
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    VStack {"], indent: 8, call: "NavigationLink",
            closing: ["    }", "    .navigationDestination(for: String.self) { Text($0) }", "}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    VStack(spacing: 16) {
                        NavigationLink(v.text("title") ?? "", value: "りんご")
                            .apply(v.flag("disabled")) { $0.disabled($1) }
                            .apply(v.color("tint")) { $0.tint($1) }
                    }
                    .navigationDestination(for: String.self) { FruitScreen(name: $0) }
                    .navigationTitle("果物")
                })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/NavigationViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationView = CatalogEntry(
        id: "NavigationView",
        kind: .view,
        topic: .navigation,
        summary: "画面を積んで行き来する View の古い形。iOS 16 から非推奨で、NavigationStack か NavigationSplitView に置き換える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationview")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationViewStyle", .choice([Choice(".automatic"), Choice(".stack")], initial: 1), on: true,
                summary: "並べ方。.stack は 1 列に積む（iPad でも 2 列にしない）")
        ],
        code: CodeTemplate(
            call: "NavigationView",
            trailing:
                " {\n    List(fruits, id: \\.self) { name in\n        NavigationLink(name) { Text(name) }\n    }\n    .navigationTitle(\"果物\")\n}"
        ),
        build: { v in
            AnyView(
                NavigationView {
                    List(navigationFruits, id: \.self) { name in
                        NavigationLink(name) { FruitScreen(name: name) }
                    }
                    .navigationTitle("果物")
                }
                .apply(v.pick("navigationViewStyle", from: [0, 1])) { view, style in
                    if style == 0 {
                        view.navigationViewStyle(.automatic)
                    } else {
                        view.navigationViewStyle(.stack)
                    }
                })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/NavigationSplitViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationSplitView = CatalogEntry(
        id: "NavigationSplitView",
        kind: .view,
        topic: .navigation,
        summary: "2 列か 3 列を並べ、前の列で選んだものを後ろの列に出す View。iPhone では 1 列に畳んで、積み重ねで行き来する。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationsplitview")!,
        stage: .full,
        properties: [
            .argument(
                "preferredCompactColumn",
                .choice(
                    [Choice(".sidebar", code: ".constant(.sidebar)"), Choice(".detail", code: ".constant(.detail)")],
                    initial: 1),
                on: true, summary: "1 列に畳んだとき（iPhone）に、はじめに出す列"),
            .modifier(
                "navigationSplitViewStyle",
                .choice([Choice(".automatic"), Choice(".balanced"), Choice(".prominentDetail")], initial: 0),
                summary: "列の並べ方。iPhone では変わらない"),
        ],
        code: CodeTemplate(
            call: "NavigationSplitView",
            trailing:
                " {\n    List(fruits, id: \\.self, selection: $selected) { Text($0) }\n} detail: {\n    Text(selected ?? \"果物を選ぶ\")\n}"
        ),
        build: { v in
            AnyView(
                NavigationSplitViewDemo(
                    column: v.pick("preferredCompactColumn", from: [NavigationSplitViewColumn.sidebar, .detail]),
                    style: v.pick("navigationSplitViewStyle", from: [0, 1, 2])))
        }
    )
}

private struct NavigationSplitViewDemo: View {
    let column: NavigationSplitViewColumn?
    let style: Int?
    @State private var selected: String?

    var body: some View {
        Group {
            if let column {
                NavigationSplitView(preferredCompactColumn: .constant(column)) {
                    sidebar
                } detail: {
                    detail
                }
            } else {
                NavigationSplitView {
                    sidebar
                } detail: {
                    detail
                }
            }
        }
        .apply(style) { view, style in
            switch style {
            case 1: view.navigationSplitViewStyle(.balanced)
            case 2: view.navigationSplitViewStyle(.prominentDetail)
            default: view.navigationSplitViewStyle(.automatic)
            }
        }
    }

    private var sidebar: some View {
        List(navigationFruits, id: \.self, selection: $selected) { Text($0) }
            .navigationTitle("果物")
    }

    private var detail: some View {
        FruitScreen(name: selected ?? "果物を選ぶ")
    }
}
```

`WidgetLab/Catalog/Navigation/NavigationTitleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationTitle = CatalogEntry(
        id: "navigationTitle",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の題名を決める modifier。ナビゲーションバーに出て、戻るボタンの文にもなる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationtitle(_:)")!,
        stage: .full,
        properties: [
            .modifier("navigationTitle", .text(initial: "果物"), on: true, summary: "題名の文")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            closing: ["}"]),
        build: { v in
            AnyView(FruitStack { $0.apply(v.text("navigationTitle")) { $0.navigationTitle($1) } })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/NavigationSubtitleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationSubtitle = CatalogEntry(
        id: "navigationSubtitle",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の、題名に添える小さな副題を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationsubtitle(_:)")!,
        stage: .full,
        properties: [
            .modifier("navigationSubtitle", .text(initial: "3 件"), on: true, summary: "副題の文。題名の下に出る")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            suffix: [".navigationTitle(\"果物\")"], closing: ["}"]),
        build: { v in
            AnyView(
                FruitStack {
                    $0.navigationTitle("果物")
                        .apply(v.text("navigationSubtitle")) { $0.navigationSubtitle($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/NavigationDocumentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationDocument = CatalogEntry(
        id: "navigationDocument",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面が見せている書類（共有できるもの）を決める modifier。iPhone では、題名のメニューの頭に書類の見出しが出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationdocument(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationDocument", .fixed(code: "URL(string: \"https://www.apple.com/jp/\")!"), on: true,
                summary: "画面の書類（Transferable）。題名を押すと出るメニューの頭に、見出しと共有が出る")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "Text", fixedArguments: ["\"題名を押す\""],
            suffix: [
                ".navigationTitle(\"Apple のサイト\")", ".navigationBarTitleDisplayMode(.inline)",
                ".toolbarTitleMenu { Button(\"名前を変える\") { } }",
            ], closing: ["}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    Text("題名を押す")
                        .apply(v["navigationDocument"] != nil ? URL(string: "https://www.apple.com/jp/")! : nil) {
                            $0.navigationDocument($1)
                        }
                        .navigationTitle("Apple のサイト")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarTitleMenu { Button("名前を変える") {} }
                })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .navigationStack,
        .navigationLink,
        .navigationView,
        .navigationSplitView,
        .navigationTitle,
        .navigationSubtitle,
        .navigationDocument,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Navigation/NavigationDemo.swift WidgetLab/Catalog/Navigation/NavigationStackEntry.swift WidgetLab/Catalog/Navigation/NavigationLinkEntry.swift WidgetLab/Catalog/Navigation/NavigationViewEntry.swift WidgetLab/Catalog/Navigation/NavigationSplitViewEntry.swift WidgetLab/Catalog/Navigation/NavigationTitleEntry.swift WidgetLab/Catalog/Navigation/NavigationSubtitleEntry.swift WidgetLab/Catalog/Navigation/NavigationDocumentEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 NavigationStack・NavigationLink・NavigationView・NavigationSplitView・navigationTitle・navigationSubtitle・navigationDocument

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 3: navigationBarBackButtonHidden・navigationBarTitleDisplayMode・TabView・tabBarMinimizeBehavior・defaultTabBarPlacement・defaultAdaptableTabBarPlacement・sectionActions

**Files:**
- Create: `WidgetLab/Catalog/Navigation/NavigationBarBackButtonHiddenEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/NavigationBarTitleDisplayModeEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/TabViewEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/TabBarMinimizeBehaviorEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/DefaultTabBarPlacementEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/DefaultAdaptableTabBarPlacementEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/SectionActionsEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。補助: `FruitScreen`・`FruitStack`・`FruitTabs`・`navigationFruits`
- Produces: `CatalogEntry.navigationBarBackButtonHidden`、`CatalogEntry.navigationBarTitleDisplayMode`、`CatalogEntry.tabView`、`CatalogEntry.tabBarMinimizeBehavior`、`CatalogEntry.defaultTabBarPlacement`、`CatalogEntry.defaultAdaptableTabBarPlacement`、`CatalogEntry.sectionActions`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py navigation`
Expected: 終了コード 1。抜けに navigationBarBackButtonHidden・navigationBarTitleDisplayMode・TabView・tabBarMinimizeBehavior・defaultTabBarPlacement・defaultAdaptableTabBarPlacement・sectionActions がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Navigation/NavigationBarBackButtonHiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationBarBackButtonHidden = CatalogEntry(
        id: "navigationBarBackButtonHidden",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックで進んだ先の画面の、戻るボタンを隠す modifier。指で端からなぞって戻ることもできなくなる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/navigationbarbackbuttonhidden(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationBarBackButtonHidden", .toggle(initial: true), on: true,
                summary: "true なら戻るボタンを隠す。代わりの戻り方（dismiss など）を用意する")
        ],
        code: CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }",
                "        .navigationDestination(for: String.self) { name in",
            ], indent: 12, call: "FruitScreen", fixedArguments: ["name: name"], closing: ["        }", "}"]),
        build: { v in
            AnyView(BackButtonHiddenDemo(hidden: v.flag("navigationBarBackButtonHidden")))
        }
    )
}

private struct BackButtonHiddenDemo: View {
    let hidden: Bool?

    var body: some View {
        NavigationStack {
            List(navigationFruits, id: \.self) { NavigationLink($0, value: $0) }
                .navigationTitle("果物")
                .navigationDestination(for: String.self) { name in
                    BackButtonHiddenScreen(name: name)
                        .apply(hidden) { $0.navigationBarBackButtonHidden($1) }
                }
        }
    }
}

/// 進んだ先の画面。戻るボタンを隠しても戻れるよう、下に戻るボタンを置く
private struct BackButtonHiddenScreen: View {
    let name: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            FruitScreen(name: name)
            Button("一覧に戻る") { dismiss() }
                .buttonStyle(.bordered)
                .padding(.bottom, 24)
        }
    }
}
```

`WidgetLab/Catalog/Navigation/NavigationBarTitleDisplayModeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationBarTitleDisplayMode = CatalogEntry(
        id: "navigationBarTitleDisplayMode",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面の題名を、大きく出すか、バーの中に小さく出すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/navigationbartitledisplaymode(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationBarTitleDisplayMode",
                .choice([Choice(".automatic"), Choice(".inline"), Choice(".large")], initial: 1),
                on: true, summary: "題名の出し方。.large は大きく、.inline はバーの真ん中に小さく出す")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "List(fruits, id: \\.self)",
            trailing: " { NavigationLink($0, value: $0) }",
            suffix: [".navigationTitle(\"果物\")"], closing: ["}"]),
        build: { v in
            AnyView(
                FruitStack {
                    $0.navigationTitle("果物")
                        .apply(
                            v.pick(
                                "navigationBarTitleDisplayMode",
                                from: [NavigationBarItem.TitleDisplayMode.automatic, .inline, .large])
                        ) { $0.navigationBarTitleDisplayMode($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/TabViewEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabView = CatalogEntry(
        id: "TabView",
        kind: .view,
        topic: .navigation,
        summary: "下のタブバーなどで、いくつかの画面を切り替える View。中身は Tab で並べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/tabview")!,
        stage: .full,
        properties: [
            .modifier(
                "tabViewStyle",
                .choice([Choice(".automatic"), Choice(".sidebarAdaptable"), Choice(".page")], initial: 0), on: true,
                summary: "切り替え方。.page は横にめくる"),
            .modifier("tint", .color(initial: 1), summary: "選んでいるタブの色"),
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}"
        ),
        build: { v in
            AnyView(
                TabView { FruitTabs() }
                    .apply(v.pick("tabViewStyle", from: [0, 1, 2])) { view, style in
                        switch style {
                        case 1: view.tabViewStyle(.sidebarAdaptable)
                        case 2: view.tabViewStyle(.page)
                        default: view.tabViewStyle(.automatic)
                        }
                    }
                    .apply(v.color("tint")) { $0.tint($1) })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/TabBarMinimizeBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabBarMinimizeBehavior = CatalogEntry(
        id: "tabBarMinimizeBehavior",
        kind: .modifier,
        topic: .navigation,
        summary: "中身をスクロールしたとき、タブバーを小さく畳むかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabbarminimizebehavior(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "tabBarMinimizeBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".onScrollDown"), Choice(".onScrollUp"), Choice(".never")], initial: 1
                ),
                on: true, summary: "畳むきっかけ。「一覧」のタブでスクロールして見る")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}"
        ),
        build: { v in
            AnyView(
                TabView { FruitTabs() }
                    .apply(
                        v.pick(
                            "tabBarMinimizeBehavior",
                            from: [TabBarMinimizeBehavior.automatic, .onScrollDown, .onScrollUp, .never])
                    ) { $0.tabBarMinimizeBehavior($1) })
        }
    )
}
```

`WidgetLab/Catalog/Navigation/DefaultTabBarPlacementEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultTabBarPlacement = CatalogEntry(
        id: "defaultTabBarPlacement",
        kind: .modifier,
        topic: .navigation,
        summary: "sidebarAdaptable のタブを、タブバーとサイドバーのどちらで出すかを決める modifier。iPhone のように、片方しか出せないところで効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaulttabbarplacement(_:)")!,
        noteReason:
            "iOS 27.0 の iPhone 18 Pro で .sidebar にしても、タブバーのままで変わらなかった。Mac・Apple TV・Vision Pro で、サイドバーかタブバーのどちらかに決まるときに効く",
        properties: [
            .modifier(
                "defaultTabBarPlacement",
                .choice([Choice(".automatic"), Choice(".tabBar"), Choice(".sidebar")], initial: 2),
                on: true, summary: "タブの出し方。.sidebar なら iPhone でもサイドバーで出す")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/Navigation/DefaultAdaptableTabBarPlacementEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultAdaptableTabBarPlacement = CatalogEntry(
        id: "defaultAdaptableTabBarPlacement",
        kind: .modifier,
        topic: .navigation,
        summary: "sidebarAdaptable のタブを、はじめにタブバーとサイドバーのどちらで出すかを決める modifier。タブバーとサイドバーを行き来できる iPad で効く。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/defaultadaptabletabbarplacement(_:)")!,
        noteReason: "iPad だけで効く（タブバーとサイドバーを切り替えられるのが iPad だけのため）。iPhone では defaultTabBarPlacement を使う",
        properties: [
            .modifier(
                "defaultAdaptableTabBarPlacement",
                .choice([Choice(".automatic"), Choice(".tabBar"), Choice(".sidebar")], initial: 2),
                on: true, summary: "はじめの出し方")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    Tab(\"一覧\", systemImage: \"list.bullet\") { List(1...40, id: \\.self) { Text(\"行 \\($0)\") } }\n    Tab(\"設定\", systemImage: \"gear\") { Text(\"設定\") }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/Navigation/SectionActionsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionActions = CatalogEntry(
        id: "sectionActions",
        kind: .modifier,
        topic: .navigation,
        summary: "まとまり（Section）に、足すなどの操作のボタンを添える modifier。iOS ではまとまりの中身の後ろに並ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sectionactions(content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "sectionActions", label: "content", .fixed(code: "{ Button(\"果物を足す\", systemImage: \"plus\") { } }"),
                on: true, summary: "まとまりに添える操作")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n        Text(\"みかん\")\n    }", closing: ["}"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") {
                        Text("りんご")
                        Text("みかん")
                    }
                    .apply(v["sectionActions"] != nil ? () : nil) { view, _ in
                        view.sectionActions { Button("果物を足す", systemImage: "plus") {} }
                    }
                })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .navigationBarBackButtonHidden,
        .navigationBarTitleDisplayMode,
        .tabView,
        .tabBarMinimizeBehavior,
        .defaultTabBarPlacement,
        .defaultAdaptableTabBarPlacement,
        .sectionActions,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Navigation/NavigationBarBackButtonHiddenEntry.swift WidgetLab/Catalog/Navigation/NavigationBarTitleDisplayModeEntry.swift WidgetLab/Catalog/Navigation/TabViewEntry.swift WidgetLab/Catalog/Navigation/TabBarMinimizeBehaviorEntry.swift WidgetLab/Catalog/Navigation/DefaultTabBarPlacementEntry.swift WidgetLab/Catalog/Navigation/DefaultAdaptableTabBarPlacementEntry.swift WidgetLab/Catalog/Navigation/SectionActionsEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 navigationBarBackButtonHidden・navigationBarTitleDisplayMode・TabView・tabBarMinimizeBehavior・defaultTabBarPlacement・defaultAdaptableTabBarPlacement・sectionActions

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 4: tabViewSidebarHeader・tabViewSidebarFooter・tabViewSidebarBottomBar・tabViewCustomization・sheet・fullScreenCover・popover

**Files:**
- Create: `WidgetLab/Catalog/ModalPresentations/ModalDemo.swift`
- Create: `WidgetLab/Catalog/Navigation/TabViewSidebarHeaderEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/TabViewSidebarFooterEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/TabViewSidebarBottomBarEntry.swift`
- Create: `WidgetLab/Catalog/Navigation/TabViewCustomizationEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/SheetEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FullScreenCoverEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PopoverEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。補助: `ModalSheetContent`
- Produces: `CatalogEntry.tabViewSidebarHeader`、`CatalogEntry.tabViewSidebarFooter`、`CatalogEntry.tabViewSidebarBottomBar`、`CatalogEntry.tabViewCustomization`、`CatalogEntry.sheet`、`CatalogEntry.fullScreenCover`、`CatalogEntry.popover`、補助 `ModalSheetContent`・`SheetModifierDemo`・`CodeTemplate.inSheet(_:)`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py navigation modal-presentations`
Expected: 終了コード 1。抜けに tabViewSidebarHeader・tabViewSidebarFooter・tabViewSidebarBottomBar・tabViewCustomization・sheet・fullScreenCover・popover がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ModalPresentations/ModalDemo.swift`:

```swift
import SwiftUI

/// 画面を重ねて出す見本で使う、シートの中身。中の見出しと、閉じるボタンを出す
/// （閉じるボタンは、指で下げて閉じられないシートや全画面のカバーでも閉じられるようにするため）
struct ModalSheetContent<Extra: View>: View {
    let title: String
    @ViewBuilder let extra: Extra
    @Environment(\.dismiss) private var dismiss

    init(_ title: String, @ViewBuilder extra: () -> Extra = { EmptyView() }) {
        self.title = title
        self.extra = extra()
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
            extra
            Button("閉じる") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// シートの中身に modifier をかける見本。ボタンでシートを開き、中身は content で組み立てる
/// （presentationDetents など、シートの中身にかける modifier の収録で使う）
struct SheetModifierDemo<Content: View>: View {
    var title = "シートを開く"
    @ViewBuilder let content: () -> Content
    @State private var shows = false

    var body: some View {
        Button(title) { shows = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $shows, content: content)
    }
}

nonisolated extension CodeTemplate {
    /// シートの中身の Text にかける modifier の収録のコード。call が Text で、modifier はその下に並ぶ
    static func inSheet(_ text: String = "シートの中身") -> CodeTemplate {
        CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"\(text)\""], closing: ["    }"])
    }
}
```

`WidgetLab/Catalog/Navigation/TabViewSidebarHeaderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarHeader = CatalogEntry(
        id: "tabViewSidebarHeader",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのいちばん上（タブより前）に、好きな View を足す modifier。 サイドバーを出しているときだけ見える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarheader(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarHeader", label: "content", .fixed(code: "{ Text(\"ようこそ\").font(.title2) }"), on: true,
                summary: "頭に出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/Navigation/TabViewSidebarFooterEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarFooter = CatalogEntry(
        id: "tabViewSidebarFooter",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのタブの後ろに、好きな View を足す modifier。 サイドバーを出しているときだけ見える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarfooter(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarFooter", label: "content",
                .fixed(code: "{ Text(\"v1.0\").foregroundStyle(.secondary) }"), on: true,
                summary: "タブの後ろに出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/Navigation/TabViewSidebarBottomBarEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewSidebarBottomBar = CatalogEntry(
        id: "tabViewSidebarBottomBar",
        kind: .modifier,
        topic: .navigation,
        summary: "TabView のサイドバーのいちばん下に、スクロールしないバーを足す modifier。 サイドバーを出しているときだけ見える。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/tabviewsidebarbottombar(content:)")!,
        noteReason: "iPhone ではタブがサイドバーで出ないので見えない。iPad と Mac で、タブをサイドバーで出しているときに出る",
        properties: [
            .modifier(
                "tabViewSidebarBottomBar", label: "content",
                .fixed(code: "{ Button(\"アカウント\", systemImage: \"person.circle\") { } }"), on: true,
                summary: "下に止まって出す View")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n        Tab(\"みかん\", systemImage: \"sun.max\") { Text(\"みかん\") }\n    }\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/Navigation/TabViewCustomizationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tabViewCustomization = CatalogEntry(
        id: "tabViewCustomization",
        kind: .modifier,
        topic: .navigation,
        summary: "サイドバーのタブを並べ替えたり隠したりした結果を、TabViewCustomization に書いて覚える modifier。タブには customizationID を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tabviewcustomization(_:)")!,
        noteReason: "iPhone ではタブを並べ替えたり隠したりできない。iPad と Mac のサイドバーで、タブを並べ替えた結果を覚える",
        properties: [
            .modifier(
                "tabViewCustomization", .fixed(code: "$customization"), on: true,
                summary: "並べ替え・隠した結果を書く Binding。@AppStorage に置けば、次に開いたときも戻る")
        ],
        code: CodeTemplate(
            call: "TabView",
            trailing:
                " {\n    Tab(\"ホーム\", systemImage: \"house\") { Text(\"ホーム\") }\n        .customizationID(\"home\")\n    TabSection(\"果物\") {\n        Tab(\"りんご\", systemImage: \"leaf\") { Text(\"りんご\") }\n            .customizationID(\"apple\")\n    }\n    .customizationID(\"fruits\")\n}",
            suffix: [".tabViewStyle(.sidebarAdaptable)"])
    )
}
```

`WidgetLab/Catalog/ModalPresentations/SheetEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sheet = CatalogEntry(
        id: "sheet",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、今の画面の上にシートを重ねて出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "sheet",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { Text(\"シートの中身\") }"),
                        Choice(
                            "onDismiss も渡す",
                            code: "isPresented: $shows, onDismiss: { closed += 1 }, content: { Text(\"シートの中身\") }"),
                    ], initial: 1), on: true,
                summary: "出すかどうかの Binding と中身。onDismiss は閉じたあとに呼ばれる")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"シートを開く\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(SheetDemo(kind: v.pick("sheet", from: [SheetDemo.Kind.plain, .onDismiss])))
        }
    )
}

private struct SheetDemo: View {
    enum Kind {
        case plain, onDismiss
    }

    let kind: Kind?
    @State private var shows = false
    @State private var closed = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("シートを開く") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .plain:
                        view.sheet(isPresented: $shows) { ModalSheetContent("シートの中身") }
                    case .onDismiss:
                        view.sheet(isPresented: $shows, onDismiss: { closed += 1 }) { ModalSheetContent("シートの中身") }
                    }
                }
            Text("閉じた回数: \(closed)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/FullScreenCoverEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fullScreenCover = CatalogEntry(
        id: "fullScreenCover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、画面をできるだけ覆う View を重ねて出す modifier。指で下げても閉じない。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fullScreenCover",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { CoverContent() }"),
                        Choice(
                            "onDismiss も渡す",
                            code: "isPresented: $shows, onDismiss: { closed += 1 }, content: { CoverContent() }"),
                    ], initial: 0), on: true,
                summary: "出すかどうかの Binding と中身。中身には閉じるボタンを置く（dismiss を呼ぶ）")
        ],
        code: CodeTemplate(
            call: "Button", fixedArguments: ["\"全画面で開く\""], trailing: " { shows = true }",
            closing: [
                "",
                "struct CoverContent: View {",
                "    @Environment(\\.dismiss) private var dismiss",
                "",
                "    var body: some View {",
                "        Button(\"閉じる\") { dismiss() }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                FullScreenCoverDemo(
                    kind: v.pick("fullScreenCover", from: [FullScreenCoverDemo.Kind.plain, .onDismiss])))
        }
    )
}

private struct FullScreenCoverDemo: View {
    enum Kind {
        case plain, onDismiss
    }

    let kind: Kind?
    @State private var shows = false
    @State private var closed = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("全画面で開く") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .plain:
                        view.fullScreenCover(isPresented: $shows) { ModalSheetContent("全画面のカバー") }
                    case .onDismiss:
                        view.fullScreenCover(isPresented: $shows, onDismiss: { closed += 1 }) {
                            ModalSheetContent("全画面のカバー")
                        }
                    }
                }
            Text("閉じた回数: \(closed)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/PopoverEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let popover = CatalogEntry(
        id: "popover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、押した View から吹き出しのように出す modifier。iPhone では、ふつうはシートに変わる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "popover",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { PopoverContent() }"),
                        Choice(
                            "arrowEdge: .top",
                            code: "isPresented: $shows, arrowEdge: .top, content: { PopoverContent() }"),
                        Choice(
                            "arrowEdge: .bottom",
                            code: "isPresented: $shows, arrowEdge: .bottom, content: { PopoverContent() }"),
                    ], initial: 0), on: true,
                summary: "出すかどうかの Binding と中身。arrowEdge は矢印を向ける向き（収まらなければ変わる）")
        ],
        code: CodeTemplate(
            call: "Button", fixedArguments: ["\"吹き出しを出す\""], trailing: " { shows = true }",
            closing: [
                "",
                "struct PopoverContent: View {",
                "    var body: some View {",
                "        Text(\"吹き出しの中身\")",
                "            .padding()",
                "            // iPhone でも吹き出しのまま出す",
                "            .presentationCompactAdaptation(.popover)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(PopoverDemo(edge: v.pick("popover", from: [Edge?.none, .top, .bottom])))
        }
    )
}

private struct PopoverDemo: View {
    /// nil の nil なら OFF、中の nil なら arrowEdge を渡さない
    let edge: Edge??
    @State private var shows = false

    var body: some View {
        Button("吹き出しを出す") { shows = true }
            .buttonStyle(.borderedProminent)
            .apply(edge) { view, edge in
                if let edge {
                    view.popover(isPresented: $shows, arrowEdge: edge) { content }
                } else {
                    view.popover(isPresented: $shows) { content }
                }
            }
    }

    private var content: some View {
        Text("吹き出しの中身")
            .padding()
            .presentationCompactAdaptation(.popover)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .tabViewSidebarHeader,
        .tabViewSidebarFooter,
        .tabViewSidebarBottomBar,
        .tabViewCustomization,
        .sheet,
        .fullScreenCover,
        .popover,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/ModalPresentations/ModalDemo.swift WidgetLab/Catalog/Navigation/TabViewSidebarHeaderEntry.swift WidgetLab/Catalog/Navigation/TabViewSidebarFooterEntry.swift WidgetLab/Catalog/Navigation/TabViewSidebarBottomBarEntry.swift WidgetLab/Catalog/Navigation/TabViewCustomizationEntry.swift WidgetLab/Catalog/ModalPresentations/SheetEntry.swift WidgetLab/Catalog/ModalPresentations/FullScreenCoverEntry.swift WidgetLab/Catalog/ModalPresentations/PopoverEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 tabViewSidebarHeader・tabViewSidebarFooter・tabViewSidebarBottomBar・tabViewCustomization・sheet・fullScreenCover・popover

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 5: presentationCompactAdaptation・presentationSizing・presentationDetents・presentationContentInteraction・presentationDragIndicator・presentationPlacement・presentationCornerRadius・presentationBackground

**Files:**
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationCompactAdaptationEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationSizingEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationDetentsEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationContentInteractionEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationDragIndicatorEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationPlacementEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationCornerRadiusEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationBackgroundEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。補助: `CodeTemplate.inSheet`・`ModalSheetContent`・`SheetModifierDemo`
- Produces: `CatalogEntry.presentationCompactAdaptation`、`CatalogEntry.presentationSizing`、`CatalogEntry.presentationDetents`、`CatalogEntry.presentationContentInteraction`、`CatalogEntry.presentationDragIndicator`、`CatalogEntry.presentationPlacement`、`CatalogEntry.presentationCornerRadius`、`CatalogEntry.presentationBackground`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py modal-presentations`
Expected: 終了コード 1。抜けに presentationCompactAdaptation・presentationSizing・presentationDetents・presentationContentInteraction・presentationDragIndicator・presentationPlacement・presentationCornerRadius・presentationBackground がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ModalPresentations/PresentationCompactAdaptationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationCompactAdaptation = CatalogEntry(
        id: "presentationCompactAdaptation",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "幅や高さが狭いとき（iPhone など）に、吹き出しやシートをどの出し方に変えるかを決める modifier。中身にかける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationcompactadaptation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationCompactAdaptation",
                .choice(
                    [
                        Choice(".automatic"), Choice(".popover"), Choice(".sheet"), Choice(".fullScreenCover"),
                        Choice(".none"),
                    ], initial: 1), on: true,
                summary: "狭いときの出し方。.automatic なら、吹き出しはシートに変わる")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"吹き出しを出す\") { shows = true }", "    .popover(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"吹き出しの中身\""], closing: ["    }"]),
        build: { v in
            AnyView(
                PresentationCompactAdaptationDemo(
                    adaptation: v.pick(
                        "presentationCompactAdaptation",
                        from: [PresentationAdaptation.automatic, .popover, .sheet, .fullScreenCover, .none])))
        }
    )
}

private struct PresentationCompactAdaptationDemo: View {
    let adaptation: PresentationAdaptation?
    @State private var shows = false

    var body: some View {
        Button("吹き出しを出す") { shows = true }
            .buttonStyle(.borderedProminent)
            .popover(isPresented: $shows) {
                ModalSheetContent("吹き出しの中身")
                    .frame(idealWidth: 240, idealHeight: 160)
                    .apply(adaptation) { $0.presentationCompactAdaptation($1) }
            }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationSizingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationSizing = CatalogEntry(
        id: "presentationSizing",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの大きさの決め方（中身に合わせる・決まった大きさなど）を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationsizing(_:)")!,
        noteReason: "iPhone ではシートがいつも幅いっぱいに出るので、大きさは変わらない。iPad と Mac で、シートの大きさが変わる",
        properties: [
            .modifier(
                "presentationSizing",
                .choice([Choice(".automatic"), Choice(".form"), Choice(".page"), Choice(".fitted")], initial: 3),
                on: true, summary: "大きさの決め方。.fitted は中身の大きさに合わせる")
        ],
        code: .inSheet()
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationDetentsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationDetents = CatalogEntry(
        id: "presentationDetents",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートが止まる高さ（半分・いっぱいなど）を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationDetents",
                .choice(
                    [
                        Choice("[.medium]"), Choice("[.medium, .large]"), Choice("[.height(200)]"),
                        Choice("[.fraction(0.3), .large]"),
                    ], initial: 1), on: true,
                summary: "止まる高さの集まり。2 つ以上なら、指で上下させて切り替えられる")
        ],
        code: .inSheet(),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(
                            v.pick(
                                "presentationDetents",
                                from: [
                                    Set<PresentationDetent>([.medium]), [.medium, .large], [.height(200)],
                                    [.fraction(0.3), .large],
                                ])
                        ) { $0.presentationDetents($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationContentInteractionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationContentInteraction = CatalogEntry(
        id: "presentationContentInteraction",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの中をスクロールしたとき、シートの高さを変えるか、中身をスクロールするかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationcontentinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationContentInteraction",
                .choice([Choice(".automatic"), Choice(".resizes"), Choice(".scrolls")], initial: 2), on: true,
                summary: "上へなぞったときの動き。.resizes は先にシートを広げ、.scrolls は中身をスクロールする")
        ],
        code: CodeTemplate(
            prefix: [
                "Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {",
            ], indent: 8, call: "List(1...30, id: \\.self)", trailing: " { Text(\"行 \\($0)\") }",
            suffix: [".presentationDetents([.medium, .large])"], closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    List(1...30, id: \.self) { Text("行 \($0)") }
                        .apply(
                            v.pick(
                                "presentationContentInteraction",
                                from: [PresentationContentInteraction.automatic, .resizes, .scrolls])
                        ) { $0.presentationContentInteraction($1) }
                        .presentationDetents([.medium, .large])
                })
        }
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationDragIndicatorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationDragIndicator = CatalogEntry(
        id: "presentationDragIndicator",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの上の端に、指でつまむ印（グラバー）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationdragindicator(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationDragIndicator",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "印を出すか。.automatic は止まる高さが 2 つ以上のときに出す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(v.pick("presentationDragIndicator", from: [Visibility.automatic, .visible, .hidden])) {
                            $0.presentationDragIndicator($1)
                        }
                        .presentationDetents([.medium])
                })
        }
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationPlacementEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationPlacement = CatalogEntry(
        id: "presentationPlacement",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートを、出した画面の中のどこ（前の端・真ん中・後ろの端）に置くかを決める modifier。シートだけが従う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationplacement(_:)")!,
        noteReason: "iPhone ではシートがいつも幅いっぱいに出るので、置く場所は変わらない。iPad など幅の広い画面で、シートを端に寄せる",
        properties: [
            .modifier(
                "presentationPlacement",
                .choice(
                    [Choice(".automatic"), Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 1),
                on: true, summary: "シートを置く場所")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"])
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationCornerRadiusEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationCornerRadius = CatalogEntry(
        id: "presentationCornerRadius",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの角の丸みの半径を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationcornerradius(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationCornerRadius", .slider(range: 0...60, step: 4, initial: 0), on: true,
                summary: "角の丸みの半径。省くとシステムの丸み")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(v.number("presentationCornerRadius")) { $0.presentationCornerRadius($1) }
                        .presentationDetents([.medium])
                })
        }
    )
}
```

`WidgetLab/Catalog/ModalPresentations/PresentationBackgroundEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationBackground = CatalogEntry(
        id: "presentationBackground",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの背景を、色や素材（すりガラス）で塗る modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationBackground",
                .choice(
                    [Choice(".yellow"), Choice(".ultraThinMaterial"), Choice(".blue.gradient"), Choice(".clear")],
                    initial: 0), on: true,
                summary: "背景の塗り。.clear なら、後ろの画面が透けて見える")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(
                            v.pick(
                                "presentationBackground",
                                from: [
                                    AnyShapeStyle(.yellow), AnyShapeStyle(.ultraThinMaterial),
                                    AnyShapeStyle(.blue.gradient), AnyShapeStyle(.clear),
                                ])
                        ) { $0.presentationBackground($1) }
                        .presentationDetents([.medium])
                })
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .presentationCompactAdaptation,
        .presentationSizing,
        .presentationDetents,
        .presentationContentInteraction,
        .presentationDragIndicator,
        .presentationPlacement,
        .presentationCornerRadius,
        .presentationBackground,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/ModalPresentations/PresentationCompactAdaptationEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationSizingEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationDetentsEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationContentInteractionEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationDragIndicatorEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationPlacementEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationCornerRadiusEntry.swift WidgetLab/Catalog/ModalPresentations/PresentationBackgroundEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 presentationCompactAdaptation・presentationSizing・presentationDetents・presentationContentInteraction・presentationDragIndicator・presentationPlacement・presentationCornerRadius・presentationBackground

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 6: presentationBackgroundInteraction・interactiveDismissDisabled・alert・confirmationDialog・dismissalConfirmationDialog・dialogIcon・dialogSuppressionToggle・inspector

**Files:**
- Create: `WidgetLab/Catalog/ModalPresentations/PresentationBackgroundInteractionEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/InteractiveDismissDisabledEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/AlertEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/ConfirmationDialogEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/DismissalConfirmationDialogEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/DialogIconEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/DialogSuppressionToggleEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/InspectorEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）。補助: `CodeTemplate.inSheet`・`ModalSheetContent`・`SheetModifierDemo`
- Produces: `CatalogEntry.presentationBackgroundInteraction`、`CatalogEntry.interactiveDismissDisabled`、`CatalogEntry.alert`、`CatalogEntry.confirmationDialog`、`CatalogEntry.dismissalConfirmationDialog`、`CatalogEntry.dialogIcon`、`CatalogEntry.dialogSuppressionToggle`、`CatalogEntry.inspector`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py modal-presentations`
Expected: 終了コード 1。抜けに presentationBackgroundInteraction・interactiveDismissDisabled・alert・confirmationDialog・dismissalConfirmationDialog・dialogIcon・dialogSuppressionToggle・inspector がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ModalPresentations/PresentationBackgroundInteractionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationBackgroundInteraction = CatalogEntry(
        id: "presentationBackgroundInteraction",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートを出している間も、後ろの画面を触れるようにするかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationbackgroundinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationBackgroundInteraction",
                .choice(
                    [
                        Choice(".automatic"), Choice(".enabled"), Choice(".enabled(upThrough: .height(200))"),
                        Choice(".disabled"),
                    ], initial: 1), on: true,
                summary: "後ろを触れるか。upThrough はその高さまで下がっているときだけ触れる")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    Button(\"+1: \\(count)\") { count += 1 }",
                "    Button(\"シートを開く\") { shows = true }", "        .sheet(isPresented: $shows) {",
            ], indent: 12, call: "Text", fixedArguments: ["\"シートの中身\""],
            suffix: [".presentationDetents([.height(200), .large])"], closing: ["        }", "}"]),
        build: { v in
            AnyView(
                PresentationBackgroundInteractionDemo(
                    interaction: v.pick(
                        "presentationBackgroundInteraction",
                        from: [
                            PresentationBackgroundInteraction.automatic, .enabled, .enabled(upThrough: .height(200)),
                            .disabled,
                        ])))
        }
    )
}

private struct PresentationBackgroundInteractionDemo: View {
    let interaction: PresentationBackgroundInteraction?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("+1: \(count)") { count += 1 }
                .buttonStyle(.bordered)
                .monospacedDigit()
            SheetModifierDemo {
                ModalSheetContent("シートの中身")
                    .apply(interaction) { $0.presentationBackgroundInteraction($1) }
                    .presentationDetents([.height(200), .large])
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 24)
    }
}
```

`WidgetLab/Catalog/ModalPresentations/InteractiveDismissDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let interactiveDismissDisabled = CatalogEntry(
        id: "interactiveDismissDisabled",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートや吹き出しを、指で下げたり外を押したりして閉じられないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/interactivedismissdisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "interactiveDismissDisabled", .toggle(initial: true), on: true,
                summary: "true なら指では閉じられない。閉じるボタン（dismiss）では閉じる")
        ],
        code: .inSheet("閉じるボタンでだけ閉じる"),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("閉じるボタンでだけ閉じる")
                        .apply(v.flag("interactiveDismissDisabled")) { $0.interactiveDismissDisabled($1) }
                })
        }
    )
}
```

`WidgetLab/Catalog/ModalPresentations/AlertEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let alert = CatalogEntry(
        id: "alert",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、題名とボタンを持つアラートを出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:)")!,
        stage: .card,
        properties: [
            .modifier(
                "alert",
                .choice(
                    [
                        Choice(
                            "OK だけ",
                            code: "\"保存しました\", isPresented: $shows, actions: { Button(\"OK\") { } }"),
                        Choice(
                            "削除と取り消し",
                            code:
                                "\"削除しますか？\", isPresented: $shows, actions: { Button(\"削除\", role: .destructive) { }; Button(\"やめる\", role: .cancel) { } }, message: { Text(\"元に戻せません\") }"
                        ),
                    ], initial: 1), on: true,
                summary: "題名・出すかどうかの Binding・ボタン（actions）・説明（message）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"アラートを出す\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(AlertDemo(kind: v.pick("alert", from: [AlertDemo.Kind.ok, .delete])))
        }
    )
}

private struct AlertDemo: View {
    enum Kind {
        case ok, delete
    }

    let kind: Kind?
    @State private var shows = false
    @State private var last = "（まだ押していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("アラートを出す") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .ok:
                        view.alert("保存しました", isPresented: $shows) {
                            Button("OK") { last = "OK" }
                        }
                    case .delete:
                        view.alert("削除しますか？", isPresented: $shows) {
                            Button("削除", role: .destructive) { last = "削除" }
                            Button("やめる", role: .cancel) { last = "やめる" }
                        } message: {
                            Text("元に戻せません")
                        }
                    }
                }
            Text("押したボタン: \(last)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/ConfirmationDialogEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let confirmationDialog = CatalogEntry(
        id: "confirmationDialog",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、選べる操作を並べた確かめのダイアログを出す modifier。iPhone では下から出る。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:actions:message:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "confirmationDialog", id: "confirmationDialog.title", .fixed(code: "\"写真を変える\""), required: true,
                summary: "題名"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.isPresented", label: "isPresented",
                .fixed(code: "$shows"), required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.titleVisibility", label: "titleVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "題名を出すか。.automatic は iPhone では隠す"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.actions", label: "actions",
                .fixed(code: "{ Button(\"写真を撮る\") { }; Button(\"削除\", role: .destructive) { } }"),
                required: true, summary: "並べる操作。やめるボタンは自動で足される"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.message", label: "message",
                .fixed(code: "{ Text(\"プロフィールの写真\") }"), on: true, summary: "題名の下の説明"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"写真を変える\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                ConfirmationDialogDemo(
                    visibility: v.pick(
                        "confirmationDialog.titleVisibility", from: [Visibility.automatic, .visible, .hidden]),
                    showsMessage: v["confirmationDialog.message"] != nil))
        }
    )
}

private struct ConfirmationDialogDemo: View {
    let visibility: Visibility?
    let showsMessage: Bool
    @State private var shows = false
    @State private var last = "（まだ押していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("写真を変える") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（titleVisibility・message）がどれも OFF なら、modifier ごと付けない
                .apply(visibility != nil || showsMessage ? () : nil) { view, _ in
                    view.confirmationDialog("写真を変える", isPresented: $shows, titleVisibility: visibility ?? .automatic) {
                        Button("写真を撮る") { last = "写真を撮る" }
                        Button("削除", role: .destructive) { last = "削除" }
                    } message: {
                        if showsMessage {
                            Text("プロフィールの写真")
                        }
                    }
                }
            Text("押したボタン: \(last)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/DismissalConfirmationDialogEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dismissalConfirmationDialog = CatalogEntry(
        id: "dismissalConfirmationDialog",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "この View を出している画面を閉じようとしたとき、閉じてよいかを確かめるダイアログを出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/dismissalconfirmationdialog(_:shouldpresent:actions:)"
        )!,
        noteReason: "iOS では窓（シーン）を閉じる操作で出る。iPhone でシートを指で下げても出なかった。iPad で窓を閉じるときや、Mac で効く",
        properties: [
            .modifier(
                "dismissalConfirmationDialog",
                .fixed(
                    code:
                        "\"書きかけを捨てますか？\", shouldPresent: !memo.isEmpty, actions: { Button(\"捨てる\", role: .destructive) { } }"
                ),
                on: true, summary: "題名・出すかどうか（書きかけがあるとき）・ボタン")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "TextField", fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["    }"])
    )
}
```

`WidgetLab/Catalog/ModalPresentations/DialogIconEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dialogIcon = CatalogEntry(
        id: "dialogIcon",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "この View の中で出すダイアログ（アラート・確かめのダイアログ）のアイコンを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dialogicon(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac ではアプリのアイコンの代わりに、Apple Watch ではダイアログの中に出る",
        properties: [
            .modifier(
                "dialogIcon", .fixed(code: "Image(systemName: \"trash\")"), on: true, summary: "ダイアログに出す画像")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"削除\") { shows = true }"], indent: 4, call: ".confirmationDialog",
            fixedArguments: ["\"削除しますか？\"", "isPresented: $shows"],
            trailing: " {\n        Button(\"削除\", role: .destructive) { }\n    }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/DialogSuppressionToggleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dialogSuppressionToggle = CatalogEntry(
        id: "dialogSuppressionToggle",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ダイアログに「今後は表示しない」のチェックを足し、選んだかを Binding に書く modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/dialogsuppressiontoggle(_:issuppressed:)")!,
        noteReason: "iPhone ではチェックが出ない。Mac のダイアログで効く",
        properties: [
            .modifier(
                "dialogSuppressionToggle", .fixed(code: "\"今後は確かめない\", isSuppressed: $suppressed"), on: true,
                summary: "チェックの文と、選んだかを書く Binding")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"削除\") { shows = true }"], indent: 4, call: ".alert",
            fixedArguments: ["\"削除しますか？\"", "isPresented: $shows"],
            trailing: " {\n        Button(\"削除\", role: .destructive) { }\n    }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/InspectorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let inspector = CatalogEntry(
        id: "inspector",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true のとき、選んだものの詳しい設定を出す欄（インスペクタ）を出す modifier。iPhone ではシートで出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/inspector(ispresented:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "inspector",
                .fixed(code: "isPresented: $shows, content: { Text(\"詳しい設定\").presentationDetents([.medium]) }"),
                on: true, summary: "出すかどうかの Binding と中身。iPad や Mac では右に列として出る")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"インスペクタを出す\""], trailing: " { shows.toggle() }"),
        build: { v in
            AnyView(InspectorDemo(inspects: v["inspector"] != nil))
        }
    )
}

private struct InspectorDemo: View {
    let inspects: Bool
    @State private var shows = false

    var body: some View {
        Button("インスペクタを出す") { shows.toggle() }
            .buttonStyle(.borderedProminent)
            .apply(inspects ? () : nil) { view, _ in
                view.inspector(isPresented: $shows) {
                    ModalSheetContent("詳しい設定")
                        .presentationDetents([.medium])
                }
            }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .presentationBackgroundInteraction,
        .interactiveDismissDisabled,
        .alert,
        .confirmationDialog,
        .dismissalConfirmationDialog,
        .dialogIcon,
        .dialogSuppressionToggle,
        .inspector,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/ModalPresentations/PresentationBackgroundInteractionEntry.swift WidgetLab/Catalog/ModalPresentations/InteractiveDismissDisabledEntry.swift WidgetLab/Catalog/ModalPresentations/AlertEntry.swift WidgetLab/Catalog/ModalPresentations/ConfirmationDialogEntry.swift WidgetLab/Catalog/ModalPresentations/DismissalConfirmationDialogEntry.swift WidgetLab/Catalog/ModalPresentations/DialogIconEntry.swift WidgetLab/Catalog/ModalPresentations/DialogSuppressionToggleEntry.swift WidgetLab/Catalog/ModalPresentations/InspectorEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 presentationBackgroundInteraction・interactiveDismissDisabled・alert・confirmationDialog・dismissalConfirmationDialog・dialogIcon・dialogSuppressionToggle・inspector

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 7: inspectorColumnWidth・fileExporter・fileExporterFilenameLabel・fileImporter・fileMover・fileDialogDefaultDirectory・fileDialogBrowserOptions

**Files:**
- Create: `WidgetLab/Catalog/ModalPresentations/InspectorColumnWidthEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileExporterEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileExporterFilenameLabelEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileImporterEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileMoverEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogDefaultDirectoryEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogBrowserOptionsEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: `CatalogEntry.inspectorColumnWidth`、`CatalogEntry.fileExporter`、`CatalogEntry.fileExporterFilenameLabel`、`CatalogEntry.fileImporter`、`CatalogEntry.fileMover`、`CatalogEntry.fileDialogDefaultDirectory`、`CatalogEntry.fileDialogBrowserOptions`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py modal-presentations`
Expected: 終了コード 1。抜けに inspectorColumnWidth・fileExporter・fileExporterFilenameLabel・fileImporter・fileMover・fileDialogDefaultDirectory・fileDialogBrowserOptions がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ModalPresentations/InspectorColumnWidthEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let inspectorColumnWidth = CatalogEntry(
        id: "inspectorColumnWidth",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "インスペクタを右の列として出すときの幅を決める modifier。インスペクタの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/inspectorcolumnwidth(_:)")!,
        noteReason: "iPhone ではインスペクタがシートで出るので、幅は効かない。iPad と Mac で、右の列として出るときに効く",
        properties: [
            .modifier(
                "inspectorColumnWidth", .slider(range: 200...400, step: 20, initial: 300), on: true,
                summary: "列の幅（ポイント）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"本文\")", "    .inspector(isPresented: $shows) {"], indent: 8, call: "Text",
            fixedArguments: ["\"詳しい設定\""], closing: ["    }"])
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileExporterEntry.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let fileExporter = CatalogEntry(
        id: "fileExporter",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、データをファイルに書き出す場所を選ぶシステムの画面を出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fileexporter(ispresented:item:contenttypes:defaultfilename:oncompletion:oncancellation:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fileExporter", id: "fileExporter.isPresented", label: "isPresented", .fixed(code: "$shows"),
                required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "fileExporter", id: "fileExporter.item", label: "item", .fixed(code: "\"買い物: 牛乳・卵\""),
                required: true, summary: "書き出すもの（Transferable。ここでは文字）"),
            .modifier(
                "fileExporter", id: "fileExporter.contentTypes", label: "contentTypes", .fixed(code: "[.plainText]"),
                on: true, summary: "書き出すファイルの種類"),
            .modifier(
                "fileExporter", id: "fileExporter.defaultFilename", label: "defaultFilename",
                .text(initial: "買い物メモ"), on: true, summary: "最初に入っているファイルの名前"),
            .modifier(
                "fileExporter", id: "fileExporter.onCompletion", label: "onCompletion",
                .fixed(code: "{ result = \"\\($0)\" }"), required: true, summary: "書き出したあと（失敗も）に呼ばれる"),
            .modifier(
                "fileExporter", id: "fileExporter.onCancellation", label: "onCancellation",
                .fixed(code: "{ result = \"やめた\" }"), required: true, summary: "やめたときに呼ばれる"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"書き出す\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                FileExporterDemo(
                    exports: v["fileExporter.contentTypes"] != nil || v["fileExporter.defaultFilename"] != nil,
                    types: v["fileExporter.contentTypes"] != nil ? [.plainText] : [],
                    filename: v.text("fileExporter.defaultFilename")))
        }
    )
}

private struct FileExporterDemo: View {
    let exports: Bool
    let types: [UTType]
    let filename: String?
    @State private var shows = false
    @State private var result = "（まだ書き出していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("書き出す") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（contentTypes・defaultFilename）がどれも OFF なら、modifier ごと付けない
                .apply(exports ? () : nil) { view, _ in
                    view.fileExporter(
                        isPresented: $shows, item: "買い物: 牛乳・卵", contentTypes: types, defaultFilename: filename
                    ) { outcome in
                        result = (try? outcome.get().lastPathComponent).map { "書き出した: \($0)" } ?? "失敗した"
                    } onCancellation: {
                        result = "やめた"
                    }
                }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/FileExporterFilenameLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileExporterFilenameLabel = CatalogEntry(
        id: "fileExporterFilenameLabel",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "fileExporter の画面の、ファイルの名前の欄に付ける見出しを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fileexporterfilenamelabel(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac の保存のダイアログで、名前の欄の見出しが変わる",
        properties: [
            .modifier("fileExporterFilenameLabel", .fixed(code: "Text(\"メモの名前\")"), on: true, summary: "名前の欄の見出し")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"書き出す\") { shows = true }"], indent: 4, call: ".fileExporter",
            fixedArguments: ["isPresented: $shows", "item: memo", "contentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileImporterEntry.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let fileImporter = CatalogEntry(
        id: "fileImporter",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、読み込むファイルを選ぶシステムの画面を出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowsmultipleselection:oncompletion:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fileImporter", id: "fileImporter.isPresented", label: "isPresented", .fixed(code: "$shows"),
                required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "fileImporter", id: "fileImporter.allowedContentTypes", label: "allowedContentTypes",
                .choice([Choice("[.item]"), Choice("[.image]"), Choice("[.plainText, .pdf]")], initial: 1), on: true,
                summary: "選べるファイルの種類。ほかの種類は薄く出て選べない"),
            .modifier(
                "fileImporter", id: "fileImporter.allowsMultipleSelection", label: "allowsMultipleSelection",
                .toggle(initial: true), summary: "true なら複数を選べる"),
            .modifier(
                "fileImporter", id: "fileImporter.onCompletion", label: "onCompletion",
                .fixed(code: "{ result = \"\\($0)\" }"), required: true, summary: "選んだあと（やめたときも）に呼ばれる"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"ファイルを選ぶ\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                FileImporterDemo(
                    types: v.pick(
                        "fileImporter.allowedContentTypes", from: [[UTType.item], [.image], [.plainText, .pdf]]),
                    multiple: v.flag("fileImporter.allowsMultipleSelection")))
        }
    )
}

private struct FileImporterDemo: View {
    let types: [UTType]?
    let multiple: Bool?
    @State private var shows = false
    @State private var result = "（まだ選んでいない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("ファイルを選ぶ") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（allowedContentTypes・allowsMultipleSelection）がどれも OFF なら、modifier ごと付けない
                .apply(types != nil || multiple != nil ? () : nil) { view, _ in
                    view.fileImporter(
                        isPresented: $shows, allowedContentTypes: types ?? [],
                        allowsMultipleSelection: multiple ?? false
                    ) { outcome in
                        result = (try? outcome.get()).map { "選んだ: \($0.count) 件" } ?? "やめた・失敗した"
                    }
                }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/FileMoverEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileMover = CatalogEntry(
        id: "fileMover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、あるファイルを別の場所へ動かすシステムの画面を出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/filemover(ispresented:file:oncompletion:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fileMover", .fixed(code: "isPresented: $shows, file: memoURL, onCompletion: { result = \"\\($0)\" }"),
                on: true, summary: "出すかどうかの Binding・動かすファイルの URL・動かしたあとに呼ばれる処理")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"メモを動かす\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(FileMoverDemo(moves: v["fileMover"] != nil))
        }
    )
}

private struct FileMoverDemo: View {
    let moves: Bool
    @State private var shows = false
    @State private var file: URL?
    @State private var result = "（まだ動かしていない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("メモを動かす") {
                // 動かすファイルを、押すたびに一時フォルダに作る
                let url = URL.temporaryDirectory.appending(path: "動かすメモ.txt")
                try? "買い物: 牛乳・卵".write(to: url, atomically: true, encoding: .utf8)
                file = url
                shows = true
            }
            .buttonStyle(.borderedProminent)
            .apply(moves ? () : nil) { view, _ in
                view.fileMover(isPresented: $shows, file: file) { outcome in
                    result = (try? outcome.get().lastPathComponent).map { "動かした: \($0)" } ?? "やめた・失敗した"
                }
            }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogDefaultDirectoryEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogDefaultDirectory = CatalogEntry(
        id: "fileDialogDefaultDirectory",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "fileExporter・fileImporter・fileMover の画面を、はじめに開くフォルダを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogdefaultdirectory(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fileDialogDefaultDirectory", .fixed(code: "URL.documentsDirectory"), on: true,
                summary: "はじめに開くフォルダ")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.item]"], trailing: " { _ in }"),
        build: { v in
            AnyView(
                FileDialogDefaultDirectoryDemo(
                    directory: v["fileDialogDefaultDirectory"] != nil ? URL.documentsDirectory : nil))
        }
    )
}

private struct FileDialogDefaultDirectoryDemo: View {
    let directory: URL?
    @State private var shows = false

    var body: some View {
        Button("ファイルを選ぶ") { shows = true }
            .buttonStyle(.borderedProminent)
            .fileImporter(isPresented: $shows, allowedContentTypes: [.item]) { _ in }
            .apply(directory) { $0.fileDialogDefaultDirectory($1) }
    }
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogBrowserOptionsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogBrowserOptions = CatalogEntry(
        id: "fileDialogBrowserOptions",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログで、隠しファイルを出すか・パッケージの中を開けるかなどを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogbrowseroptions(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、隠しファイルなどの出し方が変わる",
        properties: [
            .modifier(
                "fileDialogBrowserOptions",
                .choice(
                    [Choice(".includeHiddenFiles"), Choice(".displayFileExtensions"), Choice(".enumeratePackages")],
                    initial: 0), on: true, summary: "ファイルの出し方")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .inspectorColumnWidth,
        .fileExporter,
        .fileExporterFilenameLabel,
        .fileImporter,
        .fileMover,
        .fileDialogDefaultDirectory,
        .fileDialogBrowserOptions,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/ModalPresentations/InspectorColumnWidthEntry.swift WidgetLab/Catalog/ModalPresentations/FileExporterEntry.swift WidgetLab/Catalog/ModalPresentations/FileExporterFilenameLabelEntry.swift WidgetLab/Catalog/ModalPresentations/FileImporterEntry.swift WidgetLab/Catalog/ModalPresentations/FileMoverEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogDefaultDirectoryEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogBrowserOptionsEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 画面の行き来の収録 inspectorColumnWidth・fileExporter・fileExporterFilenameLabel・fileImporter・fileMover・fileDialogDefaultDirectory・fileDialogBrowserOptions

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 8: fileDialogConfirmationLabel・fileDialogCustomizationID・fileDialogImportsUnresolvedAliases・fileDialogMessage・fileDialogURLEnabled と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogConfirmationLabelEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogCustomizationIDEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogImportsUnresolvedAliasesEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogMessageEntry.swift`
- Create: `WidgetLab/Catalog/ModalPresentations/FileDialogURLEnabledEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（試作でわかったこと・`.note` の数え方）
- Modify: `docs/adr/ADR-0002-data-driven-demos.md`（`.full` の仕組みと `.note` の数え方）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: `CatalogEntry.fileDialogConfirmationLabel`、`CatalogEntry.fileDialogCustomizationID`、`CatalogEntry.fileDialogImportsUnresolvedAliases`、`CatalogEntry.fileDialogMessage`、`CatalogEntry.fileDialogURLEnabled`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py modal-presentations`
Expected: 終了コード 1。抜けに fileDialogConfirmationLabel・fileDialogCustomizationID・fileDialogImportsUnresolvedAliases・fileDialogMessage・fileDialogURLEnabled がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/ModalPresentations/FileDialogConfirmationLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogConfirmationLabel = CatalogEntry(
        id: "fileDialogConfirmationLabel",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの、決めるボタンの文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogconfirmationlabel(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac のファイルのダイアログで、決めるボタンの文が変わる",
        properties: [
            .modifier("fileDialogConfirmationLabel", .text(initial: "読み込む"), on: true, summary: "決めるボタンの文")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogCustomizationIDEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogCustomizationID = CatalogEntry(
        id: "fileDialogCustomizationID",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの大きさや開いていたフォルダを、id ごとに覚えて次に戻す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogcustomizationid(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、大きさや開いていたフォルダを覚える",
        properties: [
            .modifier("fileDialogCustomizationID", .text(initial: "memoImport"), on: true, summary: "覚えておく単位の id")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogImportsUnresolvedAliasesEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogImportsUnresolvedAliases = CatalogEntry(
        id: "fileDialogImportsUnresolvedAliases",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログでエイリアスを選んだとき、指す先でなくエイリアスそのものを渡すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/filedialogimportsunresolvedaliases(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、エイリアス（別名）を選んだときに効く",
        properties: [
            .modifier(
                "fileDialogImportsUnresolvedAliases", .toggle(initial: true), on: true, summary: "true ならエイリアスそのものを渡す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogMessageEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogMessage = CatalogEntry(
        id: "fileDialogMessage",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの上に、題名のような説明の文を出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogmessage(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac のファイルのダイアログで、上に説明の文が出る",
        properties: [
            .modifier("fileDialogMessage", .fixed(code: "Text(\"読み込むメモを選んでください\")"), on: true, summary: "上に出す説明の文")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

`WidgetLab/Catalog/ModalPresentations/FileDialogURLEnabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogURLEnabled = CatalogEntry(
        id: "fileDialogURLEnabled",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログで、条件に合うファイルだけを選べるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogurlenabled(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、条件に合わないファイルが選べなくなる",
        properties: [
            .modifier(
                "fileDialogURLEnabled", .fixed(code: "#Predicate<URL> { $0.lastPathComponent.hasPrefix(\"メモ\") }"),
                on: true, summary: "選べるファイルの条件")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .fileDialogConfirmationLabel,
        .fileDialogCustomizationID,
        .fileDialogImportsUnresolvedAliases,
        .fileDialogMessage,
        .fileDialogURLEnabled,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す。シートの中身にかける modifier と、全画面で開く NavigationStack の代表を 1 件ずつ撮る:

```swift
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
```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「レイアウト・描画・テキスト・操作の部品の代表 2 件ずつのスクリーンショットの 8 本」を、「レイアウト・描画・テキスト・操作の部品・画面の行き来の代表 2 件ずつのスクリーンショットの 9 本」に置き換える（ほかの束が先に本数を変えていたら、その本数に 1 を足す）

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 4 か所だけ直す（ほかの行は変えない）。

1. 5 章の「束 4 は `testDrawingEntriesShowPreview`）。」を「束 4 は `testDrawingEntriesShowPreview`、束 7 は `testNavigationEntriesShowPreview`）。」に置き換える
2. 7 章の `**違いが幅に左右されるもの → 幅を刻んで描き比べる。**` の段落のあと（`## 用語` の前）に、空行を挟んで次の段落を足す:

```markdown
**画面を重ねて出すもの → `.card` でボタンから出す。** sheet・alert・popover・fileImporter などは、見本をボタンにすると、押したときに詳細の画面の上に出る。比べるでは、仕切りの右（付けた側）のボタンを押したときだけ出る。シートの中身にかける modifier（`presentationDetents` など）は、`Catalog/ModalPresentations/ModalDemo.swift` の `SheetModifierDemo` で開き、コードは `CodeTemplate.inSheet()`（`Button` → `.sheet {` → 中身の `Text` に modifier）の形にする（束 7）。

**画面の行き来の入れ物 → `.full` にする。** NavigationStack・TabView などを枠の中に描くと、詳細の NavigationStack の中に入れ子になる。全画面で開けば、題名・戻るボタン・タブバーがふつうに出る。中の画面にかける modifier（`navigationTitle` など）も同じ（束 7）。

**iPhone では出ないもの（束 7 で `.note` にした）:** TabView のサイドバー（`defaultTabBarPlacement(.sidebar)` でも、iOS 27.0 の iPhone 18 Pro ではタブバーのまま。サイドバーにかける modifier は見えない）、シートの大きさと置き場所（`presentationSizing`・`presentationPlacement`。iPhone のシートはいつも幅いっぱい）、`dismissalConfirmationDialog`（シートを下げても出なかった）。`sectionActions` は List の Section でも効くので `.card` にした。

**システムのファイルの画面を撮る → 押してから 5 秒ほど待つ。** fileImporter・fileExporter・fileMover の画面は、出るまで数秒かかる。

**`preferredColorScheme` を全画面で試す → 「付けない」に切り替えても暗いまま。** 表示の単位が最後の値を覚えているため。閉じれば詳細は元の見た目に戻る。
```

3. 3 章の「`.note` が全体の 1 割を超えたら ADR-0002 を見直す約束になっている。」を、次に置き換える:

```markdown
`.note` のうち、iPhone で見せる工夫が足りずに `.note` にしたものが全体の 1 割を超えたら、ADR-0002 を見直す約束になっている。iPhone では効かないと公式か試作で確かめたもの（iPad・Mac・Apple Watch だけで効くもの、アプリ拡張の中で効くもの）は数えない（2026-11-04 束 7 で決定。束 7 の 19 件で、`.note` が全体の 13% になったため）。
```

4. 最後の行「最終更新: 2026-11-04（束 2・3・4 のあと）」を「最終更新: 2026-11-04（束 7 のあと）」に置き換える

- [ ] **Step 6: ADR-0002 に、`.full` の仕組みと `.note` の数え方を足す**

`docs/adr/ADR-0002-data-driven-demos.md` を、次の 2 か所だけ直す。

1. `## 結果` の前に、空行を挟んで次の節を足す:

```markdown
## 全画面で試すものと、説明だけのものの数え方（2026-11-04 束 7 で追加）
- `.full` の収録は、詳細のプレビューの枠に「試す」のボタンだけを出し、押すと見本を `fullScreenCover` で全画面に出す。下の帯で、選んでいるプロパティの付けない／付けたを切り替える。状態は `DetailViewModel`（`isTryingFull`・`trialShowsWith`・`trialValues`）に持ち、収録の型は変えない。画面の行き来の入れ物（NavigationStack・TabView）は、枠の中では詳細の NavigationStack の入れ子になるため、全画面で開く
- 選ばなかった案（`.full`）: 枠の中に描いたまま「試す」も足す（入れ子と、表示の単位に効く modifier が詳細で効く問題が残る）／ボタンを見本の上に浮かせる（タブバーやナビゲーションバーを隠す）／全画面に編集パネルも出す（見本が狭くなる）
- `.note` の 1 割の見直しのきっかけは、iPhone で見せる工夫が足りずに `.note` にしたものだけで数える。iPhone では効かないと公式か試作で確かめたもの（iPad・Mac・Apple Watch だけで効く、アプリ拡張の中で効く）は数えない。束 7 で、iPad・Mac のサイドバーや列、Mac のファイルのダイアログなど 19 件が `.note` になり、全体で 13% になった。これらは画面を足しても iPhone では見せられず、きっかけの狙い（見せる工夫の手抜きを見つける）から外れるため（2026-11-04 オーナーが決定）
- 選ばなかった案（`.note` の数え方）: きっかけをそのまま使い、収録の型を見直す（型を変えても iPhone で効き目は出ない）／見直しを束 12 にまとめる（数え方があいまいなまま束 8〜11 が進む）
```

2. `## 結果` の「見直すきっかけ」の行の最後の「`.note` の収録が 1 割を超えたとき」を、「iPhone で見せる工夫が足りずに `.note` にした収録が 1 割を超えたとき（iPhone では効かないと確かめたものは数えない）」に置き換える


- [ ] **Step 7: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テストが全部通る

Run: `python3 tools/catalog_progress.py navigation modal-presentations`
Expected: 終了コード 0。`合計 49 / 49（抜け 0）`

- [ ] **Step 8: コミットする**

```bash
git add WidgetLab/Catalog/ModalPresentations/FileDialogConfirmationLabelEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogCustomizationIDEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogImportsUnresolvedAliasesEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogMessageEntry.swift WidgetLab/Catalog/ModalPresentations/FileDialogURLEnabledEntry.swift WidgetLab/Catalog/Catalog.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md docs/adr/ADR-0002-data-driven-demos.md
git commit -m "feat: 画面の行き来の収録 fileDialogConfirmationLabel・fileDialogCustomizationID・fileDialogImportsUnresolvedAliases・fileDialogMessage・fileDialogURLEnabled と束の確かめ

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

## 終わったら

- 束の最終レビュー（opus）を通す
- `~/dev/widget-lab`（main）で、`git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からある）で、ほかの束がマージの途中でないことを確かめてから、`git merge --no-ff feat/swiftui-p3-navigation` する。`Catalog.swift`・`docs/architecture.md`・`docs/cataloging-guide.md` がぶつかったら両方の行を残す
- マージのあと、main の `swiftui/` で lint と単体テスト（Global Constraints の確かめのコマンド）を通してから push する。ブランチは消さない
