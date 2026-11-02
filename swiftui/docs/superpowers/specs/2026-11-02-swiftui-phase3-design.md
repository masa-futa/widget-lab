# SwiftUI 版 Phase 3: 全トピックの収録

> **要約**
> - 結論: 残りの 451 件を、土台の PR のあとに 30〜50 件ずつの束 11 本で収録する。土台と束 1 は直列で進めて収録の型と手順を固め、束 2〜11 は herdr で 2〜3 本ずつ並列にする。アプリの画面では試せないものは、「説明だけ」の stage（`.note`）で収録する
> - 前提: [全体の spec](2026-10-31-swiftui-app-design.md)、[Phase 2 の spec](2026-11-02-swiftui-phase2-design.md)、[次の段に回したこと](../plans/2026-11-02-swiftui-phase1-followups.md)
> - 範囲外: ストア公開の準備（Phase 4）、manifest の数え方の変更、iOS 27.1 以降の記号

## 束の分け方

土台の PR では収録しない。束はトピックを束ねて 30〜50 件にし、大分類をまたがない（束 9 だけ、件数をそろえるために Data and storage と Event handling の小さなトピックを束ねる）。件数は収録済みの 7 件（`Button`・`Text`・`VStack`・`padding`・`State`・`Binding`・`TapGesture`）を除いた数。

| 順 | 束 | トピック | 件数 |
|---|---|---|---|
| 0 | 土台 | なし（下の「土台の PR」） | – |
| 1 | レイアウト | layout-fundamentals・layout-adjustments・custom-layout・view-groupings | 33 |
| 2 | テキスト | text-input-and-output | 43 |
| 3 | 操作の部品 | controls-and-indicators・menus-and-commands・view-fundamentals・view-configuration | 42 |
| 4 | 描画と形 | drawing-and-graphics・shapes | 43 |
| 5 | スタイルと動き | view-styles・images・animations | 40 |
| 6 | 一覧とスクロール | lists・tables・scroll-views | 46 |
| 7 | 画面の行き来 | modal-presentations・navigation | 49 |
| 8 | アプリの骨組み | toolbars・search・app-organization・scenes・windows・documents・app-extensions | 32 |
| 9 | データとフォーカス | model-data・environment-values・preferences・persistent-storage・focus・system-events・clipboard | 41 |
| 10 | 入力 | gestures・input-events・drag-and-drop | 43 |
| 11 | アクセシビリティ | accessibility-fundamentals・accessible-appearance・accessible-controls・accessible-descriptions・accessible-navigation | 39 |
| 12 | 仕上げ | なし（見た目と a11y の持ち越し課題） | – |

合計 451 件。束 1 をレイアウトにするのは、`frame(width:height:)`・`offset(x:y:)` のような複数の引数を持つ modifier が多く、土台で直した型をすぐ試せるため。

## 進め方

- 順番: 土台 → 束 1 は直列（この流れで型と手順を固める）。束 1 のマージのあと、収録の手引きを書いてから、束 2〜11 を herdr で 2〜3 本ずつ並列にする。並びは上の表の順を目安にし、空いた枠から次の束を始める
- 1 束の流れ: main からブランチ `feat/swiftui-p3-<束>` を切る → 計画を書く → 試作を作業用のコピー（scratchpad）で作ってテストを通し、そのコードを計画に入れる → Subagent-Driven（実装 haiku・レビュー sonnet、1 タスク 5〜8 件）→ 束の最終レビュー（opus）→ main にマージして push。ブランチは消さない
- 計画には 1 件ずつ、stage・プロパティ・コードの形を表にし、`.note` にするものは理由も書く
- spec は Phase 3 全体でこの 1 枚。計画は土台と束ごとに 1 枚（`swiftui/docs/superpowers/plans/`）
- 並列の束が触る共通のファイルは `Catalog.swift` の一覧だけ（Xcode のフォルダの同期で、ファイルを足しても project.pbxproj は変わらない）。ぶつかったら行を足すだけで直す

## 土台の PR

### 収録の型

- **プロパティの id と名前を分ける**: `PropertySpec.modifier` に `id:` を足す。省けば今と同じく modifier の名前を id にするので、今の収録は書き直さない
- **複数の引数を持つ modifier**: 同じ modifier の名前を持つプロパティは、コードで 1 行にまとめる。例: `.modifier("frame", id: "frame.width", label: "width", …)` と `.modifier("frame", id: "frame.height", label: "height", …)` が ON なら `.frame(width: 120, height: 80)`
  - チップと ON / OFF は引数ごと。全部 OFF ならその行を出さない
  - `.modifier` にも `required:` を足す。required の引数は、同じ modifier のどれかが ON のとき必ず書く（例: `shadow` の `radius`）
  - まとめた行の `propertyIDs` には、その行に書いた全部の id を入れる（チップを選ぶとその行が光る）
  - modifier の収録そのもの（`.shadow` の収録など）は、今の `.argument` で複数の引数を表せるので変えない
- **引数の並び**: 今までどおり定義の順 = Swift の引数の順 = チップの順。分けると、収録を書く手間と間違いが増えるため。ADR-0002 の「見直すきっかけ」にこの結び付きを書く
- **スライダーの小数**: step の小数の桁数で書く（step 0.25 → "0.25"、step 0.1 → "0.1"、整数の step なら整数）
- **「説明だけ」の stage**: `DemoStage.note(reason: String)` を足す
  - プレビューの枠に、見本の代わりに「ここで試せない理由」と使う場所（例: 「ウィジェットの中で効く」）を出す
  - チップとコードはふつうの収録と同じに動き、コードの写しもできる
  - `build` を書かない初期化を用意する
  - 一覧の行は、`.full`・`.behavior` と同じく stage ごとの絵にする
  - 基準: アプリの 1 画面の中で、効き目を見たり触ったりできないもの（アプリ拡張・アプリの入口・iOS で効かない窓の modifier・外の仕組み（Core Data など）を要るもの）。迷ったら、束の計画で 1 件ずつ決める

### 道具とテスト

- 生成する `Category` を `TopicCategory` に改名する（`tools/make_manifest.py` と使う側）
- `tools/catalog_progress.py`: Manifest の id と、収録ファイル（`Catalog/*/*Entry.swift`）の id を突き合わせ、トピックごとの収録数と抜けを出す。道具のテストも足す。「抜け 0」をテストの条件にするのは束 11 で
- `CatalogTests` に足す確認
  - `code.wrapper` があるなら `.wrapper` のプロパティがある（逆も）
  - `pick` の選択肢の数と、渡す配列の数が合う（`pick` の中で DEBUG のときだけ確かめる）
  - `.behavior` の見本も `ImageRenderer` で描く（窓口が nil なら記録しない）。`.full` は組み立てだけ。`.note` は描かない。全体の spec の「テスト」の節も直す
- `CodeGenerator.wrapperLines`: 宣言の行を、`@` + id の語として一致させて探す（`@StateObject` が `@State` に当たらないように）
- `CatalogViewModel.sections` を `init` で 1 回だけ作る
- テストの抜けを埋める: `CodeGeneratorTests`（ラベル付きの modifier、required の引数、複数行の末尾のクロージャの印、`changedIDs` が空のとき、まとめた modifier の行）、`DetailViewModelTests`（`selectedLine` の代わりの行、`entry(id:)`、`TapGesture(count: 2)` と OFF のときの `TapGesture()`）

### 土台に入れないもの

followups のうち見た目と a11y の課題（VoiceOver での複数回のタップ、記録の欄の高さ、UI テストで左右を確かめる、チップの選んでいる状態の形、コードの帯の読み上げ、文字を大きくしたときの高さ、一覧の行の押したときの地）は、束 12 の仕上げの PR にまとめる。収録が増えてから、まとめて見たほうが直し方を決めやすいため。

## 収録の手引き

束 1 のマージのあと、`swiftui/docs/cataloging-guide.md` を書く。並列の束は、この手引きと束 1 の収録を手本にする。

- stage の選び方（`.card`・`.full`・`.behavior`・`.note`）
- プロパティの選び方: 1 件に 3〜6 個を目安に、よく使う引数と、同じ節の modifier から選ぶ
- コードの形（`CodeTemplate` の書き方、modifier の収録でかける相手の見本）
- `.note` にする基準
- テストの書き方

## 確かめ方

どの PR も次を通す。

- `swiftui/` で: lint・道具のテスト・`xcodebuild test`（引き継ぎメモと swiftui/CLAUDE.md のコマンド）
- 束では、`catalog_progress.py` で、その束のトピックの抜けが 0
- 束では、UI テストのスクリーンショットで代表の 1〜2 件の見た目を見る（全件は撮らない）

## 終わったと言える条件

- 458 件すべてが収録されている
- `CatalogTests` で「抜け 0」がテストの条件になり、通る
- 束 12（仕上げ）がマージされている

## 決めたことと比べた案

| 問い | 決めたこと | 選ばなかった案 |
|---|---|---|
| 持ち越しの課題をどこで扱うか | 収録の前に土台の PR でまとめて直す。見た目と a11y は最後の仕上げへ | 収録しながら要るときに直す（型の変更が収録の PR に混ざり、並列にしにくい）／followups を全部先に直す（収録に入るのが遅れる） |
| PR の単位 | トピックを束ねて 30〜50 件、11 本 | 大分類ごと 6 本（100 件を超える束があり重い）／トピックごと 41 本（1〜3 件の PR が多く手間が増える） |
| 並列にするか | 土台と束 1 は直列、そのあと herdr で 2〜3 本ずつ | 最初から並列（書き方が束ごとにばらつく）／全部直列（時間がかかる） |
| 画面で試せないもの | `.note` の stage で説明とコードだけ収録する。manifest の数は変えない | manifest から外す（数え方と PRD を直すことになる）／本物を作る（Core Data の土台・拡張のターゲットが増える） |
| 複数の引数を持つ modifier | 同じ名前のプロパティを 1 行にまとめ、チップは引数ごと | 1 つのプロパティに複数の値を持たせる（操作部品が増え、編集パネルが複雑になる） |
