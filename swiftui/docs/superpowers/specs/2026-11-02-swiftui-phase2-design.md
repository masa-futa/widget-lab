# SwiftUI 版 Phase 2: 見た目を持たないもの

> **要約**
> - 結論: `@State`・`@Binding`・`TapGesture` の 3 件で、見た目を持たないものの仕組み（記録の窓口・body の回数・イベントのログ）を通す。比べるは「付けた側」と「同じことをラッパーなしで書いた側」を左右に並べ、それぞれの記録を出す
> - 前提: [Phase 1 までの spec](2026-10-31-swiftui-app-design.md) と、[Phase 1 のレビューで次の段に回したこと](../plans/2026-11-02-swiftui-phase1-followups.md)
> - 範囲外: ほかの見た目を持たないもの（`GestureState`・`FocusState`・`onTapGesture` など）、VoiceOver の読み上げ文の記録、`.full` の「試す」は Phase 3

## 収録する 3 件

| id | 種類 | トピック | 見本 | プロパティ | OFF にした側 |
|---|---|---|---|---|---|
| `State` | `.propertyWrapper` | Model data | 「+1」のボタンと `count: N` | `@State`（`.wrapper`、最初は ON） | SwiftUI が見張らない参照型の箱に値を持つ。押すと値は増えるが、描き直されない |
| `Binding` | `.propertyWrapper` | Model data | 親の `count` と、子の `Stepper` | `@Binding`（`.wrapper`、最初は ON） | 子が値のコピーを `@State` で持つ。子の数は動くが、親の数は動かない |
| `TapGesture` | `.gesture` | Gestures | 四角に `.gesture(TapGesture(count:).onEnded { … })` | `count`（引数、スライダー 1〜3・step 1、最初は 2 で ON） | `TapGesture()`（1 回のタップ） |

3 件とも `stage: .behavior`。

## 型に足すもの

- `PropertySpec.Placement` に `.wrapper` を足す。コードでは宣言の頭の `@State` などに当たる。`PropertySpec.wrapper(_ id:, summary:)` で作り、操作部品は `.fixed(code: "@" + id)`、最初は ON
- `CodeTemplate` に `withoutWrapper: CodeTemplate?` を足す。`.wrapper` のプロパティが OFF のとき、`CodeGenerator` はこちらの形でコード全体を作る。ラッパーを外すと、宣言だけでなく使う側の行（`box.count += 1` など）も変わるため。`withoutWrapper` の行のうち、元の形と文字が違う行に「変えた」の印（`isChanged`）を付ける
- プロパティラッパーのコードは、`struct` の中身（宣言と `body`）を数行で書く:

```swift
@State private var count = 0

var body: some View {
    Button("+1") { count += 1 }
    Text("count: \(count)")
}
```

## 記録の仕組み

収録データの側（`WidgetLab/Catalog/Model/Demo/`）に置く:

```swift
@MainActor protocol DemoRecorder: AnyObject {
    /// 見本の body が評価された（name は "見本"・"親"・"子" など）
    func bodyEvaluated(_ name: String)
    /// イベントが起きた（"タップを認識（2 回）" など）
    func log(_ event: String)
}

extension EnvironmentValues {
    @Entry var demoRecorder: (any DemoRecorder)? = nil
}
```

- 窓口は SwiftUI の Environment で渡す。`CatalogEntry.build` の型は変えない。依存は「詳細 → 収録データ」の一方向のまま
- `BodyCounter(_ name:)`: 見本の body の中に置く小さな View。窓口に知らせるのは `Task { @MainActor in … }` で body のあとに遅らせる（body の中で見張られた値を書くと、描き直しが止まらなくなるため）。窓口が `nil`（一覧の行・テスト）のときは何もしない
- 詳細の側の実装 `DetailRecorder`（`Features/Detail/ViewModel/`）: `@Observable`。名前ごとの回数と、新しい順で最大 20 行のログを持つ。比べるときは左右に 1 つずつ作る。ログの行には「付けた」「付けない」の側を付ける
- 回数とログを読むのは、記録を出す View だけ。見本の View は窓口に書くだけで、読まない（記録が増えても見本が描き直されないように）
- プロパティを変えたとき・初期状態に戻したときに、両側の記録を消し、見本を作り直す（回数は 0 から）
- body の回数は SwiftUI の都合で 1〜2 回ずれることがある。見せるのは付けた側と付けない側の差で、説明に「おおよその回数」と書く。テストは正確な数ではなく「増えた／増えない」を確かめる

## 画面

### 詳細（`.behavior` のとき）

```
┌───────────────────────────┐
│ 付けた           付けない   │  ← 比べるが ON のとき（OFF なら 1 つだけ、全幅）
│ [ +1 ]         [ +1 ]     │
│ count: 3       count: 3   │
│ 描き直し 4 回   描き直し 1 回 │
├───────────────────────────┤
│ 記録              [消す]   │  ← 新しい順に 3 行見え、スクロールで 20 行
│ 付けた: 見本を描き直した     │
│ 付けない: タップを認識（2 回）│
└───────────────────────────┘
 コードの 1 行 / チップ / 編集パネル（いまのまま）
```

- プレビューの枠の高さ（280pt）は変えず、`.behavior` ではそのうち下の約 90pt を記録の欄にする
- 比べるは左右に並べ、どちらも押せる。仕切りは使わない。比べるの切り替えと、required のプロパティでは出さない決まりは `.card` と同じ
- VoiceOver: 回数は「付けた側、描き直し 4 回」と読む。記録の欄は行ごとに読める。「消す」は 44pt 以上

### 一覧の行の見本
- `.card` だけ、いまのとおり最初の値で組み立てて縮めた見本を出す
- `.full`・`.behavior` は組み立てず、SF Symbols の絵を出す（プロパティラッパー `at`・ジェスチャー `hand.tap`・`.full` `rectangle.portrait`）

### 検索
- id と `displayName` の両方で当てる（`@State`・`.pad` で見つかる）
- 「検索中か」（空白を除いて空でない）の判定を `CatalogViewModel.isSearching` に持たせ、`HomeScreen` はそれを使う

## テスト
- `CodeGeneratorTests`: `.wrapper` が OFF のとき `withoutWrapper` の形になり、元と違う行に印が付く。ON のときは宣言の行に `@State` が付く
- `DetailRecorderTests`（新規）: 名前ごとの回数、ログが新しい順で 20 行で切れる、消すと空になる
- `DetailViewModelTests`: プロパティを変えたとき・戻したときに両側の記録が消える。`@State` は最初に `@State` のプロパティを選び、比べられる
- `CatalogViewModelTests`: `@State`・`.pad` で当たる。`isSearching` の判定
- `CatalogTests`: 全件の組み立てを stage で分ける（`.card` は `ImageRenderer` で描く、`.full`・`.behavior` は組み立てだけ）
- UI テスト（3 本目）: `@State` を検索 → 詳細 → 比べるを ON → 両側の「+1」を押す → 付けた側の `count` が増え、付けない側の表示は変わらない。準備（起動 → 検索 → 詳細）を補助の関数にまとめる

## ドキュメント
- ADR-0002 に「見た目を持たないもの」の節を足す（Environment で渡す理由と、左右に並べる比べ方）
- docs/architecture.md に `Catalog/Model/Demo/` と `DetailRecorder` を書き足す
- followups の「Phase 2 の計画の前に決める・直す」の表に、済んだ印を付ける

## 決めたことと比べた案

| こと | 決めたこと | 比べた案 |
|---|---|---|
| 付けない側 | 同じことをラッパーなしで書いたもの | 比べずに記録だけ見せる（`@State` で何が変わるかが伝わりにくい）／種類ごとに分ける |
| 比べるの形 | 左右に並べ、両方押せる | 重ねる形のまま前後を切り替える（2 つの数を同時に見られない） |
| 窓口の渡し方 | SwiftUI の Environment | `build` の引数に足す（記録を使わない 400 件以上に要らない引数が付く）／アプリに 1 つの窓口（左右を分けられず、テストしにくい） |
