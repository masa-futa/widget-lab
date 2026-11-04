# SwiftUI 版 Phase 3 束 10（入力）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** gestures・input-events・drag-and-drop の 43 件を収録して、3 トピックの抜けを 0 にする。

**Architecture:** 1 件 = 1 ファイルの収録データを 4〜7 件ずつ足し、`Catalog.all` に並べる。複数の収録で使う補助（`GestureDemo`・`DragAndDropDemo`）はトピックのフォルダに置く。収録の型（`WidgetLab/Catalog/Model/`）と `CodeGenerator` は変えない。stage は `.card` が 22 件、`.behavior` が 11 件、`.full` が 1 件、`.note` が 9 件。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md`（束の表の 10 行目と「進め方」）。書き方は `swiftui/docs/cataloging-guide.md`（収録の手引き）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- シミュレータは **iPhone 18 Pro**（iOS 27.0）を使う。swiftui/CLAUDE.md のコマンドの `name=iPhone 17` は、この束では `name=iPhone 18 Pro` に置き換える（並列で動く束 8・9 と分けるため）
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
  UI テストまで通すのは Task 7 だけ（`-only-testing:WidgetLabTests` を外す）。xcodebuild の出力は長いので、ファイルに出して、結果は `xcrun xcresulttool get test-results summary --path <最新の build/Logs/Test/*.xcresult> --compact` の `result`・`failedTests` で読む（`build/` がなければ先に `mkdir -p build`）
- テストが進まず止まったら: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。最初のビルドとシミュレータの複製で 5〜10 分かかることがある
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` から始める。末尾に `Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>` を付ける（実装したモデルを正しく書く。例: `Claude Haiku 5.5`）

---

## 1 件ずつの表

「形」は収録の手引きの 4 章の 3 つ（View・引数・付け外し）。ジェスチャーの型（kind が gesture）は、`TapGesture` と同じく「かける相手 → `.gesture(型(引数).onEnded …)`」の形にし、型の引数を `.argument` にする（表では「View」）。プロパティはチップの順。* は最初から ON、R は required。

### gestures（21 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| onTapGesture | .behavior | 引数 | count*（1〜3、最初は 2） | `RoundedRectangle(cornerRadius: 12)` `.onTapGesture(count: 2) { print("タップ") }` |
| SpatialTapGesture | .card | View | count*（2）・coordinateSpace（.local・.global） | `Rectangle()` `.gesture(SpatialTapGesture(count: 2).onEnded { location = $0.location })`。押した所に点を置き、座標を出す |
| onLongPressGesture | .behavior | 引数 | minimumDuration*（0.5〜3、1.5）・maximumDistance・perform R・onPressingChanged* | `….onLongPressGesture(minimumDuration: 1.5, perform: { … }, onPressingChanged: { pressing in … })` |
| LongPressGesture | .behavior | View | minimumDuration*（1.5）・maximumDistance | `….gesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in print("長押し") })` |
| SpatialEventGesture | .card | View | coordinateSpace（.local・.global） | `Rectangle()` `.gesture(SpatialEventGesture().onChanged { … }.onEnded { … })`。触れている指ごとに丸を出す |
| gesture | .behavior | 付け外し | .gesture*（2 回タップ）・.gesture(isEnabled:) R | `RoundedRectangle(cornerRadius: 12)` `.gesture(TapGesture(count: 2).onEnded { … }, isEnabled: true)` |
| DragGesture | .card | View | minimumDistance*（0〜60、40） | `….offset(offset)` `.gesture(DragGesture(minimumDistance: 40).onChanged { offset = $0.translation })` |
| MagnifyGesture | .card | View | minimumScaleDelta*（0〜0.5、0.3） | `Image(systemName: "leaf.fill").scaleEffect(scale)` `.gesture(MagnifyGesture(minimumScaleDelta: 0.3).onChanged { … })` |
| RotateGesture | .card | View | minimumAngleDelta*（.degrees(1)・(20)・(45)、最初は 20） | `Image(systemName: "arrow.up").rotationEffect(angle)` `.gesture(RotateGesture(minimumAngleDelta: .degrees(20)).onChanged { … })` |
| onPencilDoubleTap | .note | 付け外し | .onPencilDoubleTap*（固定） | `Text("ペンで描く").onPencilDoubleTap(perform: { _ in … })` |
| onPencilSqueeze | .note | 付け外し | .onPencilSqueeze*（固定） | `Text("ペンで描く").onPencilSqueeze(perform: { phase in … })` |
| simultaneousGesture | .behavior | 付け外し | .simultaneousGesture*（外側のタップ）・including R（.all・.gesture・.subviews・.none） | `VStack { Text("内側").onTapGesture { … } }` `.simultaneousGesture(TapGesture().onEnded { print("外側") }, including: .all)` |
| SequenceGesture | .card | View | gestures R（長押し 0.5 秒・1.5 秒 → ドラッグ） | `….gesture(SequenceGesture(LongPressGesture(minimumDuration: 0.5), DragGesture()).onChanged { … })`。長押しが成り立つと橙になり、そのまま引くと動く |
| SimultaneousGesture | .card | View | gestures R（`MagnifyGesture(), RotateGesture()` 固定） | `….gesture(SimultaneousGesture(MagnifyGesture(), RotateGesture()).onChanged { … })` |
| ExclusiveGesture | .behavior | View | gestures R（2 回タップが先・1 回タップが先） | `….gesture(ExclusiveGesture(TapGesture(count: 2), TapGesture()).onEnded { print($0) })` |
| highPriorityGesture | .behavior | 付け外し | .highPriorityGesture*（外側のタップ）・including R | simultaneousGesture と同じ形で `.highPriorityGesture(…, including: .all)` |
| handGestureShortcut | .note | 付け外し | .handGestureShortcut*（`.primaryAction`） | `Button("再生") { }.handGestureShortcut(.primaryAction)` |
| defersSystemGestures | .full | 付け外し | .defersSystemGestures(on:)*（.bottom・.top・.all） | `Color.yellow.defersSystemGestures(on: .bottom).ignoresSafeArea().gesture(DragGesture()…)` |
| GestureState | .card | ラッパー | @GestureState* | `@GestureState private var offset` と `DragGesture().updating($offset)`。外すと `@State` と `onChanged` になり、離しても戻らない |
| MagnificationGesture | .card | View | minimumScaleDelta*（0.3） | MagnifyGesture と同じ形で `MagnificationGesture(minimumScaleDelta: 0.3).onChanged { scale = $0 }` |
| RotationGesture | .card | View | minimumAngleDelta*（.degrees(20)） | RotateGesture と同じ形で `RotationGesture(minimumAngleDelta: .degrees(20)).onChanged { angle = $0 }` |

### input-events（12 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| onKeyPress | .behavior | 付け外し | .onKeyPress(phases:) R（.down・.up・.all）・.onKeyPress*（action） | `TextField("キーを押す", text: $text).onKeyPress(phases: .down, action: { press in …; return .ignored })` |
| keyboardShortcut | .behavior | 付け外し | .keyboardShortcut*（"s"・"d"・.return）・.keyboardShortcut(modifiers:) R | `Button("保存") { … }.keyboardShortcut("s", modifiers: .command)` |
| onHover | .note | 付け外し | .onHover*（固定） | `Text("ポインタを乗せる").onHover(perform: { hovering in … })` |
| hoverEffect | .note | 付け外し | .hoverEffect*（.automatic・.highlight・.lift、最初は .lift） | `Button("保存") { }.hoverEffect(.lift)` |
| hoverEffectDisabled | .note | 付け外し | .hoverEffectDisabled*（true） | `Button("保存") { }.hoverEffect(.lift).hoverEffectDisabled(true)` |
| defaultHoverEffect | .note | 付け外し | .defaultHoverEffect*（最初は .highlight） | `HStack { Button…; Button… }.defaultHoverEffect(.highlight)` |
| onContinuousHover | .note | 付け外し | .onContinuousHover(coordinateSpace:) R・.onContinuousHover*（perform） | `Rectangle().onContinuousHover(coordinateSpace: .local, perform: { phase in … }).frame(…)` |
| onSubmit | .behavior | 付け外し | .onSubmit(of:) R（.text・.search）・.onSubmit* | `TextField("名前", text: $name).onSubmit(of: .text, { print("送った") })` |
| submitScope | .behavior | 付け外し（入れ子） | .submitScope*（true） | `VStack { TextField("名前"); TextField("メモ").submitScope(true) }.onSubmit { … }` |
| submitLabel | .card | 付け外し | .submitLabel*（9 つ、最初は .send） | `TextField("メッセージ", text: $message).submitLabel(.send)` |
| contentShape | .card | 付け外し | .contentShape*（.rect・.capsule・Circle()） | `HStack { Image; Spacer(); Text("右の端") }.frame(width: 240, height: 64).contentShape(.rect).onTapGesture { count += 1 }` |
| onCameraCaptureEvent | .note | 引数 | isEnabled・action R | `CameraPreview(session: session)` `.onCameraCaptureEvent(action: { event in … })` |

### drag-and-drop（10 件）

| id | stage | 形 | プロパティ | コードの形（最初の値） |
|---|---|---|---|---|
| dragConfiguration | .card | 付け外し（入れ子） | .dragConfiguration*（動かせる・写すだけ） | `Text("りんご").draggable("りんご").dragConfiguration(DragConfiguration(allowMove: true)).onDragSessionUpdated { … }`。箱は `.dropConfiguration { _ in DropConfiguration(operation: .move) }` |
| dropConfiguration | .card | 付け外し（入れ子） | .dropConfiguration*（.move・.copy・.forbidden） | 箱の `….dropDestination(for: String.self) { … }.dropConfiguration({ _ in DropConfiguration(operation: .move) })` |
| dragContainer | .card | 付け外し | .dragContainer(for:) R・.dragContainer* | `HStack { ForEach(fruits) { Text(fruit.id).draggable(containerItemID: fruit.id) } }.dragContainer(for: Fruit.self, { ids in … })` |
| dragContainerSelection | .card | 付け外し | .dragContainerSelection*（`selection`） | 同じ形で `.dragContainer(…)` の下に `.dragContainerSelection(selection)`。札を押して選ぶ |
| draggable | .card | 付け外し（入れ子） | .draggable*（文字、最初は "りんご"） | `VStack { Text("りんご").draggable("りんご"); Text(dropped…).dropDestination(for: String.self) { … } }` |
| itemProvider | .card | 付け外し（入れ子） | .itemProvider*（固定） | `List(fruits, id: \.self) { name in Text(name).itemProvider({ NSItemProvider(object: name as NSString) }) }` |
| onDrag | .card | 付け外し（入れ子） | .onDrag*（固定） | draggable と同じ形で `.onDrag({ NSItemProvider(object: "みかん" as NSString) })` |
| onDrop | .card | 付け外し（入れ子） | .onDrop(of:) R（[.text]・[.image]）・.onDrop(isTargeted:) R（$isTargeted・nil）・.onDrop*（perform） | 箱の `….frame(width: 200, height: 72).onDrop(of: [.text], isTargeted: $isTargeted, perform: { … })` |
| reorderContainer | .card | 付け外し | .reorderContainer(for:) R・.reorderContainer(isEnabled:) R・.reorderContainer*（move） | `HStack { ForEach(fruits) { Text(fruit.id) }.reorderable() }.reorderContainer(for: Fruit.self, isEnabled: true, move: { … })` |
| springLoadingBehavior | .card | 付け外し（入れ子） | .springLoadingBehavior*（.enabled・.disabled・.automatic、最初は .enabled） | `VStack { Text("りんご").draggable("りんご"); Button("開いた回数: \(count)") { … }.springLoadingBehavior(.enabled) }` |

### `.full` にするもの（1 件）と理由

`defersSystemGestures` は、表示の単位（ホストの画面）がシステムに「端の操作を後回しにする」と伝える modifier で、束 3 の `statusBarHidden` と同じく、詳細の枠の中からでは効かない。全画面で開けば、その表示の単位で効く。

### `.note` にするもの（9 件、21%）と理由

| id | 理由（`noteReason`） |
|---|---|
| onPencilDoubleTap | iPhone では Apple Pencil が使えない。iPad で、ダブルタップに対応した Apple Pencil を使うときに効く |
| onPencilSqueeze | iPhone では Apple Pencil が使えない。iPad で、Apple Pencil Pro を使うときに効く |
| handGestureShortcut | iPhone では効かない。Apple Watch で、指を 2 回合わせる（ダブルタップ）とボタンが押される |
| onHover | iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く |
| hoverEffect | iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く |
| hoverEffectDisabled | iPhone にはポインタがないので、もともと効果が出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く |
| defaultHoverEffect | iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く |
| onContinuousHover | iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く |
| onCameraCaptureEvent | カメラで撮影している（AVCaptureSession が動いている）画面で効く。このアプリには撮影の画面がなく、シミュレータにはカメラもない |

手引きの 3 章の数え方（iPhone では効かないと公式か試作で確かめたものは数えない）で数えるのは `onCameraCaptureEvent` の 1 件だけ（iPhone で効くが、撮影の画面とカメラが要る）。ほかの 8 件は、Apple Pencil・Apple Watch・ポインタのない iPhone では効かないと公式に書かれている。

### 試作でわかったこと（Task 7 で収録の手引きに足す）

- **ジェスチャーとキーの入力は `.behavior` で記録に出し、動きが見えるもの（ドラッグ・拡大・回転）は `.card` にした。** UI テストでは `doubleTap()`・`press(forDuration:)`・`pinch(withScale:velocity:)`・`rotate(_:withVelocity:)` で操作して撮れた。シミュレータはハードウェアキーボードがつながっているので、`onKeyPress`・`keyboardShortcut` は `typeKey(_:modifierFlags:)` で試せる（代わりに、入力欄をタップしてもキーボードは出ない。`submitLabel` は束 2 の `keyboardType` と同じく、入力欄にカーソルが入るところまで見た）
- **ドラッグとドロップは iPhone のアプリの中で動く。** UI テストでは `press(forDuration: 1, thenDragTo: 箱, withVelocity: .slow, thenHoldForDuration: 1)` で札を箱に落とせた。`dragConfiguration`・`dropConfiguration` の「動かす」は、元の札が消えることで見せる（`onDragSessionUpdated` で `.ended(.move)` を見る）
- **`dragContainerSelection` は `dragContainer` の外側（あと）にかける。** 内側にかけると、選んでいても引いた札 1 つしか運ばれなかった
- **ジェスチャーの組み合わせの型（`SequenceGesture`・`SimultaneousGesture`・`ExclusiveGesture`）は、2 つのジェスチャーを 1 つの名前なしの引数（required）の選択肢にした。** 片方だけでは書けず、`onChanged` の中身が組によって変わるため。比べるは出ない
- **id の頭を小文字にすると、ほかの id とぶつかるものがある。** `SimultaneousGesture`（型）と `simultaneousGesture`（modifier）。型の側の `static let` を `simultaneousGestureType` にした
- **最初の値が「付けない」と同じ効き目だと、比べるで違いが出ない。** `springLoadingBehavior` は、付けない（`.automatic`）と `.disabled` がどちらもボタンを押さなかったので、最初の値を `.enabled` にした
- **的に `.accessibilityAddTraits(.isButton)` を付けると、UI テストでは `app.buttons[…]` で探す。** 拡大・回転の画像には `.accessibilityLabel`（「葉」「矢印」）を付けて、`app.images[…]` で探した

---
### Task 1: onTapGesture・SpatialTapGesture・onLongPressGesture・LongPressGesture・SpatialEventGesture・gesture・DragGesture

**Files:**
- Create: `WidgetLab/Catalog/Gestures/GestureDemo.swift`
- Create: `WidgetLab/Catalog/Gestures/OnTapGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/SpatialTapGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/OnLongPressGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/LongPressGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/SpatialEventGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/GestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/DragGestureEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）。束 1 の `TapGesture` の収録（`TapGestureEntry.swift`）は変えない
- Produces: `CatalogEntry.onTapGesture`、`CatalogEntry.spatialTapGesture`、`CatalogEntry.onLongPressGesture`、`CatalogEntry.longPressGesture`、`CatalogEntry.spatialEventGesture`、`CatalogEntry.gesture`、`CatalogEntry.dragGesture`、補助 `GestureTile`・`OuterGestureFrame`・`coordinateSpaceChoices`・`coordinateSpace(global:)`（`GestureDemo.swift`）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py gestures`
Expected: 終了コード 1。抜けに onTapGesture・SpatialTapGesture・onLongPressGesture・LongPressGesture・SpatialEventGesture・gesture・DragGesture がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Gestures/GestureDemo.swift`:

```swift
import SwiftUI

/// ジェスチャーの見本で使う的（色の付いた角丸の四角と、中の説明）
struct GestureTile: View {
    let text: String
    var isActive = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isActive ? AnyShapeStyle(.orange) : AnyShapeStyle(.tint.opacity(0.25)))
            .frame(width: 120, height: 72)
            .overlay {
                Text(text)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .contentShape(.rect(cornerRadius: 12))
    }
}

/// 内側と外側にジェスチャーを持つ見本の外側の枠（simultaneousGesture・highPriorityGesture で使う）
struct OuterGestureFrame<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 6) {
            Text("外側")
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
        .padding(12)
        .background(.background, in: .rect(cornerRadius: 16))
        .contentShape(.rect(cornerRadius: 16))
    }
}

/// 座標の基準を選ぶ選択肢（SpatialTapGesture・SpatialEventGesture で使う）
nonisolated let coordinateSpaceChoices = [Choice(".local"), Choice(".global")]

/// 選んだ座標の基準（nil なら省く = .local）
func coordinateSpace(global: Bool?) -> any CoordinateSpaceProtocol {
    global == true ? .global as GlobalCoordinateSpace : .local as LocalCoordinateSpace
}
```

`WidgetLab/Catalog/Gestures/OnTapGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onTapGesture = CatalogEntry(
        id: "onTapGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View がタップされたときに、処理を行う modifier。count で、何回続けてタップしたら動くかを決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ontapgesture(count:perform:)")!,
        stage: .behavior,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "動くタップの回数。省くと 1 回")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".onTapGesture", trailing: " { print(\"タップ\") }"),
        build: { v in
            AnyView(OnTapGestureDemo(count: v.number("count").map { Int($0) } ?? 1))
        }
    )
}

private struct OnTapGestureDemo: View {
    let count: Int
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(count) 回タップ")
            .onTapGesture(count: count) { recorder?.log("タップ（\(count) 回）") }
            .accessibilityAddTraits(.isButton)
    }
}
```

`WidgetLab/Catalog/Gestures/SpatialTapGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let spatialTapGesture = CatalogEntry(
        id: "SpatialTapGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった回数のタップを認識し、タップした位置を知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spatialtapgesture")!,
        stage: .card,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true, summary: "認識するタップの回数。省くと 1 回"),
            .argument(
                "coordinateSpace", .choice(coordinateSpaceChoices, initial: 1),
                summary: "位置の基準。省くと .local（枠の左上から）。.global は画面の左上からになり、点が枠の外にずれる"),
        ],
        code: CodeTemplate(
            prefix: ["Rectangle()"], call: ".gesture(SpatialTapGesture",
            trailing: ".onEnded { location = $0.location })"),
        build: { v in
            AnyView(
                SpatialTapGestureDemo(
                    count: v.number("count").map { Int($0) } ?? 1,
                    space: coordinateSpace(global: v.pick("coordinateSpace", from: [false, true]))))
        }
    )
}

private struct SpatialTapGestureDemo: View {
    let count: Int
    let space: any CoordinateSpaceProtocol
    @State private var location: CGPoint?

    var body: some View {
        Rectangle()
            .fill(.tint.opacity(0.2))
            .frame(width: 240, height: 140)
            .overlay(alignment: .topLeading) {
                if let location {
                    Circle()
                        .fill(.tint)
                        .frame(width: 16, height: 16)
                        .offset(x: location.x - 8, y: location.y - 8)
                }
            }
            .overlay(alignment: .bottom) {
                Text(location.map { "x: \(Int($0.x))  y: \(Int($0.y))" } ?? "\(count) 回タップすると点を置く")
                    .font(.caption)
                    .monospacedDigit()
                    .padding(6)
            }
            .clipped()
            .gesture(SpatialTapGesture(count: count, coordinateSpace: space).onEnded { location = $0.location })
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
    }
}
```

`WidgetLab/Catalog/Gestures/OnLongPressGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onLongPressGesture = CatalogEntry(
        id: "onLongPressGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View が長押しされたときに、処理を行う modifier。押し始めと指を離したときにも処理を行える。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/onlongpressgesture(minimumduration:maximumdistance:perform:onpressingchanged:)"
        )!,
        stage: .behavior,
        properties: [
            .argument(
                "minimumDuration", .slider(range: 0.5...3, step: 0.5, initial: 1.5), on: true,
                summary: "長押しと認める秒数。省くと 0.5 秒"),
            .argument(
                "maximumDistance", .slider(range: 0...50, step: 10, initial: 0),
                summary: "押したまま指が動いてよい距離。超えると取り消す。省くと 10"),
            .argument(
                "perform", .fixed(code: "{ print(\"長押し\") }"), required: true, summary: "長押しを認めたときの処理"),
            .argument(
                "onPressingChanged", .fixed(code: "{ pressing in print(pressing) }"), on: true,
                summary: "押し始めと指を離したときの処理"),
        ],
        code: CodeTemplate(prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".onLongPressGesture"),
        build: { v in
            AnyView(
                OnLongPressGestureDemo(
                    minimumDuration: v.number("minimumDuration") ?? 0.5,
                    maximumDistance: v.number("maximumDistance") ?? 10,
                    watchesPressing: v["onPressingChanged"] != nil))
        }
    )
}

private struct OnLongPressGestureDemo: View {
    let minimumDuration: Double
    let maximumDistance: Double
    let watchesPressing: Bool
    @State private var isPressing = false
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(minimumDuration.formatted()) 秒長押し", isActive: isPressing)
            .onLongPressGesture(
                minimumDuration: minimumDuration, maximumDistance: maximumDistance,
                perform: { recorder?.log("長押しを認識") },
                onPressingChanged: { pressing in
                    guard watchesPressing else { return }
                    isPressing = pressing
                    recorder?.log(pressing ? "押し始めた" : "指を離した")
                }
            )
            .accessibilityAddTraits(.isButton)
    }
}
```

`WidgetLab/Catalog/Gestures/LongPressGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let longPressGesture = CatalogEntry(
        id: "LongPressGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった秒数より長く押されたら成り立つジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/longpressgesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "minimumDuration", .slider(range: 0.5...3, step: 0.5, initial: 1.5), on: true,
                summary: "長押しと認める秒数。省くと 0.5 秒"),
            .argument(
                "maximumDistance", .slider(range: 0...50, step: 10, initial: 0),
                summary: "押したまま指が動いてよい距離。超えると取り消す。省くと 10"),
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(LongPressGesture",
            trailing: ".onEnded { _ in print(\"長押し\") })"),
        build: { v in
            AnyView(
                LongPressGestureDemo(
                    minimumDuration: v.number("minimumDuration") ?? 0.5,
                    maximumDistance: v.number("maximumDistance") ?? 10))
        }
    )
}

private struct LongPressGestureDemo: View {
    let minimumDuration: Double
    let maximumDistance: Double
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "\(minimumDuration.formatted()) 秒長押し")
            .gesture(
                LongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance)
                    .onEnded { _ in recorder?.log("長押しを認識") }
            )
            .accessibilityAddTraits(.isButton)
    }
}
```

`WidgetLab/Catalog/Gestures/SpatialEventGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let spatialEventGesture = CatalogEntry(
        id: "SpatialEventGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "触れている指 1 本ずつの位置と段階（触れている・離れた）を、続けて知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spatialeventgesture")!,
        stage: .card,
        properties: [
            .argument(
                "coordinateSpace", .choice(coordinateSpaceChoices, initial: 1),
                summary: "位置の基準。省くと .local（枠の左上から）。.global は画面の左上からになり、丸が枠の外にずれる")
        ],
        code: CodeTemplate(
            prefix: ["Rectangle()"], call: ".gesture(SpatialEventGesture",
            trailing:
                ".onChanged { events in touches = events.filter { $0.phase == .active }.map(\\.location) }.onEnded { _ in touches = [] })"
        ),
        build: { v in
            AnyView(
                SpatialEventGestureDemo(space: coordinateSpace(global: v.pick("coordinateSpace", from: [false, true]))))
        }
    )
}

private struct SpatialEventGestureDemo: View {
    let space: any CoordinateSpaceProtocol
    @State private var touches: [CGPoint] = []

    var body: some View {
        Rectangle()
            .fill(.tint.opacity(0.2))
            .frame(width: 240, height: 150)
            .overlay(alignment: .topLeading) {
                ForEach(touches.indices, id: \.self) { i in
                    Circle()
                        .fill(.tint.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .offset(x: touches[i].x - 22, y: touches[i].y - 22)
                }
            }
            .overlay(alignment: .bottom) {
                Text(touches.isEmpty ? "指で触れる（2 本でも）" : "触れている指: \(touches.count) 本")
                    .font(.caption)
                    .padding(6)
            }
            .clipped()
            .gesture(
                SpatialEventGesture(coordinateSpace: space)
                    .onChanged { events in touches = events.filter { $0.phase == .active }.map(\.location) }
                    .onEnded { _ in touches = [] }
            )
    }
}
```

`WidgetLab/Catalog/Gestures/GestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let gesture = CatalogEntry(
        id: "gesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付ける modifier。View がもともと持つジェスチャーより後に回る。isEnabled で、効くかどうかを切り替えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/gesture(_:isenabled:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "gesture", .fixed(code: "TapGesture(count: 2).onEnded { print(\"2 回タップ\") }"), on: true,
                summary: "付けるジェスチャー"),
            .modifier(
                "gesture", id: "gesture.isEnabled", label: "isEnabled", .toggle(initial: true), required: true,
                summary: "false にすると、付けたまま効かなくなる"),
        ],
        code: CodeTemplate(call: "RoundedRectangle", fixedArguments: ["cornerRadius: 12"]),
        build: { v in
            AnyView(GestureModifierDemo(attaches: v["gesture"] != nil, isEnabled: v.flag("gesture.isEnabled") ?? true))
        }
    )
}

private struct GestureModifierDemo: View {
    let attaches: Bool
    let isEnabled: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "2 回タップ")
            .apply(attaches ? () : nil) { view, _ in
                view.gesture(TapGesture(count: 2).onEnded { recorder?.log("2 回タップを認識") }, isEnabled: isEnabled)
            }
            .accessibilityAddTraits(.isButton)
    }
}
```

`WidgetLab/Catalog/Gestures/DragGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dragGesture = CatalogEntry(
        id: "DragGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "指で引く動きを認識し、動かした量や位置を続けて知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/draggesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumDistance", .slider(range: 0...60, step: 10, initial: 40), on: true,
                summary: "引き始めと認める距離。これより短いと動かない。省くと 10")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)", "    .offset(offset)"], call: ".gesture(DragGesture",
            trailing: ".onChanged { offset = $0.translation })"),
        build: { v in
            AnyView(DragGestureDemo(minimumDistance: v.number("minimumDistance") ?? 10))
        }
    )
}

private struct DragGestureDemo: View {
    let minimumDistance: Double
    @State private var offset = CGSize.zero

    var body: some View {
        GestureTile(text: "引いて動かす")
            .offset(offset)
            .gesture(DragGesture(minimumDistance: minimumDistance).onChanged { offset = $0.translation })
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .onTapGesture,
        .spatialTapGesture,
        .onLongPressGesture,
        .longPressGesture,
        .spatialEventGesture,
        .gesture,
        .dragGesture,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Gestures/GestureDemo.swift WidgetLab/Catalog/Gestures/OnTapGestureEntry.swift WidgetLab/Catalog/Gestures/SpatialTapGestureEntry.swift WidgetLab/Catalog/Gestures/OnLongPressGestureEntry.swift WidgetLab/Catalog/Gestures/LongPressGestureEntry.swift WidgetLab/Catalog/Gestures/SpatialEventGestureEntry.swift WidgetLab/Catalog/Gestures/GestureEntry.swift WidgetLab/Catalog/Gestures/DragGestureEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: ジェスチャーの収録 onTapGesture・SpatialTapGesture・onLongPressGesture・LongPressGesture・SpatialEventGesture・gesture・DragGesture

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 2: MagnifyGesture・RotateGesture・MagnificationGesture・RotationGesture・SequenceGesture・SimultaneousGesture・ExclusiveGesture

**Files:**
- Create: `WidgetLab/Catalog/Gestures/MagnifyGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/RotateGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/MagnificationGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/RotationGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/SequenceGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/SimultaneousGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/ExclusiveGestureEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）。Task 1 の `GestureTile`・`OuterGestureFrame`
- Produces: `CatalogEntry.magnifyGesture`、`CatalogEntry.rotateGesture`、`CatalogEntry.magnificationGesture`、`CatalogEntry.rotationGesture`、`CatalogEntry.sequenceGesture`、`CatalogEntry.simultaneousGestureType`、`CatalogEntry.exclusiveGesture`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py gestures`
Expected: 終了コード 1。抜けに MagnifyGesture・RotateGesture・MagnificationGesture・RotationGesture・SequenceGesture・SimultaneousGesture・ExclusiveGesture がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Gestures/MagnifyGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let magnifyGesture = CatalogEntry(
        id: "MagnifyGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で広げたりつまんだりする動きを認識し、拡大の倍率を知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/magnifygesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumScaleDelta", .slider(range: 0...0.5, step: 0.1, initial: 0.3), on: true,
                summary: "認識し始める倍率の変わり幅。省くと 0.01")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"leaf.fill\")", "    .scaleEffect(scale)"], call: ".gesture(MagnifyGesture",
            trailing: ".onChanged { scale = $0.magnification })"),
        build: { v in
            AnyView(MagnifyGestureDemo(minimumScaleDelta: v.number("minimumScaleDelta") ?? 0.01))
        }
    )
}

private struct MagnifyGestureDemo: View {
    let minimumScaleDelta: Double
    @State private var scale = 1.0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 56))
            .foregroundStyle(.green)
            .accessibilityLabel("葉")
            .scaleEffect(scale)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(MagnifyGesture(minimumScaleDelta: minimumScaleDelta).onChanged { scale = $0.magnification })
    }
}
```

`WidgetLab/Catalog/Gestures/RotateGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let rotateGesture = CatalogEntry(
        id: "RotateGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で回す動きを認識し、回した角度を知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rotategesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumAngleDelta",
                .choice([Choice(".degrees(1)"), Choice(".degrees(20)"), Choice(".degrees(45)")], initial: 1), on: true,
                summary: "認識し始める角度の変わり幅。省くと 1 度")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .rotationEffect(angle)"], call: ".gesture(RotateGesture",
            trailing: ".onChanged { angle = $0.rotation })"),
        build: { v in
            AnyView(
                RotateGestureDemo(
                    minimumAngleDelta: v.pick(
                        "minimumAngleDelta", from: [Angle.degrees(1), .degrees(20), .degrees(45)])
                        ?? .degrees(1)))
        }
    )
}

private struct RotateGestureDemo: View {
    let minimumAngleDelta: Angle
    @State private var angle = Angle.zero

    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 56, weight: .bold))
            .foregroundStyle(.tint)
            .accessibilityLabel("矢印")
            .rotationEffect(angle)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(RotateGesture(minimumAngleDelta: minimumAngleDelta).onChanged { angle = $0.rotation })
    }
}
```

`WidgetLab/Catalog/Gestures/MagnificationGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let magnificationGesture = CatalogEntry(
        id: "MagnificationGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で広げたりつまんだりする動きを認識し、拡大の倍率を知らせるジェスチャー。iOS 17 から非推奨で、MagnifyGesture に置き換わった。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/magnificationgesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumScaleDelta", .slider(range: 0...0.5, step: 0.1, initial: 0.3), on: true,
                summary: "認識し始める倍率の変わり幅。省くと 0.01")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"leaf.fill\")", "    .scaleEffect(scale)"],
            call: ".gesture(MagnificationGesture",
            trailing: ".onChanged { scale = $0 })"),
        build: { v in
            AnyView(MagnificationGestureDemo(minimumScaleDelta: v.number("minimumScaleDelta") ?? 0.01))
        }
    )
}

private struct MagnificationGestureDemo: View {
    let minimumScaleDelta: Double
    @State private var scale = 1.0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: 56))
            .foregroundStyle(.green)
            .accessibilityLabel("葉")
            .scaleEffect(scale)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(MagnificationGesture(minimumScaleDelta: minimumScaleDelta).onChanged { scale = $0 })
    }
}
```

`WidgetLab/Catalog/Gestures/RotationGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let rotationGesture = CatalogEntry(
        id: "RotationGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 本の指で回す動きを認識し、回した角度を知らせるジェスチャー。iOS 17 から非推奨で、RotateGesture に置き換わった。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/rotationgesture")!,
        stage: .card,
        properties: [
            .argument(
                "minimumAngleDelta",
                .choice([Choice(".degrees(1)"), Choice(".degrees(20)"), Choice(".degrees(45)")], initial: 1), on: true,
                summary: "認識し始める角度の変わり幅。省くと 1 度")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .rotationEffect(angle)"], call: ".gesture(RotationGesture",
            trailing: ".onChanged { angle = $0 })"),
        build: { v in
            AnyView(
                RotationGestureDemo(
                    minimumAngleDelta: v.pick(
                        "minimumAngleDelta", from: [Angle.degrees(1), .degrees(20), .degrees(45)])
                        ?? .degrees(1)))
        }
    )
}

private struct RotationGestureDemo: View {
    let minimumAngleDelta: Angle
    @State private var angle = Angle.zero

    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 56, weight: .bold))
            .foregroundStyle(.tint)
            .accessibilityLabel("矢印")
            .rotationEffect(angle)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(RotationGesture(minimumAngleDelta: minimumAngleDelta).onChanged { angle = $0 })
    }
}
```

`WidgetLab/Catalog/Gestures/SequenceGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let sequenceGesture = CatalogEntry(
        id: "SequenceGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーを順につなぐジェスチャー。1 つ目が成り立ってから、2 つ目を認識する。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sequencegesture")!,
        stage: .card,
        properties: [
            .argument(
                "gestures", unlabeled: true,
                .choice(
                    [
                        Choice("0.5 秒の長押し → ドラッグ", code: "LongPressGesture(minimumDuration: 0.5), DragGesture()"),
                        Choice("1.5 秒の長押し → ドラッグ", code: "LongPressGesture(minimumDuration: 1.5), DragGesture()"),
                    ], initial: 0), required: true,
                summary: "つなぐ 2 つのジェスチャー。長押しが成り立つと色が変わり、そのまま引くと動く")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)", "    .offset(offset)"], call: ".gesture(SequenceGesture",
            trailing: ".onChanged { if case .second(true, let drag) = $0 { offset = drag?.translation ?? .zero } })"),
        build: { v in
            AnyView(SequenceGestureDemo(minimumDuration: v.pick("gestures", from: [0.5, 1.5]) ?? 0.5))
        }
    )
}

private struct SequenceGestureDemo: View {
    let minimumDuration: Double
    @State private var isReady = false
    @State private var offset = CGSize.zero

    var body: some View {
        GestureTile(text: isReady ? "引いて動かす" : "長押ししてから引く", isActive: isReady)
            .offset(offset)
            .gesture(
                SequenceGesture(LongPressGesture(minimumDuration: minimumDuration), DragGesture())
                    .onChanged { value in
                        if case .second(true, let drag) = value {
                            isReady = true
                            offset = drag?.translation ?? .zero
                        }
                    }
                    .onEnded { _ in isReady = false }
            )
    }
}
```

`WidgetLab/Catalog/Gestures/SimultaneousGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let simultaneousGestureType = CatalogEntry(
        id: "SimultaneousGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーを同時に認識するジェスチャー。どちらかが先になることはない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/simultaneousgesture")!,
        stage: .card,
        properties: [
            .argument(
                "gestures", unlabeled: true, .fixed(code: "MagnifyGesture(), RotateGesture()"), required: true,
                summary: "同時に認識する 2 つのジェスチャー。2 本の指で広げながら回すと、大きさと向きが一緒に変わる")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"arrow.up\")", "    .scaleEffect(scale)", "    .rotationEffect(angle)"],
            call: ".gesture(SimultaneousGesture",
            trailing:
                ".onChanged { scale = $0.first?.magnification ?? 1; angle = $0.second?.rotation ?? .zero })"),
        build: { _ in
            AnyView(SimultaneousGestureDemo())
        }
    )
}

private struct SimultaneousGestureDemo: View {
    @State private var scale: CGFloat = 1
    @State private var angle = Angle.zero

    var body: some View {
        Image(systemName: "arrow.up")
            .font(.system(size: 56, weight: .bold))
            .foregroundStyle(.tint)
            .accessibilityLabel("矢印")
            .scaleEffect(scale)
            .rotationEffect(angle)
            .frame(width: 200, height: 160)
            .contentShape(.rect)
            .gesture(
                SimultaneousGesture(MagnifyGesture(), RotateGesture())
                    .onChanged {
                        scale = $0.first?.magnification ?? 1
                        angle = $0.second?.rotation ?? .zero
                    }
            )
    }
}
```

`WidgetLab/Catalog/Gestures/ExclusiveGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let exclusiveGesture = CatalogEntry(
        id: "ExclusiveGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーのうち、片方だけを成り立たせるジェスチャー。1 つ目を先に試し、だめなら 2 つ目を試す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/exclusivegesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "gestures", unlabeled: true,
                .choice(
                    [
                        Choice("2 回タップが先", code: "TapGesture(count: 2), TapGesture()"),
                        Choice("1 回タップが先", code: "TapGesture(), TapGesture(count: 2)"),
                    ], initial: 0), required: true,
                summary: "2 つのジェスチャーと、その順番。1 回タップを先にすると、2 回タップは成り立たない")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(ExclusiveGesture",
            trailing: ".onEnded { print($0) })"),
        build: { v in
            AnyView(ExclusiveGestureDemo(doubleFirst: v.pick("gestures", from: [true, false]) ?? true))
        }
    )
}

private struct ExclusiveGestureDemo: View {
    let doubleFirst: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "1 回か 2 回タップ")
            .gesture(gesture)
            .accessibilityAddTraits(.isButton)
    }

    private var gesture: some Gesture {
        let first = TapGesture(count: doubleFirst ? 2 : 1)
        let second = TapGesture(count: doubleFirst ? 1 : 2)
        return ExclusiveGesture(first, second).onEnded { value in
            switch value {
            case .first: recorder?.log("1 つ目（\(doubleFirst ? 2 : 1) 回タップ）を認識")
            case .second: recorder?.log("2 つ目（\(doubleFirst ? 1 : 2) 回タップ）を認識")
            }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .magnifyGesture,
        .rotateGesture,
        .magnificationGesture,
        .rotationGesture,
        .sequenceGesture,
        .simultaneousGestureType,
        .exclusiveGesture,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Gestures/MagnifyGestureEntry.swift WidgetLab/Catalog/Gestures/RotateGestureEntry.swift WidgetLab/Catalog/Gestures/MagnificationGestureEntry.swift WidgetLab/Catalog/Gestures/RotationGestureEntry.swift WidgetLab/Catalog/Gestures/SequenceGestureEntry.swift WidgetLab/Catalog/Gestures/SimultaneousGestureEntry.swift WidgetLab/Catalog/Gestures/ExclusiveGestureEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: ジェスチャーの収録 MagnifyGesture・RotateGesture・MagnificationGesture・RotationGesture・SequenceGesture・SimultaneousGesture・ExclusiveGesture

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 3: simultaneousGesture・highPriorityGesture・GestureState・defersSystemGestures・handGestureShortcut・onPencilDoubleTap・onPencilSqueeze

**Files:**
- Create: `WidgetLab/Catalog/Gestures/SimultaneousGestureModifierEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/HighPriorityGestureEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/GestureStateEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/DefersSystemGesturesEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/HandGestureShortcutEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/OnPencilDoubleTapEntry.swift`
- Create: `WidgetLab/Catalog/Gestures/OnPencilSqueezeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）。Task 1 の `GestureTile`・`OuterGestureFrame`
- Produces: `CatalogEntry.simultaneousGesture`、`CatalogEntry.highPriorityGesture`、`CatalogEntry.gestureState`、`CatalogEntry.defersSystemGestures`、`CatalogEntry.handGestureShortcut`、`CatalogEntry.onPencilDoubleTap`、`CatalogEntry.onPencilSqueeze`、補助 `OuterGestureDemo`（`SimultaneousGestureModifierEntry.swift` に置き、`HighPriorityGestureEntry.swift` も使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py gestures`
Expected: 終了コード 1。抜けに simultaneousGesture・highPriorityGesture・GestureState・defersSystemGestures・handGestureShortcut・onPencilDoubleTap・onPencilSqueeze がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/Gestures/SimultaneousGestureModifierEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let simultaneousGesture = CatalogEntry(
        id: "simultaneousGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付け、中の View のジェスチャーと同時に認識させる modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/simultaneousgesture(_:including:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "simultaneousGesture", .fixed(code: "TapGesture().onEnded { print(\"外側\") }"), on: true,
                summary: "外側に付けるジェスチャー。内側をタップすると、内側と外側の両方が動く"),
            .modifier(
                "simultaneousGesture", id: "simultaneousGesture.including", label: "including",
                .choice([Choice(".all"), Choice(".gesture"), Choice(".subviews"), Choice(".none")], initial: 0),
                required: true,
                summary: "効かせる範囲。.gesture は外側だけ（内側は止まる）、.subviews は内側だけ、.none はどちらも止まる"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"内側\")\n        .onTapGesture { print(\"内側\") }\n}"),
        build: { v in
            AnyView(
                OuterGestureDemo(
                    kind: v["simultaneousGesture"] != nil ? .simultaneous : nil,
                    mask: v.pick("simultaneousGesture.including", from: [GestureMask.all, .gesture, .subviews, .none])
                        ?? .all))
        }
    )
}

/// 内側の的と外側の枠の両方にタップを付けた見本。外側のジェスチャーの付け方を kind で選ぶ（nil なら付けない）
struct OuterGestureDemo: View {
    enum Kind {
        case simultaneous
        case highPriority
    }

    let kind: Kind?
    let mask: GestureMask
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        let outer = TapGesture().onEnded { recorder?.log("外側") }
        OuterGestureFrame {
            GestureTile(text: "内側")
                .onTapGesture { recorder?.log("内側") }
                .accessibilityAddTraits(.isButton)
        }
        .apply(kind) { view, kind in
            switch kind {
            case .simultaneous: view.simultaneousGesture(outer, including: mask)
            case .highPriority: view.highPriorityGesture(outer, including: mask)
            }
        }
    }
}
```

`WidgetLab/Catalog/Gestures/HighPriorityGestureEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let highPriorityGesture = CatalogEntry(
        id: "highPriorityGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付け、中の View のジェスチャーより先に認識させる modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/highprioritygesture(_:including:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "highPriorityGesture", .fixed(code: "TapGesture().onEnded { print(\"外側\") }"), on: true,
                summary: "外側に付けるジェスチャー。内側をタップしても、外側だけが動く"),
            .modifier(
                "highPriorityGesture", id: "highPriorityGesture.including", label: "including",
                .choice([Choice(".all"), Choice(".gesture"), Choice(".subviews"), Choice(".none")], initial: 0),
                required: true,
                summary: "効かせる範囲。.subviews は外側が止まり内側が動く、.none はどちらも止まる"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"内側\")\n        .onTapGesture { print(\"内側\") }\n}"),
        build: { v in
            AnyView(
                OuterGestureDemo(
                    kind: v["highPriorityGesture"] != nil ? .highPriority : nil,
                    mask: v.pick("highPriorityGesture.including", from: [GestureMask.all, .gesture, .subviews, .none])
                        ?? .all))
        }
    )
}
```

`WidgetLab/Catalog/Gestures/GestureStateEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let gestureState = CatalogEntry(
        id: "GestureState",
        kind: .propertyWrapper,
        topic: .gestures,
        summary: "ジェスチャーの間だけ値を変え、ジェスチャーが終わると最初の値に戻すプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gesturestate")!,
        stage: .card,
        properties: [
            .wrapper("GestureState", summary: "外して @State にすると、指を離しても値が戻らず、四角は離した所に残る")
        ],
        code: CodeTemplate(
            call: "GestureState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@GestureState private var offset = CGSize.zero",
                    "",
                    "var body: some View {",
                    "    RoundedRectangle(cornerRadius: 12)",
                    "        .offset(offset)",
                    "        .gesture(DragGesture().updating($offset) { value, state, _ in state = value.translation })",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var offset = CGSize.zero",
                    "",
                    "var body: some View {",
                    "    RoundedRectangle(cornerRadius: 12)",
                    "        .offset(offset)",
                    "        .gesture(DragGesture().onChanged { offset = $0.translation })",
                    "}",
                ])),
        build: { v in
            v["GestureState"] != nil
                ? AnyView(GestureStateDemo.WithGestureState()) : AnyView(GestureStateDemo.WithState())
        }
    )
}

private enum GestureStateDemo {
    struct WithGestureState: View {
        @GestureState private var offset = CGSize.zero

        var body: some View {
            GestureTile(text: "引いて離す")
                .offset(offset)
                .gesture(DragGesture().updating($offset) { value, state, _ in state = value.translation })
        }
    }

    struct WithState: View {
        @State private var offset = CGSize.zero

        var body: some View {
            GestureTile(text: "引いて離す")
                .offset(offset)
                .gesture(DragGesture().onChanged { offset = $0.translation })
        }
    }
}
```

`WidgetLab/Catalog/Gestures/DefersSystemGesturesEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defersSystemGestures = CatalogEntry(
        id: "defersSystemGestures",
        kind: .modifier,
        topic: .gestures,
        summary: "画面の端から引く操作で、システムの操作（ホームに戻る・コントロールセンターなど）より、アプリのジェスチャーを先にする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/deferssystemgestures(on:)")!,
        stage: .full,
        properties: [
            .modifier(
                "defersSystemGestures", label: "on",
                .choice([Choice(".bottom"), Choice(".top"), Choice(".all")], initial: 0), on: true,
                summary: "後回しにする端。付けると、端から 1 回引いてもシステムの操作にならず、もう 1 回引くとなる")
        ],
        code: CodeTemplate(
            call: "Color.yellow",
            suffix: [".ignoresSafeArea()", ".gesture(DragGesture().onChanged { distance = $0.translation.height })"]),
        build: { v in
            AnyView(
                DefersSystemGesturesDemo(edges: v.pick("defersSystemGestures", from: [Edge.Set.bottom, .top, .all])))
        }
    )
}

private struct DefersSystemGesturesDemo: View {
    let edges: Edge.Set?
    @State private var distance = 0.0

    var body: some View {
        Color.yellow
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 8) {
                    Text("画面の下の端から上へ引く")
                        .font(.headline)
                    Text("引いた距離: \(Int(-distance))")
                        .monospacedDigit()
                }
            }
            .apply(edges) { $0.defersSystemGestures(on: $1) }
            .gesture(DragGesture().onChanged { distance = $0.translation.height })
    }
}
```

`WidgetLab/Catalog/Gestures/HandGestureShortcutEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let handGestureShortcut = CatalogEntry(
        id: "handGestureShortcut",
        kind: .modifier,
        topic: .gestures,
        summary: "手の動き（Apple Watch のダブルタップ）で、ボタンやトグルを押せるようにする modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/handgestureshortcut(_:isenabled:)")!,
        noteReason: "iPhone では効かない。Apple Watch で、指を 2 回合わせる（ダブルタップ）とボタンが押される",
        properties: [
            .modifier(
                "handGestureShortcut", .fixed(code: ".primaryAction"), on: true, summary: "割り当てる手の動き（主な操作）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"再生\""], trailing: " { }")
    )
}
```

`WidgetLab/Catalog/Gestures/OnPencilDoubleTapEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onPencilDoubleTap = CatalogEntry(
        id: "onPencilDoubleTap",
        kind: .modifier,
        topic: .gestures,
        summary: "Apple Pencil の軸を 2 回軽くたたいたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpencildoubletap(perform:)")!,
        noteReason: "iPhone では Apple Pencil が使えない。iPad で、ダブルタップに対応した Apple Pencil を使うときに効く",
        properties: [
            .modifier(
                "onPencilDoubleTap", label: "perform", .fixed(code: "{ _ in tool = tool == .pen ? .eraser : .pen }"),
                on: true, summary: "2 回たたいたときの処理（ペンと消しゴムを切り替えるなど）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ペンで描く\""])
    )
}
```

`WidgetLab/Catalog/Gestures/OnPencilSqueezeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onPencilSqueeze = CatalogEntry(
        id: "onPencilSqueeze",
        kind: .modifier,
        topic: .gestures,
        summary: "Apple Pencil を握ったときに、処理を行う modifier。握り始め・握っている間・離したときの段階を受け取る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpencilsqueeze(perform:)")!,
        noteReason: "iPhone では Apple Pencil が使えない。iPad で、Apple Pencil Pro を使うときに効く",
        properties: [
            .modifier(
                "onPencilSqueeze", label: "perform",
                .fixed(code: "{ phase in if case .ended = phase { showsPalette.toggle() } }"), on: true,
                summary: "握ったときの処理（道具のパレットを出すなど）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ペンで描く\""])
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .simultaneousGesture,
        .highPriorityGesture,
        .gestureState,
        .defersSystemGestures,
        .handGestureShortcut,
        .onPencilDoubleTap,
        .onPencilSqueeze,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/Gestures/SimultaneousGestureModifierEntry.swift WidgetLab/Catalog/Gestures/HighPriorityGestureEntry.swift WidgetLab/Catalog/Gestures/GestureStateEntry.swift WidgetLab/Catalog/Gestures/DefersSystemGesturesEntry.swift WidgetLab/Catalog/Gestures/HandGestureShortcutEntry.swift WidgetLab/Catalog/Gestures/OnPencilDoubleTapEntry.swift WidgetLab/Catalog/Gestures/OnPencilSqueezeEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: ジェスチャーの収録 simultaneousGesture・highPriorityGesture・GestureState・defersSystemGestures・handGestureShortcut・onPencilDoubleTap・onPencilSqueeze

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 4: onKeyPress・keyboardShortcut・onSubmit・submitScope・submitLabel・contentShape

**Files:**
- Create: `WidgetLab/Catalog/InputEvents/OnKeyPressEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/KeyboardShortcutEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/OnSubmitEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/SubmitScopeEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/SubmitLabelEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/ContentShapeEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）
- Produces: `CatalogEntry.onKeyPress`、`CatalogEntry.keyboardShortcut`、`CatalogEntry.onSubmit`、`CatalogEntry.submitScope`、`CatalogEntry.submitLabel`、`CatalogEntry.contentShape`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py input-events`
Expected: 終了コード 1。抜けに onKeyPress・keyboardShortcut・onSubmit・submitScope・submitLabel・contentShape がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/InputEvents/OnKeyPressEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onKeyPress = CatalogEntry(
        id: "onKeyPress",
        kind: .modifier,
        topic: .inputEvents,
        summary: "フォーカスのある View で、ハードウェアのキーボードのキーが押されたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onkeypress(phases:action:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onKeyPress", id: "onKeyPress.phases", label: "phases",
                .choice([Choice(".down"), Choice(".up"), Choice(".all")], initial: 0), required: true,
                summary: "受け取る段階（押した・離した・押し続けて繰り返した）"),
            .modifier(
                "onKeyPress", label: "action",
                .fixed(code: "{ press in print(press.characters); return .ignored }"), on: true,
                summary: "キーが押されたときの処理。.ignored を返すと、文字は入力欄にも入る"),
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"キーを押す\"", "text: $text"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                OnKeyPressDemo(
                    phases: v["onKeyPress"] != nil
                        ? v.pick("onKeyPress.phases", from: [KeyPress.Phases.down, .up, .all]) : nil))
        }
    )
}

private struct OnKeyPressDemo: View {
    /// nil なら onKeyPress を付けない
    let phases: KeyPress.Phases?
    @State private var text = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        TextField("キーを押す", text: $text)
            .apply(phases) { view, phases in
                view.onKeyPress(phases: phases) { press in
                    recorder?.log("「\(press.characters)」\(Self.name(press.phase))")
                    return .ignored
                }
            }
            .textFieldStyle(.bordered)
            .padding(.horizontal)
    }

    private static func name(_ phase: KeyPress.Phases) -> String {
        switch phase {
        case .down: "を押した"
        case .up: "を離した"
        case .repeat: "を押し続けた"
        default: ""
        }
    }
}
```

`WidgetLab/Catalog/InputEvents/KeyboardShortcutEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let keyboardShortcut = CatalogEntry(
        id: "keyboardShortcut",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ボタンやトグルに、ハードウェアのキーボードの近道（⌘S など）を割り当てる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/keyboardshortcut(_:modifiers:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "keyboardShortcut", .choice([Choice("\"s\""), Choice("\"d\""), Choice(".return")], initial: 0),
                on: true,
                summary: "割り当てるキー"),
            .modifier(
                "keyboardShortcut", id: "keyboardShortcut.modifiers", label: "modifiers",
                .choice([Choice(".command"), Choice(".option"), Choice("[.command, .shift]")], initial: 0),
                required: true, summary: "一緒に押す修飾キー。省くと .command"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { print(\"保存\") }"),
        build: { v in
            AnyView(
                KeyboardShortcutDemo(
                    key: v.pick("keyboardShortcut", from: [KeyEquivalent("s"), "d", .return]),
                    modifiers: v.pick(
                        "keyboardShortcut.modifiers", from: [EventModifiers.command, .option, [.command, .shift]])
                        ?? .command))
        }
    )
}

private struct KeyboardShortcutDemo: View {
    /// nil なら keyboardShortcut を付けない
    let key: KeyEquivalent?
    let modifiers: EventModifiers
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        Button("保存") { recorder?.log("保存を押した") }
            .buttonStyle(.bordered)
            .apply(key) { $0.keyboardShortcut($1, modifiers: modifiers) }
    }
}
```

`WidgetLab/Catalog/InputEvents/OnSubmitEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onSubmit = CatalogEntry(
        id: "onSubmit",
        kind: .modifier,
        topic: .inputEvents,
        summary: "入力欄で確定した（キーボードの改行キーを押した）ときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onSubmit", id: "onSubmit.of", label: "of", .choice([Choice(".text"), Choice(".search")], initial: 0),
                required: true, summary: "受け取る確定の種類。.search は検索欄（searchable）の確定だけなので、この入力欄では動かない"),
            .modifier(
                "onSubmit", .fixed(code: "{ print(\"送った\") }"), on: true, summary: "確定したときの処理"),
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"名前\"", "text: $name"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                OnSubmitDemo(
                    triggers: v["onSubmit"] != nil
                        ? v.pick("onSubmit.of", from: [SubmitTriggers.text, .search]) : nil))
        }
    )
}

private struct OnSubmitDemo: View {
    /// nil なら onSubmit を付けない
    let triggers: SubmitTriggers?
    @State private var name = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        TextField("名前", text: $name)
            .apply(triggers) { view, triggers in
                view.onSubmit(of: triggers) { recorder?.log("「\(name)」を送った") }
            }
            .textFieldStyle(.bordered)
            .padding(.horizontal)
    }
}
```

`WidgetLab/Catalog/InputEvents/SubmitScopeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let submitScope = CatalogEntry(
        id: "submitScope",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の入力欄で確定しても、外側に付けた onSubmit を動かさないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/submitscope(_:)")!,
        stage: .behavior,
        properties: [
            .modifier("submitScope", .toggle(initial: true), on: true, summary: "true なら、この入力欄の確定を外へ伝えない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    TextField(\"名前\", text: $name)"], indent: 4, call: "TextField",
            fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["}", ".onSubmit { print(\"送った\") }"]),
        build: { v in
            AnyView(SubmitScopeDemo(isBlocking: v.flag("submitScope")))
        }
    )
}

private struct SubmitScopeDemo: View {
    /// nil なら submitScope を付けない
    let isBlocking: Bool?
    @State private var name = ""
    @State private var memo = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            TextField("名前", text: $name)
            TextField("メモ", text: $memo)
                .apply(isBlocking) { $0.submitScope($1) }
        }
        .textFieldStyle(.bordered)
        .onSubmit { recorder?.log("送った（名前: \(name)、メモ: \(memo)）") }
        .padding(.horizontal)
    }
}
```

`WidgetLab/Catalog/InputEvents/SubmitLabelEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let submitLabel = CatalogEntry(
        id: "submitLabel",
        kind: .modifier,
        topic: .inputEvents,
        summary: "キーボードの確定のキー（改行キー）に出す文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/submitlabel(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "submitLabel",
                .choice(
                    [
                        Choice(".done"), Choice(".go"), Choice(".send"), Choice(".join"), Choice(".route"),
                        Choice(".search"), Choice(".return"), Choice(".next"), Choice(".continue"),
                    ], initial: 2), on: true,
                summary: "確定のキーの文（入力欄をタップすると出るキーボードで見る）")
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"メッセージ\"", "text: $message"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                TextInputDemo("") { text in
                    TextField("メッセージ", text: text)
                        .apply(
                            v.pick(
                                "submitLabel",
                                from: [SubmitLabel.done, .go, .send, .join, .route, .search, .return, .next, .continue])
                        ) { $0.submitLabel($1) }
                        .textFieldStyle(.bordered)
                }
                .padding()
            )
        }
    )
}
```

`WidgetLab/Catalog/InputEvents/ContentShapeEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let contentShape = CatalogEntry(
        id: "contentShape",
        kind: .modifier,
        topic: .inputEvents,
        summary: "タップなどが当たる範囲の形を決める modifier。何も描いていない隙間も押せるようになる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contentshape(_:eofill:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contentShape", .choice([Choice(".rect"), Choice(".capsule"), Choice("Circle()")], initial: 0),
                on: true,
                summary: "当たる範囲の形。付けないと、星と文字の上だけが押せる")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {", "    Image(systemName: \"star.fill\")", "    Spacer()", "    Text(\"右の端\")", "}",
            ], indent: 0, call: ".frame", fixedArguments: ["width: 240", "height: 64"],
            suffix: [".onTapGesture { count += 1 }"]),
        build: { v in
            AnyView(
                ContentShapeDemo(
                    shape: v.pick("contentShape", from: [AnyShape(.rect), AnyShape(.capsule), AnyShape(Circle())])))
        }
    )
}

private struct ContentShapeDemo: View {
    /// nil なら contentShape を付けない
    let shape: AnyShape?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                Spacer()
                Text("右の端")
            }
            .padding(.horizontal, 12)
            .frame(width: 240, height: 64)
            .apply(shape) { $0.contentShape($1) }
            .onTapGesture { count += 1 }
            // 押せる範囲を見せる線。線そのものはタップを受けない
            .overlay {
                (shape ?? AnyShape(.rect))
                    .stroke(.tint, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    .opacity(shape == nil ? 0 : 1)
                    .allowsHitTesting(false)
            }
            Text("押した回数: \(count)")
                .font(.caption)
                .monospacedDigit()
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .onKeyPress,
        .keyboardShortcut,
        .onSubmit,
        .submitScope,
        .submitLabel,
        .contentShape,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/InputEvents/OnKeyPressEntry.swift WidgetLab/Catalog/InputEvents/KeyboardShortcutEntry.swift WidgetLab/Catalog/InputEvents/OnSubmitEntry.swift WidgetLab/Catalog/InputEvents/SubmitScopeEntry.swift WidgetLab/Catalog/InputEvents/SubmitLabelEntry.swift WidgetLab/Catalog/InputEvents/ContentShapeEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 入力の収録 onKeyPress・keyboardShortcut・onSubmit・submitScope・submitLabel・contentShape

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 5: onHover・hoverEffect・hoverEffectDisabled・defaultHoverEffect・onContinuousHover・onCameraCaptureEvent

**Files:**
- Create: `WidgetLab/Catalog/InputEvents/OnHoverEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/HoverEffectEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/HoverEffectDisabledEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/DefaultHoverEffectEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/OnContinuousHoverEntry.swift`
- Create: `WidgetLab/Catalog/InputEvents/OnCameraCaptureEventEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）
- Produces: `CatalogEntry.onHover`、`CatalogEntry.hoverEffect`、`CatalogEntry.hoverEffectDisabled`、`CatalogEntry.defaultHoverEffect`、`CatalogEntry.onContinuousHover`、`CatalogEntry.onCameraCaptureEvent`

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py input-events`
Expected: 終了コード 1。抜けに onHover・hoverEffect・hoverEffectDisabled・defaultHoverEffect・onContinuousHover・onCameraCaptureEvent がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/InputEvents/OnHoverEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onHover = CatalogEntry(
        id: "onHover",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが View の上に乗ったときと、離れたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onhover(perform:)")!,
        noteReason: "iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く",
        properties: [
            .modifier(
                "onHover", label: "perform", .fixed(code: "{ hovering in isHovering = hovering }"), on: true,
                summary: "乗ったとき（true）と離れたとき（false）の処理")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"ポインタを乗せる\""])
    )
}
```

`WidgetLab/Catalog/InputEvents/HoverEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let hoverEffect = CatalogEntry(
        id: "hoverEffect",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが乗ったとき（visionOS では見つめたとき）の効果を、View に付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hovereffect(_:isenabled:)")!,
        noteReason: "iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier(
                "hoverEffect", .choice([Choice(".automatic"), Choice(".highlight"), Choice(".lift")], initial: 2),
                on: true, summary: "効果の種類（.highlight は地が光る、.lift は浮き上がる）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }")
    )
}
```

`WidgetLab/Catalog/InputEvents/HoverEffectDisabledEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let hoverEffectDisabled = CatalogEntry(
        id: "hoverEffectDisabled",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の View に付けたポインタの効果を、出さないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/hovereffectdisabled(_:)")!,
        noteReason: "iPhone にはポインタがないので、もともと効果が出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier("hoverEffectDisabled", .toggle(initial: true), on: true, summary: "true なら効果を出さない")
        ],
        code: CodeTemplate(prefix: ["Button(\"保存\") { }"], call: ".hoverEffect", fixedArguments: [".lift"])
    )
}
```

`WidgetLab/Catalog/InputEvents/DefaultHoverEffectEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultHoverEffect = CatalogEntry(
        id: "defaultHoverEffect",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の View に、ポインタが乗ったときの既定の効果を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaulthovereffect(_:)")!,
        noteReason: "iPhone にはポインタがないので、効果は出ない。iPad のトラックパッドやマウスと、Vision Pro の視線で効く",
        properties: [
            .modifier(
                "defaultHoverEffect",
                .choice([Choice(".automatic"), Choice(".highlight"), Choice(".lift")], initial: 1),
                on: true, summary: "中のボタンなどに使う既定の効果")
        ],
        code: CodeTemplate(call: "HStack", trailing: " {\n    Button(\"保存\") { }\n    Button(\"削除\") { }\n}")
    )
}
```

`WidgetLab/Catalog/InputEvents/OnContinuousHoverEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onContinuousHover = CatalogEntry(
        id: "onContinuousHover",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが View に入ったとき・中で動いたとき・出たときに、位置とともに処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncontinuoushover(coordinatespace:perform:)"
        )!,
        noteReason: "iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く",
        properties: [
            .modifier(
                "onContinuousHover", id: "onContinuousHover.coordinateSpace", label: "coordinateSpace",
                .choice([Choice(".local"), Choice(".global")], initial: 0), required: true, summary: "位置の基準"),
            .modifier(
                "onContinuousHover", label: "perform",
                .fixed(code: "{ phase in if case .active(let point) = phase { location = point } }"), on: true,
                summary: "ポインタが動くたびの処理（.active で位置、.ended で出たこと）"),
        ],
        code: CodeTemplate(call: "Rectangle", suffix: [".frame(width: 200, height: 120)"])
    )
}
```

`WidgetLab/Catalog/InputEvents/OnCameraCaptureEventEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onCameraCaptureEvent = CatalogEntry(
        id: "onCameraCaptureEvent",
        kind: .modifier,
        topic: .inputEvents,
        summary: "カメラで撮影している画面で、音量ボタンやカメラコントロールが押されたときに、処理を行う modifier（AVKit）。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncameracaptureevent(isenabled:action:)")!,
        noteReason: "カメラで撮影している（AVCaptureSession が動いている）画面で効く。このアプリには撮影の画面がなく、シミュレータにはカメラもない",
        properties: [
            .argument("isEnabled", .toggle(initial: true), summary: "false にすると、押しても処理を行わない"),
            .argument(
                "action", .fixed(code: "{ event in if event.phase == .ended { takePhoto() } }"), required: true,
                summary: "押されたときの処理（.began・.ended・.cancelled の段階を受け取る）"),
        ],
        code: CodeTemplate(
            prefix: ["// import AVKit が要る", "CameraPreview(session: session)"],
            call: ".onCameraCaptureEvent")
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .onHover,
        .hoverEffect,
        .hoverEffectDisabled,
        .defaultHoverEffect,
        .onContinuousHover,
        .onCameraCaptureEvent,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/InputEvents/OnHoverEntry.swift WidgetLab/Catalog/InputEvents/HoverEffectEntry.swift WidgetLab/Catalog/InputEvents/HoverEffectDisabledEntry.swift WidgetLab/Catalog/InputEvents/DefaultHoverEffectEntry.swift WidgetLab/Catalog/InputEvents/OnContinuousHoverEntry.swift WidgetLab/Catalog/InputEvents/OnCameraCaptureEventEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: 入力の収録 onHover・hoverEffect・hoverEffectDisabled・defaultHoverEffect・onContinuousHover・onCameraCaptureEvent

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 6: draggable・onDrag・onDrop・itemProvider・dragConfiguration・dropConfiguration

**Files:**
- Create: `WidgetLab/Catalog/DragAndDrop/DragAndDropDemo.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/DraggableEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/OnDragEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/OnDropEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/ItemProviderEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/DragConfigurationEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/DropConfigurationEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）
- Produces: `CatalogEntry.draggable`、`CatalogEntry.onDrag`、`CatalogEntry.onDrop`、`CatalogEntry.itemProvider`、`CatalogEntry.dragConfiguration`、`CatalogEntry.dropConfiguration`、補助 `DragFruit`・`dragFruits`・`DragChip`・`DropBox`・`loadTexts(from:add:)`・`Array.applyReorder(_:)`（`DragAndDropDemo.swift`）、`MoveDropDemo`（`DragConfigurationEntry.swift` に置き、`DropConfigurationEntry.swift` も使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drag-and-drop`
Expected: 終了コード 1。抜けに draggable・onDrag・onDrop・itemProvider・dragConfiguration・dropConfiguration がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DragAndDrop/DragAndDropDemo.swift`:

```swift
import SwiftUI

/// ドラッグの見本で運ぶ果物。名前を id にし、ドラッグでは名前の文字として渡す
nonisolated struct DragFruit: Identifiable, Hashable, Sendable, Transferable {
    let id: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.id)
    }
}

/// ドラッグの見本で使う果物の並び
nonisolated let dragFruits = ["りんご", "みかん", "ぶどう"].map(DragFruit.init)

/// ドラッグする札
struct DragChip: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.callout)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AnyShapeStyle(.orange) : AnyShapeStyle(.yellow), in: .capsule)
            .contentShape(.capsule)
    }
}

/// 落とす先の箱。落ちた文字を並べ、上に乗っているあいだは色を変える
struct DropBox: View {
    let items: [String]
    var isTargeted = false

    var body: some View {
        Text(items.isEmpty ? "ここに落とす" : items.joined(separator: "・"))
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(width: 200, height: 72)
            .background(
                isTargeted ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.background),
                in: .rect(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
            }
            .contentShape(.rect(cornerRadius: 12))
    }
}

/// 落ちた NSItemProvider から文字を読み、読めたら add に渡す（onDrop・itemProvider の見本で使う）
func loadTexts(from providers: [NSItemProvider], add: @escaping @MainActor (String) -> Void) {
    for provider in providers {
        _ = provider.loadObject(ofClass: NSString.self) { object, _ in
            guard let text = object as? NSString else { return }
            let string = String(text)
            Task { @MainActor in add(string) }
        }
    }
}

extension Array where Element: Identifiable {
    /// 並べ替えの差分を当てる。動かすものを抜き、行き先の前（または最後）に入れ直す
    mutating func applyReorder(_ difference: ReorderDifference<Element.ID, ReorderableSingleCollectionIdentifier>) {
        let moving = filter { difference.sources.contains($0.id) }
        removeAll { difference.sources.contains($0.id) }
        switch difference.destination.position {
        case .before(let id): insert(contentsOf: moving, at: firstIndex { $0.id == id } ?? endIndex)
        case .end: append(contentsOf: moving)
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/DraggableEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let draggable = CatalogEntry(
        id: "draggable",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を長押しして引くと、渡したもの（Transferable）を運べるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/draggable(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "draggable", .text(initial: "りんご"), on: true,
                summary: "運ぶもの（Transferable）。札を長押しして下の箱へ引くと、この文字が箱に入る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], indent: 4, call: "Text", fixedArguments: ["\"りんご\""],
            closing: [
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "}",
            ]),
        build: { v in
            AnyView(DraggableDemo(payload: v.text("draggable")))
        }
    )
}

private struct DraggableDemo: View {
    /// nil なら draggable を付けない
    let payload: String?
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "りんご")
                .apply(payload) { $0.draggable($1) }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/OnDragEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let onDrag = CatalogEntry(
        id: "onDrag",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を長押しして引くと、NSItemProvider に入れたものを運べるようにする modifier。今は draggable を使うことがすすめられている。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondrag(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onDrag", .fixed(code: "{ NSItemProvider(object: \"みかん\" as NSString) }"), on: true,
                summary: "運ぶものを入れた NSItemProvider を返す処理。ドラッグを始めたときに呼ばれる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], indent: 4, call: "Text", fixedArguments: ["\"みかん\""],
            closing: [
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "}",
            ]),
        build: { v in
            AnyView(OnDragDemo(attaches: v["onDrag"] != nil))
        }
    )
}

private struct OnDragDemo: View {
    let attaches: Bool
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "みかん")
                .apply(attaches ? () : nil) { view, _ in
                    view.onDrag { NSItemProvider(object: "みかん" as NSString) }
                }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/OnDropEntry.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let onDrop = CatalogEntry(
        id: "onDrop",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "View を落とす先にし、落ちてきた NSItemProvider を受け取る modifier。今は dropDestination を使うことがすすめられている。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondrop(of:istargeted:perform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onDrop", id: "onDrop.of", label: "of", .choice([Choice("[.text]"), Choice("[.image]")], initial: 0),
                required: true, summary: "受け取る種類（UTType）。[.image] にすると、文字の札は落とせない"),
            .modifier(
                "onDrop", id: "onDrop.isTargeted", label: "isTargeted",
                .choice([Choice("$isTargeted"), Choice("nil")], initial: 0), required: true,
                summary: "上に乗っているかを書く Binding。nil なら知らせない（箱の色が変わらない）"),
            .modifier(
                "onDrop", label: "perform", .fixed(code: "{ providers in load(providers); return true }"), on: true,
                summary: "落ちたときの処理。true を返すと受け取ったことになる"),
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    Text(\"ぶどう\")", "        .draggable(\"ぶどう\")",
                "    Text(dropped.joined(separator: \"・\"))",
            ],
            indent: 8, call: ".frame", fixedArguments: ["width: 200", "height: 72"], closing: ["}"]),
        build: { v in
            AnyView(
                OnDropDemo(
                    attaches: v["onDrop"] != nil,
                    types: v.pick("onDrop.of", from: [[UTType.text], [.image]]) ?? [.text],
                    tracksTarget: v.pick("onDrop.isTargeted", from: [true, false]) ?? true))
        }
    )
}

private struct OnDropDemo: View {
    let attaches: Bool
    let types: [UTType]
    let tracksTarget: Bool
    @State private var dropped: [String] = []
    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 16) {
            DragChip(text: "ぶどう")
                .draggable("ぶどう")
            DropBox(items: dropped, isTargeted: isTargeted)
                .apply(attaches ? () : nil) { view, _ in
                    view.onDrop(of: types, isTargeted: tracksTarget ? $isTargeted : nil) { providers in
                        loadTexts(from: providers) { dropped.append($0) }
                        return true
                    }
                }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/ItemProviderEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let itemProvider = CatalogEntry(
        id: "itemProvider",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "List の行などをドラッグしたときに運ぶものを、NSItemProvider で渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/itemprovider(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "itemProvider", .fixed(code: "{ NSItemProvider(object: name as NSString) }"), on: true,
                summary: "運ぶものを入れた NSItemProvider を返す処理。付けると、行を長押しして引ける")
        ],
        code: CodeTemplate(
            prefix: ["List(fruits, id: \\.self) { name in"], indent: 4, call: "Text", fixedArguments: ["name"],
            closing: ["}"]),
        build: { v in
            AnyView(ItemProviderDemo(attaches: v["itemProvider"] != nil))
        }
    )
}

private struct ItemProviderDemo: View {
    let attaches: Bool
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 12) {
            List(dragFruits.map(\.id), id: \.self) { name in
                Text(name)
                    .apply(attaches ? () : nil) { view, _ in
                        view.itemProvider { NSItemProvider(object: name as NSString) }
                    }
            }
            .frame(width: 240, height: 150)
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/DragConfigurationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dragConfiguration = CatalogEntry(
        id: "dragConfiguration",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグを始める側で、運んだものを動かしてよいか（写すだけか）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dragconfiguration(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dragConfiguration",
                .choice(
                    [
                        Choice("動かせる", code: "DragConfiguration(allowMove: true)"),
                        Choice("写すだけ", code: "DragConfiguration(allowMove: false)"),
                    ], initial: 0), on: true,
                summary: "動かせるにすると、落とした札は元の場所から消える。写すだけ（付けないときも）なら残る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    if !moved {", "        Text(\"りんご\")"], indent: 12, call: ".draggable",
            fixedArguments: ["\"りんご\""],
            suffix: [".onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }"],
            closing: [
                "    }",
                "    Text(dropped.joined(separator: \"・\"))",
                "        .frame(width: 200, height: 72)",
                "        .dropDestination(for: String.self) { items, _ in dropped += items }",
                "        .dropConfiguration { _ in DropConfiguration(operation: .move) }",
                "}",
            ]),
        build: { v in
            AnyView(
                MoveDropDemo(
                    allowsMove: v.pick("dragConfiguration", from: [true, false]),
                    operation: .move))
        }
    )
}

/// 札を動かす（写す）見本。札の側の DragConfiguration と、箱の側の DropConfiguration を渡す（nil なら付けない）。
/// 動かして落とすと、札は元の場所から消える
struct MoveDropDemo: View {
    let allowsMove: Bool?
    let operation: DropOperation?
    @State private var moved = false
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if !moved {
                    DragChip(text: "りんご")
                        .draggable("りんご")
                        .apply(allowsMove) { $0.dragConfiguration(DragConfiguration(allowMove: $1)) }
                        .onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }
                } else {
                    Button("札を戻す") {
                        moved = false
                        dropped = []
                    }
                    .font(.caption)
                }
            }
            .frame(height: 40)
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
                .apply(operation) { view, operation in
                    view.dropConfiguration { _ in DropConfiguration(operation: operation) }
                }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/DropConfigurationEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dropConfiguration = CatalogEntry(
        id: "dropConfiguration",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "落とす先の側で、落ちてきたものを写すか・動かすか・断るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dropconfiguration(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dropConfiguration",
                .choice(
                    [
                        Choice(".move", code: "{ _ in DropConfiguration(operation: .move) }"),
                        Choice(".copy", code: "{ _ in DropConfiguration(operation: .copy) }"),
                        Choice(".forbidden", code: "{ _ in DropConfiguration(operation: .forbidden) }"),
                    ], initial: 0), on: true,
                summary: ".move なら札は元の場所から消え、.copy（付けないときも）なら残る。.forbidden なら落とせない")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    if !moved {", "        Text(\"りんご\")", "            .draggable(\"りんご\")",
                "            .dragConfiguration(DragConfiguration(allowMove: true))",
                "            .onDragSessionUpdated { if case .ended(.move) = $0.phase { moved = true } }", "    }",
                "    Text(dropped.joined(separator: \"・\"))", "        .frame(width: 200, height: 72)",
            ], indent: 8, call: ".dropDestination", fixedArguments: ["for: String.self"],
            trailing: " { items, _ in dropped += items }", closing: ["}"]),
        build: { v in
            AnyView(
                MoveDropDemo(
                    allowsMove: true,
                    operation: v.pick("dropConfiguration", from: [DropOperation.move, .copy, .forbidden])))
        }
    )
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .draggable,
        .onDrag,
        .onDrop,
        .itemProvider,
        .dragConfiguration,
        .dropConfiguration,
```

- [ ] **Step 4: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンド
Expected: lint・道具のテスト・単体テストが全部通る（`result` が `Passed`）

- [ ] **Step 5: コミットする**

```bash
git add WidgetLab/Catalog/DragAndDrop/DragAndDropDemo.swift WidgetLab/Catalog/DragAndDrop/DraggableEntry.swift WidgetLab/Catalog/DragAndDrop/OnDragEntry.swift WidgetLab/Catalog/DragAndDrop/OnDropEntry.swift WidgetLab/Catalog/DragAndDrop/ItemProviderEntry.swift WidgetLab/Catalog/DragAndDrop/DragConfigurationEntry.swift WidgetLab/Catalog/DragAndDrop/DropConfigurationEntry.swift WidgetLab/Catalog/Catalog.swift
git commit -m "feat: ドラッグとドロップの収録 draggable・onDrag・onDrop・itemProvider・dragConfiguration・dropConfiguration

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```


### Task 7: dragContainer・dragContainerSelection・reorderContainer・springLoadingBehavior と束の確かめ

**Files:**
- Create: `WidgetLab/Catalog/DragAndDrop/DragContainerEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/DragContainerSelectionEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/ReorderContainerEntry.swift`
- Create: `WidgetLab/Catalog/DragAndDrop/SpringLoadingBehaviorEntry.swift`
- Modify: `WidgetLab/Catalog/Catalog.swift`（`all` の最後に足す）
- Modify: `WidgetLabUITests/LaunchUITests.swift`（代表のスクリーンショットのテストを 1 つ足す）
- Modify: `docs/architecture.md`（UI テストの本数）
- Modify: `docs/cataloging-guide.md`（試作でわかったこと）

**Interfaces:**
- Consumes: 今の `CatalogEntry`・`PropertySpec`・`CodeTemplate`・`PropertyValues.pick`・`View.apply`・`TextInputDemo`（どれも変えない）。Task 6 の `DragFruit`・`dragFruits`・`DragChip`・`DropBox`・`Array.applyReorder(_:)`
- Produces: `CatalogEntry.dragContainer`、`CatalogEntry.dragContainerSelection`、`CatalogEntry.reorderContainer`、`CatalogEntry.springLoadingBehavior`、補助 `DragContainerDemo`（`DragContainerEntry.swift` に置き、`DragContainerSelectionEntry.swift` も使う）

- [ ] **Step 1: 抜けを確かめる**

Run: `python3 tools/catalog_progress.py drag-and-drop`
Expected: 終了コード 1。抜けに dragContainer・dragContainerSelection・reorderContainer・springLoadingBehavior がある

- [ ] **Step 2: 収録のファイルを作る**

`WidgetLab/Catalog/DragAndDrop/DragContainerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dragContainer = CatalogEntry(
        id: "dragContainer",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "中の View の id から、ドラッグで運ぶものをあとで作る入れ物にする modifier。中の View は draggable(containerItemID:) で id だけを渡す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dragcontainer(for:in:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dragContainer", id: "dragContainer.for", label: "for", .fixed(code: "Fruit.self"), required: true,
                summary: "運ぶものの型（Transferable で Identifiable）"),
            .modifier(
                "dragContainer", .fixed(code: "{ ids in fruits.filter { ids.contains($0.id) } }"), on: true,
                summary: "引いた札の id から、運ぶものを作る処理。付けないと、札を引いても何も運べない"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n            .draggable(containerItemID: fruit.id)\n    }\n}"
        ),
        build: { v in
            AnyView(DragContainerDemo(isContainer: v["dragContainer"] != nil, selects: false))
        }
    )
}

/// 入れ物から札を運ぶ見本。isContainer なら dragContainer を付け、selects なら札を押して選べるようにし、
/// 選んだ札をまとめて運ぶ（dragContainerSelection）
struct DragContainerDemo: View {
    let isContainer: Bool
    let selects: Bool
    @State private var selection: [String] = []
    @State private var dropped: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(dragFruits) { fruit in
                    DragChip(text: fruit.id, isSelected: selection.contains(fruit.id))
                        .draggable(containerItemID: fruit.id)
                        .apply(selects ? () : nil) { view, _ in
                            view.onTapGesture {
                                if let i = selection.firstIndex(of: fruit.id) {
                                    selection.remove(at: i)
                                } else {
                                    selection.append(fruit.id)
                                }
                            }
                        }
                }
            }
            .apply(isContainer ? () : nil) { view, _ in
                view.dragContainer(for: DragFruit.self) { ids in dragFruits.filter { ids.contains($0.id) } }
            }
            .apply(selects ? () : nil) { view, _ in view.dragContainerSelection(selection) }
            DropBox(items: dropped)
                .dropDestination(for: String.self) { items, _ in dropped += items }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/DragContainerSelectionEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let dragContainerSelection = CatalogEntry(
        id: "dragContainerSelection",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグの入れ物で、選んでいる札をまとめて運べるようにする modifier。選んだ札の 1 つを引くと、選んだ全部が運ばれる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/dragcontainerselection(_:containernamespace:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "dragContainerSelection", .fixed(code: "selection"), on: true,
                summary: "選んでいる札の id の配列。札を押すと選べる（橙になる）")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n            .draggable(containerItemID: fruit.id)\n            .onTapGesture { selection.append(fruit.id) }\n    }\n}",
            suffix: [".dragContainer(for: Fruit.self) { ids in fruits.filter { ids.contains($0.id) } }"]),
        build: { v in
            AnyView(DragContainerDemo(isContainer: true, selects: v["dragContainerSelection"] != nil))
        }
    )
}
```

`WidgetLab/Catalog/DragAndDrop/ReorderContainerEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let reorderContainer = CatalogEntry(
        id: "reorderContainer",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "中の View を、長押しして引くと並べ替えられる入れ物にする modifier。ForEach に reorderable() を付けて使う。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/reordercontainer(for:isenabled:move:)")!,
        stage: .card,
        properties: [
            .modifier(
                "reorderContainer", id: "reorderContainer.for", label: "for", .fixed(code: "Fruit.self"),
                required: true,
                summary: "並べるものの型（Identifiable）"),
            .modifier(
                "reorderContainer", id: "reorderContainer.isEnabled", label: "isEnabled", .toggle(initial: true),
                required: true, summary: "false にすると、付けたまま並べ替えられなくなる"),
            .modifier(
                "reorderContainer", label: "move", .fixed(code: "{ difference in fruits.apply(difference) }"), on: true,
                summary: "並べ替えたときの処理。動かした id と行き先を受け取り、配列を並べ直す"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    ForEach(fruits) { fruit in\n        Text(fruit.id)\n    }\n    .reorderable()\n}"),
        build: { v in
            AnyView(
                ReorderContainerDemo(
                    attaches: v["reorderContainer"] != nil, isEnabled: v.flag("reorderContainer.isEnabled") ?? true))
        }
    )
}

private struct ReorderContainerDemo: View {
    let attaches: Bool
    let isEnabled: Bool
    @State private var fruits = dragFruits

    var body: some View {
        HStack {
            ForEach(fruits) { fruit in
                DragChip(text: fruit.id)
            }
            .reorderable()
        }
        .apply(attaches ? () : nil) { view, _ in
            view.reorderContainer(for: DragFruit.self, isEnabled: isEnabled) { fruits.applyReorder($0) }
        }
    }
}
```

`WidgetLab/Catalog/DragAndDrop/SpringLoadingBehaviorEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let springLoadingBehavior = CatalogEntry(
        id: "springLoadingBehavior",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグしたまま上で少し待つと、ボタンなどが押される（スプリングロード）かを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/springloadingbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "springLoadingBehavior",
                .choice([Choice(".enabled"), Choice(".disabled"), Choice(".automatic")], initial: 0), on: true,
                summary: ".enabled なら、札を引いたままボタンの上で待つと押される。付けない（.automatic）と、このボタンは押されない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"りんご\")", "        .draggable(\"りんご\")"], indent: 4, call: "Button",
            fixedArguments: ["\"開いた回数: \\(count)\""], trailing: " { count += 1 }", closing: ["}"]),
        build: { v in
            AnyView(
                SpringLoadingBehaviorDemo(
                    behavior: v.pick(
                        "springLoadingBehavior", from: [SpringLoadingBehavior.enabled, .disabled, .automatic])
                ))
        }
    )
}

private struct SpringLoadingBehaviorDemo: View {
    /// nil なら springLoadingBehavior を付けない
    let behavior: SpringLoadingBehavior?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 24) {
            DragChip(text: "りんご")
                .draggable("りんご")
            Button("開いた回数: \(count)") { count += 1 }
                .buttonStyle(.bordered)
                .apply(behavior) { $0.springLoadingBehavior($1) }
        }
    }
}
```

- [ ] **Step 3: `Catalog.all` に並べる**

`WidgetLab/Catalog/Catalog.swift` の `all` の最後の行（`]` の前）に、1 行に 1 件ずつ足す（ほかの束が先に行を足していたら、その後ろに足す）:

```swift
        .dragContainer,
        .dragContainerSelection,
        .reorderContainer,
        .springLoadingBehavior,
```

- [ ] **Step 4: 代表のスクリーンショットのテストを足す**

`WidgetLabUITests/LaunchUITests.swift` の `/// 起動して、検索の結果から詳細を開く` の前に足す。タップの記録（`.behavior`）と、札を箱に落とすドラッグ（`.card`）の代表を 1 件ずつ撮る:

```swift
    @MainActor
    func testInputEntriesShowPreview() {
        let tap = openDetail(searching: "onTapGesture", entryID: "onTapGesture", title: ".onTapGesture")
        tap.buttons["2 回タップ"].doubleTap()
        XCTAssertTrue(tap.staticTexts["タップ（2 回）"].waitForExistence(timeout: 5), tap.debugDescription)
        attachScreenshot(tap, name: "onTapGesture")
        tap.terminate()
        let drag = openDetail(searching: "draggable", entryID: "draggable", title: ".draggable")
        let apple = drag.staticTexts.matching(NSPredicate(format: "label == %@", "りんご")).firstMatch
        let box = drag.staticTexts["ここに落とす"]
        apple.press(forDuration: 1, thenDragTo: box, withVelocity: .slow, thenHoldForDuration: 1)
        XCTAssertTrue(box.waitForNonExistence(timeout: 5), drag.debugDescription)
        attachScreenshot(drag, name: "draggable")
        drag.terminate()
    }

```

`docs/architecture.md` の構成の `WidgetLabUITests/` の行の「画面の行き来の代表 2 件ずつのスクリーンショットの 11 本」を、「画面の行き来・入力の代表 2 件ずつのスクリーンショットの 12 本」に置き換える（ほかの束が先に並びや本数を変えていたら、その並びの最後に「・入力」を足し、本数に 1 を足す）

- [ ] **Step 5: 収録の手引きに、試作でわかったことを足す**

`docs/cataloging-guide.md` を、次の 3 か所だけ直す（ほかの行は変えない。ほかの束が先に同じ所を直していたら、その文を残したまま足す）。

1. 5 章の「束 7 は `testNavigationEntriesShowPreview`）。」を「束 7 は `testNavigationEntriesShowPreview`、束 10 は `testInputEntriesShowPreview`）。」に置き換える
2. 7 章の最後の段落（`## 用語` の前）のあとに、空行を挟んで次の段落を足す:

```markdown
**ジェスチャーとキーの入力 → 起きたことは `.behavior` の記録に出し、動きが見えるものは `.card` にする（束 10）。** タップ・長押し・内側と外側のジェスチャーの勝ち負け・キーの入力は記録に出す。ドラッグ・拡大・回転は見本が動くので `.card` にする。UI テストでは `doubleTap()`・`press(forDuration:)`・`pinch(withScale:velocity:)`・`rotate(_:withVelocity:)` で操作して撮れる。的に `.accessibilityAddTraits(.isButton)` を付けたら `app.buttons[…]` で探し、記号の画像には `.accessibilityLabel` を付けて `app.images[…]` で探す。

**ハードウェアのキーボードの入力 → `typeKey` で試す。** シミュレータはハードウェアキーボードがつながっているので、`onKeyPress`・`keyboardShortcut` は UI テストの `typeKey(_:modifierFlags:)` で試せる。代わりに、入力欄をタップしても画面のキーボードは出ない（`submitLabel` は束 2 の `keyboardType` と同じく、入力欄にカーソルが入るところまで見る）。

**ドラッグとドロップ → iPhone のアプリの中で動くので `.card` にする。** 見本は、上に札（`DragChip`）、下に落とす先の箱（`DropBox`）を置く（`Catalog/DragAndDrop/DragAndDropDemo.swift`）。UI テストでは `press(forDuration: 1, thenDragTo: 箱, withVelocity: .slow, thenHoldForDuration: 1)` で落とせる。「動かす」と「写す」の違いは、元の札が消えるかで見せる（`onDragSessionUpdated` で `.ended(.move)` を見る）。`dragContainerSelection` は `dragContainer` の外側（あと）にかける。内側にかけると、選んでいても引いた札 1 つしか運ばれなかった。

**ジェスチャーを組み合わせる型 → 2 つのジェスチャーを、1 つの名前なしの引数（required）の選択肢にする。** `SequenceGesture`・`SimultaneousGesture`・`ExclusiveGesture` は片方だけでは書けず、`onChanged` の中身も組によって変わるため。比べるは出ない。

**id の頭を小文字にした名前が、ほかの id とぶつかる → 型の側に `Type` を付ける。** `SimultaneousGesture`（型）と `simultaneousGesture`（modifier）は、型の側の `static let` を `simultaneousGestureType` にした（束 10）。

**最初の値が「付けない」と同じ効き目 → 比べるで違いが出る値を最初にする。** `springLoadingBehavior` は、付けない（`.automatic`）と `.disabled` がどちらもボタンを押さなかったので、最初の値を `.enabled` にした。

**iPhone では出ないもの（束 10 で `.note` にした）:** ポインタの効果と出入り（`onHover`・`onContinuousHover`・`hoverEffect`・`hoverEffectDisabled`・`defaultHoverEffect`。iPhone にはポインタがない）、Apple Pencil（`onPencilDoubleTap`・`onPencilSqueeze`）、Apple Watch のダブルタップ（`handGestureShortcut`）。`onCameraCaptureEvent` は、撮影の画面とカメラが要るので `.note` にした（1 割の数に入る）。
```

3. 最後の行「最終更新: 2026-11-04（束 2〜7 のあと）」を「最終更新: 2026-11-04（束 2〜7・10 のあと）」に置き換える（ほかの束が先に変えていたら、括弧の中に「・10」を足す）


- [ ] **Step 6: 通ることを確かめる**

Run: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドから `-only-testing:WidgetLabTests` を外したもの（UI テストまで）
Expected: lint・道具のテスト・単体テスト・UI テストが全部通る（`testInputEntriesShowPreview` を含む）

Run: `python3 tools/catalog_progress.py gestures input-events drag-and-drop`
Expected: 終了コード 0。`合計 44 / 44（抜け 0）`（束 1 の TapGesture を含む）

- [ ] **Step 7: コミットする**

```bash
git add WidgetLab/Catalog/DragAndDrop/DragContainerEntry.swift WidgetLab/Catalog/DragAndDrop/DragContainerSelectionEntry.swift WidgetLab/Catalog/DragAndDrop/ReorderContainerEntry.swift WidgetLab/Catalog/DragAndDrop/SpringLoadingBehaviorEntry.swift WidgetLab/Catalog/Catalog.swift WidgetLabUITests/LaunchUITests.swift docs/architecture.md docs/cataloging-guide.md
git commit -m "feat: ドラッグとドロップの収録 dragContainer・dragContainerSelection・reorderContainer・springLoadingBehavior と束の確かめ

Co-Authored-By: Claude <実装したモデルの名前> <noreply@anthropic.com>"
```

## 終わったら

- 束の最終レビュー（opus）を通す
- `~/dev/widget-lab`（main）で、`git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からある）で、ほかの束がマージの途中でないことを確かめてから、`git merge --no-ff feat/swiftui-p3-input` する。`Catalog.swift`・`docs/architecture.md`・`docs/cataloging-guide.md`・`WidgetLabUITests/LaunchUITests.swift` がぶつかったら両方の行を残す
- マージのあと、main の `swiftui/` で lint と単体テスト（Global Constraints の確かめのコマンド）を通してから push する。ブランチは消さない
