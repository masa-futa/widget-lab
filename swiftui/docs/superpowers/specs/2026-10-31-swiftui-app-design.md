# SwiftUI 版の Widget Lab を `swiftui/` に作る

> **要約**
> - 結論: SwiftUI の API リファレンスのうち、iOS 27.0 で使える View・modifier・プロパティラッパー・ジェスチャーの型（約 460 件）を、トピックをジャンルにして収録する iPhone のアプリを作る。機能と画面の形は Flutter 版と同じ
> - 影響: 新しく `swiftui/` を作る（Xcode のプロジェクト・CLAUDE.md・docs）。Flutter 版のコードは変えない
> - お願い: なし（2026-10-31 オーナーが各節を承認）

## 背景
ルートの ADR-0001 で、SwiftUI 版は Flutter 版とは別のネイティブアプリとして `swiftui/` に作ると決めた。全体の進め方（1. リポジトリの組み替え → 2. SwiftUI 版 → 3. Compose 版）のうち、この spec は 2 を扱う。

Flutter 版は「公式 Widget カタログに載る全 Widget」を収録し、`manifest.dart` との突き合わせで抜けがないことを確かめている。SwiftUI には同じ役目のカタログがないので、何を一覧の拠りどころにし、何を「全部」と数えるかから決めた。

## 収録の範囲

### 拠りどころ
SwiftUI の API リファレンス（https://developer.apple.com/documentation/swiftui ）のトピック分けを正本にする。リファレンスは JSON（`https://developer.apple.com/tutorials/data/documentation/swiftui.json` と、トピック・記号ごとの `.json`）で取り出せるので、manifest を機械で作れる。

- 大分類（6 つ）: Views・View layout・App structure・Data and storage・Event handling・Accessibility
- ジャンル: 大分類の下のトピック（Controls and indicators・Layout adjustments・Modal presentations など）。並びはリファレンスの順
- Essentials・Framework integration・Tool support・Structures の大分類は対象にしない（記事や他のフレームワークとのつなぎで、触る部品がない）

### 数え方
次のすべてを満たす記号を、1 件として収録する。

1. 上の 6 つの大分類のトピックのページに載っている
2. iOS で使え、iOS では非推奨でなく、iOS の導入の版が 27.0 以下（最低の版に合わせる。27.1 以降のものは最低の版を上げたときに足す）
3. 種類が次のどれか
   - **View**: `View` に準拠する struct。ただし型の都合の View（`AnyView`・`ModifiedContent`・`TupleView`・`EmptyView`・`Subview` などの、manifest を作る道具の除外の一覧に書いたもの）は除く
   - **modifier**: `View` の拡張のメソッド。リファレンスの同じ節（topic section）に View があれば、その節の modifier はその View のプロパティにして、単独では収録しない。View のいない節の modifier は 1 件ずつ収録する。オーバーロードは名前（`(` より前）でまとめて 1 件にする
   - **プロパティラッパー**: `DynamicProperty` に準拠する型（`State`・`Binding`・`Environment`・`FocusState`・`AppStorage`・`Namespace`・`ScaledMetric` など）
   - **ジェスチャーの型**: `Gesture` に準拠する型（`TapGesture`・`DragGesture`・`MagnifyGesture` など）
4. スタイルの型（`BorderedButtonStyle` など）・設定の型・列挙型は収録しない。`.buttonStyle` などのプロパティの選択肢として使う

2026-10-31 に数えた件数（型の都合の View を除く前）: View 103・単独の modifier 344・プロパティラッパー 19・ジェスチャーの型 14。除いたあとは約 460 件の見込み。正確な数は manifest を作ったときに決まる。

複数のトピックに載る記号は、リファレンスの順で最初に載ったトピックに置く（Flutter 版の「最初のジャンルに置く」と同じ）。

## 機能
Flutter 版の PRD と同じ一式にする。

- ホーム（大分類ごとのトピックの行）と、名前の部分一致の検索（大文字・小文字を区別しない）
- 詳細: 公式の要約（日本語）とリンク、プロパティの一言の説明
- プレイグラウンド: プロパティごとの ON/OFF と値の変更、初期状態に戻す
- 比べる: 選んでいるプロパティについて、付けた状態と付けない状態を左右に分け、仕切りをドラッグして見比べる
- 見た目を持たないもの（プロパティラッパー・アクセシビリティ・イベント系）の可視化: body が評価された回数、値の伝わり方、イベントのログ、VoiceOver の読み上げ文
- コードの表示とコピー（Swift のコード）
- オフライン（公式ページへのリンクを開くときだけ通信する）、日本語のみ、ダークモード対応、アプリ自体の UI は WCAG 2.2 AA を目安にする

対象にしないもの: modifier の順番を入れ替える操作（v2 の候補）、Flutter 版の PRD の「対象外スコープ」に挙げたもの全部（サードパーティ・自分の部品の登録・アカウント・逆引き・独自の説明文・日本語以外・収益化）。

## プロジェクトの形と道具
- 場所: `swiftui/`。Xcode のプロジェクト、`swiftui/CLAUDE.md`、`swiftui/README.md`、`swiftui/docs/`
- Xcode のプロジェクト: Xcode で作った `.xcodeproj` をそのままコミットする（XcodeGen・Tuist は使わない）。フォルダと同期するグループを使う
- 言語とスタック: Swift 6 の言語モード（厳格な並行性チェック）。外部のパッケージは使わない。状態は `@Observable`、遷移は `NavigationStack`、文言は String Catalog（`Localizable.xcstrings`、日本語のみ）
- 対象: iPhone、iOS 27.0 以上。iPad はスマホと同じ 1 カラムで表示する
- 識別子: bundle ID は `jp.nimi.widgetLab.swiftui`。表示名は `Widget Lab SwiftUI`（同じ端末の Flutter 版 `Widget Lab` と見分けるため）
- アプリ自体の UI: iOS 標準の見た目（HIG）。標準の `List`・`NavigationStack`・`.searchable` で作る
- テスト: Swift Testing。`xcodebuild test` をシミュレータで実行する。確かめのコマンドは `swiftui/CLAUDE.md` に書く
- manifest を作る道具: `swiftui/tools/` に Python のスクリプトを置き、リファレンスの JSON から `Manifest.swift`（収録すべき id・種類・トピックの一覧）を作る。生成した結果はコミットする。上の「数え方」をこのスクリプトが実装する

## 収録データとデモの組み立て
Flutter 版の ADR-0002 と同じく、収録データ（プロパティの定義の一覧＋組み立ての関数）から、操作パネル・プレビュー・比較・コードを共通の仕組みで作る。

### 型

```swift
struct CatalogEntry: Identifiable, Sendable {
    let id: String              // manifest と照らすキー（例: "Button"、"padding"、"State"）
    let kind: EntryKind         // .view / .modifier / .propertyWrapper / .gesture
    let topic: Topic            // リファレンスのトピック（= ジャンル）
    let summary: String         // 公式の要約（日本語）
    let docURL: URL
    let stage: DemoStage        // .card（普通）/ .full（画面より大きいもの・sheet など）/ .behavior（見た目を持たない）
    let properties: [PropertySpec]
    let code: CodeTemplate      // 例: "Button(\"保存\"{role}) { }"
    let build: @MainActor @Sendable (PropertyValues) -> AnyView
}
```

- `PropertySpec`: 名前・置き場所（`.argument` = イニシャライザの引数／`.modifier`）・操作部品（`PropertyControl`）・最初に ON にするか・一言の説明
- `PropertyControl`: スライダー・スイッチ・選択・色・文字・固定の 6 種。種類ごとに値の型とコードの書き方を持つ。選択肢は表示の名前とコードの文字列（`.borderedProminent` など）の組
- `PropertyValues`: プロパティの id ごとの値。`nil` が OFF
- `Topic`: リファレンスのトピックの列挙型。大分類・表示の名前・並びを持つ
- 1 件 = 1 ファイル（`Catalog/<トピック>/<名前>.swift`）。全件を `Catalog.all` に並べる

### 組み立ての関数
- 収録データごとに手で書く
- OFF の modifier はかけない。共通の小さな補助（`.apply(v["tint"]) { $0.tint($1) }` のようなもの）で書く
- OFF の引数は、その引数を省いたイニシャライザに分けて書く（Flutter 版で要った「OFF のときに既定値を手で渡す」は、引数の分だけになる）

### コードの生成
`CodeTemplate` の穴（`{role}` など）に ON の引数を埋め、そのあとに ON の modifier をプロパティの定義の順で 1 行ずつ足す。行ごとに返し、既定から変えた行に印を付けられるようにする（Flutter 版の `CodeLine` と同じ）。

### 見た目を持たないもの
- デモの部品の窓口 `DemoRecorder` を収録データの側に置く。`BodyCounter`（body が評価された回数を記録する）と、イベントのログ（ジェスチャー・フォーカス・VoiceOver の読み上げ文など）がこの窓口に書く
- 詳細画面が窓口を実装して、記録を表示する。依存は「詳細 → 収録データ」の一方向（Flutter 版の `DemoProbe` と同じ形）

## 画面・状態・遷移
画面は 3 枚で、Flutter 版の ADR-0004 と同じ形にする。

1. **ホーム**: 6 つの大分類を節にし、その下にトピックの行（件数・代表の名前）。`.searchable` で検索し、結果は名前の ABC 順に同じ形の行で出す
2. **トピック画面**: 収録したものの行。最初の値で組み立てて縮めた見本と、種類の印（View／modifier／@／ジェスチャー）を付ける
3. **詳細**: 上にプレビューと、選んでいるプロパティのコードの 1 行。その下にプロパティのチップの列（名前と今の値）、下半分に選んだ 1 つを大きく触る編集パネル。説明はツールバーの ⓘ から、コードの全文は 1 行の帯からシートで開き、コピーのボタンはシートに置く。`.full` のもの（`.sheet`・`NavigationStack` など）は、プレビューの「試す」から全画面で開く。詳細を開いたときは、最初の ON のプロパティを選んでおく

### 層と依存の向き
- `UI → ViewModel → Repository`。逆向きと、機能をまたぐ直接の参照はしない。共通のものは `Core/` に置く
- `Features/Catalog/`（ホーム・トピック画面）と `Features/Detail/`
- `Core/Data/CatalogRepository` が `Catalog.all` を読む。UI は収録データの型を、プレビューを組み立てるためにだけ使う
- クリップボードと URL を開く処理は、小さなプロトコルで包み、テストで差し替える
- ViewModel は `@MainActor @Observable` のクラス。詳細の値・比較の状態・選んでいるプロパティは詳細の ViewModel に持つ。仕切りの位置など画面の中だけの状態は `@State` に持つ
- 遷移は `NavigationStack` と値つきの `navigationDestination`。ホームとトピック画面は「行が押された」を知らせるだけにし、詳細への遷移はアプリの組み立て役（`WidgetLabApp`）が渡す

## テスト
- manifest の突き合わせ: `Catalog.all` の id と `Manifest.swift` を照らす。まだ収録していないものは、進み具合として件数を出す（失敗にしない）。重複と、manifest にない id は失敗にする。全部埋まったら「抜け 0」を条件にする
- 全件の組み立て: どの収録データも、全部 OFF・全部 ON・選択肢ごとに組み立てて落ちないこと。`ImageRenderer` で描いて確かめる（`.full`・`.behavior` は組み立てだけ）
- コードの生成: 引数の穴埋めと、modifier の並び順
- ViewModel: 検索・ON/OFF・初期状態に戻す・比較・選んでいるプロパティ。Repository は fake に差し替える
- UI テスト: 起動 → 検索 → 詳細 → コピーの 1 本だけ
- manifest を作る道具: 保存したリファレンスの JSON の小さな見本で、数え方の規則（節に View がある modifier の扱い・オーバーロードのまとめ・版と非推奨の除外・型の都合の View の除外）を確かめる

## 進め方（SwiftUI 版のフェーズ）
| Phase | 内容 |
|---|---|
| 1 | プロジェクトの土台、manifest を作る道具と `Manifest.swift`、デモの仕組み、3 画面を少数の収録（`Button`・`Text`・`VStack`・`padding` など）で通す |
| 2 | 見た目を持たないものの仕組み（`DemoRecorder`・`BodyCounter`・イベントのログ）を、`State`・`Binding`・`TapGesture` で通す |
| 3 | 全トピックを収録する（トピックごと、または大分類ごとに PR を分ける） |
| 4 | ストア公開の準備。3 アプリの公開の順番は、アプリをまたぐ話として別に決める |

この spec の次の計画は Phase 1 を扱う。Phase 2 以降は、それぞれ計画を立てる。

## 書く文書
- `swiftui/docs/PRD.md`: Flutter 版の PRD を元に、収録の範囲と数え方・iOS 27.0・Swift のコード・iOS 標準の見た目に差し替える
- `swiftui/docs/architecture.md`: 上の「層と依存の向き」と構成
- `swiftui/docs/adr/ADR-0001-project-structure-and-conventions.md`（構成と規約）と `ADR-0002-data-driven-demos.md`（収録データから組み立てる。選ばなかった案: Swift のマクロで生成する、1 件ずつ手でデモの画面を書く）。番号は `swiftui/` の中で 0001 から振る
- `swiftui/CLAUDE.md`・`swiftui/README.md`
- ルートの `README.md`・`CLAUDE.md`: `swiftui/` の「準備中」を、Phase 1 が入った時点で直す
- この spec は、ルートの CLAUDE.md の決まり（アプリの中だけの spec はそのアプリの docs/ に置く）に従い、`swiftui/docs/superpowers/specs/` に置く

## 決めたことと比べた案
| 問い | 決めたこと | 選ばなかった案 |
|---|---|---|
| 一覧の拠りどころ | API リファレンスのトピック分け | HIG のコンポーネント（iOS 以外や API に対応しないものが混じり、見た目を持たないものが載っていない）／リファレンスを正本にして名前だけ HIG に寄せる（対応表の保守が要る） |
| modifier の扱い | View の節にある modifier はその View のプロパティ、ほかは単独で収録 | View だけを収録（共通の modifier の置き場がない）／イニシャライザの引数だけ（見た目を変える手段の大半が抜ける） |
| 全部の範囲 | 6 つの大分類の iOS のもの全部 | 画面の部品に関わる大分類だけ（線引きの説明が要る）／Views と View layout だけ（NavigationStack や `.sheet` が抜ける） |
| View と modifier 以外の型 | プロパティラッパーとジェスチャーの型は 1 件ずつ、スタイルの型は選択肢 | View と modifier だけ（`@State` と `@Binding` の違いを見せる場所がない）／プロパティラッパーだけ足す（`.gesture` の詳細が重くなる） |
| 最低の iOS の版 | 27.0。収録は 27.0 で使えるもの | 26.0 にして 27 の API は版で分岐（約 70 件に分岐とテストが要る）／26.0 にして 27 の API を外す（最新の API が抜ける） |
| 機能 | Flutter 版と同じ一式、UI は iOS 標準 | コードの表示を外す（modifier の順番を見せられない）／modifier の並べ替えも足す（v2 に送る） |
| デモの組み立て | 収録データから組み立てる | Swift のマクロで生成（ビルドが重く、Swift の版で壊れやすい）／1 件ずつ手で書く（約 460 件で手間とばらつきが大きい） |

## 確かめ方
- Phase 1 の終わり: `swiftui/CLAUDE.md` の確かめのコマンド（ビルド・テスト）が通る。シミュレータ（iOS 27.0）で、ホーム → トピック → 詳細、検索 → 詳細、ON/OFF・値の変更・比べる・コードのコピーが動く
- manifest: 道具を実行し直すと同じ `Manifest.swift` ができる（差分が出ない）
