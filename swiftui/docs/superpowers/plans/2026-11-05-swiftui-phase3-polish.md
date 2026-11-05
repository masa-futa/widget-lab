# SwiftUI 版 Phase 3 束 12（仕上げ）実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **要約**
> - 結論: 収録は足さずに、見た目と a11y の持ち越しの課題を 9 件直す。6 件は直さない（理由は下の表）。VoiceOver などオーナーが耳と手で確かめるものは、マージの前に確かめ、見つかったものはこの束で直す（2026-11-05 オーナーが決定）
> - 前提: [Phase 3 の spec](../specs/2026-11-02-swiftui-phase3-design.md) の「束 12」と「終わったと言える条件」、[次の段に回したこと](2026-11-02-swiftui-phase1-followups.md)、[束 11 の計画](2026-11-04-swiftui-phase3-a11y.md) の「残したこと」
> - 進め方: 試作（scratchpad のコピー）で直して画像で確かめ、lint・道具のテスト・`xcodebuild test` を通したコードを、この計画に写した。実装はファイルを写すだけにし、コントローラーが試作のファイルと `cmp` で比べる

**Goal:** 束 1〜11 から持ち越した見た目と a11y の課題を直し、Phase 3 を終える。

**Architecture:** 共通の UI（`Features/Catalog/UI`・`Features/Detail/UI`）と収録データ 3 件（`TapGesture`・`Binding`・`signInWithAppleButtonStyle`）だけを直す。`Catalog/Model/` の型・`CodeGenerator`・ADR の決まりは変えない。

**Tech Stack:** Xcode 27.0 / Swift 6 / SwiftUI / Swift Testing / XCTest（UI テスト）

## Global Constraints

- コマンドはすべて `swiftui/` で実行する
- シミュレータは `iPhone 17`（OS 27.0）。`-derivedDataPath build`（このワークツリーの `swiftui/build/`）を使う
- `xcodebuild` はふつう前で（終わるまで待って）実行する。裏で動かして `pgrep` で終わりを待つときは、ほかのワークツリーの xcodebuild に当たらないよう、derivedDataPath を絶対パス（`-derivedDataPath /Users/masakifutami/dev/widget-lab-p3-polish/swiftui/build`）で渡し、`pgrep -f "derivedDataPath /Users/masakifutami/dev/widget-lab-p3-polish/swiftui/build"` で待つ
- `swiftui/WidgetLab/Catalog/Model/` の型・`CodeGenerator`・ADR に書いた決まりは変えない。変えたくなったら止めてオーナーに聞く
- 文言は日本語。外部のパッケージは使わない
- 確かめのコマンド（全部）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120
  ```

---

## 課題の一覧と扱い（2026-11-05 オーナーが了承）

出どころ: A = [followups](2026-11-02-swiftui-phase1-followups.md)、B = spec の 71 行目、C = 束 3〜11 の計画の「残したこと」、メモ = 束 5〜10 のころの引き継ぎメモ（「束 12 に回したもの」）。

### 直す（9 件）

| # | 課題 | 出どころ | 直し方（試作で確かめた） | タスク |
|---|---|---|---|---|
| 1 | VoiceOver で TapGesture に 2 回・3 回のタップが届かない | A・B | 見本に `accessibilityAction` を足し、VoiceOver の操作で記録に「VoiceOver の操作で押した（N 回のタップの代わり）」と出す。要約にも書く | 4 |
| 2 | UI テストで比べるの左右を確かめていない | A・B | `.behavior` の左右の列に識別子 `side-without`・`side-with` を付け、列の中で「+1」と「描き直し N 回」を探す。付けない側が左にあることも確かめる | 3 |
| 3 | 記録の欄の高さが 90pt の決め打ち。文字を大きくすると見出しが伸びてログが入らず、Binding の Stepper が半分の幅からはみ出す | A・B | 高さを `@ScaledMetric(relativeTo: .caption)` の 90 にする。`.behavior` のプレビューは文字の大きさの上限を `accessibility1` にする（280pt に見本・描き直しの回数・記録の欄が入るように）。Binding の Stepper は、入らない幅ではラベルを上に置く（`ViewThatFits`） | 3 |
| 4 | 一覧の行の押したときの地を、決め打ちの余白（-20 / -12）で広げている | A・B | 行の余白を `.listRowInsets(EdgeInsets())` で 0 にし、スタイルが同じ余白（左 16・右 20・上下 15。iOS 27 の既定の行と撮り比べて合わせた）を持つ。押したときの地は行にちょうど重なる。区切り線は中身の頭から引く | 1 |
| 5 | コードの帯を VoiceOver で読むと「コードの全文を開く」としか聞こえない | A・B | ラベルを行の文字（空なら「コード」）、ヒントを「コードの全文を開く」にする | 2 |
| 6 | 選んでいるチップを色だけで示している（WCAG 1.4.1） | A・B | 選んでいるチップに tint の 2pt の縁を付ける。編集パネルの選択肢はチェックの印があるので直さない | 2 |
| 7 | 文字を大きくすると、プレビューの 280pt に押されて編集パネルが狭くなる | A・B | 文字がアクセシビリティの大きさのとき、`.behavior` 以外のプレビューを 220pt にする（`.behavior` は記録の欄が入るので 280pt のまま。試作で 360pt にしたら画面からはみ出した） | 2 |
| 8 | NoteView に ScrollView がない（理由が長い・文字が大きいと「…」で切れる） | メモ | `ViewThatFits(in: .vertical)` で、収まれば今までどおり真ん中、収まらなければ ScrollView で読む | 3 |
| 9 | Sign in with Apple のダークモードの見た目 | メモ（束 5） | 撮ってみると、OFF（既定）はダークモードでも `.black` で、最初の値の `.black` と同じ見た目だった（比べるで違いが出ない。ダークでは黒いボタンが地に沈む）。最初の値を `.white` にし、要約に「OFF なら既定の .black（ダークモードでも黒のまま）」と書く | 4 |

### 直さない（6 件）

| 課題 | 出どころ | 理由 |
|---|---|---|
| 道具: キャッシュを一時ファイルに書いてから置き換える・JSON が欠けたときの警告・節の数え方のテスト | A（時間のあるとき） | 見た目でも a11y でもない |
| UI テストの準備を補助の関数にまとめる | A（時間のあるとき） | 同上。#2 では足りたので、まとめない |
| `FakeClipboard` の `@unchecked Sendable`・`CodeGeneratorTests` の 1 件 | A（時間のあるとき） | 同上。`CodeGenerator` まわりは決まりに触れるので、この束では触らない |
| 補助の名前（`A11yDemo` など）がモジュール全体で見える | C（束 11） | 申し送りで、課題ではない |
| 比べるで、左右の札が仕切りで切れて重なる | C（束 11） | ほかの束と同じ見え方。束 11 でそのままにすると決めた |
| `CatalogTests` の FocusState の実行時の警告 | C（束 11） | 失敗ではない。束 9 の警告と同じ種類 |

### オーナーが耳と手で確かめる（マージの前。Task 6）

| 確かめること | 出どころ |
|---|---|
| 大きく出す画面（`accessibilityShowsLargeContentViewer`）の見た目 | C（束 11） |
| スマート反転（`accessibilityIgnoresInvertColors`）の見た目 | C（束 11） |
| VoiceOver で代表を触る: speech の 4 件・ローター・操作の一覧・カーソルの移動 | C（束 11） |
| `speechAnnouncementsQueued`・`accessibilityLinkedGroup`・`accessibilityActivationPoint`・`accessibilityLabeledPair` | C（束 11 の最終レビュー） |
| この束で直したもの（#1・#4・#5・#6・#8 ほか）を耳と手で | この束 |

## ファイルの地図

| ファイル | 責務 | タスク |
|---|---|---|
| `WidgetLab/Features/Catalog/UI/NavigationRowButtonStyle.swift` | 一覧の行の見た目。余白と押したときの地を持つ | 1 |
| `WidgetLab/Features/Catalog/UI/HomeScreen.swift`・`TopicScreen.swift` | 行に `.listRowInsets(EdgeInsets())` を付ける | 1 |
| `WidgetLab/Features/Detail/UI/DetailScreen.swift` | プレビューの高さ（#7）、コードの帯の読み上げ（#5） | 2 |
| `WidgetLab/Features/Detail/UI/PropertyChips.swift` | 選んでいるチップの縁（#6） | 2 |
| `WidgetLab/Features/Detail/UI/PreviewArea.swift` | `.behavior` の文字の上限・左右の識別子（#2・#3）、NoteView（#8） | 3 |
| `WidgetLab/Features/Detail/UI/RecordPanel.swift` | 記録の欄の高さ（#3） | 3 |
| `WidgetLab/Catalog/ModelData/BindingEntry.swift` | Stepper のはみ出し（#3） | 3 |
| `WidgetLab/Catalog/Gestures/TapGestureEntry.swift` | VoiceOver の操作（#1） | 4 |
| `WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift` | 最初の値と要約（#9） | 4 |
| `WidgetLabUITests/LaunchUITests.swift` | コードの帯のラベル（#5）、左右の列（#2） | 2・3 |
| `docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md`・`docs/cataloging-guide.md`・この計画 | 済の印と、直したこと | 5 |

## コントローラーへ: 写したあとの比べ方

試作は `/private/tmp/claude-501/-Users-masakifutami-dev-widget-lab-p3-polish/98361552-eaa4-4de4-a266-779298d0bf17/scratchpad/proto/swiftui/` にある（セッションが変わって消えていたら、この計画のコードが正本）。各タスクのあとで、そのタスクのファイルを `cmp <ワークツリーのファイル> <試作のファイル>` で比べる。同じなら、タスクごとのレビューはそれで足りる（手引きの 2 章）。`LaunchUITests.swift` は Task 3 のあとで比べる。

---

### Task 1: 一覧の行の押したときの地を、行にちょうど合わせる（#4）

**Files:**
- Modify: `WidgetLab/Features/Catalog/UI/NavigationRowButtonStyle.swift`（全体を置き換える）
- Modify: `WidgetLab/Features/Catalog/UI/HomeScreen.swift`（2 か所に 1 行ずつ）
- Modify: `WidgetLab/Features/Catalog/UI/TopicScreen.swift`（1 か所に 1 行）

**Interfaces:**
- Consumes: なし
- Produces: `NavigationRowButtonStyle` は行の余白を自分で持つ。`.buttonStyle(.navigationRow)` を使う行には、必ず `.listRowInsets(EdgeInsets())` を付ける

押したときの地は UI テストでは撮れない（押している間に撮れない）ので、テストは足さない。見た目は Task 6 でオーナーが指で確かめる。行の余白が変わっていないことは、試作で直す前と後のホームを撮り比べて確かめた。

- [ ] **Step 1: `NavigationRowButtonStyle.swift` を次の中身に置き換える**

```swift
import SwiftUI

/// 次の画面へ進む一覧の行。文字は tint にせず、右端に矢印を出す（NavigationLink の行と同じ見た目）
/// 押したときの地を行いっぱいに塗るため、行の余白はこのスタイルが持つ。使う側で `.listRowInsets(EdgeInsets())` を付ける
struct NavigationRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .foregroundStyle(.primary)
        // List の行の既定の余白と同じ（iOS 27 で撮って合わせた）
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.vertical, 15)
        // 区切り線は、余白を除いた中身の頭から引く
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] + 16 }
        .contentShape(.rect)
        .background {
            if configuration.isPressed {
                Color(.systemFill)
            }
        }
    }
}

extension ButtonStyle where Self == NavigationRowButtonStyle {
    static var navigationRow: NavigationRowButtonStyle { NavigationRowButtonStyle() }
}
```

- [ ] **Step 2: `HomeScreen.swift` の 2 か所に `.listRowInsets(EdgeInsets())` を足す**

トピックの行（`TopicRow`）:

```swift
                            .buttonStyle(.navigationRow)
                            .listRowInsets(EdgeInsets())
                            .accessibilityIdentifier("topic-\(summary.topic.rawValue)")
```

検索の結果の行（`EntryRow`）:

```swift
                    .buttonStyle(.navigationRow)
                    .listRowInsets(EdgeInsets())
                    .accessibilityIdentifier("entry-\(entry.id)")
```

- [ ] **Step 3: `TopicScreen.swift` の 1 か所に足す**

```swift
            .buttonStyle(.navigationRow)
            .listRowInsets(EdgeInsets())
            .accessibilityIdentifier("entry-\(entry.id)")
```

- [ ] **Step 4: lint とビルド、UI テストの検索から詳細を開く 1 本を通す**

Run:
```
xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
  && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
     -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
     -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
     -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
     -only-testing:WidgetLabUITests/LaunchUITests/testLayoutEntriesShowPreview
```
Expected: lint の出力なし、`** TEST SUCCEEDED **`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Features/Catalog/UI/NavigationRowButtonStyle.swift WidgetLab/Features/Catalog/UI/HomeScreen.swift WidgetLab/Features/Catalog/UI/TopicScreen.swift
git commit -m "fix: 一覧の行の押したときの地を、決め打ちの余白でなく行の大きさに合わせる"
```

---

### Task 2: 詳細の上の部分（コードの帯の読み上げ・チップの縁・大きい文字のときのプレビューの高さ）（#5・#6・#7）

**Files:**
- Modify: `WidgetLab/Features/Detail/UI/DetailScreen.swift`（全体を置き換える）
- Modify: `WidgetLab/Features/Detail/UI/PropertyChips.swift`（全体を置き換える）
- Test: `WidgetLabUITests/LaunchUITests.swift`（`testSearchOpenDetailAndCopyCode` に 2 行）

**Interfaces:**
- Consumes: なし
- Produces: コードの帯（識別子 `code-strip`）の accessibility のラベルは、選んでいる行のコード（前後の空白を除いたもの）。ヒントは「コードの全文を開く」

- [ ] **Step 1: 失敗するテストを書く**

`LaunchUITests.swift` の `testSearchOpenDetailAndCopyCode` を次のようにする（2 行を足す）:

```swift
    @MainActor
    func testSearchOpenDetailAndCopyCode() {
        let app = openDetail(searching: "pad", entryID: "padding", title: ".padding")
        // VoiceOver では、コードの帯をコードの 1 行として読む
        XCTAssertEqual(app.buttons["code-strip"].label, ".padding(24)")
        app.buttons["code-strip"].tap()
        app.buttons["copy"].tap()
        XCTAssertTrue(app.buttons["コピーしました"].waitForExistence(timeout: 5))
    }
```

- [ ] **Step 2: 失敗を確かめる**

Run:
```
xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
  -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
  -only-testing:WidgetLabUITests/LaunchUITests/testSearchOpenDetailAndCopyCode
```
Expected: FAIL（`("コードの全文を開く") is not equal to (".padding(24)")`）

- [ ] **Step 3: `DetailScreen.swift` を次の中身に置き換える**

```swift
import SwiftUI

/// 詳細。上にプレビューとコードの 1 行、その下にチップの列、下半分に編集パネル
struct DetailScreen: View {
    @Bindable var viewModel: DetailViewModel
    @State private var showsInfo = false
    @State private var showsCode = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            PreviewArea(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: previewHeight)
            CodeStrip(line: viewModel.selectedLine) { showsCode = true }
            PropertyChips(viewModel: viewModel)
            Divider()
            EditorPanel(viewModel: viewModel)
        }
        .navigationTitle(viewModel.entry.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("初期状態に戻す", systemImage: "arrow.counterclockwise") { viewModel.reset() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("説明", systemImage: "info.circle") { showsInfo = true }
            }
        }
        .sheet(isPresented: $showsInfo) {
            InfoSheet(entry: viewModel.entry)
        }
        .sheet(isPresented: $showsCode) {
            CodeSheet(viewModel: viewModel)
        }
    }

    /// プレビューの高さ。文字がアクセシビリティの大きさのときは、編集パネルに場所を譲る
    /// （見た目を持たないものは記録の欄も入るので、低くしない）
    private var previewHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize && viewModel.entry.stage != .behavior ? 220 : 280
    }
}

/// 選んでいるプロパティのコードの 1 行。押すと全文のシートを開く
private struct CodeStrip: View {
    let line: CodeLine?
    let onTap: () -> Void

    private var text: String { line?.text.trimmingCharacters(in: .whitespaces) ?? "" }

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.footnote)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(.fill.tertiary)
        }
        .buttonStyle(.plain)
        // VoiceOver でもコードを読めるよう、ラベルは行の文字にする
        .accessibilityLabel(text.isEmpty ? "コード" : text)
        .accessibilityHint("コードの全文を開く")
        .accessibilityIdentifier("code-strip")
    }
}

/// ⓘ から開く説明
private struct InfoSheet: View {
    let entry: CatalogEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(entry.summary)
                    Link("公式ドキュメントを開く", destination: entry.docURL)
                }
                Section("プロパティ") {
                    ForEach(entry.properties) { spec in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spec.displayName).font(.system(.body, design: .monospaced))
                            Text(spec.summary).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
```

- [ ] **Step 4: `PropertyChips.swift` を次の中身に置き換える**

```swift
import SwiftUI

/// プロパティのチップの列（名前と今の値）。押すと選ぶ
struct PropertyChips: View {
    @Bindable var viewModel: DetailViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.entry.properties) { spec in
                    Button {
                        viewModel.selectedID = spec.id
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spec.displayName)
                                .font(.system(.caption, design: .monospaced))
                            Text(viewModel.valueLabel(spec.id))
                                .font(.caption2)
                                .foregroundStyle(viewModel.isOn(spec.id) ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44)
                        .background(
                            viewModel.selectedID == spec.id
                                ? AnyShapeStyle(.tint.opacity(0.2)) : AnyShapeStyle(.fill.tertiary),
                            in: .rect(cornerRadius: 10)
                        )
                        .overlay {
                            // 色のほかに、縁の形でも選んでいることを示す（WCAG 1.4.1）
                            if viewModel.selectedID == spec.id {
                                RoundedRectangle(cornerRadius: 10).strokeBorder(.tint, lineWidth: 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(viewModel.selectedID == spec.id ? .isSelected : [])
                    .accessibilityIdentifier("chip-\(spec.id)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
```

- [ ] **Step 5: 通ることを確かめる**

Run: Step 2 と同じコマンドの前に `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests &&` を付けて実行する
Expected: lint の出力なし、`** TEST SUCCEEDED **`

- [ ] **Step 6: コミット**

```bash
git add WidgetLab/Features/Detail/UI/DetailScreen.swift WidgetLab/Features/Detail/UI/PropertyChips.swift WidgetLabUITests/LaunchUITests.swift
git commit -m "fix: コードの帯をコードとして読み上げ、選んでいるチップに縁を付け、大きい文字ではプレビューを低くする"
```

---

### Task 3: プレビュー（左右の列の識別子・記録の欄の高さ・NoteView のスクロール・Binding の Stepper）（#2・#3・#8）

**Files:**
- Modify: `WidgetLab/Features/Detail/UI/PreviewArea.swift`（全体を置き換える）
- Modify: `WidgetLab/Features/Detail/UI/RecordPanel.swift`（全体を置き換える）
- Modify: `WidgetLab/Catalog/ModelData/BindingEntry.swift`（全体を置き換える）
- Test: `WidgetLabUITests/LaunchUITests.swift`（`testStateRedrawsOnlyWithWrapper` と補助の関数 `redraws(in:)`）

**Interfaces:**
- Consumes: なし
- Produces: `.behavior` の比べるで、左の列は accessibility の識別子 `side-without`、右の列は `side-with` の入れ物（`.accessibilityElement(children: .contain)`）。UI テストでは `app.otherElements["side-with"]` で取れる。`RecordPanel` は自分で高さを持つので、使う側で `.frame(height:)` を付けない

- [ ] **Step 1: 失敗するテストを書く**

`LaunchUITests.swift` の `testStateRedrawsOnlyWithWrapper` を、次の中身に置き換える:

```swift
    @MainActor
    func testStateRedrawsOnlyWithWrapper() {
        let app = openDetail(searching: "@State", entryID: "State", title: "@State")
        let compare = app.switches["compare"]
        XCTAssertTrue(compare.waitForExistence(timeout: 5), app.debugDescription)
        compare.tap()
        // 左右の列の中で探す（並びの番号に頼らない）
        let without = app.otherElements["side-without"]
        let with = app.otherElements["side-with"]
        XCTAssertTrue(with.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(without.exists, app.debugDescription)
        XCTAssertLessThan(without.frame.midX, with.frame.midX, "付けない側が左")
        let withoutRedraws = redraws(in: without)
        let withRedraws = redraws(in: with)
        without.buttons["+1"].tap()
        with.buttons["+1"].tap()
        XCTAssertTrue(with.staticTexts["count: 1"].waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertTrue(without.staticTexts["count: 0"].exists, "付けない側の表示は変わらない")
        XCTAssertGreaterThan(redraws(in: with), withRedraws, "付けた側は描き直す")
        XCTAssertEqual(redraws(in: without), withoutRedraws, "付けない側は描き直さない")
        attachScreenshot(app, name: "state-compare")
    }
```

同じファイルの `/// 起動して、検索の結果から詳細を開く` の行の上に、補助の関数を足す:

```swift
    /// 列の上の「描き直し N 回」の N
    @MainActor
    private func redraws(in column: XCUIElement) -> Int {
        let label = column.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "描き直し")).firstMatch.label
        return Int(label.filter(\.isNumber)) ?? -1
    }
```

- [ ] **Step 2: 失敗を確かめる**

Run:
```
xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
  -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120 \
  -only-testing:WidgetLabUITests/LaunchUITests/testStateRedrawsOnlyWithWrapper
```
Expected: FAIL（`side-with` が見つからず `waitForExistence` が false）

- [ ] **Step 3: `PreviewArea.swift` を次の中身に置き換える**

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
                VStack(spacing: 0) {
                    // 見本に重ならないよう、比べるの切り替えは記録の欄の見出しに置く
                    content
                    Divider()
                    RecordPanel(recorder: viewModel.recorder, showsSide: viewModel.comparison != nil) {
                        compareToggle
                    }
                }
                // 見本・描き直しの回数・記録の欄が 280pt に入るよう、文字の大きさの上限を決める
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
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
        // UI テストが左右の列の中で探せるよう、列を 1 つの入れ物にする
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(side == .with ? "side-with" : "side-without")
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
                    // どのプロパティを切り替えるかを目で見えるようにする（VoiceOver は Picker のラベルで読める）
                    Text(selected.displayName)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
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
        // 収まるなら枠の真ん中に、収まらない（理由が長い・文字が大きい）ならスクロールで読む
        ViewThatFits(in: .vertical) {
            message
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                message
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var message: some View {
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

- [ ] **Step 4: `RecordPanel.swift` を次の中身に置き換える**

```swift
import SwiftUI

/// 見た目を持たないものの記録の欄。イベントのログを新しい順に出す。見出しの行に accessory（比べるの切り替え）を置く
struct RecordPanel<Accessory: View>: View {
    let recorder: DetailRecorder
    /// 比べているとき、行の頭に側を付ける
    let showsSide: Bool
    @ViewBuilder let accessory: Accessory
    /// 見出しの 1 行とログの 3 行が入る高さ。文字の大きさに合わせて伸ばす
    @ScaledMetric(relativeTo: .caption) private var height: CGFloat = 90

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("記録")
                    .font(.caption.bold())
                Spacer()
                accessory
                Button {
                    recorder.clear()
                } label: {
                    Text("消す").frame(minWidth: 44, minHeight: 44)
                }
                .font(.caption)
                .disabled(recorder.lines.isEmpty)
            }
            if recorder.lines.isEmpty {
                Text("見本を触ると、ここに記録が出ます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(recorder.lines) { line in
                            Text(showsSide ? "\(line.side.title): \(line.text)" : line.text)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
        .frame(height: height)
    }
}

extension RecordSide {
    /// 比べるときの見出し
    var title: String {
        switch self {
        case .with: "付けた"
        case .without: "付けない"
        }
    }
}
```

- [ ] **Step 5: `BindingEntry.swift` を次の中身に置き換える**

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let binding = CatalogEntry(
        id: "Binding",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "ほかの View が持つ値を読み書きする参照。子の View から親の値を変えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/binding")!,
        stage: .behavior,
        properties: [
            .wrapper("Binding", summary: "外して値のコピーを持つと、子で変えても親に届かない。描き直しの回数は、SwiftUI の都合で 1〜2 回ずれることがある")
        ],
        code: CodeTemplate(
            call: "Binding",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: $count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@Binding var count: Int",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@State var count: Int  // 親の値のコピー",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ])),
        build: { v in
            AnyView(BindingDemo.Parent(usesBinding: v["Binding"] != nil))
        }
    )
}

private enum BindingDemo {
    struct Parent: View {
        let usesBinding: Bool
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Text("親: \(count)")
                    .monospacedDigit()
                if usesBinding {
                    BoundChild(count: $count)
                } else {
                    CopiedChild(count: count)
                }
            }
        }
    }

    struct BoundChild: View {
        @Binding var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした") }
        }
    }

    struct CopiedChild: View {
        /// 親の値のコピー
        @State var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした（親には届かない）") }
        }
    }

    struct ChildStepper: View {
        @Binding var count: Int

        var body: some View {
            // 文字が大きくて半分の幅に入らないときは、ラベルを上に置く
            ViewThatFits(in: .horizontal) {
                Stepper(value: $count) { label }
                    .fixedSize()
                VStack(spacing: 4) {
                    label
                    Stepper(value: $count) { label }
                        .labelsHidden()
                }
            }
        }

        private var label: some View {
            Text("子: \(count)").monospacedDigit()
        }
    }
}
```

- [ ] **Step 6: 通ることを確かめる**

Run: Step 2 と同じコマンドの前に `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests &&` を付け、`-only-testing:` を `-only-testing:WidgetLabUITests/LaunchUITests/testStateRedrawsOnlyWithWrapper -only-testing:WidgetLabTests/CatalogTests` にして実行する
Expected: lint の出力なし、`** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Features/Detail/UI/PreviewArea.swift WidgetLab/Features/Detail/UI/RecordPanel.swift WidgetLab/Catalog/ModelData/BindingEntry.swift WidgetLabUITests/LaunchUITests.swift
git commit -m "fix: 記録の欄を文字の大きさに合わせ、NoteView をスクロールでき、UI テストで比べるの左右を確かめる"
```

---

### Task 4: 収録の 2 件（TapGesture の VoiceOver の操作・Sign in with Apple の最初の値）（#1・#9）

**Files:**
- Modify: `WidgetLab/Catalog/Gestures/TapGestureEntry.swift`（全体を置き換える）
- Modify: `WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift`（全体を置き換える）

**Interfaces:**
- Consumes: なし
- Produces: なし（コードの形は変えない。`DetailViewModelTests.tapGestureCodeWritesCountAndOmitsItWhenOff` はそのまま通る）

VoiceOver の操作は UI テストから出せないので、#1 は Task 6 でオーナーが耳と手で確かめる。#9 は、最初の値が変わっても全件の組み立てのテスト（`CatalogTests`）が選択肢ごとに通すので、テストは足さない。

- [ ] **Step 1: `TapGestureEntry.swift` を次の中身に置き換える**

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let tapGesture = CatalogEntry(
        id: "TapGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった回数のタップを認識するジェスチャー。VoiceOver の操作はジェスチャーを通らないので、この見本は accessibilityAction で同じ記録を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/tapgesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "認識するタップの回数。省くと 1 回")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(TapGesture", trailing: ".onEnded { })"),
        build: { v in
            AnyView(TapGestureDemo(count: v.number("count").map { Int($0) }))
        }
    )
}

private struct TapGestureDemo: View {
    /// nil なら TapGesture()（1 回）
    let count: Int?
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        RoundedRectangle(cornerRadius: 12)
            .fill(.tint.opacity(0.25))
            .frame(width: 120, height: 72)
            .overlay {
                Text("\(count ?? 1) 回タップ")
                    .font(.caption)
            }
            .gesture(gesture.onEnded { recorder?.log("タップを認識（\(count ?? 1) 回）") })
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            // VoiceOver の操作は 1 回の押す操作として届き、2 回以上の TapGesture は認識しない。同じ記録を出す
            .accessibilityAction { recorder?.log("VoiceOver の操作で押した（\(count ?? 1) 回のタップの代わり）") }
    }

    private var gesture: TapGesture {
        if let count { TapGesture(count: count) } else { TapGesture() }
    }
}
```

- [ ] **Step 2: `SignInWithAppleButtonStyleEntry.swift` を次の中身に置き換える**

```swift
import AuthenticationServices
import SwiftUI

nonisolated extension CatalogEntry {
    static let signInWithAppleButtonStyle = CatalogEntry(
        id: "signInWithAppleButtonStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "「Apple でサインイン」のボタンの色を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/signinwithapplebuttonstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "signInWithAppleButtonStyle",
                .choice([Choice(".black"), Choice(".white"), Choice(".whiteOutline")], initial: 1), on: true,
                summary: "ボタンの色。OFF なら既定の .black になる（ダークモードでも黒のまま）")
        ],
        code: CodeTemplate(
            prefix: ["// import AuthenticationServices が要る"], indent: 0, call: "SignInWithAppleButton",
            fixedArguments: [".signIn"], trailing: " { request in\n} onCompletion: { result in\n}",
            suffix: [".frame(width: 260, height: 48)"]),
        build: { v in
            AnyView(
                SignInWithAppleButton(.signIn) { _ in
                } onCompletion: { _ in
                }
                .apply(
                    v.pick(
                        "signInWithAppleButtonStyle", from: [SignInWithAppleButton.Style.black, .white, .whiteOutline])
                ) { $0.signInWithAppleButtonStyle($1) }
                .frame(width: 260, height: 48)
            )
        }
    )
}
```

- [ ] **Step 3: 全部の確かめを通す**

Run: Global Constraints の「確かめのコマンド（全部）」
Expected: lint の出力なし、道具のテストは `OK`、`** TEST SUCCEEDED **`

- [ ] **Step 4: コミット**

```bash
git add WidgetLab/Catalog/Gestures/TapGestureEntry.swift WidgetLab/Catalog/ViewStyles/SignInWithAppleButtonStyleEntry.swift
git commit -m "fix: TapGesture の見本を VoiceOver の操作でも記録し、Sign in with Apple の最初の値を既定と違う .white にする"
```

---

### Task 5: ドキュメントに済の印と、決めたことを書く

**Files:**
- Modify: `docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md`
- Modify: `docs/cataloging-guide.md`

- [ ] **Step 1: followups の「Phase 2 のレビューで、次の段に回したこと」の 3 行に済の印を付ける**

3 行（VoiceOver での複数回のタップ・UI テストで左右を確かめる・記録の欄の高さ）の「こと」の頭に `済: ` を付け、「中身」の末尾の `→ Phase 3 の束 12（仕上げ）で扱う` を、それぞれ次に置き換える:

- VoiceOver での複数回のタップ: `→ 見本に accessibilityAction を足し、VoiceOver の操作でも記録に出す（束 12）`
- UI テストで左右を確かめる: `→ 左右の列に識別子（side-without・side-with）を付け、列の中で探す。描き直しの回数も確かめる（束 12）`
- 記録の欄の高さ: `→ 高さを @ScaledMetric にし、.behavior のプレビューは文字の大きさの上限を accessibility1 にした。Stepper は入らない幅でラベルを上に置く（束 12）`

- [ ] **Step 2: followups の「時間のあるときに直す」の 4 行に済の印を付ける**

次の 4 行の頭（`- ` のあと）に `済（束 12）: ` を付ける。ほかの 3 行（道具・UI テストの準備・`FakeClipboard`）はそのまま残す。

- 一覧の行の押したときの地は、…
- コードの 1 行の帯は、…
- チップの選んでいる状態を、…
- 文字を大きくしたとき、プレビューの高さ 280pt で…

- [ ] **Step 3: 収録の手引きの 7 章に 1 項目足す**

`docs/cataloging-guide.md` の 7 章「困ったとき」の最後の項目のあと（`## 用語` の前）に、空の行をはさんで次の段落を足す:

```markdown
**`.behavior` の見本の文字は、大きくしても accessibility1 で止まる（束 12）。** プレビューの 280pt に、見本・描き直しの回数・記録の欄を入れるため、`PreviewArea` が `.behavior` の分だけ `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` をかけている。文字の大きさで効き目が変わる見本は `.card` にする（`.card` には上限をかけない）。半分の幅に入らない部品は、`ViewThatFits(in: .horizontal)` で縦に並べ替える（`BindingEntry` の Stepper）。
```

- [ ] **Step 4: コミット**

```bash
git add docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md docs/cataloging-guide.md
git commit -m "docs: 束 12 で直した持ち越しの課題に済の印を付け、.behavior の文字の上限を手引きに書く"
```

---

### Task 6: オーナーが耳と手で確かめる（マージの前）

サブエージェントには渡さない。コントローラーが、Task 1〜5 のあとで、この節をオーナーに見せて止まる。オーナーは Xcode で `WidgetLab.xcodeproj` を開き、iPhone 17 のシミュレータ（または実機）で動かす。見つかったものはこの束で直し（直したら Task 7 の前にこの計画の「確かめた結果」に書く）、直さないものは理由を書いて followups に回す。

VoiceOver はシミュレータでは使えないので、実機で確かめる（シミュレータでは Xcode の Accessibility Inspector で読み上げの内容までは見られる）。

**A. 束 11 から持ち越したもの**

| # | 見るもの | 手順 | 期待 |
|---|---|---|---|
| A1 | `accessibilityShowsLargeContentViewer` | 設定 → アクセシビリティ → 画面表示とテキストサイズ → さらに大きな文字 を ON にし、いちばん大きくする。アプリでこの収録を開き、見本の部品を長押しする | 付けた側は、画面の真ん中に大きく出る。付けない側は出ない |
| A2 | `accessibilityIgnoresInvertColors` | 設定 → アクセシビリティ → 画面表示とテキストサイズ → 反転（スマート）を ON にし、この収録を開く | 付けた側の見本は色が反転しない。付けない側は反転する |
| A3 | speech の 4 件（`speechAdjustedPitch`・`speechAlwaysIncludesPunctuation`・`speechAnnouncementsQueued`・`speechSpellsOutCharacters`） | VoiceOver を ON にし、それぞれの見本を読ませる。比べるの左右を聞き比べる | 付けた側だけ、声の高さ・句読点・続けて読む・1 文字ずつ、が変わる。`speechAnnouncementsQueued` は、カーソルが「進める」にあるときも値の読み上げが変わるか（変わらないなら要約に書く） |
| A4 | ローター（`accessibilityRotor`・`AccessibilityRotorEntry`） | VoiceOver で 2 本の指を回してローターを出す | 収録した名前の項目が出て、上下のスワイプでその要素へ移る |
| A5 | 操作の一覧（`accessibilityAction`・`accessibilityActions`） | 見本に VoiceOver のカーソルを置き、上下にスワイプする | 収録した名前の操作が読まれ、ダブルタップで記録・表示が変わる |
| A6 | カーソルの移動（`accessibilityFocused`・`AccessibilityFocusState`・`accessibilitySortPriority`） | 見本のボタンで移動させる・左右のスワイプで順に読む | カーソルが指定の要素へ移る。読む順が sort priority のとおり |
| A7 | `accessibilityLinkedGroup` | VoiceOver で見本の中を行き来する | どの操作で組の間を行き来するかを書き留める（公式に書かれていないため。要約に書く） |
| A8 | `accessibilityActivationPoint` | VoiceOver で見本をダブルタップする | 付けた側は、押す場所の指定どおりの部品が切り替わる。`.combine` でまとまっていて場所にかかわらず切り替わるなら、要約に書くか見本を直す |
| A9 | `accessibilityLabeledPair` | VoiceOver で見本を読む | 組にした値の要素がラベルといっしょに読まれる。ラベルの要素が別に残るかを書き留める |

**B. この束で直したもの**

| # | 見るもの | 手順 | 期待 |
|---|---|---|---|
| B1 | #1 `TapGesture` | VoiceOver で、回数 2 の見本をダブルタップする | 記録に「VoiceOver の操作で押した（2 回のタップの代わり）」が出る |
| B2 | #5 コードの帯 | VoiceOver で詳細のコードの帯を読む | コードの 1 行が読まれ、ヒント「コードの全文を開く」が続く |
| B3 | #6 チップ | 詳細でチップを選ぶ | 選んだチップに tint の縁が付く。VoiceOver では「選択済み」が読まれる |
| B4 | #4 一覧の行 | ホーム・トピック・検索の結果の行を指で押したままにする（iPhone と、あれば iPad） | 押している間、行いっぱいに地が付き、はみ出さず、足りなくもない |
| B5 | #3・#7・#8 大きい文字 | さらに大きな文字をいちばん大きくし、`@Binding`（比べる）・`.padding`・`.assistiveAccessNavigationIcon` を開く | 記録の欄が崩れず、Stepper がはみ出さない。`.padding` の編集パネルが前より広い。NoteView の理由をスクロールで最後まで読める |
| B6 | #9 Sign in with Apple | ライトとダークで `.signInWithAppleButtonStyle` を開き、比べるを ON にする | 左（付けない・黒）と右（付けた・白）の違いが見える |

---

### Task 7: 束の最終レビューとマージ

- [ ] **Step 1: 全部の確かめを通す**（Global Constraints のコマンド。`** TEST SUCCEEDED **`）
- [ ] **Step 2: 束の最終レビュー（opus）**: `git diff 0b9f21e..HEAD` を、この計画・spec・手引き・ADR と照らしてレビューする。直したものと残したものを、この計画の末尾に「束の最終レビューで直したこと」「残したこと」として書いてコミットする
- [ ] **Step 3: マージの前に main を確かめる**: `git -C ~/dev/widget-lab status` がきれい（`.claude/` の未追跡は元からあるので可）
- [ ] **Step 4: マージ**: `git -C ~/dev/widget-lab merge --no-ff feat/swiftui-p3-polish -m "Merge branch 'feat/swiftui-p3-polish': SwiftUI 版 Phase 3 束 12（仕上げ。見た目と a11y の持ち越しの課題）"`。ブランチは消さない
- [ ] **Step 5: main で lint と単体テストを流す**: `~/dev/widget-lab/swiftui` で `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && python3 -m unittest discover tools && xcodebuild test ... -only-testing:WidgetLabTests`（derivedDataPath は `build`）
- [ ] **Step 6: push はオーナーに頼んで止まる**（サンドボックスの中からは SSH で push できない）。`git -C ~/dev/widget-lab push origin main`

---

## 確かめた結果（2026-11-05 オーナー）

A1〜A9・B1〜B6 は、全部期待どおりだった。A7（`accessibilityLinkedGroup` の行き来）・A9（`accessibilityLabeledPair` のラベルの要素）の書き留める点も、特に問題はない。この束で直すものはない。
