# SwiftUI 版 Phase 3 束 4（描画と形）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** drawing-and-graphics・shapes の 43 件を収録し、2 トピックの抜けを 0 にする。

**Architecture:** 1 件 = 1 ファイルの収録データ（`WidgetLab/Catalog/<トピック>/<名前>Entry.swift`）を、Task 1〜7 で 3〜8 件ずつ足し、`Catalog.all` に並べる。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。複数の収録で使う補助（`ShapeStyleDemo`・`ScaledToDemo`）はトピックのフォルダに置き、シェーダーの 3 件のために `Shaders.metal` を 1 つ足す。42 件が `.card`、1 件（`materialActiveAppearance`）が `.note`。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Metal（シェーダーの 3 件）/ Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 4 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- **シミュレータは iPhone 18 Pro を使う**（束 2・3 が並列で動いているため。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` も `name=iPhone 18 Pro` に置き換えて使う）
- **`WidgetLab/Catalog/Model/` の型と `CodeGenerator` は変えない。** 変えたくなったら、変える前に止まってオーナーに聞く（ほかの束とぶつかるため）
- シェーダー（`.metal`）のビルドに Metal Toolchain が要る。`xcrun metal --version` が `missing Metal Toolchain` で失敗するなら、`xcodebuild -downloadComponent MetalToolchain` を一度実行する（2026-11-03 オーナーが決定。この Mac には入れてある）
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension`）。組み立ての関数だけが `@MainActor`。収録のファイルの中だけで使う補助の型は `private`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- id・種類・トピックは `WidgetLab/Catalog/Generated/Manifest.swift` に合わせる。`Generated/` は手で直さない
- `Catalog.all` には 1 行に 1 件ずつ並べる（`tools/catalog_progress.py` は 1 行 1 件の形を読む）
- 収録のファイルは、この計画に書いたコードをそのまま写す（試作でテストと画像を通したもの）。写したあとに `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける
- 試作は `/private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-p3-drawing/fd7c4e0d-f86c-41c8-b9f5-98898ded27a3/scratchpad/proto/swiftui`（以下「試作」）にある。コントローラーは各タスクのあと、写したファイルを試作と `cmp` で比べる（`Catalog.swift` と `LaunchUITests.swift` は最後のタスクのあとに比べる）
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
       -only-testing:WidgetLabTests > build/test.log 2>&1
  ```
  UI テストまで通すのは Task 7 だけ（`-only-testing:WidgetLabTests` を外す）。結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` は**使わない**（ほかの束のシミュレータも止まる）。代わりに `xcrun simctl shutdown "iPhone 18 Pro"` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。* は最初から ON、R は required。

| id | トピック | 形 | プロパティ（チップの順） | コードの形（最初の値） |
|---|---|---|---|---|
| Rectangle | shapes | View | .fill*・.stroke R（線の太さが ON のときだけ書く）・.stroke(lineWidth:) | `Rectangle().fill(.blue).frame(width: 160, height: 100)` |
| RoundedRectangle | shapes | View | cornerRadius R・style・.fill* | `RoundedRectangle(cornerRadius: 25).fill(.blue).frame(…)` |
| UnevenRoundedRectangle | shapes | View | topLeadingRadius*・bottomLeadingRadius・bottomTrailingRadius*・topTrailingRadius・style | `UnevenRoundedRectangle(topLeadingRadius: 40, bottomTrailingRadius: 40).fill(.blue).frame(…)` |
| ConcentricRectangle | shapes | View（入れ子） | corners R（同心・下限あり・固定）・.fill*・.padding* | `ZStack { ConcentricRectangle(corners: .concentric).fill(.blue).padding(12) }.frame(…).background(…).containerShape(.rect(cornerRadius: 40))` |
| Circle | shapes | View | .trim(to:)*・.stroke*・.stroke(lineWidth:)* | `Circle().trim(to: 0.75).stroke(.blue, lineWidth: 12).frame(width: 120, height: 120)` |
| Ellipse | shapes | View | .fill*・.frame(width:)*・.frame(height:)* | `Ellipse().fill(.green).frame(width: 200, height: 100)` |
| Capsule | shapes | View | style（OFF なら .continuous）・.fill*・.frame(width:)*・.frame(height:)* | `Capsule().fill(.purple).frame(width: 200, height: 60)` |
| Path | shapes | View | .fill*・.stroke R（線の太さが ON のときだけ書く）・.stroke(lineWidth:) | `Path { path in move・addLine・addQuadCurve・closeSubpath }.fill(.orange).frame(…)` |
| ContainerRelativeShape | shapes | View（入れ子） | .fill*・.padding* | `ZStack { ContainerRelativeShape().fill(.blue).padding(12) }…containerShape(.rect(cornerRadius: 40))` |
| Canvas | drawing-and-graphics | View | opaque*・colorMode | `Canvas(opaque: true) { context, size in グラデーションの帯と赤い楕円 }.frame(…)` |
| Color | drawing-and-graphics | View | red R・green R・blue R・opacity | `Color(red: 0.2, green: 0.6, blue: 0.9).frame(…)` |
| MeshGradient | drawing-and-graphics | View | points R（等間隔・中央を右上へ）・colors R・smoothsColors | `MeshGradient(width: 3, height: 3, points: […], colors: […]).frame(…)` |
| brightness | drawing-and-graphics | 付け外し | .brightness* | `LinearGradient(…).frame(width: 200, height: 80).brightness(0.3)` |
| contrast | drawing-and-graphics | 付け外し | .contrast* | `….contrast(2)` |
| colorInvert | drawing-and-graphics | 付け外し | .colorInvert* | `….colorInvert()` |
| colorMultiply | drawing-and-graphics | 付け外し | .colorMultiply* | `….colorMultiply(.blue)` |
| saturation | drawing-and-graphics | 付け外し | .saturation* | `….saturation(0.2)` |
| grayscale | drawing-and-graphics | 付け外し | .grayscale* | `….grayscale(0.8)` |
| hueRotation | drawing-and-graphics | 付け外し | .hueRotation*（60・120・180 度） | `….hueRotation(.degrees(120))` |
| luminanceToAlpha | drawing-and-graphics | 付け外し | .luminanceToAlpha* | `….luminanceToAlpha()` |
| materialActiveAppearance | drawing-and-graphics | 付け外し・**.note** | .materialActiveAppearance*（.automatic・.active・.matchWindow） | `Text("見本").padding().background(.regularMaterial).materialActiveAppearance(.active)` |
| scaledToFill | drawing-and-graphics | 付け外し | .resizable*・.scaledToFill* | `Image(systemName: "car.fill").resizable().scaledToFill().frame(width: 200, height: 80)` |
| scaledToFit | drawing-and-graphics | 付け外し | .resizable*・.scaledToFit* | `Image(systemName: "car.fill").resizable().scaledToFit().frame(…)` |
| scaleEffect | drawing-and-graphics | 引数 | x*・y・anchor | `Text("見本").padding().background(.yellow).scaleEffect(x: 2)` |
| aspectRatio | drawing-and-graphics | 引数 | aspectRatio*（名前なし）・contentMode R | `Image(…).resizable().aspectRatio(2, contentMode: .fit).frame(…)` |
| rotationEffect | drawing-and-graphics | 引数 | angle R（名前なし）・anchor | `Text("見本")….rotationEffect(.degrees(45))` |
| rotation3DEffect | drawing-and-graphics | 引数 | angle R（名前なし）・axis R・anchor・perspective | `Text("見本")….rotation3DEffect(.degrees(60), axis: (x: 0, y: 1, z: 0))` |
| transformEffect | drawing-and-graphics | 付け外し | .transformEffect*（傾ける・横に伸ばす・回す） | `Text("見本").padding().background(.yellow).transformEffect(CGAffineTransform(a: 1, b: 0, c: 0.5, …))` |
| projectionEffect | drawing-and-graphics | 付け外し | .projectionEffect*（縦の軸で回す・横の軸で回す・傾ける） | `….projectionEffect(ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 0, 1, 0)))` |
| mask | drawing-and-graphics | 引数 | alignment* | `LinearGradient(…).frame(width: 240, height: 80).mask(alignment: .leading) { Text("MASK")… }` |
| clipped | drawing-and-graphics | 付け外し | .clipped* | `Image(…).resizable().scaledToFill().frame(width: 200, height: 60).clipped()` |
| clipShape | drawing-and-graphics | 付け外し | .clipShape*（.circle・.rect(cornerRadius: 24)・.capsule・.ellipse） | `LinearGradient(…).frame(width: 200, height: 120).clipShape(.circle)` |
| blur | drawing-and-graphics | 付け外し | .blur*（radius） | `Text("見本").font(…).background(.yellow).blur(radius: 4)` |
| shadow | drawing-and-graphics | 付け外し | .shadow(color:)*・.shadow(radius:) R・.shadow(x:)*・.shadow(y:)* | `RoundedRectangle(cornerRadius: 16).fill(.yellow).frame(…).shadow(color: .gray, radius: 8, x: 8, y: 8)` |
| visualEffect | drawing-and-graphics | 付け外し（入れ子、indent 12） | .visualEffect*（色を回す・ずらす・ぼかす） | `ScrollView { ForEach { Text….background(.yellow).visualEffect({ content, proxy in … }) } }` |
| blendMode | drawing-and-graphics | 付け外し（入れ子、indent 8） | .blendMode*（.multiply ほか 4） | `ZStack { Circle 黄・Circle 青.frame(…).blendMode(.multiply).offset(x: 30) }` |
| compositingGroup | drawing-and-graphics | 付け外し | .compositingGroup* | `ZStack { 赤と青の円 }.compositingGroup().opacity(0.5)` |
| drawingGroup | drawing-and-graphics | 付け外し（indent 0） | .drawingGroup*（opaque） | `ZStack { 枠から左にはみ出す円 }.frame(width: 120, height: 80).drawingGroup(opaque: false)` |
| GeometryReader | drawing-and-graphics | View | .frame(width:)*・.frame(height:)* | `GeometryReader { proxy in 円と「200 × 100」 }.frame(width: 200, height: 100)` |
| onGeometryChange | drawing-and-graphics | 引数 | of R（幅・高さ・左端の x） | `Text("見本")….onGeometryChange(for: CGFloat.self, of: { proxy in proxy.size.width }) { value in … }` |
| colorEffect | drawing-and-graphics | 付け外し | .colorEffect.shader R（細い縞・太い縞・白と黒）・.colorEffect(isEnabled:)* | `LinearGradient(…).frame(…).colorEffect(ShaderLibrary.stripes(.float(6)), isEnabled: true)` |
| distortionEffect | drawing-and-graphics | 付け外し | .distortionEffect.shader R・.distortionEffect(maxSampleOffset:) R・.distortionEffect(isEnabled:)* | `Text("Widget Lab")….distortionEffect(ShaderLibrary.wave(.float(4), .float(40)), maxSampleOffset: CGSize(width: 0, height: 10), isEnabled: true)` |
| layerEffect | drawing-and-graphics | 付け外し | .layerEffect.shader R・.layerEffect(maxSampleOffset:) R・.layerEffect(isEnabled:)* | `Image(systemName: "car.fill")….layerEffect(ShaderLibrary.pixelate(.float(6)), maxSampleOffset: CGSize(width: 7, height: 7), isEnabled: true)` |

### `.note` にするもの（1 件、全体の 2%）

| id | 理由 |
|---|---|
| materialActiveAppearance | macOS の窓が奥にあるときの素材の見た目を決める modifier。iOS では `.inactive` が使えず（`'inactive' is unavailable in iOS` でビルドが通らない）、窓もいつも手前にあるので、`.automatic`・`.active`・`.matchWindow` のどれを選んでも、見た目が変わる場面がない。手引きの「iOS では効かない窓の modifier」に当たる |

`.note` にしかけて `.card` にしたもの:

- `colorEffect`・`distortionEffect`・`layerEffect`: Metal のシェーダーが要る。Metal Toolchain を入れて `Shaders.metal` を足し、`.card` にした（2026-11-03 オーナーが決定）
- `ConcentricRectangle`・`ContainerRelativeShape`: 入れ物の形が要る。見本の中で `ZStack` に `.containerShape(.rect(cornerRadius: 40))` をかけて見せた
- `visualEffect`: スクロールの位置で効く。見本の中に `ScrollView` を置き、詳細画面でスクロールして確かめられる

### 試作でわかったこと（Task 7 で収録の手引きに足す）

- **かける相手の modifier のあとに、付け外しの modifier を並べる形。** prefix に相手の View を書き、`call` を相手の最後の modifier（`".frame"`、`fixedArguments: ["width: 200", "height: 80"]`）にすると、ON の modifier はその下に同じ桁で並ぶ。色の modifier 8 件・`clipped`・`clipShape`・`shadow`・シェーダーの 3 件で使った
- **複数の収録で使う補助は、トピックのフォルダに `<名前>Demo.swift` で置く。** `Entry` で終わらない名前にすれば `catalog_progress.py` は数えない（`ShapeStyleDemo`・`ScaledToDemo`）
- **ImageRenderer では出ない効き目がある。** `Canvas(opaque: true)` の黒い地と、`drawingGroup` が枠の外を描かないことは、テストの画像では出ず、シミュレータでは出た。ScrollView・List・Form と同じく、シミュレータで撮って確かめる
- **比べるの「付けない」側は左半分。** 効き目が右半分にしか出ない見本だと、比べるで違いが見えない。`drawingGroup` の円は、はじめ右にはみ出させていて比べるで違いが見えなかったので、左にはみ出させた
- **シェーダーの引数は required にし、`isEnabled` を付け外しの相手にする。** `shader` を OFF にすると `.colorEffect(isEnabled: true)` という書けないコードになるため。`maxSampleOffset` も省けないので required の `.fixed`
- **`blur(radius:opaque:)` の `opaque` は入れない。** `radius` を OFF にして `opaque` だけ ON にすると、書けないコード（`.blur(opaque: true)`）になる。`radius` を required にすると、`opaque` を ON にしないとぼかしが出ない

### 束の最終レビュー（opus）で直したこと

計画の下のコードは、直したあとのもの（実装と同じ）。

- ・:  のあとの  は色を省けず、 というビルドできないコードが出ていた。線の色を required にし、線の太さが ON のときだけ  と書く。 から  の枝を消した。収録の手引きの 7 章にも足した
- :  の既定は （ と書いていた）。OFF のときの値と説明を直した
- :  は升の中央（最大で升の半分、7pt 離れた点）の色を取るので、 を  から  にした
- : 4 つの半径の説明に「OFF なら 0」をそろえた。 の「ぼかす」は、上へ出た行で半径が負にならないよう  にした

---

### Task 1: 形 1（Rectangle・RoundedRectangle・UnevenRoundedRectangle・ConcentricRectangle・Circle）

`ShapeStyleDemo` は、Rectangle・Circle（このタスク）と Path（Task 2）が使う補助。`.fill` と `.stroke` を ON のものだけかける。

**Files:**
- Create: `WidgetLab/Catalog/Shapes/ShapeStyleDemo.swift`
- Create: `WidgetLab/Catalog/Shapes/RectangleEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/RoundedRectangleEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/UnevenRoundedRectangleEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/ConcentricRectangleEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/CircleEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.rectangle`、`CatalogEntry.roundedRectangle`、`CatalogEntry.unevenRoundedRectangle`、`CatalogEntry.concentricRectangle`、`CatalogEntry.circle`、`ShapeStyleDemo.styled(_ shape: some Shape, fill: Color?, stroke: Color?, lineWidth: Double?) -> some View`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py shapes`
Expected: 終了コード 1。抜けに Rectangle・RoundedRectangle・UnevenRoundedRectangle・ConcentricRectangle・Circle がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Shapes/ShapeStyleDemo.swift`:

```swift
import SwiftUI

/// Shape に、ON の .fill と .stroke だけをかける（Rectangle・Circle・Path の見本で使う）。
/// .fill のあとの .stroke は色を省けない（ShapeView の stroke）ので、fill と線を両方かけるのは stroke の色があるときだけ
enum ShapeStyleDemo {
    @ViewBuilder
    static func styled(_ shape: some Shape, fill: Color?, stroke: Color?, lineWidth: Double?) -> some View {
        let hasStroke = stroke != nil || lineWidth != nil
        let width = CGFloat(lineWidth ?? 1)
        if let fill, let stroke {
            shape.fill(fill).stroke(stroke, lineWidth: width)
        } else if let fill {
            shape.fill(fill)
        } else if hasStroke {
            if let stroke {
                shape.stroke(stroke, lineWidth: width)
            } else {
                shape.stroke(lineWidth: width)
            }
        } else {
            shape
        }
    }
}
```

`WidgetLab/Catalog/Shapes/RectangleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let rectangle = CatalogEntry(
        id: "Rectangle",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠いっぱいの長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rectangle")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色（OFF なら前景の色）"),
            .modifier(
                "stroke", .color(initial: 0), required: true,
                summary: "縁の線の色（線の太さが ON のときだけ書く）"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 1...16, step: 1, initial: 6),
                summary: "縁の線の太さ"),
        ],
        code: CodeTemplate(call: "Rectangle", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Rectangle(), fill: v.color("fill"),
                    stroke: v.number("stroke.lineWidth") != nil ? v.color("stroke") : nil,
                    lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 160, height: 100)
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/RoundedRectangleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let roundedRectangle = CatalogEntry(
        id: "RoundedRectangle",
        kind: .view,
        topic: .shapes,
        summary: "角を丸めた長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/roundedrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "cornerRadius", .slider(range: 0...50, step: 5, initial: 25), required: true, summary: "角の丸みの半径"),
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（.circular は円弧、.continuous はなめらかにつなぐ。OFF なら .continuous）"),
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色（OFF なら前景の色）"),
        ],
        code: CodeTemplate(call: "RoundedRectangle", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                RoundedRectangle(
                    cornerRadius: CGFloat(v.number("cornerRadius") ?? 0),
                    style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .continuous
                )
                .apply(v.color("fill")) { $0.fill($1) }
                .frame(width: 160, height: 100)
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/UnevenRoundedRectangleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let unevenRoundedRectangle = CatalogEntry(
        id: "UnevenRoundedRectangle",
        kind: .view,
        topic: .shapes,
        summary: "4 つの角を、それぞれ別の半径で丸めた長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/unevenroundedrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "topLeadingRadius", .slider(range: 0...50, step: 5, initial: 40), on: true,
                summary: "左上の角の半径（OFF なら 0）"),
            .argument(
                "bottomLeadingRadius", .slider(range: 0...50, step: 5, initial: 10), summary: "左下の角の半径（OFF なら 0）"),
            .argument(
                "bottomTrailingRadius", .slider(range: 0...50, step: 5, initial: 40), on: true,
                summary: "右下の角の半径（OFF なら 0）"),
            .argument("topTrailingRadius", .slider(range: 0...50, step: 5, initial: 10), summary: "右上の角の半径（OFF なら 0）"),
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（OFF なら .continuous）"),
        ],
        code: CodeTemplate(
            call: "UnevenRoundedRectangle", suffix: [".fill(.blue)", ".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                UnevenRoundedRectangle(
                    topLeadingRadius: CGFloat(v.number("topLeadingRadius") ?? 0),
                    bottomLeadingRadius: CGFloat(v.number("bottomLeadingRadius") ?? 0),
                    bottomTrailingRadius: CGFloat(v.number("bottomTrailingRadius") ?? 0),
                    topTrailingRadius: CGFloat(v.number("topTrailingRadius") ?? 0),
                    style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .continuous
                )
                .fill(.blue)
                .frame(width: 160, height: 100)
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/ConcentricRectangleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let concentricRectangle = CatalogEntry(
        id: "ConcentricRectangle",
        kind: .view,
        topic: .shapes,
        summary: "入れ物の角の丸みと中心をそろえて（同心に）角を丸める長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/concentricrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "corners",
                .choice(
                    [Choice(".concentric"), Choice(".concentric(minimum: 24)"), Choice(".fixed(8)")], initial: 0),
                required: true, summary: "角の決め方（入れ物と同心・同心で下限あり・決めた半径）"),
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色"),
            .modifier(
                "padding", .slider(range: 0...40, step: 4, initial: 12), on: true,
                summary: "入れ物の縁からの距離。離すほど、同心の角は小さくなる"),
        ],
        code: CodeTemplate(
            prefix: ["ZStack {"], call: "ConcentricRectangle",
            closing: [
                "}", ".frame(width: 200, height: 120)", ".background(.yellow, in: .rect(cornerRadius: 40))",
                ".containerShape(.rect(cornerRadius: 40))",
            ]),
        build: { v in
            AnyView(
                ZStack {
                    ConcentricRectangle(
                        corners: v.pick("corners", from: [.concentric, .concentric(minimum: 24), .fixed(8)])
                            ?? .concentric
                    )
                    .apply(v.color("fill")) { $0.fill($1) }
                    .apply(v.number("padding")) { $0.padding(CGFloat($1)) }
                }
                .frame(width: 200, height: 120)
                .background(.yellow, in: .rect(cornerRadius: 40))
                .containerShape(.rect(cornerRadius: 40))
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/CircleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let circle = CatalogEntry(
        id: "Circle",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠の中心に、短い辺を直径にして描く円の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/circle")!,
        stage: .card,
        properties: [
            .modifier(
                "trim", label: "to", .slider(range: 0.1...1, step: 0.05, initial: 0.75), on: true,
                summary: "線をどこまで描くか（0〜1。始まりは右端）"),
            .modifier("stroke", .color(initial: 4), on: true, summary: "線の色（OFF でほかの線も OFF なら、中を塗る）"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 2...24, step: 2, initial: 12),
                on: true, summary: "線の太さ"),
        ],
        code: CodeTemplate(call: "Circle", suffix: [".frame(width: 120, height: 120)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Circle().trim(from: 0, to: CGFloat(v.number("trim") ?? 1)), fill: nil, stroke: v.color("stroke"),
                    lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 120, height: 120)
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .rectangle,
        .roundedRectangle,
        .unevenRoundedRectangle,
        .concentricRectangle,
        .circle,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Shapes/ShapeStyleDemo.swift \
  WidgetLab/Catalog/Shapes/RectangleEntry.swift \
  WidgetLab/Catalog/Shapes/RoundedRectangleEntry.swift \
  WidgetLab/Catalog/Shapes/UnevenRoundedRectangleEntry.swift \
  WidgetLab/Catalog/Shapes/ConcentricRectangleEntry.swift \
  WidgetLab/Catalog/Shapes/CircleEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: Rectangle・RoundedRectangle・UnevenRoundedRectangle・ConcentricRectangle・Circle を収録する"
```

---

### Task 2: 形 2 と描く View（Ellipse・Capsule・Path・ContainerRelativeShape・Canvas・Color・MeshGradient）

**Files:**
- Create: `WidgetLab/Catalog/Shapes/EllipseEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/CapsuleEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/PathEntry.swift`
- Create: `WidgetLab/Catalog/Shapes/ContainerRelativeShapeEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/CanvasEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ColorEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/MeshGradientEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`。Task 1 の `ShapeStyleDemo.styled(_:fill:stroke:lineWidth:)`（Path が使う）
- Produces: `CatalogEntry.ellipse`、`CatalogEntry.capsule`、`CatalogEntry.path`、`CatalogEntry.containerRelativeShape`、`CatalogEntry.canvas`、`CatalogEntry.color`、`CatalogEntry.meshGradient`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py shapes drawing-and-graphics`
Expected: 終了コード 1。抜けに Ellipse・Capsule・Path・ContainerRelativeShape・Canvas・Color・MeshGradient がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Shapes/EllipseEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let ellipse = CatalogEntry(
        id: "Ellipse",
        kind: .view,
        topic: .shapes,
        summary: "置かれた枠にぴったり収まる楕円の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/ellipse")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 3), on: true, summary: "中を塗る色"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 200), on: true,
                summary: "枠の幅（楕円の横の直径）"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 40...160, step: 20, initial: 100),
                on: true,
                summary: "枠の高さ（楕円の縦の直径）"),
        ],
        code: CodeTemplate(call: "Ellipse"),
        build: { v in
            AnyView(
                Ellipse()
                    .apply(v.color("fill")) { $0.fill($1) }
                    .frame(
                        width: v.number("frame.width").map { CGFloat($0) },
                        height: v.number("frame.height").map { CGFloat($0) })
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/CapsuleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let capsule = CatalogEntry(
        id: "Capsule",
        kind: .view,
        topic: .shapes,
        summary: "短い辺の両端を半円にした、カプセルの形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/capsule")!,
        stage: .card,
        properties: [
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（OFF なら .continuous）"),
            .modifier("fill", .color(initial: 5), on: true, summary: "中を塗る色"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 200), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 20...160, step: 20, initial: 60), on: true,
                summary: "枠の高さ（縦を長くすると、上下が丸くなる）"),
        ],
        code: CodeTemplate(call: "Capsule"),
        build: { v in
            AnyView(
                Capsule(style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .continuous)
                    .apply(v.color("fill")) { $0.fill($1) }
                    .frame(
                        width: v.number("frame.width").map { CGFloat($0) },
                        height: v.number("frame.height").map { CGFloat($0) })
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/PathEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let path = CatalogEntry(
        id: "Path",
        kind: .view,
        topic: .shapes,
        summary: "線や曲線をつないで、好きな形を描く Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/path")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 1), on: true, summary: "中を塗る色（OFF なら前景の色）"),
            .modifier(
                "stroke", .color(initial: 4), required: true,
                summary: "縁の線の色（線の太さが ON のときだけ書く）"),
            .modifier(
                "stroke", id: "stroke.lineWidth", label: "lineWidth", .slider(range: 1...16, step: 1, initial: 6),
                summary: "縁の線の太さ"),
        ],
        code: CodeTemplate(
            call: "Path",
            trailing: " { path in\n    path.move(to: CGPoint(x: 20, y: 100))\n"
                + "    path.addLine(to: CGPoint(x: 100, y: 20))\n"
                + "    path.addQuadCurve(to: CGPoint(x: 180, y: 100), control: CGPoint(x: 180, y: 20))\n"
                + "    path.closeSubpath()\n}",
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                ShapeStyleDemo.styled(
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: 100))
                        path.addLine(to: CGPoint(x: 100, y: 20))
                        path.addQuadCurve(to: CGPoint(x: 180, y: 100), control: CGPoint(x: 180, y: 20))
                        path.closeSubpath()
                    },
                    fill: v.color("fill"), stroke: v.number("stroke.lineWidth") != nil ? v.color("stroke") : nil,
                    lineWidth: v.number("stroke.lineWidth")
                )
                .frame(width: 200, height: 120)
            )
        }
    )
}
```

`WidgetLab/Catalog/Shapes/ContainerRelativeShapeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let containerRelativeShape = CatalogEntry(
        id: "ContainerRelativeShape",
        kind: .view,
        topic: .shapes,
        summary: "入れ物の形（containerShape で決めた形）を、置かれた場所に合わせて写した Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/containerrelativeshape")!,
        stage: .card,
        properties: [
            .modifier("fill", .color(initial: 4), on: true, summary: "中を塗る色"),
            .modifier(
                "padding", .slider(range: 0...40, step: 4, initial: 12), on: true, summary: "入れ物の縁からの距離"),
        ],
        code: CodeTemplate(
            prefix: ["ZStack {"], call: "ContainerRelativeShape",
            closing: [
                "}", ".frame(width: 200, height: 120)", ".background(.yellow, in: .rect(cornerRadius: 40))",
                ".containerShape(.rect(cornerRadius: 40))",
            ]),
        build: { v in
            AnyView(
                ZStack {
                    ContainerRelativeShape()
                        .apply(v.color("fill")) { $0.fill($1) }
                        .apply(v.number("padding")) { $0.padding(CGFloat($1)) }
                }
                .frame(width: 200, height: 120)
                .background(.yellow, in: .rect(cornerRadius: 40))
                .containerShape(.rect(cornerRadius: 40))
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/CanvasEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let canvas = CatalogEntry(
        id: "Canvas",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "GraphicsContext に、Path や画像や文字を直接描いていく View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/canvas")!,
        stage: .card,
        properties: [
            .argument("opaque", .toggle(initial: true), on: true, summary: "不透明として描く（描いていないところが黒くなる）"),
            .argument(
                "colorMode", .choice([Choice(".nonLinear"), Choice(".linear"), Choice(".extendedLinear")], initial: 1),
                summary: "色を混ぜる計算の色空間（グラデーションの中ほどの明るさが変わる）"),
        ],
        code: CodeTemplate(
            call: "Canvas",
            trailing: " { context, size in\n"
                + "    let bar = CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)\n"
                + "    context.fill(\n"
                + "        Path(roundedRect: bar, cornerRadius: 12),\n"
                + "        with: .linearGradient(\n"
                + "            Gradient(colors: [.blue, .yellow]), startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))\n"
                + "    context.fill(\n"
                + "        Path(ellipseIn: CGRect(x: 0, y: size.height / 2 + 8, width: 60, height: 40)), with: .color(.red))\n"
                + "}",
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                Canvas(
                    opaque: v.flag("opaque") ?? false,
                    colorMode: v.pick("colorMode", from: [ColorRenderingMode.nonLinear, .linear, .extendedLinear])
                        ?? .nonLinear
                ) { context, size in
                    let bar = CGRect(x: 0, y: 0, width: size.width, height: size.height / 2)
                    context.fill(
                        Path(roundedRect: bar, cornerRadius: 12),
                        with: .linearGradient(
                            Gradient(colors: [.blue, .yellow]), startPoint: .zero,
                            endPoint: CGPoint(x: size.width, y: 0)))
                    context.fill(
                        Path(ellipseIn: CGRect(x: 0, y: size.height / 2 + 8, width: 60, height: 40)),
                        with: .color(.red))
                }
                .frame(width: 200, height: 120)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ColorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let color = CatalogEntry(
        id: "Color",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "色。View としては、置かれた枠いっぱいをその色で塗る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/color")!,
        stage: .card,
        properties: [
            .argument("red", .slider(range: 0...1, step: 0.1, initial: 0.2), required: true, summary: "赤の強さ（0〜1）"),
            .argument("green", .slider(range: 0...1, step: 0.1, initial: 0.6), required: true, summary: "緑の強さ"),
            .argument("blue", .slider(range: 0...1, step: 0.1, initial: 0.9), required: true, summary: "青の強さ"),
            .argument("opacity", .slider(range: 0...1, step: 0.1, initial: 0.5), summary: "不透明度（OFF なら 1）"),
        ],
        code: CodeTemplate(call: "Color", suffix: [".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                Color(
                    red: v.number("red") ?? 0, green: v.number("green") ?? 0, blue: v.number("blue") ?? 0,
                    opacity: v.number("opacity") ?? 1
                )
                .frame(width: 160, height: 100)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/MeshGradientEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let meshGradient = CatalogEntry(
        id: "MeshGradient",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "格子の点ごとに色を置き、そのあいだを混ぜて塗るグラデーション。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/meshgradient")!,
        stage: .card,
        properties: [
            .argument(
                "points",
                .choice(
                    [
                        Choice(
                            "等間隔",
                            code: "[[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]]"
                        ),
                        Choice(
                            "中央を右上へ",
                            code: "[[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.8, 0.2], [1, 0.5], [0, 1], [0.5, 1], [1, 1]]"
                        ),
                    ],
                    initial: 1),
                required: true, summary: "3 × 3 の点の場所（0〜1）"),
            .argument(
                "colors",
                .choice(
                    [
                        Choice("暖色と寒色", code: "[.red, .orange, .yellow, .purple, .white, .green, .blue, .cyan, .mint]"),
                        Choice("青の濃淡", code: "[.indigo, .blue, .cyan, .blue, .white, .cyan, .cyan, .mint, .teal]"),
                    ],
                    initial: 0),
                required: true, summary: "点ごとの色（points と同じ並び）"),
            .argument("smoothsColors", .toggle(initial: false), summary: "色をなめらかに混ぜる（OFF なら true）"),
        ],
        code: CodeTemplate(
            call: "MeshGradient", fixedArguments: ["width: 3", "height: 3"],
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                MeshGradient(
                    width: 3, height: 3,
                    points: v.pick("points", from: MeshGradientDemo.points) ?? MeshGradientDemo.points[0],
                    colors: v.pick("colors", from: MeshGradientDemo.colors) ?? MeshGradientDemo.colors[0],
                    smoothsColors: v.flag("smoothsColors") ?? true
                )
                .frame(width: 200, height: 120)
            )
        }
    )
}

private enum MeshGradientDemo {
    static let points: [[SIMD2<Float>]] = [
        [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
        [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.8, 0.2], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
    ]
    static let colors: [[Color]] = [
        [.red, .orange, .yellow, .purple, .white, .green, .blue, .cyan, .mint],
        [.indigo, .blue, .cyan, .blue, .white, .cyan, .cyan, .mint, .teal],
    ]
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .ellipse,
        .capsule,
        .path,
        .containerRelativeShape,
        .canvas,
        .color,
        .meshGradient,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Shapes/EllipseEntry.swift \
  WidgetLab/Catalog/Shapes/CapsuleEntry.swift \
  WidgetLab/Catalog/Shapes/PathEntry.swift \
  WidgetLab/Catalog/Shapes/ContainerRelativeShapeEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/CanvasEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ColorEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/MeshGradientEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: Ellipse・Capsule・Path・ContainerRelativeShape・Canvas・Color・MeshGradient を収録する"
```

---

### Task 3: 色の modifier（brightness・contrast・colorInvert・colorMultiply・saturation・grayscale・hueRotation・luminanceToAlpha）

**Files:**
- Create: `WidgetLab/Catalog/DrawingAndGraphics/BrightnessEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ContrastEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ColorInvertEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ColorMultiplyEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/SaturationEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/GrayscaleEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/HueRotationEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/LuminanceToAlphaEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.brightness`、`CatalogEntry.contrast`、`CatalogEntry.colorInvert`、`CatalogEntry.colorMultiply`、`CatalogEntry.saturation`、`CatalogEntry.grayscale`、`CatalogEntry.hueRotation`、`CatalogEntry.luminanceToAlpha`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drawing-and-graphics`
Expected: 終了コード 1。抜けに brightness・contrast・colorInvert・colorMultiply・saturation・grayscale・hueRotation・luminanceToAlpha がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DrawingAndGraphics/BrightnessEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let brightness = CatalogEntry(
        id: "brightness",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を明るく（負なら暗く）する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/brightness(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "brightness", .slider(range: -1...1, step: 0.1, initial: 0.3), on: true, summary: "足す明るさ（-1〜1。0 で元のまま）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.number("brightness")) { $0.brightness($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ContrastEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contrast = CatalogEntry(
        id: "contrast",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "明るいところと暗いところの差（コントラスト）を変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contrast(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contrast", .slider(range: 0...3, step: 0.25, initial: 2), on: true, summary: "差の倍率（1 で元のまま、0 で灰色一色）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.number("contrast")) { $0.contrast($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ColorInvertEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let colorInvert = CatalogEntry(
        id: "colorInvert",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を反転する modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/colorinvert()")!,
        stage: .card,
        properties: [
            .modifier("colorInvert", .fixed(code: ""), on: true, summary: "色を反転する")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.flag("colorInvert")) { view, _ in view.colorInvert() }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ColorMultiplyEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let colorMultiply = CatalogEntry(
        id: "colorMultiply",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色に、決めた色を掛け合わせる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/colormultiply(_:)")!,
        stage: .card,
        properties: [
            .modifier("colorMultiply", .color(initial: 4), on: true, summary: "掛け合わせる色（白なら元のまま）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.color("colorMultiply")) { $0.colorMultiply($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/SaturationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let saturation = CatalogEntry(
        id: "saturation",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色の鮮やかさ（彩度）を変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/saturation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "saturation", .slider(range: 0...2, step: 0.2, initial: 0.2), on: true, summary: "彩度の倍率（1 で元のまま、0 で白黒）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.number("saturation")) { $0.saturation($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/GrayscaleEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let grayscale = CatalogEntry(
        id: "grayscale",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色を灰色に近づける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/grayscale(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "grayscale", .slider(range: 0...1, step: 0.1, initial: 0.8), on: true,
                summary: "灰色に近づける量（0 で元のまま、1 で白黒）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.number("grayscale")) { $0.grayscale($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/HueRotationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let hueRotation = CatalogEntry(
        id: "hueRotation",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色相を、決めた角度だけ回す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/huerotation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "hueRotation",
                .choice([Choice(".degrees(60)"), Choice(".degrees(120)"), Choice(".degrees(180)")], initial: 1),
                on: true, summary: "色相を回す角度")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.pick("hueRotation", from: [Angle.degrees(60), .degrees(120), .degrees(180)])) {
                        $0.hueRotation($1)
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/LuminanceToAlphaEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let luminanceToAlpha = CatalogEntry(
        id: "luminanceToAlpha",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "明るさを不透明度にして、黒の濃淡で描く modifier。暗いところほど透ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/luminancetoalpha()")!,
        stage: .card,
        properties: [
            .modifier("luminanceToAlpha", .fixed(code: ""), on: true, summary: "明るさを不透明度にする")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.flag("luminanceToAlpha")) { view, _ in view.luminanceToAlpha() }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .brightness,
        .contrast,
        .colorInvert,
        .colorMultiply,
        .saturation,
        .grayscale,
        .hueRotation,
        .luminanceToAlpha,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/DrawingAndGraphics/BrightnessEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ContrastEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ColorInvertEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ColorMultiplyEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/SaturationEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/GrayscaleEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/HueRotationEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/LuminanceToAlphaEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 色の modifier 8 件（brightness ほか）を収録する"
```

---

### Task 4: 大きさと向き（materialActiveAppearance・scaledToFill・scaledToFit・scaleEffect・aspectRatio・rotationEffect・rotation3DEffect）

`materialActiveAppearance` は `.note`（`noteReason:` を渡す初期化で、`build` を書かない）。理由は上の「`.note` にするもの」。`ScaledToDemo` は scaledToFill・scaledToFit の 2 件が使う補助。

**Files:**
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ScaledToDemo.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/MaterialActiveAppearanceEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ScaledToFillEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ScaledToFitEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ScaleEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/AspectRatioEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/RotationEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/Rotation3DEffectEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.materialActiveAppearance`、`CatalogEntry.scaledToFill`、`CatalogEntry.scaledToFit`、`CatalogEntry.scaleEffect`、`CatalogEntry.aspectRatio`、`CatalogEntry.rotationEffect`、`CatalogEntry.rotation3DEffect`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drawing-and-graphics`
Expected: 終了コード 1。抜けに materialActiveAppearance・scaledToFill・scaledToFit・scaleEffect・aspectRatio・rotationEffect・rotation3DEffect がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DrawingAndGraphics/ScaledToDemo.swift`:

```swift
import SwiftUI

/// scaledToFit・scaledToFill の見本の画像。resizable と、ON なら scaledToFit / scaledToFill をかける
enum ScaledToDemo {
    @ViewBuilder
    static func image(resizable: Bool, contentMode: ContentMode?) -> some View {
        let image = Image(systemName: "car.fill")
        if resizable {
            switch contentMode {
            case .fit: image.resizable().scaledToFit()
            case .fill: image.resizable().scaledToFill()
            case nil: image.resizable()
            }
        } else {
            switch contentMode {
            case .fit: image.scaledToFit()
            case .fill: image.scaledToFill()
            case nil: image
            }
        }
    }
}
```

`WidgetLab/Catalog/DrawingAndGraphics/MaterialActiveAppearanceEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let materialActiveAppearance = CatalogEntry(
        id: "materialActiveAppearance",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の素材（material）を、窓が手前にあるとき（active）の見た目で描くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/materialactiveappearance(_:)")!,
        noteReason: "macOS の窓が奥にあるときの、素材の見た目を決める。iOS では窓がいつも手前にあり、.inactive も使えないので、見た目は変わらない",
        properties: [
            .modifier(
                "materialActiveAppearance",
                .choice([Choice(".automatic"), Choice(".active"), Choice(".matchWindow")], initial: 1), on: true,
                summary: "素材の見た目（いつも手前・窓に合わせる）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()"], call: ".background", fixedArguments: [".regularMaterial"])
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ScaledToFillEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scaledToFill = CatalogEntry(
        id: "scaledToFill",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、縦横比を保ったまま、置かれた枠を埋める大きさにする modifier。枠からはみ出すところが出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scaledtofill()")!,
        stage: .card,
        properties: [
            .modifier("resizable", .fixed(code: ""), on: true, summary: "画像を、置かれた大きさに伸び縮みさせる（OFF なら元の大きさ）"),
            .modifier("scaledToFill", .fixed(code: ""), on: true, summary: "枠を埋める大きさにする（はみ出す）"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"car.fill\""], suffix: [".frame(width: 200, height: 80)"]),
        build: { v in
            AnyView(
                ScaledToDemo.image(
                    resizable: v.flag("resizable") != nil, contentMode: v.flag("scaledToFill") != nil ? .fill : nil
                )
                .frame(width: 200, height: 80)
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ScaledToFitEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scaledToFit = CatalogEntry(
        id: "scaledToFit",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、縦横比を保ったまま、置かれた枠に収まる大きさにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scaledtofit()")!,
        stage: .card,
        properties: [
            .modifier("resizable", .fixed(code: ""), on: true, summary: "画像を、置かれた大きさに伸び縮みさせる（OFF なら元の大きさ）"),
            .modifier("scaledToFit", .fixed(code: ""), on: true, summary: "枠に収まる大きさにする（はみ出さない）"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"car.fill\""], suffix: [".frame(width: 200, height: 80)"]),
        build: { v in
            AnyView(
                ScaledToDemo.image(
                    resizable: v.flag("resizable") != nil, contentMode: v.flag("scaledToFit") != nil ? .fit : nil
                )
                .frame(width: 200, height: 80)
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ScaleEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let scaleEffect = CatalogEntry(
        id: "scaleEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く大きさだけを、横と縦の倍率で変える modifier。並びの中の大きさは変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scaleeffect(x:y:anchor:)")!,
        stage: .card,
        properties: [
            .argument("x", .slider(range: 0.25...3, step: 0.25, initial: 2), on: true, summary: "横の倍率（OFF なら 1）"),
            .argument("y", .slider(range: 0.25...3, step: 0.25, initial: 1.5), summary: "縦の倍率（OFF なら 1）"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".topLeading"), Choice(".bottomTrailing")], initial: 1),
                summary: "伸び縮みの中心（OFF なら .center）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".scaleEffect"),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .scaleEffect(
                        x: v.number("x").map { CGFloat($0) } ?? 1, y: v.number("y").map { CGFloat($0) } ?? 1,
                        anchor: v.pick("anchor", from: [UnitPoint.center, .topLeading, .bottomTrailing]) ?? .center
                    )
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/AspectRatioEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let aspectRatio = CatalogEntry(
        id: "aspectRatio",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の縦横比を決めて、置かれた枠に収める（または埋める）modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/aspectratio(_:contentmode:)")!,
        stage: .card,
        properties: [
            .argument(
                "aspectRatio", unlabeled: true, .slider(range: 0.5...3, step: 0.25, initial: 2), on: true,
                summary: "幅 ÷ 高さ（OFF なら View の元の比）"),
            .argument(
                "contentMode", .choice([Choice(".fit"), Choice(".fill")], initial: 0), required: true,
                summary: "枠に収めるか（.fit）、枠を埋めるか（.fill）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .resizable()"], call: ".aspectRatio",
            suffix: [".frame(width: 200, height: 80)"]),
        build: { v in
            AnyView(
                Image(systemName: "car.fill")
                    .resizable()
                    .aspectRatio(
                        v.number("aspectRatio").map { CGFloat($0) },
                        contentMode: v.pick("contentMode", from: [ContentMode.fit, .fill]) ?? .fit
                    )
                    .frame(width: 200, height: 80)
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/RotationEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let rotationEffect = CatalogEntry(
        id: "rotationEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く向きだけを、決めた角度だけ回す modifier。並びの中の場所は変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/rotationeffect(_:anchor:)")!,
        stage: .card,
        properties: [
            .argument(
                "angle", unlabeled: true,
                .choice(
                    [Choice(".degrees(15)"), Choice(".degrees(45)"), Choice(".degrees(90)"), Choice(".degrees(180)")],
                    initial: 1),
                required: true, summary: "回す角度（時計回り）"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".topLeading"), Choice(".bottomTrailing")], initial: 1),
                summary: "回す中心（OFF なら .center）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".rotationEffect"),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .rotationEffect(
                        v.pick("angle", from: [Angle.degrees(15), .degrees(45), .degrees(90), .degrees(180)]) ?? .zero,
                        anchor: v.pick("anchor", from: [UnitPoint.center, .topLeading, .bottomTrailing]) ?? .center
                    )
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/Rotation3DEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let rotation3DEffect = CatalogEntry(
        id: "rotation3DEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、決めた軸のまわりに奥行きをつけて回して描く modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/rotation3deffect(_:axis:anchor:anchorz:perspective:)"
        )!,
        stage: .card,
        properties: [
            .argument(
                "angle", unlabeled: true,
                .choice([Choice(".degrees(30)"), Choice(".degrees(60)"), Choice(".degrees(150)")], initial: 1),
                required: true, summary: "回す角度"),
            .argument(
                "axis",
                .choice(
                    [
                        Choice("縦の軸", code: "(x: 0, y: 1, z: 0)"), Choice("横の軸", code: "(x: 1, y: 0, z: 0)"),
                        Choice("斜めの軸", code: "(x: 1, y: 1, z: 0)"),
                    ],
                    initial: 0),
                required: true, summary: "回す軸の向き"),
            .argument(
                "anchor", .choice([Choice(".center"), Choice(".leading"), Choice(".top")], initial: 1),
                summary: "軸が通る場所（OFF なら .center）"),
            .argument(
                "perspective", .slider(range: 0...2, step: 0.25, initial: 0.5),
                summary: "遠近の強さ（0 で遠近なし。OFF なら 1）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .font(.largeTitle)", "    .padding()", "    .background(.yellow)"],
            call: ".rotation3DEffect"),
        build: { v in
            let axes: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [(0, 1, 0), (1, 0, 0), (1, 1, 0)]
            return AnyView(
                Text("見本")
                    .font(.largeTitle)
                    .padding()
                    .background(.yellow)
                    .rotation3DEffect(
                        v.pick("angle", from: [Angle.degrees(30), .degrees(60), .degrees(150)]) ?? .zero,
                        axis: v.pick("axis", from: axes) ?? (0, 1, 0),
                        anchor: v.pick("anchor", from: [UnitPoint.center, .leading, .top]) ?? .center,
                        perspective: v.number("perspective").map { CGFloat($0) } ?? 1
                    )
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .materialActiveAppearance,
        .scaledToFill,
        .scaledToFit,
        .scaleEffect,
        .aspectRatio,
        .rotationEffect,
        .rotation3DEffect,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/DrawingAndGraphics/ScaledToDemo.swift \
  WidgetLab/Catalog/DrawingAndGraphics/MaterialActiveAppearanceEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ScaledToFillEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ScaledToFitEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ScaleEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/AspectRatioEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/RotationEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/Rotation3DEffectEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: materialActiveAppearance・scaledToFill・scaledToFit・scaleEffect・aspectRatio・rotationEffect・rotation3DEffect を収録する"
```

---

### Task 5: 変形と切り取り（transformEffect・projectionEffect・mask・clipped・clipShape・blur・shadow）

**Files:**
- Create: `WidgetLab/Catalog/DrawingAndGraphics/TransformEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ProjectionEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/MaskEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ClippedEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ClipShapeEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/BlurEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ShadowEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.transformEffect`、`CatalogEntry.projectionEffect`、`CatalogEntry.mask`、`CatalogEntry.clipped`、`CatalogEntry.clipShape`、`CatalogEntry.blur`、`CatalogEntry.shadow`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drawing-and-graphics`
Expected: 終了コード 1。抜けに transformEffect・projectionEffect・mask・clipped・clipShape・blur・shadow がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DrawingAndGraphics/TransformEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let transformEffect = CatalogEntry(
        id: "transformEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く形を、アフィン変換（回す・伸ばす・傾ける・ずらす）で変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transformeffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformEffect",
                .choice(
                    [
                        Choice("傾ける", code: "CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0)"),
                        Choice("横に伸ばす", code: "CGAffineTransform(scaleX: 1.5, y: 1)"),
                        Choice("回す", code: "CGAffineTransform(rotationAngle: .pi / 8)"),
                    ],
                    initial: 0),
                on: true, summary: "かける変換（原点は View の左上）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()"], call: ".background", fixedArguments: [".yellow"]),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .apply(
                        v.pick(
                            "transformEffect",
                            from: [
                                CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0),
                                CGAffineTransform(scaleX: 1.5, y: 1), CGAffineTransform(rotationAngle: .pi / 8),
                            ])
                    ) { $0.transformEffect($1) }
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ProjectionEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let projectionEffect = CatalogEntry(
        id: "projectionEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の描く形を、射影変換（3D の回転を平面に写したものなど）で変える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/projectioneffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "projectionEffect",
                .choice(
                    [
                        Choice("縦の軸で回す", code: "ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 0, 1, 0))"),
                        Choice("横の軸で回す", code: "ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 1, 0, 0))"),
                        Choice(
                            "傾ける",
                            code: "ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0))"),
                    ],
                    initial: 0),
                on: true, summary: "かける変換（原点は View の左上）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()"], call: ".background", fixedArguments: [".yellow"]),
        build: { v in
            AnyView(
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .apply(
                        v.pick(
                            "projectionEffect",
                            from: [
                                ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 0, 1, 0)),
                                ProjectionTransform(CATransform3DMakeRotation(.pi / 3, 1, 0, 0)),
                                ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: 0.5, d: 1, tx: 0, ty: 0)),
                            ])
                    ) { $0.projectionEffect($1) }
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/MaskEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let mask = CatalogEntry(
        id: "mask",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "別の View の不透明なところだけを残して、View を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/mask(alignment:_:)")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true,
                summary: "マスクの View の揃え方（OFF なら .center）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)",
                "    .frame(width: 240, height: 80)",
            ],
            call: ".mask",
            trailing: " {\n        Text(\"MASK\")\n            .font(.system(size: 56, weight: .black))\n    }"),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 240, height: 80)
                    .mask(alignment: v.pick("alignment", from: [Alignment.leading, .center, .trailing]) ?? .center) {
                        Text("MASK")
                            .font(.system(size: 56, weight: .black))
                    }
                    .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ClippedEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let clipped = CatalogEntry(
        id: "clipped",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の枠からはみ出したところを切り取る modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/clipped(antialiased:)")!,
        stage: .card,
        properties: [
            .modifier("clipped", .fixed(code: ""), on: true, summary: "枠の外を切り取る")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .resizable()", "    .scaledToFill()"], call: ".frame",
            fixedArguments: ["width: 200", "height: 60"]),
        build: { v in
            AnyView(
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 60)
                    .apply(v.flag("clipped")) { view, _ in view.clipped() }
                    .border(.red)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ClipShapeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let clipShape = CatalogEntry(
        id: "clipShape",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、決めた Shape の形に切り取る modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:)")!,
        stage: .card,
        properties: [
            .modifier(
                "clipShape",
                .choice(
                    [Choice(".circle"), Choice(".rect(cornerRadius: 24)"), Choice(".capsule"), Choice(".ellipse")],
                    initial: 0),
                on: true, summary: "切り取る形")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 120"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 120)
                    .apply(
                        v.pick(
                            "clipShape",
                            from: [
                                AnyShape(.circle), AnyShape(.rect(cornerRadius: 24)), AnyShape(.capsule),
                                AnyShape(.ellipse),
                            ])
                    ) { $0.clipShape($1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/BlurEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let blur = CatalogEntry(
        id: "blur",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View をぼかして描く modifier（ガウスぼかし）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/blur(radius:opaque:)")!,
        stage: .card,
        properties: [
            .modifier("blur", label: "radius", .slider(range: 0...20, step: 1, initial: 4), on: true, summary: "ぼかしの半径")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .font(.system(size: 48, weight: .bold))"], call: ".background",
            fixedArguments: [".yellow"]),
        build: { v in
            AnyView(
                Text("見本")
                    .font(.system(size: 48, weight: .bold))
                    .background(.yellow)
                    .apply(v.number("blur")) { $0.blur(radius: $1) }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ShadowEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let shadow = CatalogEntry(
        id: "shadow",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の後ろに影を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:)")!,
        stage: .card,
        properties: [
            .modifier(
                "shadow", id: "shadow.color", label: "color", .color(initial: 7), on: true,
                summary: "影の色（OFF なら半透明の黒）"),
            .modifier(
                "shadow", id: "shadow.radius", label: "radius", .slider(range: 0...20, step: 2, initial: 8),
                required: true, summary: "影のぼかしの半径"),
            .modifier(
                "shadow", id: "shadow.x", label: "x", .slider(range: -20...20, step: 2, initial: 8), on: true,
                summary: "影を横にずらす距離"),
            .modifier(
                "shadow", id: "shadow.y", label: "y", .slider(range: -20...20, step: 2, initial: 8), on: true,
                summary: "影を縦にずらす距離"),
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 16)", "    .fill(.yellow)"], call: ".frame",
            fixedArguments: ["width: 160", "height: 80"]),
        build: { v in
            let color = v.color("shadow.color")
            let x = v.number("shadow.x").map { CGFloat($0) }
            let y = v.number("shadow.y").map { CGFloat($0) }
            let hasShadow = color != nil || x != nil || y != nil
            return AnyView(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.yellow)
                    .frame(width: 160, height: 80)
                    .apply(hasShadow ? () : nil) { view, _ in
                        view.shadow(
                            color: color ?? Color(.sRGBLinear, white: 0, opacity: 0.33),
                            radius: CGFloat(v.number("shadow.radius") ?? 0), x: x ?? 0, y: y ?? 0)
                    }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .transformEffect,
        .projectionEffect,
        .mask,
        .clipped,
        .clipShape,
        .blur,
        .shadow,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/DrawingAndGraphics/TransformEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ProjectionEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/MaskEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ClippedEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ClipShapeEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/BlurEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/ShadowEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: transformEffect・projectionEffect・mask・clipped・clipShape・blur・shadow を収録する"
```

---

### Task 6: 合成と大きさの読み取り（visualEffect・blendMode・compositingGroup・drawingGroup・GeometryReader・onGeometryChange）

`visualEffect` は見本の中に ScrollView を置くので、テストの `ImageRenderer` では白く描かれる（エラーにはならない）。見た目は Task 7 のスクリーンショットで見る。

**Files:**
- Create: `WidgetLab/Catalog/DrawingAndGraphics/VisualEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/BlendModeEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/CompositingGroupEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/DrawingGroupEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/GeometryReaderEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/OnGeometryChangeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.visualEffect`、`CatalogEntry.blendMode`、`CatalogEntry.compositingGroup`、`CatalogEntry.drawingGroup`、`CatalogEntry.geometryReader`、`CatalogEntry.onGeometryChange`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drawing-and-graphics`
Expected: 終了コード 1。抜けに visualEffect・blendMode・compositingGroup・drawingGroup・GeometryReader・onGeometryChange がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DrawingAndGraphics/VisualEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let visualEffect = CatalogEntry(
        id: "visualEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の場所と大きさ（GeometryProxy）から、見た目の効果を決めてかける modifier。並びは変わらない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/visualeffect(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "visualEffect",
                .choice(
                    [
                        Choice(
                            "色を回す",
                            code:
                                "{ content, proxy in content.hueRotation(.degrees(proxy.frame(in: .scrollView).minY)) }"
                        ),
                        Choice(
                            "ずらす",
                            code: "{ content, proxy in content.offset(x: proxy.frame(in: .scrollView).minY / 4) }"),
                        Choice(
                            "ぼかす",
                            code:
                                "{ content, proxy in content.blur(radius: max(0, proxy.frame(in: .scrollView).minY / 40)) }"
                        ),
                    ],
                    initial: 0),
                on: true, summary: "かける効果（スクロールの枠の中の縦の位置で変える）")
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(0..<20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)",
            ],
            indent: 12, call: ".background", fixedArguments: [".yellow"], closing: ["    }", "}"]),
        build: { v in
            let effect = v.pick("visualEffect", from: [0, 1, 2])
            return AnyView(
                ScrollView {
                    ForEach(0..<20, id: \.self) { i in
                        VisualEffectDemo.row(
                            Text("行 \(i)").frame(maxWidth: .infinity).background(.yellow), effect: effect)
                    }
                }
            )
        }
    )
}

private enum VisualEffectDemo {
    @ViewBuilder
    static func row(_ view: some View, effect: Int?) -> some View {
        switch effect {
        case 0: view.visualEffect { content, proxy in content.hueRotation(.degrees(proxy.frame(in: .scrollView).minY)) }
        case 1: view.visualEffect { content, proxy in content.offset(x: proxy.frame(in: .scrollView).minY / 4) }
        case 2:
            view.visualEffect { content, proxy in content.blur(radius: max(0, proxy.frame(in: .scrollView).minY / 40)) }
        default: view
        }
    }
}
```

`WidgetLab/Catalog/DrawingAndGraphics/BlendModeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let blendMode = CatalogEntry(
        id: "blendMode",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、後ろに描いたものとどう混ぜて描くか（合成の方法）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/blendmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "blendMode",
                .choice(
                    [Choice(".multiply"), Choice(".screen"), Choice(".difference"), Choice(".overlay")], initial: 0),
                on: true, summary: "混ぜ方（.multiply は掛けて暗く、.screen は明るく、.difference は差）")
        ],
        code: CodeTemplate(
            prefix: [
                "ZStack {", "    Circle()", "        .fill(.yellow)", "        .frame(width: 100, height: 100)",
                "        .offset(x: -30)", "    Circle()", "        .fill(.blue)",
            ],
            indent: 8, call: ".frame", fixedArguments: ["width: 100", "height: 100"], suffix: [".offset(x: 30)"],
            closing: ["}"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 100, height: 100)
                        .offset(x: -30)
                    Circle()
                        .fill(.blue)
                        .frame(width: 100, height: 100)
                        .apply(v.pick("blendMode", from: [BlendMode.multiply, .screen, .difference, .overlay])) {
                            $0.blendMode($1)
                        }
                        .offset(x: 30)
                }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/CompositingGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let compositingGroup = CatalogEntry(
        id: "compositingGroup",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の View を 1 枚の絵に合成してから、あとの効果（不透明度など）をかける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/compositinggroup()")!,
        stage: .card,
        properties: [
            .modifier(
                "compositingGroup", .fixed(code: ""), on: true,
                summary: "1 枚に合成してから透かす（OFF なら円ごとに透け、重なりが見える）")
        ],
        code: CodeTemplate(
            call: "ZStack",
            trailing: " {\n    Circle().fill(.red).frame(width: 100, height: 100).offset(x: -30)\n"
                + "    Circle().fill(.blue).frame(width: 100, height: 100).offset(x: 30)\n}",
            suffix: [".opacity(0.5)"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle().fill(.red).frame(width: 100, height: 100).offset(x: -30)
                    Circle().fill(.blue).frame(width: 100, height: 100).offset(x: 30)
                }
                .apply(v.flag("compositingGroup")) { view, _ in view.compositingGroup() }
                .opacity(0.5)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/DrawingGroupEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let drawingGroup = CatalogEntry(
        id: "drawingGroup",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の View を、画面に出す前に 1 枚の画像に描いてから合成する modifier（Metal で描く）。枠の外は描かれない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/drawinggroup(opaque:colormode:)")!,
        stage: .card,
        properties: [
            .modifier(
                "drawingGroup", label: "opaque", .toggle(initial: false), on: true,
                summary: "不透明として描く（true なら描いていないところが黒くなる）")
        ],
        code: CodeTemplate(
            prefix: [
                "ZStack {", "    Circle()", "        .fill(.yellow)", "        .frame(width: 80, height: 80)",
                "        .offset(x: -50)", "}",
            ],
            indent: 0, call: ".frame", fixedArguments: ["width: 120", "height: 80"]),
        build: { v in
            AnyView(
                ZStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 80, height: 80)
                        .offset(x: -50)
                }
                .frame(width: 120, height: 80)
                .apply(v.flag("drawingGroup")) { $0.drawingGroup(opaque: $1) }
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/GeometryReaderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let geometryReader = CatalogEntry(
        id: "GeometryReader",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "置かれた枠いっぱいに広がり、その大きさと場所（GeometryProxy）を中身に渡す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/geometryreader")!,
        stage: .card,
        properties: [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 80...280, step: 20, initial: 200), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 40...200, step: 20, initial: 100),
                on: true,
                summary: "枠の高さ"),
        ],
        code: CodeTemplate(
            call: "GeometryReader",
            trailing: " { proxy in\n    Circle()\n        .fill(.yellow)\n"
                + "        .frame(width: min(proxy.size.width, proxy.size.height))\n"
                + "    Text(\"\\(Int(proxy.size.width)) × \\(Int(proxy.size.height))\")\n}"),
        build: { v in
            AnyView(
                GeometryReader { proxy in
                    Circle()
                        .fill(.yellow)
                        .frame(width: min(proxy.size.width, proxy.size.height))
                    Text("\(Int(proxy.size.width)) × \(Int(proxy.size.height))")
                }
                .frame(
                    width: v.number("frame.width").map { CGFloat($0) },
                    height: v.number("frame.height").map { CGFloat($0) }
                )
                .border(.secondary)
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/OnGeometryChangeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onGeometryChange = CatalogEntry(
        id: "onGeometryChange",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の大きさや場所から取り出した値が変わったときに、処理を呼ぶ modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ongeometrychange(for:of:action:)")!,
        stage: .card,
        properties: [
            .argument(
                "of",
                .choice(
                    [
                        Choice("幅", code: "{ proxy in proxy.size.width }"),
                        Choice("高さ", code: "{ proxy in proxy.size.height }"),
                        Choice("左端の x", code: "{ proxy in proxy.frame(in: .global).minX }"),
                    ],
                    initial: 0),
                required: true, summary: "取り出す値（GeometryProxy から計算する）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"], call: ".onGeometryChange",
            fixedArguments: ["for: CGFloat.self"], trailing: " { value in\n        self.value = value\n    }"),
        build: { v in
            AnyView(
                GeometryChangeDemo(
                    measure: v.pick("of", from: GeometryChangeDemo.measures) ?? GeometryChangeDemo.measures[0]))
        }
    )
}

private struct GeometryChangeDemo: View {
    static let measures: [@Sendable (GeometryProxy) -> CGFloat] = [
        { proxy in proxy.size.width }, { proxy in proxy.size.height }, { proxy in proxy.frame(in: .global).minX },
    ]

    let measure: @Sendable (GeometryProxy) -> CGFloat
    @State private var value: CGFloat?

    var body: some View {
        VStack(spacing: 12) {
            Text("見本")
                .padding()
                .background(.yellow)
                .onGeometryChange(for: CGFloat.self, of: measure) { value = $0 }
            Text(value.map { "value = \(Int($0))" } ?? "まだ呼ばれていない")
                .font(.callout.monospacedDigit())
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .visualEffect,
        .blendMode,
        .compositingGroup,
        .drawingGroup,
        .geometryReader,
        .onGeometryChange,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/DrawingAndGraphics/VisualEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/BlendModeEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/CompositingGroupEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/DrawingGroupEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/GeometryReaderEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/OnGeometryChangeEntry.swift \
  WidgetLab/Catalog/Catalog.swift
git commit -m "feat: visualEffect・blendMode・compositingGroup・drawingGroup・GeometryReader・onGeometryChange を収録する"
```

---

### Task 7: シェーダー（colorEffect・distortionEffect・layerEffect）と束の確かめ

`Shaders.metal` は 4 つのシェーダー関数（`stripes`・`threshold`・`wave`・`pixelate`）を持ち、`ShaderLibrary.<関数名>` で呼ぶ。フォルダの同期で、置くだけでアプリのターゲットに入る。ビルドに Metal Toolchain が要る（Global Constraints）。

**Files:**
- Create: `WidgetLab/Catalog/DrawingAndGraphics/Shaders.metal`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/ColorEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/DistortionEffectEntry.swift`
- Create: `WidgetLab/Catalog/DrawingAndGraphics/LayerEffectEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `CLAUDE.md`（Metal Toolchain の 1 行）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（束 4 でわかったこと）

**Interfaces:**
- Consumes: 収録の型（変えない）: `CatalogEntry(id:kind:topic:summary:docURL:stage:properties:code:build:)`、`.note` は `CatalogEntry(id:kind:topic:summary:docURL:noteReason:properties:code:)`、`PropertySpec.argument(_:unlabeled:_:on:required:summary:)`、`PropertySpec.modifier(_:id:label:line:_:on:required:summary:)`、`CodeTemplate(prefix:indent:call:fixedArguments:trailing:suffix:closing:wrapper:)`、`View.apply(_:_:)`
- Produces: `CatalogEntry.colorEffect`、`CatalogEntry.distortionEffect`、`CatalogEntry.layerEffect`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drawing-and-graphics`
Expected: 終了コード 1。抜けに colorEffect・distortionEffect・layerEffect がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DrawingAndGraphics/Shaders.metal`:

```metal
// colorEffect・distortionEffect・layerEffect の見本で使うシェーダー（ShaderLibrary.default から呼ぶ）
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// colorEffect: width の幅ごとの横縞で、1 本おきに暗くする
[[ stitchable ]] half4 stripes(float2 position, half4 color, float width) {
    bool dark = fmod(floor(position.y / width), 2.0) == 1.0;
    return dark ? half4(color.rgb * 0.4h, color.a) : color;
}

// colorEffect: 明るさが level より上なら白、下なら黒にする
[[ stitchable ]] half4 threshold(float2 position, half4 color, float level) {
    half luminance = dot(color.rgb, half3(0.299h, 0.587h, 0.114h));
    half value = luminance > half(level) * color.a ? color.a : 0.0h;
    return half4(value, value, value, color.a);
}

// distortionEffect: 横に進む波で、縦にずらした場所の色を取る
[[ stitchable ]] float2 wave(float2 position, float amplitude, float wavelength) {
    return float2(position.x, position.y + amplitude * sin(position.x / wavelength * 2.0 * M_PI_F));
}

// layerEffect: size の升ごとに、升の中央の色で塗る
[[ stitchable ]] half4 pixelate(float2 position, SwiftUI::Layer layer, float size) {
    float2 cell = (floor(position / size) + 0.5) * size;
    return layer.sample(cell);
}
```

`WidgetLab/Catalog/DrawingAndGraphics/ColorEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let colorEffect = CatalogEntry(
        id: "colorEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "点ごとの色を、Metal のシェーダーで計算し直して描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/coloreffect(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "colorEffect", id: "colorEffect.shader",
                .choice(
                    [
                        Choice("細い縞", code: "ShaderLibrary.stripes(.float(6))"),
                        Choice("太い縞", code: "ShaderLibrary.stripes(.float(16))"),
                        Choice("白と黒", code: "ShaderLibrary.threshold(.float(0.5))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（Shaders.metal の関数と引数）"),
            .modifier(
                "colorEffect", id: "colorEffect.isEnabled", label: "isEnabled", .toggle(initial: true), on: true,
                summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            let shader = v.pick(
                "colorEffect.shader",
                from: [
                    ShaderLibrary.stripes(.float(6)), ShaderLibrary.stripes(.float(16)),
                    ShaderLibrary.threshold(.float(0.5)),
                ])
            return AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.flag("colorEffect.isEnabled")) {
                        $0.colorEffect(shader ?? ShaderLibrary.stripes(.float(6)), isEnabled: $1)
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/DistortionEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let distortionEffect = CatalogEntry(
        id: "distortionEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "点ごとに、色を取ってくる場所を Metal のシェーダーで計算し、View をゆがめて描く modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/distortioneffect(_:maxsampleoffset:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "distortionEffect", id: "distortionEffect.shader",
                .choice(
                    [
                        Choice("小さい波", code: "ShaderLibrary.wave(.float(4), .float(40))"),
                        Choice("大きい波", code: "ShaderLibrary.wave(.float(10), .float(60))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（振れ幅と波長）"),
            .modifier(
                "distortionEffect", id: "distortionEffect.maxSampleOffset", label: "maxSampleOffset",
                .fixed(code: "CGSize(width: 0, height: 10)"), required: true,
                summary: "元の場所から、どれだけ離れた点の色を取るか（の上限）"),
            .modifier(
                "distortionEffect", id: "distortionEffect.isEnabled", label: "isEnabled", .toggle(initial: true),
                on: true, summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"Widget Lab\")", "    .font(.system(size: 40, weight: .bold))"], call: ".padding",
            fixedArguments: [".vertical", "10"]),
        build: { v in
            let shader = v.pick(
                "distortionEffect.shader",
                from: [ShaderLibrary.wave(.float(4), .float(40)), ShaderLibrary.wave(.float(10), .float(60))])
            return AnyView(
                Text("Widget Lab")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.vertical, 10)
                    .apply(v.flag("distortionEffect.isEnabled")) {
                        $0.distortionEffect(
                            shader ?? ShaderLibrary.wave(.float(4), .float(40)),
                            maxSampleOffset: CGSize(width: 0, height: 10), isEnabled: $1)
                    }
            )
        }
    )
}
```

`WidgetLab/Catalog/DrawingAndGraphics/LayerEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let layerEffect = CatalogEntry(
        id: "layerEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を 1 枚の絵（Layer）にしてシェーダーに渡し、ほかの点の色も使って描き直す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/layereffect(_:maxsampleoffset:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layerEffect", id: "layerEffect.shader",
                .choice(
                    [
                        Choice("細かい升", code: "ShaderLibrary.pixelate(.float(6))"),
                        Choice("粗い升", code: "ShaderLibrary.pixelate(.float(14))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（升の大きさ）"),
            .modifier(
                "layerEffect", id: "layerEffect.maxSampleOffset", label: "maxSampleOffset",
                .fixed(code: "CGSize(width: 7, height: 7)"),
                required: true, summary: "元の場所から、どれだけ離れた点の色を取るか（の上限）"),
            .modifier(
                "layerEffect", id: "layerEffect.isEnabled", label: "isEnabled", .toggle(initial: true), on: true,
                summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .font(.system(size: 80))"], call: ".foregroundStyle",
            fixedArguments: [".blue"]),
        build: { v in
            let shader = v.pick(
                "layerEffect.shader", from: [ShaderLibrary.pixelate(.float(6)), ShaderLibrary.pixelate(.float(14))])
            return AnyView(
                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .apply(v.flag("layerEffect.isEnabled")) {
                        $0.layerEffect(
                            shader ?? ShaderLibrary.pixelate(.float(6)), maxSampleOffset: CGSize(width: 7, height: 7),
                            isEnabled: $1)
                    }
            )
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す:

```swift
        .colorEffect,
        .distortionEffect,
        .layerEffect,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `testLayoutEntriesShowPreview` のあと（`/// 起動して、検索の結果から詳細を開く` の前、空の行を 1 つはさむ）に足す。ScrollView の代表（visualEffect）とシェーダーの代表（colorEffect）を撮る:

```swift
    @MainActor
    func testDrawingEntriesShowPreview() {
        for (id, title) in [("visualEffect", ".visualEffect"), ("colorEffect", ".colorEffect")] {
            let app = openDetail(searching: id, entryID: id, title: title)
            attachScreenshot(app, name: id)
            app.terminate()
        }
    }
```

- [ ] **Step 5: 文書を直す**

次の 4 か所を、左の文字列（ファイルの中に 1 つだけある）から右の文字列に置き換える。

`CLAUDE.md` の

```markdown
- Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）。外部のパッケージは使わない
```

を

```markdown
- Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）。外部のパッケージは使わない
- シェーダー（`WidgetLab/Catalog/DrawingAndGraphics/Shaders.metal`）のビルドに Metal Toolchain が要る。Xcode 27 には入っていないので、`xcrun metal --version` が失敗するなら `xcodebuild -downloadComponent MetalToolchain` を一度実行する
```

にする。

`docs/architecture.md` の

```markdown
レイアウトの代表 2 件のスクリーンショットの 4 本）
```

を

```markdown
レイアウトの代表 2 件のスクリーンショット、描画の代表 2 件のスクリーンショットの 5 本）
```

にする。

`docs/cataloging-guide.md` の

```markdown
チップとコードはふつうに動く。迷ったら束の計画で 1 件ずつ決める。
```

を

```markdown
チップとコードはふつうに動く。迷ったら束の計画で 1 件ずつ決める。束 4 では `materialActiveAppearance` を `.note` にした（iOS では `.inactive` が使えず、窓もいつも手前にあるので、見た目が変わらない）。
```

にする。

`docs/cataloging-guide.md` の

```markdown
## 用語
```

を

```markdown
**かける相手の modifier のあとに、付け外しの modifier を並べたい → `call` を相手の最後の modifier にする。** prefix に相手の View を書き、`call: ".frame", fixedArguments: ["width: 200", "height: 80"]` のようにすると、ON の modifier はその下に同じ桁で並ぶ（束 4 の `brightness` ほか色の modifier・`clipped`・`shadow`）。

**複数の収録で使う補助がある → トピックのフォルダに `<名前>Demo.swift` で置く。** `Entry` で終わらない名前にすれば、`catalog_progress.py` は数えない（束 4 の `ShapeStyleDemo`・`ScaledToDemo`）。

**シェーダーを使う → `Catalog/DrawingAndGraphics/Shaders.metal` に関数を足し、`ShaderLibrary.<関数名>(…)` で呼ぶ。** ビルドに Metal Toolchain が要る（swiftui/CLAUDE.md）。シェーダーと `maxSampleOffset` は required にし、`isEnabled` を付け外しの相手にする。シェーダーを OFF にできると `.colorEffect(isEnabled: true)` という書けないコードになるため。

**ImageRenderer の画像に出ない効き目がある → シミュレータで撮る。** ScrollView・List・Form のほか、`Canvas(opaque: true)` の黒い地と、`drawingGroup` が枠の外を描かないことも、テストの画像には出ず、シミュレータでは出た。

**比べるで違いが見えない → 効き目を左半分に出す。** 比べるは左半分が「付けない」側になる。`drawingGroup` の円は、はじめ枠の右にはみ出させていて違いが見えなかったので、左にはみ出させた。

## 用語
```

にする。

- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テスト（6 本）が全部通る

Run: `python3 tools/catalog_progress.py drawing-and-graphics shapes`
Expected: 終了コード 0。`合計 43 / 43（抜け 0）`

- [ ] **Step 7: スクリーンショットを見る**

Run: `rm -rf build/shots && xcrun xcresulttool export attachments --path <最新の build/Logs/Test/*.xcresult> --output-path build/shots`
Expected: `build/shots/manifest.json` で名前が `visualEffect`・`colorEffect` の画像を開く。`visualEffect` は黄色の行が下へ行くほど緑・水色・紫と色が回っている。`colorEffect` は虹色の帯に、黒っぽい横縞が 1 本おきに入っている

- [ ] **Step 8: コミット**

```bash
git add WidgetLab/Catalog/DrawingAndGraphics/Shaders.metal \
  WidgetLab/Catalog/DrawingAndGraphics/ColorEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/DistortionEffectEntry.swift \
  WidgetLab/Catalog/DrawingAndGraphics/LayerEffectEntry.swift \
  WidgetLab/Catalog/Catalog.swift \
  WidgetLabUITests/LaunchUITests.swift \
  CLAUDE.md \
  docs/architecture.md \
  docs/cataloging-guide.md
git commit -m "feat: colorEffect・distortionEffect・layerEffect を収録し、描画の代表のスクリーンショットを撮る"
```


## 終わったら

- 束の最終レビュー（opus）を通す。指摘を直したら、`~/dev/widget-lab`（main）で `--no-ff` でマージし、main で lint と単体テストを通してから push する（ブランチは消さない）。マージの前に `git -C ~/dev/widget-lab status` がきれいなことと、ほかの束がマージの途中でないことを確かめる。`Catalog.swift`・`LaunchUITests.swift`・`docs/architecture.md`・収録の手引きがぶつかったら、両方の行を残す
