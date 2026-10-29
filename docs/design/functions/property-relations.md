# 機能設計: プロパティの仲間・関係・入れ子・補足

> **要約**
> - 結論: 収録する Widget の、見た目・挙動が変わる引数は全部プロパティにする。プロパティを仲間（タブ）に分け、「組で使う」「ON のときだけ効く」「同時に使えない」の関係と入れ子の中身を見せる。見た目が変わらない引数は「補足」に読むだけで載せる
> - 影響: 収録データの型（`PropertySpec`・`WidgetEntry`）、詳細画面（cb_dtl）のチップの列と編集パネル、コードの生成。212 件の収録データは段 2 で増やす
> - お願い: なし（2026-10-29 にオーナーと決めた）

## 背景

実機で触ったオーナーの感想（2026-10-29）: 「UI はとても良いが、パラメーターが足りない（Container はもっとある）。セットで使うものも分かる構成にしたい」。

収録の時点で、1 Widget あたりのプロパティは中央値 3 件（最大 8 件）。Container はコンストラクタの引数およそ 13 のうち 7 件（`decoration`・`foregroundDecoration`・`constraints`・`transform`・`transformAlignment`・`clipBehavior` がない）。

## 決めたこと

| 項目 | 決定 |
|---|---|
| どこまで載せるか | コンストラクタの引数のうち、見た目・挙動が変わるものは全部プロパティにする |
| 見た目が変わらない引数 | `key`・見た目に出ないコールバックなどは、触れない「補足」として名前・型・一言の説明を載せる |
| 見せる関係 | 仲間（同じ側面を決める）・組で使う・ON のときだけ効く・同時に使えない・入れ子の中身 の 5 つ全部 |
| 画面の形 | 今のチップの列と編集パネルを残し、チップの列の上に仲間のタブを置く（縦の一覧への作り直し・注記だけの案は採らない） |
| 進め方 | 段 1 で仕組みを作り Container 1 件で確かめる。段 2 で 212 件の中身を増やす（herdr で並列、ジャンルごとに 1 PR） |

採らなかった案:

- 仲間ごとの縦の一覧（押すとその場で展開）: 全体を見渡せるが、詳細画面の作り直しに近い。今の UI の評価が高いので採らない
- 今の形のまま注記だけ足す: 12 個以上のチップを横に送るのは探しにくい
- コンストラクタの引数を全部プロパティにする: `key` やコールバックは触っても何も起きず、触れる項目に混ざると分かりにくい

## 収録データの型（足すもの）

### PropertySpec

| フィールド | 型 | 意味 | Container での例 |
|---|---|---|---|
| `group` | `PropertyGroup` | 仲間。タブに使う | width → `size` |
| `pairsWith` | `List<String>` | 組で使うことが多い相手（プロパティ名）。向きは問わない | width ↔ height |
| `requires` | `String?` | これが ON でないと効かない相手 | transformAlignment → transform |
| `excludes` | `List<String>` | 同時には使えない相手。両方向に書く（全件のテストで見張る） | color ✕ decoration |
| `children` | `List<PropertySpec>` | 入れ子の中身。空でなければ入れ子のプロパティ。実体は `NestedControl.children` で、`PropertySpec.children` はその近道 | decoration → color・borderRadius・border・boxShadow・gradient・shape |

- 入れ子のプロパティの値は、ON の子の値から組み立てる関数（`NestedControl`）で作る。例: `BoxDecoration(color: …, borderRadius: …)`
- 入れ子のプロパティのコードは、`decoration: BoxDecoration(` の次の行から ON の子を 1 行ずつ字下げして書き、`),` で閉じる。ON の子がなければ `decoration: const BoxDecoration(),`
- 既存の `omitIf`（値の組み合わせで渡さない。NavigationRail の extended が true の間の labelType）は残し、入れ子の子にも効かせる（Container は decoration の shape が circle の間 borderRadius を渡さない）。`excludes` は ON・OFF の段階でぶつかるもの、`omitIf` は値によってぶつかるもの
- 既存の `PropertyArg.nested` と `WidgetEntry.codeNest`（MediaQuery の `copyWith`）は、見た目を持たない Widget の入れ子の式のまま残す。`children` は引数の値そのものが入れ子のもの

### PropertyGroup

決めた語彙から選ぶ。タブの順はこの順。

| 値 | タブの名前 | 入るものの例 |
|---|---|---|
| `size` | 大きさ | width・height・constraints・aspectRatio |
| `spacing` | 余白 | padding・margin・spacing |
| `layout` | 配置 | alignment・mainAxisAlignment・crossAxisAlignment・textDirection |
| `paint` | 色と装飾 | color・decoration・foregroundDecoration・elevation・shape |
| `transform` | 変形 | transform・transformAlignment・clipBehavior |
| `text` | 文字 | style・textAlign・maxLines・overflow |
| `behavior` | 挙動 | enabled・duration・curve・physics |
| `content` | 中身 | child・children・title・icon |

- どの仲間に入れるか迷うものは、その Widget の公式ドキュメントでの説明の順と、利用者が探すときの言葉で決める
- プロパティが 1 つの仲間にしかない Widget は、タブを出さない

### WidgetEntry

| フィールド | 型 | 意味 |
|---|---|---|
| `references` | `List<ReferenceArg>` | 見た目が変わらない引数。`ReferenceArg` は `name`・`typeLabel`・`description` |

## 画面のふるまい（詳細画面 cb_dtl）

### 仲間のタブ

- チップの列の上に置く。プロパティのある仲間と、補足があれば「補足」を、語彙の順に並べる。横に収まらなければ横にスクロールする
- タブの名前の横に、そのタブで ON のプロパティの数を出す（例:「大きさ 2」）。開いていないタブで何が効いているかを見落とさないため
- タブを替えると、そのタブのチップだけを並べ、最初の ON のチップを選ぶ（ON がなければ先頭）
- タブは並べ方だけを変える。ON のプロパティはタブにかかわらず全部プレビューとコードに効く
- 開いたときは、最初の ON のプロパティがある仲間のタブを選ぶ（今の「最初の ON のプロパティを選ぶ」と同じ考え方）

### 編集パネルの関係の行

値の操作の下に、関係を 1 行ずつ出す。相手の名前を押すと、相手のタブとチップに移る。

| 関係 | 行の例 |
|---|---|
| 組で使う | ↔ height と組で使うことが多い |
| ON のときだけ効く | transform が ON のときだけ効く（相手が OFF の間は、チップを薄くする） |
| 同時に使えない | decoration と同時には使えない |

### 同時に使えない組

- ON になる操作（スイッチ・既定に戻す・比較の付けた側）では、相手を OFF にする
- 片方を ON にすると、もう片方を OFF にし、パネルに「decoration と同時には使えないので color を OFF にしました」を 3 秒ほど出す
- OFF にした側の値は覚えておく（今の OFF と同じ）

### 入れ子のプロパティ

- 入れ子のプロパティを選ぶと、パネルの中に子のチップを並べ、その下に選んだ子の値の操作を出す
- 子にも ON・OFF がある。親が OFF なら子は効かない
- コードの帯には、選んだ子の行を出す
- 比べるのは、選んだ子 1 つの付けた／付けない

### 補足タブ

- チップと編集パネルの代わりに、読むだけの一覧（名前・型・一言の説明）を出す
- 補足タブを開いている間は「比べる」を出さない

### 変えないこと

- 比べる・既定に戻す・初期状態に戻すのふるまい
- 見た目を持たない Widget の比較（Widget そのものを使った／使わない）

## テスト

- ロジック（DetailNotifier）: `requires` の相手が OFF なら効かない、`excludes` で相手が OFF になり知らせが出る、入れ子の子の ON・OFF
- コードの生成: 入れ子のプロパティの書き方（ON の子あり・なし）
- 画面（detail_screen_test、Container を手本）: タブと ON の数、タブの切り替え、関係の行と相手へ移る、同時に使えない組の知らせ、入れ子の子のチップ、補足の一覧
- 収録データの決まり（catalog_test、全件）: 関係の相手が実在するプロパティ、`excludes` が両方向、`requires` が自分を指さない
- 全件の見張り（段 2 の土台）: 収録データの `codeName` のクラスのコンストラクタの引数を、Flutter SDK のソースから analyzer で読み、どの引数もプロパティか補足のどちらかに入っていることを求める。段 1 では Container だけを厳しく見て、ほかは抜けの数を出して skip する（TC-04 と同じ形）

## 段 2（別の計画）

- 212 件の収録データに、残りの引数（プロパティか補足）と仲間・関係を足す
- 全件の見張りのテストが通る（skip が 0 件）まで、ジャンルごとに 1 PR で進める

## 関係するもの

- 設計: docs/design/functions/demo-engine.md、docs/design/screens/cb_dtl_詳細画面.md
- Figma: https://www.figma.com/design/W9DAjjGAmMzNhnCQu0BLo7/Widget-Lab?node-id=3-2（詳細画面に「仲間のタブ」「関係の行」「入れ子」「補足」の 4 枚を足す）
- ADR-0002（データから組み立てるデモ）、ADR-0004（チップと編集パネルの詳細）
