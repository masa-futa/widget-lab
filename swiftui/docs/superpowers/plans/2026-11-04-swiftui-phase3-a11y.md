# SwiftUI 版 Phase 3 束 11（アクセシビリティ）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** accessibility-fundamentals・accessible-appearance・accessible-controls・accessible-descriptions・accessible-navigation の 39 件を収録して、5 トピックの抜けを 0 にする。main（束 10 までマージ済み）を取り込み、「抜け 0」を `CatalogTests` の条件にする（spec の「束 11 で」）。

**Architecture:** 1 件 = 1 ファイルの収録データを 4〜8 件ずつ足し、`Catalog.all` に並べる。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator`、詳細画面は変えない。VoiceOver などの支援技術がないと効き目が見えないので、見本の下に「支援技術に渡る中身」の札（`A11yDemo`）を出す。札は見本に渡したのと同じ値から書き、中身は試作で UI テストのアクセシビリティの木と突き合わせた。stage は `.card` が 38 件、`.note` が 1 件。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Accessibility（`AXChartDescriptor`）/ Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 11 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone 17**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドのまま（`name=iPhone 17`）でよい
- 並列で束 10 が動いている。`xcodebuild` には `-derivedDataPath "$PWD/build"`（このワークツリーの `build/` の絶対の道）を渡し、終わりを待つときは `pgrep -f "derivedDataPath $PWD/build"` で自分の xcodebuild だけを見る（ほかの束の xcodebuild を待たない・止めない）
- `WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない。変えたくなったら、変える前にコントローラーに知らせて止まる（並列の束とぶつかるため）
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）
- この計画に書いたコードは、試作でテストとスクリーンショットを通したもの。そのまま写す。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける。コントローラーが試作のファイルと `cmp` で比べる
- 確かめ（各タスクの終わり）:
  ```
  mkdir -p build
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath "$PWD/build" CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests > build/test.log 2>&1
  ```
  UI テストまで通すのは Task 6 だけ（`-only-testing:WidgetLabTests` を外す）。結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む。コマンドを裏で流したときは、`while pgrep -f "derivedDataPath $PWD/build" > /dev/null; do sleep 10; done` で終わりを待つ
- テストが進まず止まったら: `pkill -f "derivedDataPath $PWD/build"` → もう一度（`xcrun simctl shutdown all` は、ほかの束のシミュレータも止めるので使わない）。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 支援技術の効き目を画面に出す（この束で決めた）

アクセシビリティの modifier は、VoiceOver・音声コントロール・スイッチコントロールなどの支援技術が動いていないと、見た目が変わらない。そこで全件に、見本の下に「支援技術に渡る中身」の札を出す。

- **札は `A11yDemo`（`Catalog/AccessibilityFundamentals/AccessibilityDemo.swift`）で出す。** `A11yDemo(title:lines:) { 見本 }` と書くと、上に見本、下に札が並ぶ。札そのものは `accessibilityHidden(true)` で、VoiceOver では読まない
- **札は、見本に渡したのと同じ値から書く。** はじめは、見本を別の `UIHostingController` で描き、その `accessibilityElements` を読んで札に出す形を試した。しかし SwiftUI は、支援技術が動いていないとアクセシビリティの要素を作らない（試作の単体テストで、ホストの View の要素は 0 件だった）。アプリの中から木を読めないので、値から書く
- **札の中身は、試作で UI テストの木と突き合わせた。** UI テストはアクセシビリティの木を読める（`app.debugDescription`）。39 件を撮り、札の書き方を実際のラベル・値に合わせた（下の「試作でわかったこと」）。束の終わりの UI テスト `testA11yEntriesShowPreview` も、木にラベルが届いたことを確かめる
- **札の書き方:** 要素 1 つは `A11yText.element(_:value:traits:hint:)` で「「星」 値「3」 .isButton ヒント「…」」の形にする。特性は SwiftUI の名前（`.isButton`・`.isHeader`・`.isImage`・`.isToggle`・`.isSelected`）で書き、VoiceOver が日本語でどう読むかは書かない（言い方を当て推量で書かないため）。読む順のあるものは `A11yText.ordered` で番号を付ける
- **触れる場所の modifier（activationPoint・dragPoint・dropPoint）は、赤い点で場所を出す。** `A11yPointMarker`（`Catalog/AccessibleControls/AccessibilityPointDemo.swift`）

こうすると、支援技術がなくても違いが目で見え、VoiceOver を入れれば実際の読み上げで確かめられる。`.note` の基準（アプリの 1 画面の中で、効き目を見ることも触ることもできない）に当たらないので、`.card` にした。

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）と、プロパティラッパーの「ラッパー」。プロパティはチップの順。* は最初から ON、R は required。札は「最初の値の札 / 付けない札」。

### accessibility-fundamentals（5 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） | 札 |
|---|---|---|---|---|---|
| accessibilityElement | .card | 付け外し | .accessibilityElement*（.combine・.ignore・.contain） | `HStack { Image(systemName: "star.fill").accessibilityLabel("星"); Text("お気に入り"); Text("12") }.accessibilityElement(children: .combine)` | 「星、お気に入り、12」（1 つ） / 3 つを順に |
| accessibilityChildren | .card | 付け外し | .accessibilityChildren*（`{ HStack { ForEach(days) { day in Rectangle().accessibilityLabel(day.name).accessibilityValue(…) } } }`） | `Canvas { … }.accessibilityLabel("歩数").accessibilityChildren(children: { … })` | 「歩数」の組の中に月・火・水 / 「歩数」（中の棒は読まない） |
| accessibilityRepresentation | .card | 付け外し | .accessibilityRepresentation*（`{ Toggle("通知", isOn: $isOn) }`） | `Capsule()…onTapGesture { isOn.toggle() }.accessibilityRepresentation(representation: { Toggle("通知", isOn: $isOn) })` | 「通知」 値「1」 .isToggle / 読まない |
| accessibilityIdentifier | .card | 付け外し | .accessibilityIdentifier*（文字、"save-button"） | `Button("保存") { save() }.accessibilityIdentifier("save-button")` | `app.buttons["save-button"]` / `app.buttons["保存"]` |
| accessibilityHidden | .card | 付け外し | .accessibilityHidden*（toggle、true） | `HStack { Image(systemName: "sparkles").accessibilityHidden(true); Text("新着") }` | 「新着」 / 「ぴかぴか」 .isImage →「新着」 |

### accessible-appearance（3 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） | 札 |
|---|---|---|---|---|---|
| accessibilityIgnoresInvertColors | .card | 付け外し | .accessibilityIgnoresInvertColors*（toggle、true） | `HStack { Image("sunset").accessibilityIgnoresInvertColors(true); Text("夕焼け") }` | スマート反転で写真が元の色のまま / 写真も反転する。どちらも「今のスマート反転: 入・切」（環境の値） |
| accessibilityShowsLargeContentViewer | .card | 付け外し | .accessibilityShowsLargeContentViewer*（既定・中身を渡す） | `Button { goHome() } label: { Image(systemName: "house") }.accessibilityShowsLargeContentViewer()` | 長押しで家の絵が大きく出る / 出ない。どちらも「今は使える・使えない」（環境の値） |
| assistiveAccessNavigationIcon | .note | 付け外し | .assistiveAccessNavigationIcon*（`systemImage: "photo"`・`Image("PhotosIcon")`） | `NavigationStack { Text("写真の一覧").assistiveAccessNavigationIcon(systemImage: "photo").navigationTitle("写真") }` | – |

### accessible-controls（12 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） | 札 |
|---|---|---|---|---|---|
| accessibilityAction | .card | 付け外し | .accessibilityAction*（名前を付ける `named: "既読にする", { isRead = true }`・`.magicTap, { … }`） | `Text(isRead ? "既読: 会議の件" : "未読: 会議の件").accessibilityAction(named: "既読にする", { isRead = true })` | 上下にスワイプして「既読にする」 / 操作なし |
| accessibilityActions | .card | 付け外し | .accessibilityActions*（`{ Button("既読にする") { … }; Button("旗を付ける") { … } }`） | `Text(…).accessibilityActions({ … })` | 既読にする・旗を付ける / 操作なし |
| accessibilityAdjustableAction | .card | 付け外し | .accessibilityAdjustableAction*（`{ direction in rating += direction == .increment ? 1 : -1 }`） | `StarRating(rating: $rating).accessibilityElement().accessibilityLabel("評価").accessibilityValue("\(rating) 個").accessibilityAdjustableAction({ … })` | 「評価」 値「3 個」 .adjustable / VoiceOver からは変えられない |
| accessibilityScrollAction | .card | 付け外し | .accessibilityScrollAction*（`{ edge in page += edge == .trailing ? 1 : -1 }`） | `Text("\(page) / 5 ページ").accessibilityScrollAction({ … })` | 3 本指で左右にスワイプしてページを送る / 変わらない |
| accessibilityActivationPoint | .card | 付け外し | .accessibilityActivationPoint*（スイッチの上 `UnitPoint(x: 0.85, y: 0.5)`・.leading） | `HStack { Text("Wi-Fi"); Spacer(); Toggle("", isOn: $isOn).labelsHidden() }.accessibilityActivationPoint(…).accessibilityElement(children: .combine)` | 赤い点 / 赤い点（既定の真ん中） |
| accessibilityDragPoint | .card | 付け外し | .accessibilityDragPoint R（.topLeading・.center）・.accessibilityDragPoint(description:)*（文字、"写真を運ぶ"） | `Image("sunset").accessibilityDragPoint(.topLeading, description: "写真を運ぶ").draggable(photo)` | 「写真を運ぶ」と赤い点 / 既定の名前で真ん中から |
| accessibilityDropPoint | .card | 付け外し | .accessibilityDropPoint R（.trailing・.center）・.accessibilityDropPoint(description:)*（文字、"アルバムに入れる"） | `Label("アルバム", systemImage: "photo.on.rectangle").accessibilityDropPoint(.trailing, description: "アルバムに入れる").dropDestination(…)` | 「アルバムに入れる」と赤い点 / 既定の名前で真ん中で |
| accessibilityDirectTouch | .card | 付け外し | .accessibilityDirectTouch.isDirectTouchArea*（toggle、true）・.accessibilityDirectTouch(options:)（.silentOnTouch・.requiresActivation） | `Piano().accessibilityDirectTouch(true)` | 触れた鍵盤がすぐ鳴る / 選んで 2 回タップ |
| accessibilityZoomAction | .card | 付け外し | .accessibilityZoomAction*（`{ action in zoom += action.direction == .zoomIn ? 1 : -1 }`） | `Image(systemName: "map").accessibilityZoomAction({ … }).scaleEffect(CGFloat(zoom))` | 「地図」 値「1 倍」と拡大・縮小の操作 / 変えられない |
| accessibilityFocused | .card | 付け外し（入れ子） | .accessibilityFocused*（`$isTotalFocused`） | `VStack { Button("合計へ移る") { isTotalFocused = true }; Text("合計: 1,200 円").accessibilityFocused($isTotalFocused) }` | `isTotalFocused` の今の値と「カーソルが合計に移る」 / 動かない |
| AccessibilityFocusState | .card | ラッパー | @AccessibilityFocusState | `@AccessibilityFocusState private var isTotalFocused: Bool` と `.accessibilityFocused($isTotalFocused)`。外すと `@State private var isTotalFocused = false  // カーソルとつながらない` で `.accessibilityFocused` も書けない | 同上 / ただの値 |
| accessibilityRespondsToUserInteraction | .card | 付け外し | .accessibilityRespondsToUserInteraction*（toggle、true） | `Text("お知らせ 3 件").accessibilityRespondsToUserInteraction(true).onTapGesture { showNotices() }` | 押せる要素として選べる / 選ばれない |

### accessible-descriptions（15 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） | 札 |
|---|---|---|---|---|---|
| accessibilityLabel | .card | 付け外し | .accessibilityLabel*（文字、"ごみ箱に入れる"） | `Button { moveToTrash() } label: { Image(systemName: "trash") }.accessibilityLabel("ごみ箱に入れる")` | 「ごみ箱に入れる」 .isButton / 「ゴミ箱」 .isButton |
| accessibilityInputLabels | .card | 付け外し | .accessibilityInputLabels*（`["保存", "セーブ"]`） | `Button("保存して閉じる") { saveAndClose() }.accessibilityInputLabels(["保存", "セーブ"])` | 「保存をタップ」「セーブをタップ」 / 「保存して閉じるをタップ」 |
| accessibilityLabeledPair | .card | 付け外し（入れ子） | .accessibilityLabeledPair*（`role: .content, id: "notify", in: namespace`） | `HStack { Text("通知").accessibilityLabeledPair(role: .label, …); Toggle("", isOn: $isOn).labelsHidden().accessibilityLabeledPair(role: .content, …) }` | 「通知」 値「1」 .isToggle / 「通知」→（ラベルなし）の 2 つ |
| accessibilityValue | .card | 付け外し | .accessibilityValue*（文字、"75%"） | `Image(systemName: "battery.75percent").accessibilityLabel("電池").accessibilityValue("75%")` | 「電池」 値「75%」 .isImage / 値なし |
| accessibilityTextContentType | .card | 付け外し | .accessibilityTextContentType*（.sourceCode・.console・.narrative） | `Text("let total = price * 2").accessibilityTextContentType(.sourceCode).monospaced()` | ソースコード / ふつうの文（.plain） |
| accessibilityHeading | .card | 付け外し（入れ子） | .accessibilityHeading*（.h1・.h2・.h3、最初は .h2） | `VStack(alignment: .leading) { Text("お知らせ").accessibilityHeading(.h2).accessibilityAddTraits(.isHeader); Text("明日は休みです") }` | 「お知らせ」 .isHeader 段 2 / 段なし |
| accessibilityChartDescriptor | .card | 付け外し | .accessibilityChartDescriptor*（`StepsChart()`） | `HStack(alignment: .bottom) { … }.accessibilityElement().accessibilityLabel("歩数").accessibilityChartDescriptor(StepsChart())` と `struct StepsChart: AXChartDescriptorRepresentable` | 題名・軸とオーディオグラフ / 中身は伝わらない |
| accessibilityCustomContent | .card | 付け外し | .accessibilityCustomContent.content*（産地・値段）・.accessibilityCustomContent(importance:) R（.default・.high） | `Text("りんご").accessibilityCustomContent("産地", "青森", importance: .default)` | ローターの「詳しい情報」で 産地 青森 / なし |
| accessibilityAddTraits | .card | 付け外し | .accessibilityAddTraits*（.isButton・[.isButton, .isSelected]・.isHeader） | `Text("お気に入り").accessibilityAddTraits(.isButton).onTapGesture { isFavorite.toggle() }` | 「お気に入り」 .isButton / 特性なし |
| accessibilityRemoveTraits | .card | 付け外し | .accessibilityRemoveTraits*（`.isImage`） | `Image(systemName: "star.fill").accessibilityLabel("評価 3").accessibilityRemoveTraits(.isImage)` | 「評価 3」 / 「評価 3」 .isImage |
| accessibilityHint | .card | 付け外し | .accessibilityHint*（文字、"メールを送って、一覧に戻ります"） | `Button("送る") { send() }.accessibilityHint("メールを送って、一覧に戻ります")` | ヒント付き / ヒントなし |
| speechAdjustedPitch | .card | 付け外し | .speechAdjustedPitch*（スライダー -1〜1、0.5 刻み、0.5） | `Text("電池が残りわずかです").speechAdjustedPitch(0.5)` | ふつうより高い声で読む（0.5） / ふつうの高さ |
| speechAlwaysIncludesPunctuation | .card | 付け外し | .speechAlwaysIncludesPunctuation*（toggle、true） | `Text("a + b = 10;").speechAlwaysIncludesPunctuation(true)` | 記号もすべて読む / 設定に従う |
| speechAnnouncementsQueued | .card | 付け外し（入れ子） | .speechAnnouncementsQueued*（toggle、true） | `VStack { Button("進める") { progress += 25 }; Text("ダウンロード \(progress)%").speechAnnouncementsQueued(true) }` | 今の読み上げのあとに読む / 止めてすぐ読む |
| speechSpellsOutCharacters | .card | 付け外し | .speechSpellsOutCharacters*（toggle、true） | `Text("XK7-29Q").speechSpellsOutCharacters(true)` | 1 文字ずつ読む / ひと続きに読む |

### accessible-navigation（4 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） | 札 |
|---|---|---|---|---|---|
| accessibilityRotor | .card | 付け外し | .accessibilityRotor*（未読 `"未読", entries: unreadMails, entryLabel: \.subject`・既読） | `VStack { ForEach(mails) { mail in MailRow(mail: mail) } }.accessibilityRotor("未読", entries: unreadMails, entryLabel: \.subject)` | 「未読」: 会議の件 → 請求書 / 足した項目なし |
| accessibilityRotorEntry | .card | 付け外し（入れ子） | .accessibilityRotorEntry*（`id: mail.id, in: namespace`） | `VStack { ForEach(mails) { mail in MailRow(mail: mail).accessibilityRotorEntry(id: mail.id, in: namespace) } }.accessibilityRotor("未読") { ForEach(unreadMails) { mail in AccessibilityRotorEntry(mail.subject, mail.id, in: namespace) } }` | 「未読」で行へ飛ぶ / 飛ぶ先が決まらない |
| accessibilityLinkedGroup | .card | 付け外し（入れ子） | .accessibilityLinkedGroup*（`id: "q1", in: namespace`） | `VStack(alignment: .leading) { Text("問 1: …").accessibilityLinkedGroup(id: "q1", in: namespace); Text("問 2: …"); Divider(); Text("答え 1: 5").accessibilityLinkedGroup(id: "q1", in: namespace); Text("答え 2: 8") }` | 問 1 と答え 1 を行き来できる / 順にしか進めない |
| accessibilitySortPriority | .card | 付け外し（入れ子） | .accessibilitySortPriority*（スライダー -1〜2、1 刻み、1） | `VStack { Text("りんご"); Text("200 円").accessibilitySortPriority(1); Text("青森") }.accessibilityElement(children: .contain)` | 1.「200 円」2.「りんご」3.「青森」 / 上から順 |

### 「付け外し（入れ子）」と、片方だけ付け外すもの

`accessibilityLabeledPair`・`accessibilityLinkedGroup` は、2 つの View に同じ modifier を付けて組にする。`CodeGenerator` は 1 つのプロパティから 1 行しか書けないので、片方（ラベルの側・問 1 の側）を `prefix` にいつも書き、もう片方（中身の側・答え 1 の側）を付け外しにした。OFF では組の片方しかないので、組にならない（見本も同じ）。`accessibilityRotorEntry` も同じ考えで、ローターの側を `closing` にいつも書き、行の側を付け外しにした。

### `.note` にするもの（1 件、3%）と理由

| id | 理由（`noteReason`） |
|---|---|
| assistiveAccessNavigationIcon | アシスティブアクセス（設定で入れる、ホーム画面ごと簡単な見た目に切り替える仕組み）のときだけ効く。アプリの中からは切り替えられない。アシスティブアクセスに対応したアプリで、画面の題名の横に絵を出すときに使う |

手引きの数え方（iPhone で見せる工夫が足りずに `.note` にしたものだけ数える）では、この 1 件を数える（iPhone で効くが、アプリの外の設定のモードが要るため。厳しめに数えた）。

選ばなかった案:

| 案 | 選ばなかった理由 |
|---|---|
| 見本を別の `UIHostingController` で描き、`accessibilityElements` を読んで札に出す | 支援技術が動いていないと SwiftUI が要素を作らず、0 件だった（試作で確かめた） |
| VoiceOver がないと効き目の見えないもの（speech の 4 件・rotor など）を `.note` にする | 札で違いが見え、VoiceOver を入れればアプリの中で聞いて確かめられる。`.note` の基準（見ることも触ることもできない）に当たらない |
| 札に VoiceOver の日本語の読み上げ（「ボタン」「見出し」など）をそのまま書く | 言い方を当て推量で書くことになる。特性は SwiftUI の名前で書いた |
| `assistiveAccessNavigationIcon` を、`AssistiveAccess` のシーンや Preview の trait で見せる | アプリのシーンを足すことになり（収録の型の外）、アシスティブアクセスに入らないと出ない |

### 試作でわかったこと（Task 6 で収録の手引きに足す）

- **SwiftUI は、支援技術が動いていないとアクセシビリティの要素を作らない。** `UIHostingController` の View の `accessibilityElements` は空だった。UI テストの中では作られる（UI テストが支援技術として木を読むため）
- **札の中身は、一時的な UI テストの `app.debugDescription` と突き合わせて書く。** 突き合わせて直したもの: `.combine` のラベルは「、」でつなぐ（「星、お気に入り、12」）。SF Symbols の既定のラベルは日本語の名前になる（`trash` は「ゴミ箱」、`sparkles` は「ぴかぴか」、`envelope.badge` は「未開封にする」）。`Label` は絵と文字の 2 つの要素になるので、操作を足す見本は `Text` にした。`Text("\(3000) 歩")` の値は「3,000 歩」になる
- **UI テストの木は、VoiceOver が読むものと同じではない。** `accessibilityHidden(true)` の View も木に出て、`accessibilityLabeledPair` の組もラベルに出ない。木で確かめられるのは、ラベル・値・識別子・`.combine` の結果・`accessibilitySortPriority` の並び（「200 円」が先頭に来た）・`accessibilityChildren` の子
- **`accessibilityRepresentation` を同じ View のまま付け外しすると、UI テストでアプリが止まった（idle を待ち続けた）。** 見本を `.id(represents)` で作り直すと止まらない
- **文字の大きさを変えて撮る → `launchArguments` に `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXL`。** `accessibilityLargeContentViewerEnabled` が true になった。ただし、UI テストの長押し（`press(forDuration:)`）では、大きく出す画面は撮れなかった
- **iOS の UI テストには `XCUIElement.increment()` がない**（macOS だけ）。調整できる要素の上げ下げは UI テストで試せない
- **一時的な UI テストで 39 件を 1 つのテストで撮ると、10 分の時間の上限を超えた。** `executionTimeAllowance` を延ばすか、テストを分ける

---

### Task 1: 札の補助と accessibility-fundamentals・accessible-appearance の 8 件

**Files:**
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityDemo.swift`
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityElementEntry.swift`
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityChildrenEntry.swift`
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityRepresentationEntry.swift`
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityIdentifierEntry.swift`
- Create: `WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityHiddenEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleAppearance/AccessibilityIgnoresInvertColorsEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleAppearance/AccessibilityShowsLargeContentViewerEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleAppearance/AssistiveAccessNavigationIconEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`（どれも変えない）
- Produces: 8 件の `CatalogEntry`。補助 `A11yDemo(title:lines:content:)`・`A11yCaption(title:lines:)`・`A11yText.element(_:value:traits:hint:) -> String`・`A11yText.ordered(_:) -> [String]`（Task 2〜6 の全部の見本が使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessibility-fundamentals; python3 tools/catalog_progress.py accessible-appearance`
Expected: どちらも終了コード 1。抜けが 5 件と 3 件

- [ ] **Step 2: 収録のファイルを作る**

フォルダがなければ作る（Xcode のフォルダの同期で、project.pbxproj は変わらない）。

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityDemo.swift`:

```swift
import SwiftUI

/// アクセシビリティの収録で使う入れ物。上に見本、下に「支援技術に渡る中身」の札を出す。
/// SwiftUI は VoiceOver などの支援技術が動いていないとアクセシビリティの要素を作らず、アプリの中から読めない。
/// そこで札は、見本に渡したのと同じ値から書く。札そのものは読み上げない（支援技術の木に入れない）
struct A11yDemo<Content: View>: View {
    /// 札の見出し（例: "VoiceOver が読む要素"）
    let title: String
    /// 札の中身。1 行に 1 つ
    let lines: [String]
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 14) {
            content
            A11yCaption(title: title, lines: lines)
        }
        .padding(12)
    }
}

/// 支援技術に渡る中身の札
struct A11yCaption: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(spacing: 3) {
            Label(title, systemImage: "accessibility")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.caption)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: 260)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .accessibilityHidden(true)
    }
}

/// 札の行の書き方
nonisolated enum A11yText {
    /// 要素 1 つ。例: 「星」 値「3」 .isButton ヒント「…」
    static func element(_ label: String?, value: String? = nil, traits: [String] = [], hint: String? = nil) -> String {
        var parts = [label.map { "「\($0)」" } ?? "（ラベルなし）"]
        if let value { parts.append("値「\(value)」") }
        parts += traits
        if let hint { parts.append("ヒント「\(hint)」") }
        return parts.joined(separator: " ")
    }

    /// 読む順に番号を付ける（1 つなら付けない）
    static func ordered(_ items: [String]) -> [String] {
        items.count < 2 ? items : items.enumerated().map { "\($0.offset + 1). \($0.element)" }
    }
}
```

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityElementEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityElement = CatalogEntry(
        id: "accessibilityElement",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "子の View を、支援技術から見て 1 つの要素にまとめる modifier。子の扱いを children で選ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityelement(children:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityElement", label: "children",
                .choice([Choice(".combine"), Choice(".ignore"), Choice(".contain")], initial: 0), on: true,
                summary: "子の扱い。.combine は子のラベルをつないで 1 つに、.ignore は子を読まず中身のない 1 つに、.contain は子を残して組にする")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Image(systemName: \"star.fill\")\n        .accessibilityLabel(\"星\")\n    Text(\"お気に入り\")\n    Text(\"12\")\n}"
        ),
        build: { v in
            AnyView(AccessibilityElementDemo(children: v.pick("accessibilityElement", from: [0, 1, 2])))
        }
    )
}

private struct AccessibilityElementDemo: View {
    /// nil なら modifier をかけない。0 .combine・1 .ignore・2 .contain
    let children: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel("星")
                Text("お気に入り")
                Text("12")
                    .monospacedDigit()
            }
            .font(.title3)
            .apply(children) { view, children in
                view.accessibilityElement(children: [AccessibilityChildBehavior.combine, .ignore, .contain][children])
            }
        }
    }

    private var lines: [String] {
        let each = [A11yText.element("星", traits: [".isImage"]), A11yText.element("お気に入り"), A11yText.element("12")]
        return switch children {
        case 0: [A11yText.element("星、お気に入り、12") + "（1 つ）"]
        case 1: ["（ラベルなし）（1 つ。子は読まない）"]
        case 2: A11yText.ordered(each) + ["（3 つで 1 つの組）"]
        default: A11yText.ordered(each)
        }
    }
}
```

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityChildrenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityChildren = CatalogEntry(
        id: "accessibilityChildren",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "要素の子を、渡した View から作った要素に置き換える modifier。Canvas のように中身を読めない絵に、読める子を足す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitychildren(children:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityChildren", label: "children",
                .fixed(
                    code:
                        "{ HStack { ForEach(days) { day in Rectangle().accessibilityLabel(day.name).accessibilityValue(\"\\(day.steps) 歩\") } } }"
                ), on: true,
                summary: "子の要素を作る View。画面には描かない。棒 1 本ごとに曜日と歩数を読む")
        ],
        code: CodeTemplate(
            prefix: ["Canvas { context, size in", "    drawBars(in: context, size: size)", "}"], indent: 0,
            call: ".accessibilityLabel", fixedArguments: ["\"歩数\""]),
        build: { v in
            AnyView(AccessibilityChildrenDemo(hasChildren: v["accessibilityChildren"] != nil))
        }
    )
}

private struct AccessibilityChildrenDemo: View {
    let hasChildren: Bool
    private let days = [(name: "月", steps: 3000), (name: "火", steps: 5000), (name: "水", steps: 2000)]

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Canvas { context, size in
                let width = size.width / CGFloat(days.count)
                for (index, day) in days.enumerated() {
                    let height = size.height * CGFloat(day.steps) / 5000
                    let bar = CGRect(
                        x: CGFloat(index) * width + 8, y: size.height - height, width: width - 16, height: height)
                    context.fill(Path(bar), with: .color(.blue))
                }
            }
            .frame(width: 180, height: 90)
            .accessibilityLabel("歩数")
            .apply(hasChildren ? () : nil) { view, _ in
                view.accessibilityChildren {
                    HStack {
                        ForEach(days, id: \.name) { day in
                            Rectangle()
                                .accessibilityLabel(day.name)
                                .accessibilityValue("\(day.steps) 歩")
                        }
                    }
                }
            }
        }
    }

    private var lines: [String] {
        guard hasChildren else { return [A11yText.element("歩数") + "（中の棒は読まない）"] }
        return ["「歩数」の組の中に 3 つ"]
            + A11yText.ordered(days.map { A11yText.element($0.name, value: "\($0.steps.formatted()) 歩") })
    }
}
```

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityRepresentationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRepresentation = CatalogEntry(
        id: "accessibilityRepresentation",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "支援技術には、渡した View の要素を見せる modifier。自作の部品を、Toggle などの既製の部品として読ませる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/accessibilityrepresentation(representation:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRepresentation", label: "representation",
                .fixed(code: "{ Toggle(\"通知\", isOn: $isOn) }"), on: true,
                summary: "代わりに読ませる View。画面には描かない。自作のスイッチを Toggle として読み、2 回タップで切り替わる")
        ],
        code: CodeTemplate(
            prefix: [
                "// 自作のスイッチ", "Capsule()", "    .fill(isOn ? .green : .gray)", "    .frame(width: 52, height: 32)",
            ],
            call: ".onTapGesture", trailing: " { isOn.toggle() }"),
        build: { v in
            AnyView(AccessibilityRepresentationDemo(represents: v["accessibilityRepresentation"] != nil))
        }
    )
}

private struct AccessibilityRepresentationDemo: View {
    let represents: Bool
    @State private var isOn = true

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Capsule()
                .fill(isOn ? .green : .gray)
                .frame(width: 52, height: 32)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(.white).padding(3)
                }
                .onTapGesture { isOn.toggle() }
                .apply(represents ? () : nil) { view, _ in
                    view.accessibilityRepresentation {
                        Toggle("通知", isOn: $isOn)
                    }
                }
        }
        // 付け外しのたびに作り直す（同じ View のまま representation を外すと、UI テストでアプリが止まった）
        .id(represents)
    }

    private var lines: [String] {
        represents
            ? [A11yText.element("通知", value: isOn ? "1" : "0", traits: [".isToggle"])]
            : ["（読まない。押せることも伝わらない）"]
    }
}
```

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityIdentifierEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityIdentifier = CatalogEntry(
        id: "accessibilityIdentifier",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "View を見分ける名前を付ける modifier。VoiceOver は読まず、UI テストが要素を探すときに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityidentifier(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityIdentifier", .text(initial: "save-button"), on: true,
                summary: "見分ける名前。文言を変えても、UI テストは同じ名前で探せる")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { save() }"),
        build: { v in
            AnyView(AccessibilityIdentifierDemo(identifier: v.text("accessibilityIdentifier")))
        }
    )
}

private struct AccessibilityIdentifierDemo: View {
    let identifier: String?

    var body: some View {
        A11yDemo(title: "UI テストで探す書き方", lines: lines) {
            Button("保存") {}
                .buttonStyle(.borderedProminent)
                .apply(identifier) { view, identifier in
                    view.accessibilityIdentifier(identifier)
                }
        }
    }

    private var lines: [String] {
        if let identifier {
            ["app.buttons[\"\(identifier)\"]", "（VoiceOver は「保存」と読み、名前は読まない）"]
        } else {
            ["app.buttons[\"保存\"]", "（名前がないのでラベルで探す。文言を変えるとテストが壊れる）"]
        }
    }
}
```

`WidgetLab/Catalog/AccessibilityFundamentals/AccessibilityHiddenEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHidden = CatalogEntry(
        id: "accessibilityHidden",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "View を支援技術から隠す modifier。飾りの画像など、読ませなくてよいものに付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityhidden(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHidden", .toggle(initial: true), on: true,
                summary: "true なら隠す。飾りの画像を読まず、「新着」だけを読む")
        ],
        code: CodeTemplate(
            prefix: ["HStack {"], call: "Image", fixedArguments: ["systemName: \"sparkles\""],
            closing: ["    Text(\"新着\")", "}"]),
        build: { v in
            AnyView(AccessibilityHiddenDemo(hidden: v.flag("accessibilityHidden")))
        }
    )
}

private struct AccessibilityHiddenDemo: View {
    /// nil なら modifier をかけない
    let hidden: Bool?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                    .apply(hidden) { view, hidden in
                        view.accessibilityHidden(hidden)
                    }
                Text("新着")
            }
            .font(.title3)
        }
    }

    private var lines: [String] {
        hidden == true
            ? [A11yText.element("新着")]
            : A11yText.ordered([A11yText.element("ぴかぴか", traits: [".isImage"]), A11yText.element("新着")])
    }
}
```

`WidgetLab/Catalog/AccessibleAppearance/AccessibilityIgnoresInvertColorsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityIgnoresInvertColors = CatalogEntry(
        id: "accessibilityIgnoresInvertColors",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "設定のスマート反転で、この View の色を反転しないようにする modifier。写真や絵に付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityignoresinvertcolors(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityIgnoresInvertColors", .toggle(initial: true), on: true,
                summary: "true なら反転しない。設定 > アクセシビリティ > 画面表示とテキストサイズ > 反転（スマート）を入れて見る")
        ],
        code: CodeTemplate(
            prefix: ["HStack {"], call: "Image", fixedArguments: ["\"sunset\""], closing: ["    Text(\"夕焼け\")", "}"]),
        build: { v in
            AnyView(InvertColorsDemo(ignores: v.flag("accessibilityIgnoresInvertColors")))
        }
    )
}

private struct InvertColorsDemo: View {
    /// nil なら modifier をかけない
    let ignores: Bool?
    @Environment(\.accessibilityInvertColors) private var invertColors

    var body: some View {
        A11yDemo(title: "スマート反転のとき", lines: lines) {
            HStack(spacing: 12) {
                // 写真の代わりの絵
                LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay { Image(systemName: "sun.horizon.fill").font(.largeTitle).foregroundStyle(.yellow) }
                    .frame(width: 96, height: 72)
                    .clipShape(.rect(cornerRadius: 8))
                    .apply(ignores) { view, ignores in
                        view.accessibilityIgnoresInvertColors(ignores)
                    }
                Text("夕焼け")
                    .font(.title3)
            }
        }
    }

    private var lines: [String] {
        [
            ignores == true ? "写真は元の色のまま、まわりだけ反転する" : "写真も反転して、色が逆になる",
            "今のスマート反転: \(invertColors ? "入" : "切")",
        ]
    }
}
```

`WidgetLab/Catalog/AccessibleAppearance/AccessibilityShowsLargeContentViewerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityShowsLargeContentViewer = CatalogEntry(
        id: "accessibilityShowsLargeContentViewer",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "文字を特大にしているとき、長押しで View を画面の真ん中に大きく出す modifier。大きくできないバーのボタンに付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityshowslargecontentviewer()")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityShowsLargeContentViewer",
                .choice(
                    [Choice("既定", code: ""), Choice("中身を渡す", code: "{ Label(\"ホーム\", systemImage: \"house\") }")],
                    initial: 0), on: true,
                summary: "大きく出す中身。既定はボタンのラベル。設定で文字をアクセシビリティのサイズにして、ボタンを長押しする")
        ],
        code: CodeTemplate(
            call: "Button", trailing: " {\n    goHome()\n} label: {\n    Image(systemName: \"house\")\n}"),
        build: { v in
            AnyView(LargeContentViewerDemo(content: v.pick("accessibilityShowsLargeContentViewer", from: [0, 1])))
        }
    )
}

private struct LargeContentViewerDemo: View {
    /// nil なら modifier をかけない。0 既定・1 中身を渡す
    let content: Int?
    @Environment(\.accessibilityLargeContentViewerEnabled) private var isEnabled

    var body: some View {
        A11yDemo(title: "長押しで大きく出るもの", lines: lines) {
            Button {
            } label: {
                Image(systemName: "house")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .apply(content) { view, content in
                if content == 0 {
                    view.accessibilityShowsLargeContentViewer()
                } else {
                    view.accessibilityShowsLargeContentViewer {
                        Label("ホーム", systemImage: "house")
                    }
                }
            }
        }
    }

    private var lines: [String] {
        let shown =
            switch content {
            case 0: "家の絵"
            case 1: "家の絵と「ホーム」"
            default: "なし（長押ししても出ない）"
            }
        return [
            shown,
            "今は\(isEnabled ? "使える" : "使えない（文字がアクセシビリティのサイズでない）")",
        ]
    }
}
```

`WidgetLab/Catalog/AccessibleAppearance/AssistiveAccessNavigationIconEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let assistiveAccessNavigationIcon = CatalogEntry(
        id: "assistiveAccessNavigationIcon",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "アシスティブアクセスのとき、画面の題名の横や戻るボタンに出す絵を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/assistiveaccessnavigationicon(systemimage:)"
        )!,
        noteReason:
            "アシスティブアクセス（設定で入れる、ホーム画面ごと簡単な見た目に切り替える仕組み）のときだけ効く。アプリの中からは切り替えられない。アシスティブアクセスに対応したアプリで、画面の題名の横に絵を出すときに使う",
        properties: [
            .modifier(
                "assistiveAccessNavigationIcon",
                .choice(
                    [
                        Choice("SF Symbols", code: "systemImage: \"photo\""),
                        Choice("画像", code: "Image(\"PhotosIcon\")"),
                    ], initial: 0), on: true,
                summary: "出す絵。SF Symbols の名前か Image")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "Text", fixedArguments: ["\"写真の一覧\""],
            suffix: [".navigationTitle(\"写真\")"], closing: ["}"])
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityElement,
        .accessibilityChildren,
        .accessibilityRepresentation,
        .accessibilityIdentifier,
        .accessibilityHidden,
        .accessibilityIgnoresInvertColors,
        .accessibilityShowsLargeContentViewer,
        .assistiveAccessNavigationIcon,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `python3 tools/catalog_progress.py accessibility-fundamentals; python3 tools/catalog_progress.py accessible-appearance`
Expected: `5 / 5` と `3 / 3`、どちらも終了コード 0

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AccessibilityFundamentals WidgetLab/Catalog/AccessibleAppearance WidgetLab/Catalog/Catalog.swift
git commit -m "feat: アクセシビリティの札の補助と、基本と見た目の 8 件の収録

accessibilityElement・accessibilityChildren・accessibilityRepresentation・accessibilityIdentifier・accessibilityHidden・accessibilityIgnoresInvertColors・accessibilityShowsLargeContentViewer・assistiveAccessNavigationIcon

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 2: accessible-controls の前半 7 件（操作と触れる場所）

**Files:**
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityPointDemo.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityActionEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityActionsEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityAdjustableActionEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityScrollActionEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityActivationPointEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityDragPointEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityDropPointEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `A11yDemo`・`A11yText`
- Produces: 7 件の `CatalogEntry`。補助 `A11yPointMarker(point: UnitPoint, label: String? = nil)`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessible-controls`
Expected: 終了コード 1。抜けが 12 件

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/AccessibleControls/AccessibilityPointDemo.swift`:

```swift
import SwiftUI

/// 支援技術が触れる場所の印。親の大きさの中で、point の場所に赤い点を出す
struct A11yPointMarker: View {
    let point: UnitPoint
    var label: String? = nil

    var body: some View {
        GeometryReader { geometry in
            let x = geometry.size.width * point.x
            let y = geometry.size.height * point.y
            Circle()
                .fill(.red)
                .stroke(.white, lineWidth: 2)
                .frame(width: 14, height: 14)
                .position(x: x, y: y)
            if let label {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .background(.red, in: .capsule)
                    .fixedSize()
                    .position(x: min(max(x, 40), geometry.size.width - 40), y: y + 16)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityActionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAction = CatalogEntry(
        id: "accessibilityAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から呼べる操作を 1 つ足す modifier。VoiceOver では、上下にスワイプして操作を選び、2 回タップで行う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityaction(named:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAction",
                .choice(
                    [
                        Choice("名前を付ける", code: "named: \"既読にする\", { isRead = true }"),
                        Choice(".magicTap", code: ".magicTap, { isRead = true }"),
                    ], initial: 0), on: true,
                summary: "足す操作。名前を付けると操作の一覧に出る。.magicTap は 2 本指で 2 回タップしたときに行う")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["isRead ? \"既読: 会議の件\" : \"未読: 会議の件\""]),
        build: { v in
            AnyView(AccessibilityActionDemo(kind: v.pick("accessibilityAction", from: [0, 1])))
        }
    )
}

private struct AccessibilityActionDemo: View {
    /// nil なら modifier をかけない。0 名前を付ける・1 .magicTap
    let kind: Int?
    @State private var isRead = false

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text(isRead ? "既読: 会議の件" : "未読: 会議の件")
                .font(.title3)
                .apply(kind) { view, kind in
                    if kind == 0 {
                        view.accessibilityAction(named: "既読にする") { isRead = true }
                    } else {
                        view.accessibilityAction(.magicTap) { isRead = true }
                    }
                }
        }
    }

    private var lines: [String] {
        let action =
            switch kind {
            case 0: "上下にスワイプして「既読にする」を選び、2 回タップ"
            case 1: "2 本指で 2 回タップすると既読にする"
            default: "（操作なし）"
            }
        return [A11yText.element(isRead ? "既読: 会議の件" : "未読: 会議の件"), action]
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityActionsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityActions = CatalogEntry(
        id: "accessibilityActions",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から呼べる操作を、Button を並べてまとめて足す modifier。ボタンの名前が操作の名前になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityactions(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityActions",
                .fixed(code: "{ Button(\"既読にする\") { isRead = true }; Button(\"旗を付ける\") { isFlagged = true } }"),
                on: true,
                summary: "足す操作を Button で並べる。画面には描かない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["isRead ? \"既読: 会議の件\" : \"未読: 会議の件\""]),
        build: { v in
            AnyView(AccessibilityActionsDemo(hasActions: v["accessibilityActions"] != nil))
        }
    )
}

private struct AccessibilityActionsDemo: View {
    let hasActions: Bool
    @State private var isRead = false
    @State private var isFlagged = false

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text(isRead ? "既読: 会議の件" : "未読: 会議の件")
                .font(.title3)
                .foregroundStyle(isFlagged ? .orange : .primary)
                .apply(hasActions ? () : nil) { view, _ in
                    view.accessibilityActions {
                        Button("既読にする") { isRead = true }
                        Button("旗を付ける") { isFlagged = true }
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element(isRead ? "既読: 会議の件" : "未読: 会議の件")] + (hasActions ? ["上下にスワイプして選ぶ: 既読にする・旗を付ける"] : ["（操作なし）"])
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityAdjustableActionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAdjustableAction = CatalogEntry(
        id: "accessibilityAdjustableAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術から値を上げ下げできるようにする modifier。VoiceOver では、上下にスワイプして 1 つずつ変える。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityadjustableaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAdjustableAction",
                .fixed(code: "{ direction in rating += direction == .increment ? 1 : -1 }"), on: true,
                summary: "上げ下げの処理。上にスワイプで .increment、下で .decrement が渡る")
        ],
        code: CodeTemplate(
            prefix: ["StarRating(rating: $rating)", "    .accessibilityElement()", "    .accessibilityLabel(\"評価\")"],
            call: ".accessibilityValue", fixedArguments: ["\"\\(rating) 個\""]),
        build: { v in
            AnyView(AdjustableActionDemo(isAdjustable: v["accessibilityAdjustableAction"] != nil))
        }
    )
}

private struct AdjustableActionDemo: View {
    let isAdjustable: Bool
    @State private var rating = 3

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .onTapGesture { rating = index }
                }
            }
            .font(.title2)
            .accessibilityElement()
            .accessibilityLabel("評価")
            .accessibilityValue("\(rating) 個")
            .apply(isAdjustable ? () : nil) { view, _ in
                view.accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: rating = min(rating + 1, 5)
                    case .decrement: rating = max(rating - 1, 1)
                    @unknown default: break
                    }
                }
            }
        }
    }

    private var lines: [String] {
        isAdjustable
            ? [A11yText.element("評価", value: "\(rating) 個", traits: [".adjustable"]), "上下にスワイプで 1 つずつ変える"]
            : [A11yText.element("評価", value: "\(rating) 個"), "（VoiceOver からは変えられない）"]
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityScrollActionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityScrollAction = CatalogEntry(
        id: "accessibilityScrollAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術のスクロールの操作に応える modifier。VoiceOver では、3 本指でスワイプしたときに呼ばれる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityscrollaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityScrollAction", .fixed(code: "{ edge in page += edge == .trailing ? 1 : -1 }"), on: true,
                summary: "スクロールの処理。スクロールする向きの端（Edge）が渡る")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"\\(page) / 5 ページ\""]),
        build: { v in
            AnyView(ScrollActionDemo(isScrollable: v["accessibilityScrollAction"] != nil))
        }
    )
}

private struct ScrollActionDemo: View {
    let isScrollable: Bool
    @State private var page = 2

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Text("\(page) / 5 ページ")
                .font(.title2)
                .monospacedDigit()
                .apply(isScrollable ? () : nil) { view, _ in
                    view.accessibilityScrollAction { edge in
                        page = min(max(page + (edge == .trailing ? 1 : -1), 1), 5)
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element("\(page) / 5 ページ")]
            + (isScrollable ? ["3 本指で左右にスワイプして、ページを送る"] : ["（3 本指でスワイプしても変わらない）"])
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityActivationPointEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityActivationPoint = CatalogEntry(
        id: "accessibilityActivationPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術が要素を押すときに触れる場所を決める modifier。VoiceOver の 2 回タップは、ふつう要素の真ん中を押す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityactivationpoint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityActivationPoint",
                .choice(
                    [Choice("スイッチの上", code: "UnitPoint(x: 0.85, y: 0.5)"), Choice(".leading")], initial: 0),
                on: true,
                summary: "押す場所（UnitPoint か CGPoint）。赤い点の場所を押す")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Text(\"Wi-Fi\")\n    Spacer()\n    Toggle(\"\", isOn: $isOn).labelsHidden()\n}",
            suffix: [".accessibilityElement(children: .combine)"]),
        build: { v in
            AnyView(
                ActivationPointDemo(
                    point: v.pick("accessibilityActivationPoint", from: [UnitPoint(x: 0.85, y: 0.5), .leading])))
        }
    )
}

private struct ActivationPointDemo: View {
    /// nil なら modifier をかけない
    let point: UnitPoint?
    @State private var isOn = true

    var body: some View {
        A11yDemo(
            title: "VoiceOver が 2 回タップで押す場所",
            lines: [A11yText.element("Wi-Fi", value: isOn ? "1" : "0", traits: [".isToggle"]), lines]
        ) {
            HStack {
                Text("Wi-Fi")
                Spacer()
                Toggle("", isOn: $isOn).labelsHidden()
            }
            .padding(.horizontal, 12)
            .frame(width: 260, height: 52)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
            .overlay { A11yPointMarker(point: point ?? .center) }
            .apply(point) { view, point in
                view.accessibilityActivationPoint(point)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var lines: String {
        point == nil ? "赤い点（既定の真ん中。何もない所を押す）" : "赤い点"
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityDragPointEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDragPoint = CatalogEntry(
        id: "accessibilityDragPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術でドラッグを始めるときに触れる場所と、その説明を決める modifier。VoiceOver の操作の一覧に出る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydragpoint(_:description:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDragPoint", id: "accessibilityDragPoint.point", label: nil,
                .choice([Choice(".topLeading"), Choice(".center")], initial: 0), required: true,
                summary: "ドラッグを始める場所"),
            .modifier(
                "accessibilityDragPoint", id: "accessibilityDragPoint.description", label: "description",
                .text(initial: "写真を運ぶ"), on: true,
                summary: "操作の一覧に出す名前"),
        ],
        code: CodeTemplate(call: "Image", fixedArguments: ["\"sunset\""], suffix: [".draggable(photo)"]),
        build: { v in
            AnyView(
                DragPointDemo(
                    point: v.pick("accessibilityDragPoint.point", from: [UnitPoint.topLeading, .center]),
                    description: v.text("accessibilityDragPoint.description")))
        }
    )
}

private struct DragPointDemo: View {
    let point: UnitPoint?
    /// nil なら modifier をかけない
    let description: String?

    var body: some View {
        A11yDemo(title: "VoiceOver でドラッグを始める操作", lines: lines) {
            LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom)
                .overlay { Image(systemName: "sun.horizon.fill").font(.largeTitle).foregroundStyle(.yellow) }
                .frame(width: 140, height: 96)
                .clipShape(.rect(cornerRadius: 8))
                .overlay {
                    if let description, let point {
                        A11yPointMarker(point: point, label: description)
                    }
                }
                .draggable("写真")
                .apply(description.map { ($0, point ?? .topLeading) }) { view, pair in
                    view.accessibilityDragPoint(pair.1, description: LocalizedStringKey(pair.0))
                }
        }
    }

    private var lines: [String] {
        if let description {
            ["上下にスワイプして「\(description)」を選び、2 回タップ", "赤い点からドラッグを始める"]
        } else {
            ["（ドラッグの操作は既定の名前で、真ん中から始める）"]
        }
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityDropPointEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDropPoint = CatalogEntry(
        id: "accessibilityDropPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術でドラッグを終えるときに離す場所と、その説明を決める modifier。VoiceOver の操作の一覧に出る。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydroppoint(_:description:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDropPoint", id: "accessibilityDropPoint.point", label: nil,
                .choice([Choice(".trailing"), Choice(".center")], initial: 0), required: true,
                summary: "ドラッグを終える場所"),
            .modifier(
                "accessibilityDropPoint", id: "accessibilityDropPoint.description", label: "description",
                .text(initial: "アルバムに入れる"), on: true,
                summary: "操作の一覧に出す名前"),
        ],
        code: CodeTemplate(
            call: "Label", fixedArguments: ["\"アルバム\"", "systemImage: \"photo.on.rectangle\""],
            suffix: [".dropDestination(for: String.self) { items, _ in add(items) }"]),
        build: { v in
            AnyView(
                DropPointDemo(
                    point: v.pick("accessibilityDropPoint.point", from: [UnitPoint.trailing, .center]),
                    description: v.text("accessibilityDropPoint.description")))
        }
    )
}

private struct DropPointDemo: View {
    let point: UnitPoint?
    /// nil なら modifier をかけない
    let description: String?
    @State private var count = 0

    var body: some View {
        A11yDemo(title: "VoiceOver でドラッグを終える操作", lines: lines) {
            Label("アルバム（\(count) 枚）", systemImage: "photo.on.rectangle")
                .frame(width: 200, height: 80)
                .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
                .overlay {
                    if let description, let point {
                        A11yPointMarker(point: point, label: description)
                    }
                }
                .dropDestination(for: String.self) { items, _ in
                    count += items.count
                    return true
                }
                .apply(description.map { ($0, point ?? .trailing) }) { view, pair in
                    view.accessibilityDropPoint(pair.1, description: LocalizedStringKey(pair.0))
                }
        }
    }

    private var lines: [String] {
        if let description {
            ["運んでいるときに、上下にスワイプして「\(description)」を選び、2 回タップ", "赤い点で離す"]
        } else {
            ["（離す操作は既定の名前で、真ん中で離す）"]
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityAction,
        .accessibilityActions,
        .accessibilityAdjustableAction,
        .accessibilityScrollAction,
        .accessibilityActivationPoint,
        .accessibilityDragPoint,
        .accessibilityDropPoint,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `python3 tools/catalog_progress.py accessible-controls`
Expected: `7 / 12`、終了コード 1（残りは Task 3）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AccessibleControls WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 支援技術の操作と触れる場所の 7 件の収録

accessibilityAction・accessibilityActions・accessibilityAdjustableAction・accessibilityScrollAction・accessibilityActivationPoint・accessibilityDragPoint・accessibilityDropPoint

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 3: accessible-controls の後半 5 件と、ラベルの 2 件

**Files:**
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityFocusDemo.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityDirectTouchEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityZoomActionEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityFocusedEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityFocusStateEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleControls/AccessibilityRespondsToUserInteractionEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityLabelEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityInputLabelsEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `A11yDemo`・`A11yText`
- Produces: 7 件の `CatalogEntry`（プロパティラッパーの `AccessibilityFocusState` は `static let accessibilityFocusState`。modifier の `accessibilityFocused` とは名前が違うので `Wrapper` は付けない）。補助 `AccessibilityFocusDemo(connects: Bool)`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessible-controls`
Expected: 終了コード 1。抜けが accessibilityDirectTouch・accessibilityZoomAction・accessibilityFocused・AccessibilityFocusState・accessibilityRespondsToUserInteraction の 5 件

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/AccessibleControls/AccessibilityFocusDemo.swift`:

```swift
import SwiftUI

/// accessibilityFocused と AccessibilityFocusState の見本。ボタンで、VoiceOver のカーソルを合計へ移す
struct AccessibilityFocusDemo: View {
    /// false なら accessibilityFocused をかけない
    let connects: Bool
    @AccessibilityFocusState private var isTotalFocused: Bool

    var body: some View {
        A11yDemo(title: "VoiceOver のカーソル", lines: lines) {
            VStack(spacing: 12) {
                Button("合計へ移る") { isTotalFocused = true }
                    .buttonStyle(.bordered)
                Text("合計: 1,200 円")
                    .font(.title3)
                    .apply(connects ? () : nil) { view, _ in
                        view.accessibilityFocused($isTotalFocused)
                    }
            }
        }
    }

    private var lines: [String] {
        [
            "isTotalFocused: \(isTotalFocused)",
            connects ? "VoiceOver が入っていれば、ボタンでカーソルが合計に移る" : "（つないでいないので、カーソルは動かない）",
        ]
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityDirectTouchEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDirectTouch = CatalogEntry(
        id: "accessibilityDirectTouch",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "VoiceOver が入っていても、指で触れた操作をそのままアプリに渡す場所にする modifier。楽器の鍵盤などに付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydirecttouch(_:options:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDirectTouch", id: "accessibilityDirectTouch.isDirectTouchArea", label: nil,
                .toggle(initial: true), on: true,
                summary: "true なら、触れた操作をそのままアプリに渡す"),
            .modifier(
                "accessibilityDirectTouch", id: "accessibilityDirectTouch.options", label: "options",
                .choice([Choice(".silentOnTouch"), Choice(".requiresActivation")], initial: 0),
                summary: ".silentOnTouch は触れても読み上げない。.requiresActivation は、先に 2 回タップしてから直接触れる"),
        ],
        code: CodeTemplate(
            prefix: ["// Piano は鍵盤を並べ、触れた鍵盤の音を鳴らす自作の View"], indent: 0, call: "Piano"),
        build: { v in
            AnyView(
                DirectTouchDemo(
                    isDirect: v["accessibilityDirectTouch.isDirectTouchArea"] == nil
                        ? (v["accessibilityDirectTouch.options"] == nil ? nil : true)
                        : v.flag("accessibilityDirectTouch.isDirectTouchArea"),
                    options: v.pick(
                        "accessibilityDirectTouch.options",
                        from: [AccessibilityDirectTouchOptions.silentOnTouch, .requiresActivation]),
                    optionIndex: v.pick("accessibilityDirectTouch.options", from: [0, 1])))
        }
    )
}

private struct DirectTouchDemo: View {
    /// nil なら modifier をかけない（options だけ ON なら、既定の true でかける）
    let isDirect: Bool?
    let options: AccessibilityDirectTouchOptions?
    let optionIndex: Int?
    @State private var played = "–"

    var body: some View {
        A11yDemo(title: "VoiceOver が入っているとき", lines: lines) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(["ド", "レ", "ミ", "ファ"], id: \.self) { note in
                        Text(note)
                            .frame(width: 44, height: 72, alignment: .bottom)
                            .padding(.bottom, 6)
                            .background(Color(.systemBackground), in: .rect(cornerRadius: 4))
                            .onTapGesture { played = note }
                    }
                }
                .apply(isDirect) { view, isDirect in
                    view.accessibilityDirectTouch(isDirect, options: options ?? [])
                }
                Text("鳴らした音: \(played)")
                    .font(.caption)
            }
        }
    }

    private var lines: [String] {
        guard isDirect == true else { return ["鍵盤を選んで、2 回タップで鳴らす"] }
        let option: [String] =
            switch optionIndex {
            case 0: ["触れても、鍵盤の名前を読まない"]
            case 1: ["先に 2 回タップしてから、直接触れられる"]
            default: []
            }
        return ["触れた鍵盤がすぐ鳴る（2 回タップしなくてよい）"] + option
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityZoomActionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityZoomAction = CatalogEntry(
        id: "accessibilityZoomAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術の拡大・縮小の操作に応える modifier。地図や写真のように、倍率を変えられる View に付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityzoomaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityZoomAction", .fixed(code: "{ action in zoom += action.direction == .zoomIn ? 1 : -1 }"),
                on: true,
                summary: "拡大・縮小の処理。向き（.zoomIn・.zoomOut）と場所が渡る")
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"map\""], suffix: [".scaleEffect(CGFloat(zoom))"]),
        build: { v in
            AnyView(ZoomActionDemo(isZoomable: v["accessibilityZoomAction"] != nil))
        }
    )
}

private struct ZoomActionDemo: View {
    let isZoomable: Bool
    @State private var zoom = 1

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Image(systemName: "map")
                .font(.title)
                .scaleEffect(CGFloat(zoom))
                .frame(width: 120, height: 80)
                .accessibilityLabel("地図")
                .accessibilityValue("\(zoom) 倍")
                .apply(isZoomable ? () : nil) { view, _ in
                    view.accessibilityZoomAction { action in
                        zoom = min(max(zoom + (action.direction == .zoomIn ? 1 : -1), 1), 3)
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element("地図", value: "\(zoom) 倍", traits: [".isImage"])]
            + (isZoomable ? ["VoiceOver の拡大・縮小の操作で、倍率を変える"] : ["（VoiceOver からは倍率を変えられない）"])
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityFocusedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityFocused = CatalogEntry(
        id: "accessibilityFocused",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "VoiceOver などのカーソルがこの View にあるかを、@AccessibilityFocusState の値とつなぐ modifier。値を変えるとカーソルが移る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityfocused(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityFocused", .fixed(code: "$isTotalFocused"), on: true,
                summary: "つなぐ値（@AccessibilityFocusState）。VoiceOver を入れてボタンを押すと、カーソルが合計に移る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"合計へ移る\") { isTotalFocused = true }"], call: "Text",
            fixedArguments: ["\"合計: 1,200 円\""], closing: ["}"]),
        build: { v in
            AnyView(AccessibilityFocusDemo(connects: v["accessibilityFocused"] != nil))
        }
    )
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityFocusStateEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityFocusState = CatalogEntry(
        id: "AccessibilityFocusState",
        kind: .propertyWrapper,
        topic: .accessibleControls,
        summary: "VoiceOver などのカーソルがどこにあるかを持つ値。読んでカーソルの場所を知り、書いてカーソルを移す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/accessibilityfocusstate")!,
        stage: .card,
        properties: [
            .wrapper("AccessibilityFocusState", summary: "外すと、ただの値になり、カーソルとつながらない（.accessibilityFocused も書けない）")
        ],
        code: CodeTemplate(
            call: "AccessibilityFocusState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@AccessibilityFocusState private var isTotalFocused: Bool",
                    "var body: some View {",
                    "    Button(\"合計へ移る\") { isTotalFocused = true }",
                    "    Text(\"合計: 1,200 円\")",
                    "        .accessibilityFocused($isTotalFocused)",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var isTotalFocused = false  // カーソルとつながらない",
                    "var body: some View {",
                    "    Button(\"合計へ移る\") { isTotalFocused = true }",
                    "    Text(\"合計: 1,200 円\")",
                    "}",
                ])),
        build: { v in
            v["AccessibilityFocusState"] != nil
                ? AnyView(AccessibilityFocusDemo(connects: true)) : AnyView(PlainFocusDemo())
        }
    )
}

/// ラッパーを外した見本。ただの値なので、VoiceOver のカーソルとつながらない
private struct PlainFocusDemo: View {
    @State private var isTotalFocused = false

    var body: some View {
        A11yDemo(
            title: "VoiceOver のカーソル",
            lines: ["isTotalFocused: \(isTotalFocused)", "（ただの値。ボタンで true になっても、カーソルは動かない）"]
        ) {
            VStack(spacing: 12) {
                Button("合計へ移る") { isTotalFocused = true }
                    .buttonStyle(.bordered)
                Text("合計: 1,200 円")
                    .font(.title3)
            }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleControls/AccessibilityRespondsToUserInteractionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRespondsToUserInteraction = CatalogEntry(
        id: "accessibilityRespondsToUserInteraction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "要素が押せるものかを、支援技術に伝える modifier。スイッチコントロール・音声コントロール・フルキーボードアクセスが、押せる要素として選ぶ。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/accessibilityrespondstouserinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRespondsToUserInteraction", .toggle(initial: true), on: true,
                summary: "true なら押せるものとして伝える。false なら、押せる部品でも選ばれない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"お知らせ 3 件\""], suffix: [".onTapGesture { showNotices() }"]),
        build: { v in
            AnyView(RespondsToUserInteractionDemo(responds: v.flag("accessibilityRespondsToUserInteraction")))
        }
    )
}

private struct RespondsToUserInteractionDemo: View {
    /// nil なら modifier をかけない
    let responds: Bool?
    @State private var taps = 0

    var body: some View {
        A11yDemo(title: "音声コントロール・スイッチコントロール", lines: [lines]) {
            VStack(spacing: 8) {
                Text("お知らせ 3 件")
                    .font(.title3)
                    .padding(8)
                    .background(Color(.systemBackground), in: .rect(cornerRadius: 8))
                    .apply(responds) { view, responds in
                        view.accessibilityRespondsToUserInteraction(responds)
                    }
                    .onTapGesture { taps += 1 }
                Text("押した回数: \(taps)")
                    .font(.caption)
            }
        }
    }

    private var lines: String {
        responds == true ? "押せる要素として選べる（番号や名前が付く）" : "文字なので、押せる要素として選ばれない"
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLabel = CatalogEntry(
        id: "accessibilityLabel",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の中身を言葉で伝えるラベルを付ける modifier。絵だけのボタンなどに、VoiceOver が読む名前を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylabel(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLabel", .text(initial: "ごみ箱に入れる"), on: true,
                summary: "読ませる名前。外すと、絵の名前（SF Symbols の名前から作ったもの）を読む")
        ],
        code: CodeTemplate(
            call: "Button", trailing: " {\n    moveToTrash()\n} label: {\n    Image(systemName: \"trash\")\n}"),
        build: { v in
            AnyView(AccessibilityLabelDemo(label: v.text("accessibilityLabel")))
        }
    )
}

private struct AccessibilityLabelDemo: View {
    /// nil なら modifier をかけない
    let label: String?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element(label ?? "ゴミ箱", traits: [".isButton"])]) {
            Button {
            } label: {
                Image(systemName: "trash")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .apply(label) { view, label in
                view.accessibilityLabel(label)
            }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityInputLabelsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityInputLabels = CatalogEntry(
        id: "accessibilityInputLabels",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "音声コントロールなどで要素を呼ぶ名前を、ラベルとは別に足す modifier。長いラベルのボタンを、短い言葉で押せるようにする。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityinputlabels(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityInputLabels", .fixed(code: "[\"保存\", \"セーブ\"]"), on: true,
                summary: "呼ぶ名前の候補。前にあるものほど優先する")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存して閉じる\""], trailing: " { saveAndClose() }"),
        build: { v in
            AnyView(InputLabelsDemo(hasInputLabels: v["accessibilityInputLabels"] != nil))
        }
    )
}

private struct InputLabelsDemo: View {
    let hasInputLabels: Bool

    var body: some View {
        A11yDemo(title: "音声コントロールで押すときの言い方", lines: lines) {
            Button("保存して閉じる") {}
                .buttonStyle(.borderedProminent)
                .apply(hasInputLabels ? () : nil) { view, _ in
                    view.accessibilityInputLabels(["保存", "セーブ"])
                }
        }
    }

    private var lines: [String] {
        hasInputLabels
            ? ["「保存をタップ」", "「セーブをタップ」", "（VoiceOver はラベルの「保存して閉じる」を読む）"]
            : ["「保存して閉じるをタップ」（ラベルを全部言う）"]
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityDirectTouch,
        .accessibilityZoomAction,
        .accessibilityFocused,
        .accessibilityFocusState,
        .accessibilityRespondsToUserInteraction,
        .accessibilityLabel,
        .accessibilityInputLabels,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `python3 tools/catalog_progress.py accessible-controls; python3 tools/catalog_progress.py accessible-descriptions`
Expected: `12 / 12`（終了コード 0）と `2 / 15`（終了コード 1。残りは Task 4・5）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AccessibleControls WidgetLab/Catalog/AccessibleDescriptions WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 支援技術のカーソル・直接の操作と、ラベルの 7 件の収録

accessibilityDirectTouch・accessibilityZoomAction・accessibilityFocused・AccessibilityFocusState・accessibilityRespondsToUserInteraction・accessibilityLabel・accessibilityInputLabels

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 4: accessible-descriptions の 7 件（組・値・見出し・グラフ・特性）

**Files:**
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityLabeledPairEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityValueEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityTextContentTypeEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityHeadingEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityChartDescriptorEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityCustomContentEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityAddTraitsEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `A11yDemo`・`A11yText`
- Produces: 7 件の `CatalogEntry`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessible-descriptions`
Expected: 終了コード 1。抜けが 13 件

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityLabeledPairEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLabeledPair = CatalogEntry(
        id: "accessibilityLabeledPair",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "離れて置いたラベルの要素と中身の要素を組にする modifier。中身の要素を、ラベルの文字で読ませる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylabeledpair(role:id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLabeledPair", .fixed(code: "role: .content, id: \"notify\", in: namespace"), on: true,
                summary: "中身の側の印。ラベルの側（role: .label）と同じ id と namespace を渡すと組になる")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {", "    Text(\"通知\")",
                "        .accessibilityLabeledPair(role: .label, id: \"notify\", in: namespace)",
                "    Toggle(\"\", isOn: $isOn)",
            ], indent: 8, call: ".labelsHidden", closing: ["}"]),
        build: { v in
            AnyView(LabeledPairDemo(pairs: v["accessibilityLabeledPair"] != nil))
        }
    )
}

private struct LabeledPairDemo: View {
    let pairs: Bool
    @State private var isOn = true
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: lines) {
            HStack {
                Text("通知")
                    .accessibilityLabeledPair(role: .label, id: "notify", in: namespace)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .apply(pairs ? () : nil) { view, _ in
                        view.accessibilityLabeledPair(role: .content, id: "notify", in: namespace)
                    }
            }
            .padding(.horizontal, 12)
            .frame(width: 240, height: 52)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        }
    }

    private var lines: [String] {
        let value = isOn ? "1" : "0"
        return pairs
            ? [A11yText.element("通知", value: value, traits: [".isToggle"])]
            : A11yText.ordered([A11yText.element("通知"), A11yText.element(nil, value: value, traits: [".isToggle"])])
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityValueEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityValue = CatalogEntry(
        id: "accessibilityValue",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素が持つ値を言葉で伝える modifier。ラベルのあとに読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityvalue(_:)")!,
        stage: .card,
        properties: [
            .modifier("accessibilityValue", .text(initial: "75%"), on: true, summary: "読ませる値。ラベル「電池」のあとに読む")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"battery.75percent\")"], call: ".accessibilityLabel",
            fixedArguments: ["\"電池\""]),
        build: { v in
            AnyView(AccessibilityValueDemo(value: v.text("accessibilityValue")))
        }
    )
}

private struct AccessibilityValueDemo: View {
    /// nil なら modifier をかけない
    let value: String?

    var body: some View {
        A11yDemo(
            title: "VoiceOver が読む要素", lines: [A11yText.element("電池", value: value, traits: [".isImage"])]
        ) {
            Image(systemName: "battery.75percent")
                .font(.largeTitle)
                .accessibilityLabel("電池")
                .apply(value) { view, value in
                    view.accessibilityValue(value)
                }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityTextContentTypeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityTextContentType = CatalogEntry(
        id: "accessibilityTextContentType",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "文がどんな種類か（ソースコード・会話・表計算など）を支援技術に伝える modifier。VoiceOver が読み方を合わせる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitytextcontenttype(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityTextContentType",
                .choice([Choice(".sourceCode"), Choice(".console"), Choice(".narrative")], initial: 0), on: true,
                summary: "文の種類。外すと .plain（ふつうの文）として読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"let total = price * 2\""], suffix: [".monospaced()"]),
        build: { v in
            AnyView(TextContentTypeDemo(type: v.pick("accessibilityTextContentType", from: [0, 1, 2])))
        }
    )
}

private struct TextContentTypeDemo: View {
    /// nil なら modifier をかけない。0 .sourceCode・1 .console・2 .narrative
    let type: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver に伝える文の種類", lines: [line]) {
            Text("let total = price * 2")
                .monospaced()
                .apply(type) { view, type in
                    view.accessibilityTextContentType(
                        [AccessibilityTextContentType.sourceCode, .console, .narrative][type])
                }
        }
    }

    private var line: String {
        switch type {
        case 0: "ソースコード（記号や字下げも伝わるように読む）"
        case 1: "コンソールの出力"
        case 2: "物語の文（続けて読む）"
        default: "ふつうの文（.plain）"
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityHeadingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHeading = CatalogEntry(
        id: "accessibilityHeading",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "見出しの段（1〜6）を決める modifier。VoiceOver のローターで、段ごとに見出しへ飛べる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityheading(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHeading", .choice([Choice(".h1"), Choice(".h2"), Choice(".h3")], initial: 1), on: true,
                summary: "見出しの段。.isHeader の特性と組で使う")
        ],
        code: CodeTemplate(
            prefix: ["VStack(alignment: .leading) {"], call: "Text", fixedArguments: ["\"お知らせ\""],
            suffix: [".accessibilityAddTraits(.isHeader)"], closing: ["    Text(\"明日は休みです\")", "}"]),
        build: { v in
            AnyView(HeadingDemo(level: v.pick("accessibilityHeading", from: [1, 2, 3])))
        }
    )
}

private struct HeadingDemo: View {
    /// nil なら modifier をかけない
    let level: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            VStack(alignment: .leading, spacing: 4) {
                Text("お知らせ")
                    .font(.headline)
                    .apply(level) { view, level in
                        view.accessibilityHeading([AccessibilityHeadingLevel.h1, .h2, .h3][level - 1])
                    }
                    .accessibilityAddTraits(.isHeader)
                Text("明日は休みです")
            }
        }
    }

    private var lines: [String] {
        A11yText.ordered([
            A11yText.element("お知らせ", traits: [".isHeader"] + (level.map { ["段 \($0)"] } ?? [])),
            A11yText.element("明日は休みです"),
        ])
            + [level.map { "ローターの「見出しレベル \($0)」でも飛べる" } ?? "ローターの「見出し」で飛べる（段なし）"]
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityChartDescriptorEntry.swift`:

```swift
import Accessibility
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityChartDescriptor = CatalogEntry(
        id: "accessibilityChartDescriptor",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "グラフの題名・軸・データを支援技術に渡す modifier。VoiceOver のオーディオグラフで、値を音の高さで聞ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitychartdescriptor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityChartDescriptor", .fixed(code: "StepsChart()"), on: true,
                summary: "グラフの中身（AXChartDescriptorRepresentable）。VoiceOver のローターで「オーディオグラフ」を選んで聞く")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack(alignment: .bottom) {", "    ForEach(days) { day in",
                "        Rectangle().frame(width: 24, height: day.steps / 50)", "    }", "}",
                ".accessibilityElement()",
            ], indent: 0, call: ".accessibilityLabel", fixedArguments: ["\"歩数\""],
            closing: [
                "", "struct StepsChart: AXChartDescriptorRepresentable {",
                "    func makeChartDescriptor() -> AXChartDescriptor {",
                "        let x = AXCategoricalDataAxisDescriptor(title: \"曜日\", categoryOrder: [\"月\", \"火\", \"水\"])",
                "        let y = AXNumericDataAxisDescriptor(title: \"歩数\", range: 0...5000, gridlinePositions: []) { \"\\(Int($0)) 歩\" }",
                "        let points = [AXDataPoint(x: \"月\", y: 3000), AXDataPoint(x: \"火\", y: 5000), AXDataPoint(x: \"水\", y: 2000)]",
                "        let series = AXDataSeriesDescriptor(name: \"歩数\", isContinuous: false, dataPoints: points)",
                "        return AXChartDescriptor(title: \"1 週間の歩数\", summary: nil, xAxis: x, yAxis: y, additionalAxes: [], series: [series])",
                "    }", "}",
            ]),
        build: { v in
            AnyView(ChartDescriptorDemo(describes: v["accessibilityChartDescriptor"] != nil))
        }
    )
}

private struct ChartDescriptorDemo: View {
    let describes: Bool
    private let days = [(name: "月", steps: 3000.0), (name: "火", steps: 5000), (name: "水", steps: 2000)]

    var body: some View {
        A11yDemo(title: "VoiceOver に渡るグラフの中身", lines: lines) {
            HStack(alignment: .bottom) {
                ForEach(days, id: \.name) { day in
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 24, height: day.steps / 50)
                }
            }
            .accessibilityElement()
            .accessibilityLabel("歩数")
            .apply(describes ? () : nil) { view, _ in
                view.accessibilityChartDescriptor(StepsChart())
            }
        }
    }

    private var lines: [String] {
        describes
            ? ["「1 週間の歩数」 横の軸: 曜日・縦の軸: 歩数", "ローターの「オーディオグラフ」で、月 3,000・火 5,000・水 2,000 を音で聞ける"]
            : [A11yText.element("歩数"), "（グラフの中身は伝わらない）"]
    }
}

private struct StepsChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let x = AXCategoricalDataAxisDescriptor(title: "曜日", categoryOrder: ["月", "火", "水"])
        let y = AXNumericDataAxisDescriptor(title: "歩数", range: 0...5000, gridlinePositions: []) { "\(Int($0)) 歩" }
        let points = [AXDataPoint(x: "月", y: 3000), AXDataPoint(x: "火", y: 5000), AXDataPoint(x: "水", y: 2000)]
        let series = AXDataSeriesDescriptor(name: "歩数", isContinuous: false, dataPoints: points)
        return AXChartDescriptor(
            title: "1 週間の歩数", summary: nil, xAxis: x, yAxis: y, additionalAxes: [], series: [series])
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityCustomContentEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityCustomContent = CatalogEntry(
        id: "accessibilityCustomContent",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素に詳しい情報を足す modifier。VoiceOver はラベルのあとすぐには読まず、ローターの「詳しい情報」で読む。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitycustomcontent(_:_:importance:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityCustomContent", id: "accessibilityCustomContent.content", label: nil,
                .choice(
                    [Choice("産地", code: "\"産地\", \"青森\""), Choice("値段", code: "\"値段\", \"200 円\"")], initial: 0),
                on: true,
                summary: "情報の名前と中身"),
            .modifier(
                "accessibilityCustomContent", id: "accessibilityCustomContent.importance", label: "importance",
                .choice([Choice(".default"), Choice(".high")], initial: 0), required: true,
                summary: ".high なら、ラベルのあとに続けて読む"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"りんご\""]),
        build: { v in
            AnyView(
                CustomContentDemo(
                    content: v.pick("accessibilityCustomContent.content", from: [("産地", "青森"), ("値段", "200 円")]),
                    isHigh: v.pick("accessibilityCustomContent.importance", from: [false, true]) ?? false))
        }
    )
}

private struct CustomContentDemo: View {
    /// nil なら modifier をかけない
    let content: (label: String, value: String)?
    let isHigh: Bool

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Text("りんご")
                .font(.title3)
                .apply(content) { view, content in
                    view.accessibilityCustomContent(
                        LocalizedStringKey(content.label), Text(content.value), importance: isHigh ? .high : .default)
                }
        }
    }

    private var lines: [String] {
        guard let content else { return [A11yText.element("りんご")] }
        return [A11yText.element("りんご")]
            + [isHigh ? "続けて読む: \(content.label) \(content.value)" : "ローターの「詳しい情報」で: \(content.label) \(content.value)"]
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityAddTraitsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityAddTraits = CatalogEntry(
        id: "accessibilityAddTraits",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の特性（ボタン・見出し・選択中など）を足す modifier。VoiceOver はラベルのあとに特性を読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityaddtraits(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityAddTraits",
                .choice([Choice(".isButton"), Choice("[.isButton, .isSelected]"), Choice(".isHeader")], initial: 0),
                on: true,
                summary: "足す特性。押せる文字に .isButton を足すと「ボタン」と読む")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"お気に入り\""], suffix: [".onTapGesture { isFavorite.toggle() }"]),
        build: { v in
            AnyView(AddTraitsDemo(choice: v.pick("accessibilityAddTraits", from: [0, 1, 2])))
        }
    )
}

private struct AddTraitsDemo: View {
    /// nil なら modifier をかけない
    let choice: Int?
    @State private var isFavorite = false

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element("お気に入り", traits: traitNames)]) {
            Label("お気に入り", systemImage: isFavorite ? "star.fill" : "star")
                .labelStyle(.titleOnly)
                .font(.title3)
                .foregroundStyle(isFavorite ? .orange : .primary)
                .apply(choice) { view, choice in
                    view.accessibilityAddTraits(
                        [AccessibilityTraits.isButton, [.isButton, .isSelected], .isHeader][choice])
                }
                .onTapGesture { isFavorite.toggle() }
        }
    }

    private var traitNames: [String] {
        switch choice {
        case 0: [".isButton"]
        case 1: [".isButton", ".isSelected"]
        case 2: [".isHeader"]
        default: ["（特性なし。押せることが伝わらない）"]
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityLabeledPair,
        .accessibilityValue,
        .accessibilityTextContentType,
        .accessibilityHeading,
        .accessibilityChartDescriptor,
        .accessibilityCustomContent,
        .accessibilityAddTraits,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `python3 tools/catalog_progress.py accessible-descriptions`
Expected: `9 / 15`、終了コード 1（残りは Task 5）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AccessibleDescriptions WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 要素の説明の 7 件の収録

accessibilityLabeledPair・accessibilityValue・accessibilityTextContentType・accessibilityHeading・accessibilityChartDescriptor・accessibilityCustomContent・accessibilityAddTraits

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 5: accessible-descriptions の残り 6 件（特性・ヒント・読み方）

**Files:**
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityRemoveTraitsEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/AccessibilityHintEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/SpeechAdjustedPitchEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/SpeechAlwaysIncludesPunctuationEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/SpeechAnnouncementsQueuedEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleDescriptions/SpeechSpellsOutCharactersEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: Task 1 の `A11yDemo`・`A11yText`
- Produces: 6 件の `CatalogEntry`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessible-descriptions`
Expected: 終了コード 1。抜けが 6 件

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityRemoveTraitsEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRemoveTraits = CatalogEntry(
        id: "accessibilityRemoveTraits",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素の特性を取り除く modifier。文字の代わりに置いた絵を、「画像」と読ませないときなどに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityremovetraits(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRemoveTraits", .fixed(code: ".isImage"), on: true,
                summary: "取り除く特性。.isImage を取ると「画像」と読まない")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"star.fill\")"], call: ".accessibilityLabel", fixedArguments: ["\"評価 3\""]),
        build: { v in
            AnyView(RemoveTraitsDemo(removes: v["accessibilityRemoveTraits"] != nil))
        }
    )
}

private struct RemoveTraitsDemo: View {
    let removes: Bool

    var body: some View {
        A11yDemo(
            title: "VoiceOver が読む要素",
            lines: [A11yText.element("評価 3", traits: removes ? [] : [".isImage"])]
        ) {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
                .accessibilityLabel("評価 3")
                .apply(removes ? () : nil) { view, _ in
                    view.accessibilityRemoveTraits(.isImage)
                }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/AccessibilityHintEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityHint = CatalogEntry(
        id: "accessibilityHint",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "押すと何が起きるかを伝えるヒントを付ける modifier。VoiceOver は、ラベルと特性を読んで少し間をおいてから読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityhint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityHint", .text(initial: "メールを送って、一覧に戻ります"), on: true,
                summary: "ヒントの文。何が起きるかを短く書く")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"送る\""], trailing: " { send() }"),
        build: { v in
            AnyView(HintDemo(hint: v.text("accessibilityHint")))
        }
    )
}

private struct HintDemo: View {
    /// nil なら modifier をかけない
    let hint: String?

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: [A11yText.element("送る", traits: [".isButton"], hint: hint)]) {
            Button("送る") {}
                .buttonStyle(.borderedProminent)
                .apply(hint) { view, hint in
                    view.accessibilityHint(hint)
                }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/SpeechAdjustedPitchEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAdjustedPitch = CatalogEntry(
        id: "speechAdjustedPitch",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文を読む声の高さを上げ下げする modifier。-1（低い）〜 1（高い）で、0 がふつう。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechadjustedpitch(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAdjustedPitch", .slider(range: -1...1, step: 0.5, initial: 0.5), on: true,
                summary: "声の高さ。VoiceOver を入れて、文を読ませて聞く")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"電池が残りわずかです\""]),
        build: { v in
            AnyView(SpeechPitchDemo(pitch: v.number("speechAdjustedPitch")))
        }
    )
}

private struct SpeechPitchDemo: View {
    /// nil なら modifier をかけない
    let pitch: Double?

    var body: some View {
        A11yDemo(title: "VoiceOver の読み方", lines: [A11yText.element("電池が残りわずかです"), line]) {
            Text("電池が残りわずかです")
                .font(.title3)
                .apply(pitch) { view, pitch in
                    view.speechAdjustedPitch(pitch)
                }
        }
    }

    private var line: String {
        guard let pitch else { return "ふつうの高さの声で読む" }
        return switch pitch {
        case ..<0: "ふつうより低い声で読む（\(pitch.formatted())）"
        case 0: "ふつうの高さの声で読む（0）"
        default: "ふつうより高い声で読む（\(pitch.formatted())）"
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/SpeechAlwaysIncludesPunctuationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAlwaysIncludesPunctuation = CatalogEntry(
        id: "speechAlwaysIncludesPunctuation",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文の句読点や記号を、いつもすべて読むようにする modifier。記号に意味がある文に付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/speechalwaysincludespunctuation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAlwaysIncludesPunctuation", .toggle(initial: true), on: true,
                summary: "true なら記号もすべて読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"a + b = 10;\""]),
        build: { v in
            AnyView(PunctuationDemo(includes: v.flag("speechAlwaysIncludesPunctuation")))
        }
    )
}

private struct PunctuationDemo: View {
    /// nil なら modifier をかけない
    let includes: Bool?

    var body: some View {
        A11yDemo(
            title: "VoiceOver の読み方",
            lines: [
                A11yText.element("a + b = 10;"),
                includes == true ? "＋・＝・；もすべて読む" : "記号は、VoiceOver の設定（句読点）に従って読む",
            ]
        ) {
            Text("a + b = 10;")
                .font(.title3.monospaced())
                .apply(includes) { view, includes in
                    view.speechAlwaysIncludesPunctuation(includes)
                }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/SpeechAnnouncementsQueuedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAnnouncementsQueued = CatalogEntry(
        id: "speechAnnouncementsQueued",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "ラベルや値が変わったときの読み上げを、今の読み上げのあとに並べる modifier。付けないと、今の読み上げを止めて読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechannouncementsqueued(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAnnouncementsQueued", .toggle(initial: true), on: true,
                summary: "true なら、今の読み上げのあとに並べる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"進める\") { progress += 25 }"], call: "Text",
            fixedArguments: ["\"ダウンロード \\(progress)%\""], closing: ["}"]),
        build: { v in
            AnyView(AnnouncementsQueuedDemo(queued: v.flag("speechAnnouncementsQueued")))
        }
    )
}

private struct AnnouncementsQueuedDemo: View {
    /// nil なら modifier をかけない
    let queued: Bool?
    @State private var progress = 25

    var body: some View {
        A11yDemo(
            title: "値が変わったときの読み上げ",
            lines: [queued == true ? "今の読み上げのあとに読む" : "今の読み上げを止めて、すぐに読む"]
        ) {
            VStack(spacing: 8) {
                Button("進める") { progress = progress >= 100 ? 0 : progress + 25 }
                    .buttonStyle(.bordered)
                Text("ダウンロード \(progress)%")
                    .monospacedDigit()
                    .apply(queued) { view, queued in
                        view.speechAnnouncementsQueued(queued)
                    }
            }
        }
    }
}
```

`WidgetLab/Catalog/AccessibleDescriptions/SpeechSpellsOutCharactersEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let speechSpellsOutCharacters = CatalogEntry(
        id: "speechSpellsOutCharacters",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文を 1 文字ずつ区切って読むようにする modifier。確認のコードや型番に付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechspellsoutcharacters(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechSpellsOutCharacters", .toggle(initial: true), on: true,
                summary: "true なら 1 文字ずつ読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"XK7-29Q\""]),
        build: { v in
            AnyView(SpellsOutDemo(spells: v.flag("speechSpellsOutCharacters")))
        }
    )
}

private struct SpellsOutDemo: View {
    /// nil なら modifier をかけない
    let spells: Bool?

    var body: some View {
        A11yDemo(
            title: "VoiceOver の読み方",
            lines: [spells == true ? "X、K、7、ハイフン、2、9、Q と 1 文字ずつ読む" : "ひと続きの言葉として読む（数字はまとめて読むことがある）"]
        ) {
            Text("XK7-29Q")
                .font(.title2.monospaced())
                .apply(spells) { view, spells in
                    view.speechSpellsOutCharacters(spells)
                }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityRemoveTraits,
        .accessibilityHint,
        .speechAdjustedPitch,
        .speechAlwaysIncludesPunctuation,
        .speechAnnouncementsQueued,
        .speechSpellsOutCharacters,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `python3 tools/catalog_progress.py accessible-descriptions`
Expected: `15 / 15`、終了コード 0

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/AccessibleDescriptions WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 特性・ヒントと VoiceOver の読み方の 6 件の収録

accessibilityRemoveTraits・accessibilityHint・speechAdjustedPitch・speechAlwaysIncludesPunctuation・speechAnnouncementsQueued・speechSpellsOutCharacters

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

---

### Task 6: accessible-navigation の 4 件と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/AccessibleNavigation/AccessibilityNavigationDemo.swift`
- Create: `WidgetLab/Catalog/AccessibleNavigation/AccessibilityRotorEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleNavigation/AccessibilityRotorEntryEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleNavigation/AccessibilityLinkedGroupEntry.swift`
- Create: `WidgetLab/Catalog/AccessibleNavigation/AccessibilitySortPriorityEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（1 本足す）
- Modify: `docs/architecture.md`・`docs/cataloging-guide.md`

**Interfaces:**
- Consumes: Task 1 の `A11yDemo`・`A11yText`
- Produces: 4 件の `CatalogEntry`（id `accessibilityRotorEntry` のファイルは `AccessibilityRotorEntryEntry.swift`。手引きの決まり `<名前>Entry.swift` のまま）、補助 `DemoMail`・`DemoMailRow(mail:)`。UI テスト `testA11yEntriesShowPreview`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py accessible-navigation`
Expected: 終了コード 1。抜けが 4 件

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/AccessibleNavigation/AccessibilityNavigationDemo.swift`:

```swift
import SwiftUI

/// accessible-navigation の収録で使うメール 1 通
nonisolated struct DemoMail: Identifiable, Sendable {
    let id: Int
    let subject: String
    let isUnread: Bool

    static let samples = [
        DemoMail(id: 1, subject: "会議の件", isUnread: true),
        DemoMail(id: 2, subject: "週末の予定", isUnread: false),
        DemoMail(id: 3, subject: "請求書", isUnread: true),
        DemoMail(id: 4, subject: "お礼", isUnread: false),
    ]
}

/// メールの行。未読は太字と青い点
struct DemoMailRow: View {
    let mail: DemoMail

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(mail.isUnread ? .blue : .clear)
                .frame(width: 8, height: 8)
            Text(mail.subject)
                .fontWeight(mail.isUnread ? .bold : .regular)
            Spacer()
        }
        .frame(width: 200)
    }
}
```

`WidgetLab/Catalog/AccessibleNavigation/AccessibilityRotorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRotor = CatalogEntry(
        id: "accessibilityRotor",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "VoiceOver のローターに、自分で決めた項目を足す modifier。選んだ項目で、当てはまる要素だけを順に飛べる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityrotor(_:entries:entrylabel:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRotor",
                .choice(
                    [
                        Choice("未読", code: "\"未読\", entries: unreadMails, entryLabel: \\.subject"),
                        Choice("既読", code: "\"既読\", entries: readMails, entryLabel: \\.subject"),
                    ], initial: 0), on: true,
                summary: "ローターの名前と、飛ぶ先の一覧。一覧の id で、同じ id の行へ飛ぶ")
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    ForEach(mails) { mail in\n        MailRow(mail: mail)\n    }\n}"),
        build: { v in
            AnyView(RotorDemo(unread: v.pick("accessibilityRotor", from: [true, false])))
        }
    )
}

private struct RotorDemo: View {
    /// nil なら modifier をかけない。true なら未読、false なら既読
    let unread: Bool?

    var body: some View {
        A11yDemo(title: "VoiceOver のローター", lines: [line]) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(DemoMail.samples) { mail in
                    DemoMailRow(mail: mail)
                }
            }
            .apply(unread) { view, unread in
                view.accessibilityRotor(
                    unread ? "未読" : "既読", entries: DemoMail.samples.filter { $0.isUnread == unread },
                    entryLabel: \.subject)
            }
        }
    }

    private var line: String {
        guard let unread else { return "（自分で足した項目なし）" }
        let subjects = DemoMail.samples.filter { $0.isUnread == unread }.map(\.subject)
        return "「\(unread ? "未読" : "既読")」を選び、上下にスワイプ: " + subjects.joined(separator: " → ")
    }
}
```

`WidgetLab/Catalog/AccessibleNavigation/AccessibilityRotorEntryEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRotorEntry = CatalogEntry(
        id: "accessibilityRotorEntry",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "View の要素に、ローターの項目が飛ぶ先の id を付ける modifier。ローターの AccessibilityRotorEntry と、同じ id と namespace で結ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityrotorentry(id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRotorEntry", .fixed(code: "id: mail.id, in: namespace"), on: true,
                summary: "飛ぶ先の id と namespace。外すと、ローターの項目はあっても飛ぶ先が見つからない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    ForEach(mails) { mail in"], indent: 8, call: "MailRow",
            fixedArguments: ["mail: mail"],
            closing: [
                "    }", "}", ".accessibilityRotor(\"未読\") {", "    ForEach(unreadMails) { mail in",
                "        AccessibilityRotorEntry(mail.subject, mail.id, in: namespace)", "    }", "}",
            ]),
        build: { v in
            AnyView(RotorEntryDemo(marks: v["accessibilityRotorEntry"] != nil))
        }
    )
}

private struct RotorEntryDemo: View {
    let marks: Bool
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver のローター", lines: lines) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(DemoMail.samples) { mail in
                    DemoMailRow(mail: mail)
                        .apply(marks ? () : nil) { view, _ in
                            view.accessibilityRotorEntry(id: mail.id, in: namespace)
                        }
                }
            }
            .accessibilityRotor("未読") {
                ForEach(DemoMail.samples.filter(\.isUnread)) { mail in
                    AccessibilityRotorEntry(mail.subject, mail.id, in: namespace)
                }
            }
        }
    }

    private var lines: [String] {
        marks
            ? ["「未読」を選び、上下にスワイプ: 会議の件 → 請求書", "（その行へ VoiceOver のカーソルが移る）"]
            : ["「未読」はあるが、飛ぶ先の行が決まらない"]
    }
}
```

`WidgetLab/Catalog/AccessibleNavigation/AccessibilityLinkedGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityLinkedGroup = CatalogEntry(
        id: "accessibilityLinkedGroup",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "離れた場所にある要素どうしをつなぐ modifier。VoiceOver で、つないだ要素の間をすぐ行き来できる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitylinkedgroup(id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityLinkedGroup", .fixed(code: "id: \"q1\", in: namespace"), on: true,
                summary: "つなぐ印。問 1 と同じ id と namespace を答え 1 に付ける")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack(alignment: .leading) {", "    Text(\"問 1: 2 + 3 は？\")",
                "        .accessibilityLinkedGroup(id: \"q1\", in: namespace)", "    Text(\"問 2: 4 + 4 は？\")",
                "    Divider()",
            ], call: "Text", fixedArguments: ["\"答え 1: 5\""], closing: ["    Text(\"答え 2: 8\")", "}"]),
        build: { v in
            AnyView(LinkedGroupDemo(links: v["accessibilityLinkedGroup"] != nil))
        }
    )
}

private struct LinkedGroupDemo: View {
    let links: Bool
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver の行き来", lines: [line]) {
            VStack(alignment: .leading, spacing: 6) {
                Text("問 1: 2 + 3 は？")
                    .accessibilityLinkedGroup(id: "q1", in: namespace)
                Text("問 2: 4 + 4 は？")
                Divider()
                Text("答え 1: 5")
                    .apply(links ? () : nil) { view, _ in
                        view.accessibilityLinkedGroup(id: "q1", in: namespace)
                    }
                Text("答え 2: 8")
            }
            .frame(width: 200)
        }
    }

    private var line: String {
        links ? "「問 1」と「答え 1」の間を、間の要素を飛ばして行き来できる" : "問 1 → 問 2 → 答え 1 の順にしか進めない"
    }
}
```

`WidgetLab/Catalog/AccessibleNavigation/AccessibilitySortPriorityEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilitySortPriority = CatalogEntry(
        id: "accessibilitySortPriority",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "同じ入れ物の中で、要素を読む順を決める modifier。数が大きいものから読む（既定は 0）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitysortpriority(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilitySortPriority", .slider(range: -1...2, step: 1, initial: 1), on: true,
                summary: "読む順の重み。値段に 1 を付けると、名前より先に読む")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"りんご\")"], call: "Text", fixedArguments: ["\"200 円\""],
            closing: ["    Text(\"青森\")", "}", ".accessibilityElement(children: .contain)"]),
        build: { v in
            AnyView(SortPriorityDemo(priority: v.number("accessibilitySortPriority")))
        }
    )
}

private struct SortPriorityDemo: View {
    /// nil なら modifier をかけない
    let priority: Double?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: A11yText.ordered(order.map { A11yText.element($0) })) {
            VStack(spacing: 4) {
                Text("りんご")
                    .font(.title3)
                Text("200 円")
                    .font(.headline)
                    .apply(priority) { view, priority in
                        view.accessibilitySortPriority(priority)
                    }
                Text("青森")
                    .font(.caption)
            }
            .accessibilityElement(children: .contain)
        }
    }

    /// 重みの大きい順。同じ重みなら上から
    private var order: [String] {
        let items = [("りんご", 0.0), ("200 円", priority ?? 0), ("青森", 0)]
        return items.enumerated().sorted { a, b in
            a.element.1 != b.element.1 ? a.element.1 > b.element.1 : a.offset < b.offset
        }.map(\.element.0)
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .accessibilityRotor,
        .accessibilityRotorEntry,
        .accessibilityLinkedGroup,
        .accessibilitySortPriority,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す。UI テストはアクセシビリティの木を読めるので、ラベル（accessibilityLabel）と `.combine` の結果（accessibilityElement）が木に届いたことも確かめる:

```swift
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

```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「アプリの骨組み・データとフォーカスの代表 2 件ずつのスクリーンショットの 13 本」を、「アプリの骨組み・データとフォーカス・アクセシビリティの代表 2 件ずつのスクリーンショットの 14 本」に置き換える（ほかの束が先に本数を変えていたら、その並びに「アクセシビリティ」を足し、本数に 1 を足す）

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 3 か所だけ直す（ほかの行は変えない）。ほかの束が先に同じ行を直していたら、その行に束 11 の分を足す。

1. 5 章の「束 9 は `testDataEntriesShowPreview`）。」を「束 9 は `testDataEntriesShowPreview`、束 11 は `testA11yEntriesShowPreview`）。」に置き換える
2. 7 章の最後の段落（`## 用語` の前）のあとに、空行を挟んで次の段落を足す:

```markdown
**支援技術がないと効き目が見えない modifier → 見本の下に「支援技術に渡る中身」の札を出す。** SwiftUI は、VoiceOver などの支援技術が動いていないとアクセシビリティの要素を作らない（`UIHostingController` の `accessibilityElements` は空だった）ので、アプリの中から木を読んで出すことはできない。`Catalog/AccessibilityFundamentals/AccessibilityDemo.swift` の `A11yDemo(title:lines:) { 見本 }` で、見本に渡したのと同じ値から札を書く。特性は SwiftUI の名前（`.isButton` など）で書き、VoiceOver の日本語の言い方は書かない。触れる場所の modifier は `A11yPointMarker` の赤い点で場所を出す（束 11）。

**札の中身は、一時的な UI テストの木と突き合わせる。** UI テストは支援技術として木を読めるので、`app.debugDescription` を書き出して札と比べる。`.combine` のラベルは「、」でつなぐ、SF Symbols の既定のラベルは日本語の名前（`trash` は「ゴミ箱」、`sparkles` は「ぴかぴか」）、`Label` は絵と文字の 2 つの要素、`Text("\(3000) 歩")` は「3,000 歩」になる。ただし UI テストの木は VoiceOver と同じではない（`accessibilityHidden(true)` の View も出る、`accessibilityLabeledPair` の組は出ない）。束の終わりの UI テストでは、ラベルが木に届いたことを `buttons["ごみ箱に入れる"]` のように確かめられる（束 11）。

**`accessibilityRepresentation` の付け外し → `.id` で見本を作り直す。** 同じ View のまま representation を外すと、UI テストでアプリが idle にならず止まった（束 11）。

**文字の大きさを変えて撮る → `launchArguments` に `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXL` を足す。** `accessibilityLargeContentViewerEnabled` は true になるが、UI テストの長押しでは大きく出す画面は撮れなかった。iOS の UI テストには `XCUIElement.increment()` もないので、調整できる要素の上げ下げも試せない（束 11）。

**iPhone で試せなかったアクセシビリティの modifier（束 11 で `.note` にした）:** `assistiveAccessNavigationIcon`（アシスティブアクセスに入ったときだけ効き、アプリの中からは入れない）。VoiceOver で聞けば確かめられるもの（speech の 4 件・ローター）は、札で違いを見せて `.card` にした。
```

3. 最後の行「最終更新: 2026-11-04（束 2〜9 のあと）」を「最終更新: 2026-11-04（束 2〜9・11 のあと）」に置き換える（ほかの束が先に変えていたら、括弧の中に「・11」を足す）

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0

Run: `for t in accessibility-fundamentals accessible-appearance accessible-controls accessible-descriptions accessible-navigation; do python3 tools/catalog_progress.py $t || echo "抜けあり: $t"; done`
Expected: `5 / 5`・`3 / 3`・`12 / 12`・`15 / 15`・`4 / 4`。「抜けあり」は出ない

撮った画像を取り出して、`accessibilityLabel` と `accessibilityElement` の詳細画面で、見本の下に札が出ていることを見る:

Run: `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`

- [ ] **Step 7: コミットする**

```bash
git add WidgetLab/Catalog/AccessibleNavigation WidgetLab/Catalog/Catalog.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md
git commit -m "feat: 画面の中の移り方の 4 件の収録と、束 11 の確かめ

accessibilityRotor・accessibilityRotorEntry・accessibilityLinkedGroup・accessibilitySortPriority。UI テスト testA11yEntriesShowPreview と手引きの追記

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

### Task 7: main を取り込み、「抜け 0」をテストの条件にする

計画を書いた時点では束 10 が main に入っておらず、このテストは足さない予定だった。作業中に束 10（`cf73ae0`）が main にマージされ、main で抜けているのがこの束の 39 件だけになったので、オーナーの判断（2026-11-04）でこの束で足す。

**Files:**
- Modify: `WidgetLabTests/Catalog/CatalogTests.swift`（テストを 1 本足す）
- Modify: `docs/cataloging-guide.md`（5 章の 1 か所）
- Merge: `main` をこのブランチに取り込む（ぶつかったファイルを直す）

**Interfaces:**
- Consumes: `Catalog.all`・`Manifest.entries`（どちらも今のまま）
- Produces: `CatalogTests.everyManifestEntryIsCataloged()`

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Catalog/CatalogTests.swift` の `idsAreUniqueAndListedInManifestWithSameKindAndTopic()` の閉じ括弧のあと（`propertyIDsAreUniqueInEachEntry()` の前）に、空行を挟んで足す:

```swift
    @Test func everyManifestEntryIsCataloged() {
        let cataloged = Set(Catalog.all.map(\.id))
        let missing = Manifest.entries.map(\.id).filter { !cataloged.contains($0) }
        #expect(missing.isEmpty, "Catalog.all にない Manifest の id（収録の抜け）: \(missing.joined(separator: ", "))")
    }
```

- [ ] **Step 2: 失敗することを確かめる**

Run: Global Constraints の確かめのコマンドの `-only-testing:WidgetLabTests` を `-only-testing:WidgetLabTests/CatalogTests/everyManifestEntryIsCataloged` に変えたもの
Expected: 失敗する。メッセージに束 10 の id（`DragGesture`・`onDrop` など 43 件）が並ぶ（このブランチには束 10 がまだないため）

- [ ] **Step 3: テストをコミットし、main を取り込む**

```bash
git add WidgetLabTests/Catalog/CatalogTests.swift
git commit -m "test: Manifest の全件が収録されていること（抜け 0）を CatalogTests の条件にする

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
git merge --no-ff main -m "Merge branch 'main' into feat/swiftui-p3-a11y: 束 10 を取り込む"
```

ぶつかったら、両方の行を残して直す:
- `WidgetLab/Catalog/Catalog.swift`: `all` の最後に、main の側（束 10）の行を先に、この束の 39 行をあとに並べる。1 行に 1 件
- `docs/architecture.md`: `WidgetLabUITests/` の行の並びに「入力」と「アクセシビリティ」の両方を残し、本数は main の本数に 1 を足す
- `docs/cataloging-guide.md`: 5 章の UI テストの並びに両方の束を残す。7 章の段落は両方を残す（main の段落が先）。最後の「最終更新」の行は、括弧の中に両方の束の番号を入れる
- `WidgetLabUITests/LaunchUITests.swift`: 両方のテストの関数を残す

直したら `git add` で解消を記録し、`git commit --no-edit` でマージを終える

- [ ] **Step 4: 手引きに書く**

`docs/cataloging-guide.md` の 5 章の「id と Manifest の一致、」を「id と Manifest の一致、Manifest の全件が `Catalog.all` にあること（抜け 0。束 11 から）、」に置き換える（ほかの行は変えない）

- [ ] **Step 5: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint は何も出さない。道具のテストは `OK`。`result` が `Passed`、`failedTests` が 0（`everyManifestEntryIsCataloged` も通る）

Run: `python3 tools/catalog_progress.py`
Expected: 最後の行が `合計 458 / 458（抜け 0）`、終了コード 0

- [ ] **Step 6: コミットする**

```bash
git add docs/cataloging-guide.md
git commit -m "docs: 収録の手引きに、抜け 0 がテストの条件になったことを書く

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

## 残したこと

- **大きく出す画面（`accessibilityShowsLargeContentViewer`）とスマート反転（`accessibilityIgnoresInvertColors`）の見た目は、画像で確かめていない。** UI テストの長押しでは大きく出す画面が出ず、スマート反転はシミュレータの設定を UI テストから入れられない。札の環境の値（「今は使える」）が文字の大きさで変わることは確かめた。実機かシミュレータの設定で、手で一度見る
- **VoiceOver の実際の読み上げ・操作（speech の 4 件・ローター・操作の一覧・カーソルの移動）は、耳と手では確かめていない。** UI テストの木で確かめたのは、ラベル・値・識別子・`.combine`・並び・子まで。束 12 の仕上げで、VoiceOver を入れて代表を触る
- 比べるでは、左右の札が仕切りで切れて重なる。ほかの束と同じ見え方（仕切りを動かして読む）なので、そのままにした
- `CatalogTests` で「FocusState の値を View の body の外で読んだ」という実行時の警告が出る（失敗ではない）。ImageRenderer で `@FocusState`・`@AccessibilityFocusState` を持つ見本を描くため。束 9 の SceneStorage の警告と同じ種類

## 終わったら

- 束の最終レビュー（opus）を通す
- Task 7 で main を取り込んであるので、マージの前に main がそのあと進んでいないかを `git log feat/swiftui-p3-a11y..main` で見る（進んでいたら、もう一度取り込んでテストを通す）
- `~/dev/widget-lab`（main）で、`git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からある）で、ほかの束がマージの途中でない（`git -C ~/dev/widget-lab rev-parse -q --verify MERGE_HEAD` が何も出さない）ことを確かめてから、`git merge --no-ff feat/swiftui-p3-a11y` する。`Catalog.swift`・`docs/architecture.md`・`docs/cataloging-guide.md`・`WidgetLabUITests/LaunchUITests.swift` がぶつかったら両方の行を残す
- マージのあと、main の `swiftui/` で lint と単体テスト（Global Constraints の確かめのコマンド）を通してから push する。ブランチは消さない
