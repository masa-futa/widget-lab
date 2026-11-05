# SwiftUI 版 Phase 1 のレビューで、次の段に回したこと

> **要約**
> - 結論: Phase 1 のブランチ全体のレビュー（2026-11-02）で、マージ前に直す 3 点は直した。ほかは Phase 2・3 の計画を立てるときに扱う
> - 影響: Phase 2（見た目を持たないもの）と Phase 3（全トピックの収録）の計画
> - お願い: 各段の計画を書くとき、この表の「いつ」がその段のものを計画のタスクに入れる

## マージ前に直したもの
- required のプロパティでは「比べる」を出さない（`DetailViewModel.canCompare`）。最初に選ぶのは required でないプロパティ
- 比べるの仕切りを、VoiceOver で操作できる 1 つの要素にした（ラベル「仕切り」、値「付けた側 N%」）。付けない側の重ねた見本は読み上げない
- コードを写したあとに値を変えたら「コピーしました」を戻す

## Phase 2 の計画の前に決める・直す
| こと | 場所 | 中身 |
|---|---|---|
| 済: 一覧の見本を stage で分ける | `Features/Catalog/UI/TopicScreen.swift`（`EntryRow`）、`WidgetLabTests/Catalog/CatalogTests.swift` | `.full`・`.behavior` は一覧の行で組み立てない（sheet が行から出る・NavigationStack が入れ子になる・記録の窓口がない）。SF Symbols の代わりの絵にする。全件のテストも `.full`・`.behavior` は描かずに組み立てだけにする（spec のとおり） |
| 済: `DemoRecorder` を組み立ての関数に渡す方法 | `CatalogEntry.build` | 型は変えず、SwiftUI の Environment で渡す案が有力（依存が「詳細 → 収録データ」の一方向のまま）。→ Environment で渡した（ADR-0002） |
| 済: 検索を表示の名前でも当てる | `CatalogViewModel.results` | 今は id だけで当てるので、`.pad` や `@State` で見つからない。id と `displayName` の両方で当てる |
| 済: 「検索中か」を ViewModel に持たせる | `HomeScreen`・`CatalogViewModel` | 空白を除く判定が 2 か所にある |

## Phase 3 の最初の PR の前に決める・直す
| こと | 場所 | 中身 |
|---|---|---|
| 済: プロパティの id を名前と分ける | `PropertySpec.modifier` | 今は id = modifier の名前なので、同じ modifier に 2 つのプロパティを付けられない（`frame(width:)` と `frame(height:)` など）。id が重なると `Dictionary(uniqueKeysWithValues:)` で落ちる → `PropertySpec.modifier` に `id:` を足した |
| 済: 引数の並びと、複数の引数を持つ modifier | `PropertySpec`・`CodeGenerator` | 引数は定義の順に並ぶので、チップの順と Swift の引数の順が結び付いている。`shadow(color:radius:x:y:)` のような modifier を表せない。決めたら ADR-0002 の「見直すきっかけ」に書く → 同じ modifier のプロパティを 1 行にまとめた。並びは定義の順のまま（ADR-0002） |
| 済: スライダーの値の書き方 | `PropertyControl.code(for:)` | `%.1f` なので 0.25 が "0.2" になる。step から小数の桁を決める（`opacity`・`scaleEffect` で要る） → step の小数の桁数で書く |
| 済: 生成する `Category` の名前 | `tools/make_manifest.py` | Objective-C のランタイムの `Category` と名前がぶつかる（ビルドは通る）。`TopicCategory` などに変える → `TopicCategory` にした |
| 済: 収録の進み具合の出し方 | `CatalogTests` | テストの `print` は xcodebuild のログに出ない。Catalog と Manifest の id の差を出す小さなスクリプトにする。全部埋まったら「抜け 0」をテストの条件にする → `tools/catalog_progress.py`。「抜け 0」をテストの条件にするのは Phase 3 の束 11 |
| 済: `sections` の作り直し | `CatalogViewModel` | 収録は変わらないので、`init` で 1 回だけ作る → init で 1 回だけ作る |
| 済: `pick` の選択肢の数の確認 | 収録データ | 選択肢と、`pick` に渡す配列の数が合っているかを、デバッグのときだけ確かめる → 番号が options の外なら DEBUG で止める。全件の組み立てのテストが選択肢ごとに通す |
| 済: テストの抜け | `CodeGeneratorTests`・`DetailViewModelTests` | ラベル付きの modifier、required の引数、複数行の末尾のクロージャの印、`changedIDs` が空のとき、`selectedLine` の代わりの行、`entry(id:)` → 足した |

## Phase 2 のレビューで、次の段に回したこと
| こと | 場所 | 中身 |
|---|---|---|
| 済: ラッパーの宣言の行の見つけ方 | `CodeGenerator.wrapperLines` | `contains("@" + id)` は部分一致なので、`@StateObject` を足すと `@State` に当たる。語として一致させる → 語として一致させた |
| 済: ラッパーのコードとプロパティの組み合わせの確認 | `CatalogTests` | `code.wrapper` があるのに `.wrapper` のプロパティがないと、黙って普通の形になる。テストの条件にする → `CatalogTests.wrapperCodeGoesWithWrapperProperty` |
| 済: `.behavior` の見本も描いて確かめる | `CatalogTests` | いまは組み立てだけで、Binding・TapGesture の body はテストで評価されない。窓口が nil なら記録しないので、`ImageRenderer` で描ける。`.full` だけ組み立てだけにする（spec も直す） → 描いて確かめる。spec も直した |
| 済: TapGesture のコードの行のテスト | `DetailViewModelTests` | `TapGesture(count: 2)` と、OFF のときの `TapGesture()` → `DetailViewModelTests.tapGestureCodeWritesCountAndOmitsItWhenOff` |
| 済: VoiceOver での複数回のタップ | `TapGestureEntry` | VoiceOver の操作では 1 回しか届かない。`accessibilityAction` を足すか、説明に書く → 見本に accessibilityAction を足し、VoiceOver の操作でも記録に出す（束 12） |
| 済: UI テストで左右を確かめる | `LaunchUITests` | 今は「+1」を並びの番号で押し、`count: 1` がどちら側かを見ていない。左右の列の中で探す。付けた側の描き直しが増えることも確かめる → 左右の列に識別子（side-without・side-with）を付け、列の中で探す。描き直しの回数も確かめる（束 12） |
| 済: 記録の欄の高さ | `PreviewArea`（`RecordPanel` の 90pt） | 文字を大きくすると見出しが伸びて、ログが 3 行入らない。Binding の Stepper も半分の幅からはみ出すことがある → 高さを @ScaledMetric にし、.behavior のプレビューは文字の大きさの上限を accessibility1 にした。Stepper は入らない幅でラベルを上に置く（束 12） |

## 時間のあるときに直す
- 道具: キャッシュを一時ファイルに書いてから置き換える（取り出しが途中で切れても壊れたキャッシュが残らない）。記号の JSON が欠けたら件数を警告に出す。前のトピックで見た View がある節の modifier の数え方を、テストで確かめる
- 済（束 12）: 一覧の行の押したときの地は、余白を決め打ち（-20 / -12）で広げている。iPad や読みやすい幅の余白では足りないことがある
- 済（束 12）: コードの 1 行の帯は、VoiceOver でコードを読めるようにする（ラベルを行の文字、ヒントを「コードの全文を開く」に）
- 済（束 12）: チップの選んでいる状態を、色のほかに形でも示す（WCAG 1.4.1）
- 済（束 12）: 文字を大きくしたとき、プレビューの高さ 280pt で編集パネルが狭くなる
- UI テストの準備（起動 → 検索 → 詳細）を補助の関数にまとめる（3 本目を足すとき）
- `FakeClipboard` の `@unchecked Sendable` は要らない（既定の MainActor に属している）。`CodeGeneratorTests` の 1 件は Swift として正しくない呼び出しを期待しているので、実在の形にする
