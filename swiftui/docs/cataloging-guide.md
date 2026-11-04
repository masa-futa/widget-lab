# 収録の手引き

> **要約**
> - 1 件の収録は、`WidgetLab/Catalog/<トピック>/<名前>Entry.swift` を 1 つ書き、`Catalog.all` に 1 行足すだけ。チップ・編集パネル・プレビュー・比べる・コードは、そのファイルから共通の仕組みが作る
> - 迷うのは「stage」「形」「コードの形」の 3 つ。ふつうは `.card` で、形は「View」「引数」「付け外し」のどれかになる
> - 束では、計画に 1 件ずつの表を書き、scratchpad のコピーで試作して画像で確かめてから、そのコードを計画に写す
> - 対象: SwiftUI 版 Phase 3 の束 2〜11 を収録する人とサブエージェント。束 1（レイアウトの 33 件）を手本にしている

1〜3 章は、初めて収録するときに通して読む。4 章から後は、迷ったときに引く。型の決まりと理由は [ADR-0002](adr/ADR-0002-data-driven-demos.md)、層と依存の向きは [architecture.md](architecture.md) にある。この手引きは、その決まりの下で 1 件を書くときの判断に絞る。

## 1. 1 件は、データのファイル 1 つと一覧の 1 行で足す

いちばん小さい収録は次の形になる。`CatalogEntry` の `static let` を 1 つ書き、`build` で見本を組み立てる。

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let zStack = CatalogEntry(
        id: "ZStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を奥から手前へ重ねる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/zstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment",
                .choice([Choice(".topLeading"), Choice(".center"), Choice(".bottomTrailing")], initial: 0),
                on: true, summary: "重ねる子の揃え方")
        ],
        code: CodeTemplate(call: "ZStack", trailing: " {\n    Color.yellow\n    Text(\"手前\")\n}"),
        build: { v in
            AnyView(
                ZStack(alignment: v.pick("alignment", from: [Alignment.topLeading, .center, .bottomTrailing]) ?? .center) {
                    Color.yellow
                    Text("手前")
                }
            )
        }
    )
}
```

（実際の `ZStackEntry.swift` は選択肢が 5 つあり、見本も少し大きい。形を見せるために縮めてある。）

足すときに守ることは 5 つある。

- **id・種類・トピックは `Generated/Manifest.swift` の行と同じにする。** 違うと `CatalogTests` が落ちる。`static let` の名前は id の頭を小文字にしたもの（`ZStack` → `zStack`、`padding` → `padding`）
- **ファイルは `Catalog/<トピック>/` に置く。** フォルダ名はトピックの名前を大文字始まりにしたもの（`LayoutFundamentals`・`ViewGroupings`）。新しいフォルダを作っても、Xcode のフォルダの同期で project.pbxproj は変わらない
- **`Catalog.all` には 1 行に 1 件ずつ足す。** `tools/catalog_progress.py` は 1 行 1 件の形しか読まない。1 行に並べると、テストは通るのに進み具合では「抜け」と出る
- **型は `nonisolated` にする。** extension も `nonisolated extension` と書く。`build` だけが `@MainActor` で動く。ファイルの中だけで使う補助の型は `private` にし、Layout や LayoutValueKey のように MainActor の外から呼ばれるものは `nonisolated private` にする（`LayoutValueEntry.swift` の `RankedHStack`）
- **選択肢と `pick` の配列は同じ並びにする。** `v.pick("alignment", from: [...])` は選ばれた番号で配列を引くので、並びがずれると別の値でプレビューが描かれる。数が足りないとデバッグのときに止まる

並列の束がぶつかるのは `Catalog.swift` の一覧だけ。ぶつかったら、両方の行を残せば直る。

## 2. 束は「表 → 試作 → 画像で確かめる → 計画に写す」の順で進める

束 1 では、この順で 33 件を書き、写す側（haiku）の作り直しはなかった。

1. **計画に 1 件ずつの表を書く。** 列は id・トピック・形・プロパティ・コードの形（最初の値）。`.note` にするものは理由も書く
2. **scratchpad にアプリをコピーして試作する。** `rsync -a --exclude build ./ <scratchpad>/proto/swiftui/` で写し、そこで収録を書いて、lint とテストを通す
3. **画像で見る。** 一時的なテストで、収録ごとに最初の値と全部 OFF の 2 枚を `ImageRenderer` で書き出す。ScrollView・List・Form を使う見本は白くなるので、一時的な UI テストで詳細画面を撮る（5 章）。一覧の行の小さな見本も、トピック画面を撮って見る
4. **計画に写す。** 試作のファイルをスクリプトで計画に埋め込む。手で書き写すと、引用符や `\(` で間違える
5. **実装はファイルを写すだけにする。** 写したあと、コントローラーが試作のファイルと `cmp` で 1 文字ずつ比べる。同じなら、タスクごとのレビューはそれで足りる。コードの中身は束の最後のレビュー（opus）で見る

試作でコードの形を決めきってから計画に入れるのは、計画の段階で決めたつもりの書き方が、描いてみると崩れていることが多いため。束 1 では `GroupBox` の箱が地と同じ色で見えない、`layoutDirectionBehavior` で文字が反転して読めない、の 2 件を画像で見つけた。

## 3. stage はふつう `.card`。`.note` は 1 画面で効き目が見えないものだけ

| stage | 使うとき | 束 1 での例 |
|---|---|---|
| `.card` | プレビューの枠に収まり、触って変化が見えるもの | 33 件すべて |
| `.behavior` | 見た目を持たず、記録（描き直しの回数・ログ）で違いを見せるもの | `@State`・`@Binding`・`TapGesture` |
| `.note(reason:)` | アプリの 1 画面の中で、効き目を見ることも触ることもできないもの | なし |
| `.full` | 画面の行き来の入れ物（NavigationStack・TabView）と、表示の単位ぜんたいに効くもの。詳細の「試す」から全画面で開く | なし |

**`.note` の基準**は、アプリ拡張の中で効くもの、iOS では効かない窓の modifier、外の仕組み（Core Data など）が要るもの。理由には使う場所を一言入れる（例: 「ウィジェットの中で効く」）。`.note` は `build` を書かない初期化（`noteReason:` を渡すもの）で書ける。チップとコードはふつうに動く。迷ったら束の計画で 1 件ずつ決める。束 4 では `materialActiveAppearance` を `.note` にした（iOS では `.inactive` が使えず、窓もいつも手前にあるので、見た目が変わらない）。束 5 では `textEditorStyle`・`tableStyle` を `.note` にした（iPhone では選べる既製のスタイルがどれも同じ見た目になり、`TextEditorStyleConfiguration` は中身を渡さないので自作のスタイルも作れない）。

`.note` にしたくなっても、まず枠の中で見せる方法を探す。束 1 の `ignoresSafeArea` は、親に `.safeAreaPadding(.vertical, 40)` をかけて安全な領域を作り、`.card` で見せられた。`.note` のうち、iPhone で見せる工夫が足りずに `.note` にしたものが全体の 1 割を超えたら、ADR-0002 を見直す約束になっている。iPhone では効かないと公式か試作で確かめたもの（iPad・Mac・Apple Watch だけで効くもの、アプリ拡張の中で効くもの）は数えない（2026-11-04 束 7 で決定。束 7 の 19 件で、`.note` が全体の 1 割を超えたため。束 5〜7 のマージのあとで 32 / 303 件）。

**`.full` は、詳細の「試す」から全画面で開く（束 7 で作った）。** 枠には見本を描かず「試す」のボタンだけを出し、押すと見本を画面いっぱいに出す。下の帯の「付けない｜付けた」で、選んでいるプロパティを外した見本に切り替え、「閉じる」で詳細に戻る。値を変えるときは、詳細のチップと編集パネルで変えてから、もう一度「試す」を押す。一覧の行は絵にする。束 3 では、表示の単位（presentation）ぜんたいに効く modifier（`preferredColorScheme`・`statusBarHidden`・`persistentSystemOverlays`）を `.full` にした（2026-11-03 オーナーが決定）。`.card` にすると一覧の行の見本からも効いてしまい（行が見えただけでアプリ全体が暗くなる）、押し込んだ詳細画面からではステータスバーが消えないため。全画面で開けば、その表示の単位でだけ効く。

## 4. 形は 3 つ。modifier を消して比べたいなら「付け外し」

収録の型の使い方は、次の 3 つに分かれる。

| 形 | 書き方 | OFF にしたとき | 見本 |
|---|---|---|---|
| View | `call` が View。イニシャライザの引数は `.argument`、かける modifier は `.modifier` | その引数・modifier だけが消える | `VStackEntry.swift`・`HStackEntry.swift` |
| 引数 | modifier の収録で、`prefix` がかける相手、`call` が `".padding"` のような modifier。modifier の引数は `.argument` | 引数が消え、modifier は既定の値で残る | `PaddingEntry.swift`・`OffsetEntry.swift` |
| 付け外し | modifier の収録で、`call` がかける相手の View。modifier の引数は `.modifier` のプロパティ | modifier ごと消える | `FrameEntry.swift`・`FixedSizeEntry.swift` |

modifier の収録は、まず「引数」の形を考える。引数がどれも省けて、OFF でも意味のある書き方（`.padding()`・`.offset()`）になるなら、それで足りる。

次のどれかに当たるときは「付け外し」にする。

- 引数がどれも省けない（`fixedSize(horizontal:vertical:)`・`alignmentGuide(_:computeValue:)`）。「引数」の形では modifier が消せないので、比べるで違いが出ない
- 同じ modifier を 2 回かける（`frame`）。6 章の `line` を使う
- 比べるで「付けない」と「付けた」を見比べること自体が、その modifier の要点になる（`layoutPriority`・`ignoresSafeArea`）

プロパティは 1 件に 3〜6 個を目安に、よく使う引数と、同じ節の modifier から選ぶ。API が小さいもの（`GridRow`・`ZStack`・`Spacer`）は 1〜2 個でよい。数を合わせるために modifier を足すなら、効き目が見えるものだけにする。

## 5. 見た目の確かめは、テストの画像とシミュレータの画像で分ける

`CatalogTests` の `buildsAllCombinations` が、全件を全部 OFF・全部 ON・選択肢ごとに組み立て、`.card` と `.behavior` は `ImageRenderer` で描く。id と Manifest の一致、Manifest の全件が `Catalog.all` にあること（抜け 0。束 11 から）、チップの名前の重なり、required の引数に兄弟があるか、1 つの行の鍵に違う modifier の名前が混ざっていないかも見ている。だから収録ごとのテストは書かない。新しい型の使い方を足したときだけ `CodeGeneratorTests` に足す。

ただし `ImageRenderer` は、ScrollView・List・Form・GroupBox・ControlGroup を白く描き、UIKit で描くコントロール（Toggle・Slider・Stepper・Picker・DatePicker・ColorPicker・Menu など）を黄色の地に禁止の印で描く。エラーにはならないので、テストが通っても見た目は確かめられていない。これらは一時的な UI テストで詳細画面を撮って見る。束の終わりには、代表の 1〜2 件を撮る UI テストを残す（束 1 は `testLayoutEntriesShowPreview`、束 2 は `testTextEntriesShowPreview`、束 3 は `testControlEntriesShowPreview`、束 4 は `testDrawingEntriesShowPreview`、束 5 は `testStyleEntriesShowPreview`、束 6 は `testListEntriesShowPreview`、束 7 は `testNavigationEntriesShowPreview`、束 8 は `testShellEntriesShowPreview`、束 9 は `testDataEntriesShowPreview`、束 10 は `testInputEntriesShowPreview`、束 11 は `testA11yEntriesShowPreview`）。

撮った画像は `xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots` で取り出せる。名前と画像のファイルの対応は `build/shots/manifest.json` にある。

## 6. コードの形は `CodeTemplate` の 8 つの欄で書く

`CodeGenerator` は、次の順に行を並べる。

| 欄 | 書くもの | 字下げ |
|---|---|---|
| `prefix` | 呼び出しより前の行（かける相手、包む入れ物の開き括弧） | 書いたまま |
| `indent` | 呼び出しの行の字下げの桁数 | 省けば、prefix があるとき 4、ないとき 0 |
| `call` + `fixedArguments` | 呼び出し。ON の `.argument` が `fixedArguments` のあとに並ぶ | `indent` |
| `trailing` | 末尾のクロージャ（`" { }"`、複数行なら `"\n"` で区切る） | 2 行目から自分で書く |
| modifier のプロパティ | ON の `.modifier` を、行の鍵ごとに 1 行にまとめる | 下の決まり |
| `suffix` | いちばん最後にかける modifier | 下の決まり |
| `closing` | prefix で開いた括弧を閉じる行、並びの後ろの兄弟 | 書いたまま |
| `wrapper` | プロパティラッパーの収録だけ。ほかの欄の代わりに使う | – |

modifier と suffix の字下げは、呼び出しで決まる。呼び出しが modifier（`"."` で始まる）なら呼び出しと同じ桁、末尾のクロージャが複数行なら閉じ括弧 `}` と同じ桁、ほかは呼び出しより 1 段深い。この決まりは、**複数行の `trailing` の最後の行が `}` だけ**であることを前提にしている。最後の行に中身を書くと、modifier の桁がずれる。

入れ子の中に置く書き方は、束 1 の 3 件が手本になる。

- 並びの中の 1 つ（`SpacerEntry.swift`）: `prefix: ["HStack {", "    Text(\"左\")"]`、`call: "Spacer"`、`closing: ["    Text(\"右\")", "}"]`
- 入れ物の中の 1 行（`GridRowEntry.swift`）: `prefix: ["Grid {"]`、`trailing` の 2 行目から 8 桁、`closing` に 2 行目の `GridRow` と `}`
- 深い入れ子の中の View にかける modifier（`ContainerRelativeFrameEntry.swift`）: `prefix` に ScrollView・HStack・ForEach と相手の `Text`、`indent: 16`、`closing` に 3 つの `}`

コードには、効き目に関わるものを全部書く。`fixedSize` の `.frame(width: 120, height: 40)` を省くと、写したコードで同じことが起きない。見本を見やすくするためだけの `.border`・`.background` は、コードに書かなくてよい（`VStack` から続く書き方）。

## 7. 困ったとき

**片方だけでは成り立たない引数の組がある → 1 つの選択肢にまとめ、コードにラベルごと書く。** `containerRelativeFrame` は `count`・`span`・`spacing` を 3 つそろえないと書けないので、`Choice("3 等分", code: "count: 3, span: 1, spacing: 8")` のような選択肢にした。名前なしの引数（`unlabeled: true`）にすると、そのままコードに入る。`fixedSize` の `horizontal: false, vertical: true` も同じ。

**引数のない modifier を付け外ししたい → `.fixed(code: "")` の modifier にする。** コードは `.labelsHidden()` になる。

**同じ modifier を 2 回かけたい → 2 回目の引数に `line:` で別の鍵を付ける。** `frame` は `.frame(width:height:alignment:)` を名前の鍵で、`.frame(maxWidth:maxHeight:)` を `line: "frame.max"` でまとめ、2 行に書いている。1 つの行の鍵に、違う modifier の名前を混ぜない（テストが落ちる）。`width` と `maxWidth` のように 1 回の呼び出しで組み合わせられないラベルは、同じ行に入れない。

**省けない modifier の引数がある → `required: true` にし、build でも「required でない引数が 1 つ以上 ON のとき」だけかける。** コードの側は、行の required でない引数がどれも OFF なら、その行を書かない。build も同じ条件にしないと、プレビューとコードが食い違う。例は `AlignmentGuideEntry.swift`（`.leading` が required、`computeValue` が ON のときだけかける）。`line` で行を分けたときは、行ごとに判断する。

**条件だけで modifier をかけ分けたい → 今は `.apply(cond ? () : nil) { view, _ in … }` と書く。** `apply` は値が nil でないときだけかける補助なので、Void の Optional で条件を渡している。使っているのは `frame`・`ignoresSafeArea`・`underline`・`strikethrough` の 4 件（束 2 のあと）。補助を足すには `Model/` を変えるので、並列の束が落ち着いてから決める。

**見本が地に溶けて見えない → 背景の modifier を最初から ON にする。** `GroupBox` の箱は、プレビューの地（`secondarySystemBackground`）と同じ色で、OFF では箱が見えなかった。`.backgroundStyle` を `on: true` にして直した。

**一覧の行の見本が崩れていないか気になる → トピック画面を撮る。** `.card` の見本は、一覧の行でも最初の値で組み立てて縮めて出す。束 1 では List や Form の入れ子も崩れなかったが、試作のときに一度は見る。

**高いコントロールで一覧の行が伸びる → 見本を ScrollView に入れる。** `MultiDatePicker` のカレンダーは、行の見本の枠に収まらず、行が高くなって押す場所がずれた。見本を `ScrollView` に入れると、行にも詳細のプレビューにも収まる。スタイルで高さが変わるもの（`DatePicker` の `.graphical`）は、`ViewThatFits(in: .vertical) { 見本; ScrollView { 見本 } }` で、収まらないときだけスクロールにする。

**画面ぜんたいに効く modifier がある → `.full` にする。** `.card` の見本は一覧の行でも組み立てるので、表示の単位に効くもの（`preferredColorScheme` など）は、行が見えただけで効いてしまう（3 章）。

**クロージャを渡す modifier を付け外ししたい → ラベル付きの引数にクロージャごと書く。** `CodeGenerator` は modifier を末尾のクロージャの形では書けないので、`.onAppear(perform: { … })`・`.contextMenu(menuItems: { … })` の形にする。`task` のように、引数の組でやり直すきっかけが変わるものは、`Choice("count が変わるたび", code: "id: count, { await load(count) }")` のように組で選ぶ。

**見本の View を Equatable にする → `nonisolated struct` にする。** 既定の分離が MainActor だと、Equatable への準拠も MainActor に閉じ、SwiftUI が `==` を使わない（`equatable` の見本で、付けた側も毎回描き直された）。念のため、`@Environment(\.demoRecorder)` も読まず、記録の窓口は親から引く（`EquatableEntry.swift` の `recorders`）。

**テストが何分も進まない → 最初のビルドとシミュレータの複製を待つ。** 試作では 5〜10 分かかったが、テストそのものは数秒だった。本当に止まったときは `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。

**かける相手の modifier のあとに、付け外しの modifier を並べたい → `call` を相手の最後の modifier にする。** prefix に相手の View を書き、`call: ".frame", fixedArguments: ["width: 200", "height: 80"]` のようにすると、ON の modifier はその下に同じ桁で並ぶ（束 4 の `brightness` ほか色の modifier・`clipped`・`shadow`）。

**複数の収録で使う補助がある → トピックのフォルダに `<名前>Demo.swift` で置く。** `Entry` で終わらない名前にすれば、`catalog_progress.py` は数えない（束 4 の `ShapeStyleDemo`・`ScaledToDemo`）。

**シェーダーを使う → `Catalog/DrawingAndGraphics/Shaders.metal` に関数を足し、`ShaderLibrary.<関数名>(…)` で呼ぶ。** ビルドに Metal Toolchain が要る（swiftui/CLAUDE.md）。シェーダーと `maxSampleOffset` は required にし、`isEnabled` を付け外しの相手にする。シェーダーを OFF にできると `.colorEffect(isEnabled: true)` という書けないコードになるため。

**`.fill` のあとに `.stroke` をかける → 線の色を required にする。** `.fill` のあとは `Shape` でなく `ShapeView` になり、`.stroke(lineWidth:)` の色を省けない（書いたコードがビルドできない）。束 4 の `Rectangle`・`Path` は、線の色を required にして、線の太さが ON のときだけ `.stroke(.red, lineWidth: 6)` と書く。

**ImageRenderer の画像に出ない効き目がある → シミュレータで撮る。** ScrollView・List・Form のほか、`Canvas(opaque: true)` の黒い地と、`drawingGroup` が枠の外を描かないことも、テストの画像には出ず、シミュレータでは出た。

**比べるで違いが見えない → 効き目を左半分に出す。** 比べるは左半分が「付けない」側になる。`drawingGroup` の円は、はじめ枠の右にはみ出させていて違いが見えなかったので、左にはみ出させた。

**入力欄の見本が禁止の印になる → シミュレータで撮る。** TextField・SecureField・TextEditor（UIKit で描く入力欄）は、`ImageRenderer` では黄色の地に赤い禁止の印で描かれる。エラーにはならないので、5 章の ScrollView と同じく、一時的な UI テストで詳細画面を撮って見る。

**入力した値を持つ見本 → `TextInputDemo` に包む。** `build` の中では `@State` を持てないので、`TextInputDemo("") { text in TextField("名前", text: text) }` のように、値を持つ入れ物（`Catalog/TextInputAndOutput/TextInputDemo.swift`）から Binding を受け取る。String でも AttributedString でも使える。

**公式の要約と URL → リファレンスの JSON で確かめる。** `https://developer.apple.com/tutorials/data/documentation/swiftui/<トピックの slug>.json` の `references` に、記号ごとの URL と要約（`abstract`）がある。OS ごとに同じ名前の記号があるもの（`textContentType(_:)`）は、素の URL が macOS 版のことがあるので、iOS 版の URL（`textcontenttype(_:)-ufdv`）を使う。

**効き目が出るか怪しいもの → 公式の説明と試作で確かめてから `.note` にする。** 束 2 では、公式に「visionOS で効く」「macOS・Mac Catalyst で効く」とあるもの（`searchDictationBehavior`・`writingToolsAffordanceVisibility`）、iOS 27.0 の iPhone で試して変わらなかったもの（`textInputBorderShape`）、Mac のキーボード操作で効くもの（`typeSelectEquivalent`）の 4 件を `.note` にした。

**入力欄の枠 → `.textFieldStyle(.bordered)`。** iOS 27 の SDK では、`.roundedBorder` が `.bordered` と `textInputBorderShape(.roundedRectangle)` に置き換える予定になっている。

**コードの頭に説明のコメントを置きたい → `prefix` にコメントの行を書き、`indent: 0` にする。** `prefix` があると呼び出しは 4 桁下がる（入れ物の中に置く前提のため）。コメントだけなら入れ物ではないので、`indent: 0` で頭をそろえる（`TextRendererEntry.swift`・`TextInputFormattingControlVisibilityEntry.swift`）。

**違いが幅に左右されるもの → 幅を刻んで描き比べる。** `allowsTightening` は、詰めれば収まり、付けなければ省かれる幅でないと違いが見えない。一時的なテストで幅を 2 ずつ変えて描き、206 に決めた。

**既製のスタイルが `.automatic` だけ → 自作のスタイルと比べる。** `disclosureGroupStyle`・`groupBoxStyle`・`labeledContentStyle` は、iOS の既製のスタイルが `.automatic` しかない。選択肢を `.automatic` と `Choice("自作", code: "TintedGroupBoxStyle()")` にし、自作のスタイルの struct を `closing` に空の行をはさんで書く（コードに定義まで出る）。見本の側では同じ名前の `private struct` を使う。

**アニメーションの見本 → 値と動かすボタンを、見本の `private struct` に持たせる。** `build` の中では `@State` を持てないので、`AnimationDemo` のように struct に `@State` とボタンを置く。コードはボタンまで書く（`closing` に `Button(…)` と `}`）。テストの画像では動きが見えないので、一時的な UI テストでボタンを押して 0.4〜0.5 秒後に撮る。比べるは左右で 2 つの見本が重なり、途中の見た目が読みにくいので、チップの「付ける」を切って片方ずつ撮る。一覧の行でも最初の値で組み立てるので、ずっと動き続ける見本は最初の値で止めておく（`PhaseAnimator` は `trigger` を最初から ON にした）。

**sheet を開く見本 → 開くのは押したときだけにする。** `.card` の見本は一覧の行でも組み立てる（行は押せない）。`matchedTransitionSource`・`navigationTransition` の見本（`ZoomTransitionDemo`）は、ボタンを押したときだけ sheet を開くので、行からは開かない。最初から開いている（`isPresented` の初期値が true の）見本は作らない。

**ネットから読む見本 → 端末の一時フォルダに書いたファイルの URL を渡す。** アプリはオフラインで動くので、`AsyncImage` は `AsyncImageDemo` が `ImageRenderer` で書き出した PNG の file URL を読む。コードには `https://example.com/…` と書き、要約にそのことを書く。

**UI テストで編集パネルの選択肢を押す → 名前（label）で探す。** 選択肢は `staticTexts[".automatic"]` では見つからない。`app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", ".automatic")).firstMatch` で押す。チップを OFF にするのは、`app.buttons["chip-<id>"]` を押してから `app.switches["editor-on"]` を押す。

**1 行にまとめる引数が複数ある → 中身の引数 1 つを ON / OFF にし、ほかの引数を required にする（既定の値があるかは問わない）。** `listRowSeparatorTint(_:edges:)` の色は省けず、`edges` は省ける。`edges` を ON / OFF できると、色が OFF で `edges` が ON のとき `.listRowSeparatorTint(edges: .top)` という書けないコードになる。色を required でない ON のプロパティにし、`edges` を required にすると、色が OFF なら行ごと消え、ON なら `edges` も書かれる。既定の値がない引数（`onScrollGeometryChange` の `for`・`of`、`safeAreaBar` の `edge`）も同じで、中身の引数（`action`・`content`）が OFF なら行ごと消える（束 6 の `listRowSeparator`・`listRowInsets`・`swipeActions`・`scrollPosition`・`scrollTransition`・`onScrollGeometryChange` ほか）。

**iPhone で形が変わる View → 幅の区分では戻らないことがある。** `Table` は iPhone（幅が compact）で、最初の列だけを 1 列の一覧として出す。`.environment(\.horizontalSizeClass, .regular)` をかけても、列も見出しも出なかった。束 6 では `tableColumnHeaders` を `.note` にした。

**スクロールしないと見えない効き目 → 開いたときから見える位置にする。** `scrollEdgeEffectStyle` などの端の効果は、バーの下に中身が入らないと見えない。`.defaultScrollAnchor(.center)` で、最初から中身がバーの下に入るようにした（コードにも書く）。

**右端に出る効き目は、比べるで見えない → 最初の値を、付けないときと違う見た目にする。** 比べるの左半分は「付けない」側なので、List の索引やバッジのように右端に出るものは違いが見えない。索引は付けないと出る（`.automatic`）ので、`listSectionIndexVisibility` の最初の値を `.hidden` にし、編集パネルの ON / OFF で違いが出るようにした。

**ScrollGeometry の値が負から始まる → `contentInsets.top` を足す。** `contentOffset.y` は、上の余白（`safeAreaInset` で置いた表示など）の分だけ負から始まる。`onScrollGeometryChange` の見本は、`$0.contentOffset.y + $0.contentInsets.top` で 0 から数える。

**操作してから見る効き目 → 一時的な UI テストで操作してから撮る。** チップは `app.buttons["chip-<プロパティの id>"]`、編集パネルの ON / OFF は `app.switches["editor-on"]` で、スイッチの右端（`coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))`）を押す（真ん中を押しても切り替わらない）。引っ張って更新は、行の座標から `press(forDuration:thenDragTo:)` で下へ引く。

**画面を重ねて出すもの → `.card` でボタンから出す。** sheet・alert・popover・fileImporter などは、見本をボタンにすると、押したときに詳細の画面の上に出る。比べるでは、仕切りの右（付けた側）のボタンを押したときだけ出る。シートの中身にかける modifier（`presentationDetents` など）は、`Catalog/ModalPresentations/ModalDemo.swift` の `SheetModifierDemo` で開き、コードは `CodeTemplate.inSheet()`（`Button` → `.sheet {` → 中身の `Text` に modifier）の形にする（束 7）。

**画面の行き来の入れ物 → `.full` にする。** NavigationStack・TabView などを枠の中に描くと、詳細の NavigationStack の中に入れ子になる。全画面で開けば、題名・戻るボタン・タブバーがふつうに出る。中の画面にかける modifier（`navigationTitle` など）も同じ（束 7）。

**iPhone では出ないもの（束 7 で `.note` にした）:** TabView のサイドバー（`defaultTabBarPlacement(.sidebar)` でも、iOS 27.0 の iPhone 18 Pro ではタブバーのまま。サイドバーにかける modifier は見えない）、シートの大きさと置き場所（`presentationSizing`・`presentationPlacement`。iPhone のシートはいつも幅いっぱい）、`dismissalConfirmationDialog`（シートを下げても出なかった）。`sectionActions` は List の Section でも効くので `.card` にした。

**システムのファイルの画面を撮る → 押してから 5 秒ほど待つ。** fileImporter・fileExporter・fileMover の画面は、出るまで数秒かかる。

**`preferredColorScheme` を全画面で試す → 「付けない」に切り替えても暗いまま。** 表示の単位が最後の値を覚えているため。閉じれば詳細は元の見た目に戻る。

**ツールバーと検索の欄に効く modifier → `.full` にする。** 枠の中に描くと、詳細の NavigationStack のバーと混ざる。見本は `Catalog/Toolbars/ToolbarDemo.swift` の `ToolbarStack`・`Catalog/Search/SearchDemo.swift` の `SearchStack` に modifier をかけ、コードは `CodeTemplate.inToolbarStack()`・`.inSearchStack()` の形にする（束 8）。

**ツールバーの地 → 色と組にする。** iOS 27 のバーは地がなく、`toolbarBackgroundVisibility(.visible)` だけでは見た目が変わらない。`toolbarBackground(.yellow, for:)` と組にし、大きな題名が消えるので `toolbarTitleDisplayMode(.inline)` でバーの中に出す（束 8）。

**スクロールでバーを畳むもの → `for: .navigationBar` で見る。** 下のバーのボタンが 1 つだけだと、`.bottomBar` を畳んでも見た目が変わらない。安全な領域が広がるか（`toolbarMinimizationSafeAreaAdjustment`）は、`.overlay(alignment: .top)` で上の端に文字の印を置いて見る。印の地は `background(_:ignoresSafeAreaEdges: [])` にする（ふつうの `background` は安全な領域の外まで伸びる）（束 8）。

**検索の範囲の切り替え → `activation: .onSearchPresentation` を渡す。** `searchScopes(_:scopes:)` のままでは、iOS 27.0 の iPhone 17 で欄を押しても出なかった（束 8）。

**TextEditor の find の帯 → 文を押してから出す。** `findNavigator(isPresented:)` は、TextEditor に入力の印があるときだけ帯を出す。UI テストでは `app.textViews.firstMatch` を押してから、帯を出すボタンを押す（束 8）。

**iPhone では変わらないもの（束 8 で `.note` にした）:** `toolbarRole`（iOS 26 から戻るボタンはいつも矢印だけで、.browser・.editor でも題名と戻るボタンが変わらない）、窓の modifier（`windowToolbarFullScreenVisibility` は Mac だけ、`allowsWindowActivationEvents` は窓を並べられる iPad と Mac）。アプリの入口（`UIApplicationDelegateAdaptor`）と外のディスプレイ（`sceneAccessory`）も、アプリの画面の中では見せられない。

**大文字と小文字だけ違う id がある → プロパティラッパーの側に `Wrapper` を付ける。** `environmentObject` と `EnvironmentObject` のように、modifier とプロパティラッパーの id が頭の文字だけ違うと、`static let` の名前がぶつかり、macOS のファイルの名前（大文字と小文字を区別しない）もぶつかる。modifier は決まりどおり（`environmentObject`・`EnvironmentObjectEntry.swift`）にし、プロパティラッパーは `environmentObjectWrapper`・`EnvironmentObjectWrapperEntry.swift` にする（束 9）。

**比べるの画像は、左半分が「付けない」、右半分が「付けた」の合成になる → 違いを仕切りにまたがせる。** 印を付ける子を真ん中に置くと、仕切りで印が半分に切れて違いが見える（束 9 の `anchorPreference` の「ぶどう」）。付けた側だけに出る値は右に寄せる（`defaultAppStorage` の数、`environmentObject` の「テーマ: 夜」）。

**シーンぜんたいに値を出すもの → `.full` にする。** `focusedSceneValue`・`focusedSceneObject` を `.card` にすると、比べるの左（付けない側）の札にも値が届き、一覧の行からも届いた。全画面で開けば、「付けない」に切り替えたときに値が消える（束 9）。

**見本の init で記録の窓口に書かない。** 子を作るたびに `recorder?.log` を書いたら、記録の表示の描き直しが続いて UI テストが止まった。記録はボタンを押したときなど、操作のときに書く（束 9 の `StateObject`）。

**保存先ごとに初めの値を変えたい → `set(_:forKey:)` で書く。** `UserDefaults.register(defaults:)` の値は、どの保存先（`standard` も）からも見えるので、付けない側も同じ値になった（束 9 の `defaultAppStorage`）。

**クリップボードの modifier → キーボードの ⌘C・⌘X・⌘V で試す。** `copyable`・`cuttable`・`pasteDestination` は、iOS 27.0 の iPhone でも、フォーカスのある View でハードウェアキーボードの操作に応える（シミュレータは Mac のキーボード）。長押しでは編集メニューは出ない。UI テストでは `typeKey("c", modifierFlags: .command)` で試せる。見本は `.focusable()` の札に `@FocusState` でフォーカスを当てる（束 9）。

**iPhone では効かなかったフォーカスの modifier（束 9 で `.note` にした）:** `defaultFocus`（はじめのフォーカスが決まらず、`@FocusState` は nil のまま）、`focusEffectDisabled`（iPhone にはフォーカスの輪が出ない）。`focusable` は、ボタンから `@FocusState` でフォーカスを当てられることで見せられたので `.card` にした。

**ジェスチャーとキーの入力 → 起きたことは `.behavior` の記録に出し、動きが見えるものは `.card` にする（束 10）。** タップ・長押し・内側と外側のジェスチャーの勝ち負け・キーの入力は記録に出す。ドラッグ・拡大・回転は見本が動くので `.card` にする。UI テストでは `doubleTap()`・`press(forDuration:)`・`pinch(withScale:velocity:)`・`rotate(_:withVelocity:)` で操作して撮れる。的に `.accessibilityAddTraits(.isButton)` を付けたら `app.buttons[…]` で探し、記号の画像には `.accessibilityLabel` を付けて `app.images[…]` で探す。

**ハードウェアのキーボードの入力 → `typeKey` で試す。** シミュレータはハードウェアキーボードがつながっているので、`onKeyPress`・`keyboardShortcut` は UI テストの `typeKey(_:modifierFlags:)` で試せる。代わりに、入力欄をタップしても画面のキーボードは出ない（`submitLabel` は束 2 の `keyboardType` と同じく、入力欄にカーソルが入るところまで見る）。

**ドラッグとドロップ → iPhone のアプリの中で動くので `.card` にする。** 見本は、上に札（`DragChip`）、下に落とす先の箱（`DropBox`）を置く（`Catalog/DragAndDrop/DragAndDropDemo.swift`）。UI テストでは 札と箱が出るのを待ち、札が hittable になるまで待ってから、`press(forDuration: 1.5, thenDragTo: 箱, withVelocity: .slow, thenHoldForDuration: 1.5)` で落とす。箱が残っていれば 3 回まで繰り返す。「動かす」と「写す」の違いは、元の札が消えるかで見せる（`onDragSessionUpdated` で `.ended(.move)` を見る）。`dragContainerSelection` は `dragContainer` の外側（あと）にかける。内側にかけると、選んでいても引いた札 1 つしか運ばれなかった。

**ジェスチャーを組み合わせる型 → 2 つのジェスチャーを、1 つの名前なしの引数（required）の選択肢にする。** `SequenceGesture`・`SimultaneousGesture`・`ExclusiveGesture` は片方だけでは書けず、`onChanged` の中身も組によって変わるため。比べるは出ない。

**id の頭を小文字にした名前が、ほかの id とぶつかる → 型の側に `Type` を付ける。** `SimultaneousGesture`（型）と `simultaneousGesture`（modifier）は、型の側の `static let` を `simultaneousGestureType` にした（束 10）。

**最初の値が「付けない」と同じ効き目 → 比べるで違いが出る値を最初にする。** `springLoadingBehavior` は、付けない（`.automatic`）と `.disabled` がどちらもボタンを押さなかったので、最初の値を `.enabled` にした。

**iPhone では出ないもの（束 10 で `.note` にした）:** ポインタの効果と出入り（`onHover`・`onContinuousHover`・`hoverEffect`・`hoverEffectDisabled`・`defaultHoverEffect`。iPhone にはポインタがない）、Apple Pencil（`onPencilDoubleTap`・`onPencilSqueeze`）、Apple Watch のダブルタップ（`handGestureShortcut`）。`onCameraCaptureEvent` は、撮影の画面とカメラが要るので `.note` にした（1 割の数に入る）。

**支援技術がないと効き目が見えない modifier → 見本の下に「支援技術に渡る中身」の札を出す。** SwiftUI は、VoiceOver などの支援技術が動いていないとアクセシビリティの要素を作らない（`UIHostingController` の `accessibilityElements` は空だった）ので、アプリの中から木を読んで出すことはできない。`Catalog/AccessibilityFundamentals/AccessibilityDemo.swift` の `A11yDemo(title:lines:) { 見本 }` で、見本に渡したのと同じ値から札を書く。特性は SwiftUI の名前（`.isButton` など）で書き、VoiceOver の日本語の言い方は書かない。触れる場所の modifier は `A11yPointMarker` の赤い点で場所を出す（束 11）。

**札の中身は、一時的な UI テストの木と突き合わせる。** UI テストは支援技術として木を読めるので、`app.debugDescription` を書き出して札と比べる。`.combine` のラベルは「、」でつなぐ、SF Symbols の既定のラベルは日本語の名前（`trash` は「ゴミ箱」、`sparkles` は「ぴかぴか」）、`Label` は絵と文字の 2 つの要素、`Text("\(3000) 歩")` は「3,000 歩」になる。ただし UI テストの木は VoiceOver と同じではない（`accessibilityHidden(true)` の View も出る、`accessibilityLabeledPair` の組は出ない）。束の終わりの UI テストでは、ラベルが木に届いたことを `buttons["ごみ箱に入れる"]` のように確かめられる（束 11）。

**`accessibilityRepresentation` の付け外し → `.id` で見本を作り直す。** 同じ View のまま representation を外すと、UI テストでアプリが idle にならず止まった（束 11）。

**文字の大きさを変えて撮る → `launchArguments` に `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXL` を足す。** `accessibilityLargeContentViewerEnabled` は true になるが、UI テストの長押しでは大きく出す画面は撮れなかった。iOS の UI テストには `XCUIElement.increment()` もないので、調整できる要素の上げ下げも試せない（束 11）。

**iPhone で試せなかったアクセシビリティの modifier（束 11 で `.note` にした）:** `assistiveAccessNavigationIcon`（アシスティブアクセスに入ったときだけ効き、アプリの中からは入れない）。VoiceOver で聞けば確かめられるもの（speech の 4 件・ローター）は、札で違いを見せて `.card` にした。

## 用語

- **収録**: 1 つの API（View・modifier・プロパティラッパー・ジェスチャー）を 1 件として `CatalogEntry` に書いたもの
- **stage**: プレビューの出し方（`DemoStage`）
- **形**: この手引きの言葉。収録の型の使い方を「View」「引数」「付け外し」の 3 つに分けたもの（4 章）
- **行の鍵**: modifier のプロパティを 1 行にまとめる単位。`PropertySpec.line`、省けば modifier の名前
- **束**: 30〜50 件ずつに分けた収録の PR の単位。表は [Phase 3 の spec](superpowers/specs/2026-11-02-swiftui-phase3-design.md)

この手引きで決まらないことは、束の計画で決め、決めたことをここに足す。型を変える判断は ADR-0002 に書く。

最終更新: 2026-11-04（束 2〜11 のあと）
