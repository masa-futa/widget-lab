# SwiftUI 版 Phase 3 土台 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 全トピックの収録（束 1〜11）に入る前に、収録の型（modifier の id・複数の引数・小数・説明だけの stage）と道具・テストを直す。収録の件数は増やさない。

**Architecture:** 収録データの型（`WidgetLab/Catalog/Model/`）に、modifier のプロパティの id と required、同じ modifier の引数を 1 行にまとめるコード生成、`DemoStage.note(reason:)` を足す。詳細画面は `.note` のとき見本の代わりに理由を出し、比べるを出さない。道具に `tools/catalog_progress.py` を足し、テストの `print` の代わりにする。

**Tech Stack:** Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）/ SwiftUI / Observation / Swift Testing / XCTest（UI テストだけ）/ swift-format / Python 3（道具）

**Spec:** `swiftui/docs/superpowers/specs/2026-11-02-swiftui-phase3-design.md` の「土台の PR」

## Global Constraints

- コマンドはすべて `swiftui/` で実行する。外部のパッケージは使わない
- 収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にする（extension も `nonisolated extension` / `nonisolated private extension`）。組み立ての関数と記録の窓口だけが `@MainActor`
- 依存の向きは `UI → ViewModel → Repository`。`Catalog/` から `Features/` と `Core/` は参照しない
- 文言は日本語のみ。コメントも日本語で、まわりのコードと同じ密度にする
- 今の収録 7 件（`Button`・`Text`・`VStack`・`padding`・`State`・`Binding`・`TapGesture`）は書き直さない。`PropertySpec.modifier` の新しい引数はどれも省略できる
- `WidgetLab/Catalog/Generated/` は道具の出力。リファレンスのキャッシュ（`tools/.cache`）がこの作業場所にないので、道具を走らせずに、道具の出力と同じになるよう手で直す（Task 1）
- 確かめ（各タスクの終わり）:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO \
       -test-timeouts-enabled YES -maximum-test-execution-time-allowance 120
  ```
  単体テストだけなら末尾に `-only-testing:WidgetLabTests` を付ける。整形は `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests`
- テストが進まず止まったら（試作で、途中で止めた実行のあとに起きた）: `pkill -f "xcodebuild test"` → `xcrun simctl shutdown all` → もう一度。それでも止まるなら `-parallel-testing-enabled NO` を付ける。終わったら `pgrep -fl xcodebuild` で裏に残っていないことを確かめる
- コミットのメッセージは日本語で `feat:` / `fix:` / `test:` / `docs:` / `refactor:` から始める。末尾に `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` を付ける

---

### Task 1: 生成する `Category` を `TopicCategory` に改名する

Objective-C のランタイムの `Category` と名前がぶつかるため（ビルドは通るが紛らわしい）。

**Files:**
- Modify: `tools/make_manifest.py`（`render_topics` の 2 行）
- Modify: `tools/test_make_manifest.py`（テストを 1 つ足す）
- Modify: `WidgetLab/Catalog/Generated/Topic.swift`（2 行）
- Modify: `WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`（`Category` を使う 3 か所）

**Interfaces:**
- Produces: `nonisolated enum TopicCategory: String, CaseIterable, Sendable`（case は今の `Category` と同じ）、`Topic.category: TopicCategory`、`CategorySection.category: TopicCategory`

- [ ] **Step 1: 道具の失敗するテストを書く**

`tools/test_make_manifest.py` の `test_render_manifest` のあと（`if __name__ == "__main__":` の前）に足す:

```python
    def test_render_topics_names_category_enum_topic_category(self):
        # Objective-C のランタイムの Category と名前がぶつからないように
        text = mm.render_topics([{"slug": "controls", "title": "Controls", "category": "Views"}])
        self.assertIn("nonisolated enum TopicCategory: String, CaseIterable, Sendable {", text)
        self.assertIn("    var category: TopicCategory {", text)
        self.assertNotIn("enum Category", text)
```

- [ ] **Step 2: 落ちることを確かめる**

Run: `python3 -m unittest discover tools`
Expected: FAIL（`test_render_topics_names_category_enum_topic_category`）

- [ ] **Step 3: 道具を直す**

`tools/make_manifest.py` の `render_topics` で:
- `lines.append("nonisolated enum Category: String, CaseIterable, Sendable {")` → `lines.append("nonisolated enum TopicCategory: String, CaseIterable, Sendable {")`
- `"    var category: Category {"` → `"    var category: TopicCategory {"`

- [ ] **Step 4: 生成済みのファイルを同じに直す**

`WidgetLab/Catalog/Generated/Topic.swift` で:
- `nonisolated enum Category: String, CaseIterable, Sendable {` → `nonisolated enum TopicCategory: String, CaseIterable, Sendable {`
- `    var category: Category {` → `    var category: TopicCategory {`

`WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift` で:
- `let category: Category` → `let category: TopicCategory`
- `var id: Category { category }` → `var id: TopicCategory { category }`
- `Category.allCases.compactMap` → `TopicCategory.allCases.compactMap`
- コメントの `（並びは Category・Topic の宣言の順）` → `（並びは TopicCategory・Topic の宣言の順）`

確かめ: `grep -rn '\bCategory\b' WidgetLab WidgetLabTests tools --include='*.swift' --include='*.py' | grep -v 'TopicCategory\|CategorySection'` の出力が、`tools/test_make_manifest.py` のコメントと `assertNotIn` の 2 行だけ

- [ ] **Step 5: 確かめる**

Global Constraints の確かめのコマンドを実行する。Expected: 道具のテスト OK、`** TEST SUCCEEDED **`

- [ ] **Step 6: コミット**

```bash
git add tools/make_manifest.py tools/test_make_manifest.py WidgetLab/Catalog/Generated/Topic.swift WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift
git commit -m "refactor: 生成する大分類の型を TopicCategory に改名する"
```

---

### Task 2: 収録の進み具合を出す道具を足す

テストの `print` は xcodebuild のログに出ないので、Manifest と収録ファイルの id を突き合わせる小さなスクリプトにする。「抜け 0」をテストの条件にするのは束 11 で（この計画ではしない）。

**Files:**
- Create: `tools/catalog_progress.py`
- Create: `tools/test_catalog_progress.py`
- Modify: `WidgetLabTests/Catalog/CatalogTests.swift`（`print` の行を消す）
- Modify: `CLAUDE.md`（swiftui/ の。コマンドの節に 1 行）

**Interfaces:**
- Produces: `python3 tools/catalog_progress.py [topic-slug ...]`。引数なしなら全トピックの「収録数 / 全数」と抜けの id、最後に `合計 N / 458（抜け M）`。トピックを指定すると、そのトピックだけを出し、抜けがあれば終了コード 1。Manifest にないトピックなら終了コード 2。束の計画は `python3 tools/catalog_progress.py layout-fundamentals layout-adjustments ...` で抜け 0（終了コード 0）を確かめる

- [ ] **Step 1: 失敗するテストを書く**

`tools/test_catalog_progress.py`:

```python
"""catalog_progress.py のテスト。swiftui/ で `python3 -m unittest discover tools` で実行する。"""
import os
import tempfile
import unittest

import catalog_progress as cp

TOPIC_SWIFT = """nonisolated enum Topic: String, CaseIterable, Sendable {
    case layoutFundamentals = "layout-fundamentals"
    case gestures = "gestures"
"""
MANIFEST_SWIFT = """        ManifestEntry(id: "VStack", kind: .view, topic: .layoutFundamentals),
        ManifestEntry(id: "HStack", kind: .view, topic: .layoutFundamentals),
        ManifestEntry(id: "TapGesture", kind: .gesture, topic: .gestures),
"""
ENTRY_SWIFT = """    static let vStack = CatalogEntry(
        id: "VStack",
        properties: [
            .modifier("frame", id: "HStack", label: "width", .slider(range: 0...1, step: 1, initial: 0), summary: ""),
        ],
"""


class CatalogProgressTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        self.app = self.dir.name
        self.write("Catalog/Generated/Topic.swift", TOPIC_SWIFT)
        self.write("Catalog/Generated/Manifest.swift", MANIFEST_SWIFT)
        self.write("Catalog/LayoutFundamentals/VStackEntry.swift", ENTRY_SWIFT)

    def tearDown(self):
        self.dir.cleanup()

    def write(self, path, text):
        full = os.path.join(self.dir.name, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        with open(full, "w", encoding="utf-8") as f:
            f.write(text)

    def test_counts_by_topic_and_ignores_property_ids(self):
        rows = cp.progress(cp.read_manifest(self.app), cp.read_catalog_ids(self.app))
        self.assertEqual(
            rows,
            {"layout-fundamentals": (1, 2, ["HStack"]), "gestures": (0, 1, ["TapGesture"])},
        )

    def test_report_shows_missing_and_total(self):
        text = cp.report({"layout-fundamentals": (1, 2, ["HStack"])})
        self.assertIn("抜け: HStack", text)
        self.assertIn("合計 1 / 2（抜け 1）", text)

    def test_exit_code_is_1_only_when_selected_topics_have_missing(self):
        self.write("Catalog/Gestures/TapGestureEntry.swift", 'CatalogEntry(\n        id: "TapGesture",')
        self.assertEqual(cp.main(["gestures"], app_dir=self.app), 0)
        self.assertEqual(cp.main(["layout-fundamentals"], app_dir=self.app), 1)
        self.assertEqual(cp.main([], app_dir=self.app), 0)
        self.assertEqual(cp.main(["nope"], app_dir=self.app), 2)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: 落ちることを確かめる**

Run: `python3 -m unittest discover tools`
Expected: ERROR（`ModuleNotFoundError: No module named 'catalog_progress'`）

- [ ] **Step 3: 道具を書く**

`tools/catalog_progress.py`:

```python
#!/usr/bin/env python3
"""収録の進み具合を出す。Manifest.swift の id と、収録データ（Catalog/<トピック>/*Entry.swift）の id を突き合わせる。

使い方（swiftui/ で実行する）:
    python3 tools/catalog_progress.py                      # 全トピックの収録数と、抜けのあるトピックの抜け
    python3 tools/catalog_progress.py layout-fundamentals  # 指定したトピックだけ。抜けがあれば終了コード 1
"""
import argparse
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.join(HERE, "..", "WidgetLab")
MANIFEST_ENTRY = re.compile(r'ManifestEntry\(id: "([^"]+)", kind: \.\w+, topic: \.(\w+)\)')
TOPIC_CASE = re.compile(r'case (\w+) = "([^"]+)"')
# 収録の 1 件の id（プロパティの id: と区別するため、CatalogEntry( の直後のものだけ）
CATALOG_ID = re.compile(r'CatalogEntry\(\s*id:\s*"([^"]+)"')


def read_manifest(app_dir):
    """[(id, トピックの slug), ...] を Manifest.swift の並びで返す"""
    generated = os.path.join(app_dir, "Catalog", "Generated")
    with open(os.path.join(generated, "Topic.swift"), encoding="utf-8") as f:
        slugs = dict(TOPIC_CASE.findall(f.read()))
    with open(os.path.join(generated, "Manifest.swift"), encoding="utf-8") as f:
        return [(entry_id, slugs[case]) for entry_id, case in MANIFEST_ENTRY.findall(f.read())]


def read_catalog_ids(app_dir):
    """収録データのファイルに書いた id の集合"""
    ids = set()
    for path in glob.glob(os.path.join(app_dir, "Catalog", "*", "*Entry.swift")):
        with open(path, encoding="utf-8") as f:
            ids.update(CATALOG_ID.findall(f.read()))
    return ids


def progress(manifest, catalog_ids):
    """{slug: (収録数, 全数, [抜けの id])} をトピックの並び（Manifest に最初に出てきた順）で返す"""
    result = {}
    for entry_id, slug in manifest:
        done, total, missing = result.get(slug, (0, 0, []))
        if entry_id in catalog_ids:
            done += 1
        else:
            missing = missing + [entry_id]
        result[slug] = (done, total + 1, missing)
    return result


def report(rows):
    lines = []
    for slug, (done, total, missing) in rows.items():
        lines.append("{:<28} {:>3} / {:<3}".format(slug, done, total))
        if missing:
            lines.append("    抜け: " + ", ".join(missing))
    done = sum(r[0] for r in rows.values())
    total = sum(r[1] for r in rows.values())
    lines.append("合計 {} / {}（抜け {}）".format(done, total, total - done))
    return "\n".join(lines)


def main(argv=None, app_dir=APP_DIR):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("topics", nargs="*", help="トピックの slug（例: layout-fundamentals）。省くと全部")
    args = parser.parse_args(argv)
    rows = progress(read_manifest(app_dir), read_catalog_ids(app_dir))
    unknown = [t for t in args.topics if t not in rows]
    if unknown:
        print("Manifest にないトピック: " + ", ".join(unknown), file=sys.stderr)
        return 2
    if args.topics:
        rows = {slug: rows[slug] for slug in args.topics}
    print(report(rows))
    return 1 if args.topics and any(r[2] for r in rows.values()) else 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 4: 通ることと、実物で動くことを確かめる**

Run: `python3 -m unittest discover tools`
Expected: `OK`（11 件）

Run: `python3 tools/catalog_progress.py | tail -1`
Expected: `合計 7 / 458（抜け 451）`

Run: `python3 tools/catalog_progress.py gestures > /dev/null; echo $?`
Expected: `1`

- [ ] **Step 5: テストの `print` を消し、CLAUDE.md にコマンドを書く**

`WidgetLabTests/Catalog/CatalogTests.swift` の `idsAreUniqueAndListedInManifestWithSameKindAndTopic` から、次の行を消す:

```swift
        print("収録の進み具合: \(ids.count) / \(Manifest.entries.count)")
```

`CLAUDE.md`（swiftui/ の）の「コマンド」の節で、「manifest を作り直す」の行のあとに足す:

```markdown
- 収録の進み具合: `python3 tools/catalog_progress.py`（トピックの slug を渡すと、そのトピックだけ。抜けがあれば終了コード 1）
```

- [ ] **Step 6: 確かめる**

Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add tools/catalog_progress.py tools/test_catalog_progress.py WidgetLabTests/Catalog/CatalogTests.swift CLAUDE.md
git commit -m "feat: 収録の進み具合を出す道具を足し、テストの print をやめる"
```

---

### Task 3: modifier のプロパティの id を分け、同じ modifier の引数を 1 行にまとめる

`frame(width:)` と `frame(height:)` のように、同じ modifier に複数のプロパティを付けられるようにする。チップと ON / OFF は引数ごと、コードは 1 行。

**Files:**
- Modify: `WidgetLab/Catalog/Model/PropertySpec.swift`（`displayName`・`modifier(...)`）
- Modify: `WidgetLab/Catalog/Model/CodeTemplate.swift`（`CodeGenerator.lines` の modifier の部分を `modifierLines` に）
- Test: `WidgetLabTests/Catalog/CodeGeneratorTests.swift`

**Interfaces:**
- Produces:
  - `static func modifier(_ name: String, id: String? = nil, label: String? = nil, _ control: PropertyControl, on: Bool = false, required: Bool = false, summary: String) -> PropertySpec`。id を省くと `name`。required なら `initiallyOn` も true
  - `displayName`: `.modifier` で id が名前と同じなら `".name"`、違えば `".name(label:)"`（label が nil なら `".name(_:)"`）
  - コード: 同じ `name` の `.modifier` プロパティを、最初に出てきた位置に 1 行で書く（引数は定義の順）。required でない引数が 1 つも ON でなければ、その行は書かない。行の `propertyIDs` は書いた全部の id、`isChanged` はそのどれかが変わっていれば true

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Catalog/CodeGeneratorTests.swift` の `keepsParenthesesWhenTrailingIsNotClosure` のあと（`private let wrapperCode = ...` の前）に足す:

```swift
    @Test func groupsArgumentsOfSameModifierIntoOneLine() {
        let frame: [PropertySpec] = [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 0...200, step: 10, initial: 120),
                summary: ""),
            .modifier("tint", .color(initial: 0), summary: ""),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 0...200, step: 10, initial: 80),
                summary: ""),
        ]
        #expect(frame.map(\.displayName) == [".frame(width:)", ".tint", ".frame(height:)"])
        let values = PropertyValues(["frame.width": .number(120), "frame.height": .number(80), "tint": .color(0)])
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "Rectangle"), properties: frame, values: values, changed: ["frame.height"])
        #expect(lines.map(\.text) == ["Rectangle()", "    .frame(width: 120, height: 80)", "    .tint(.red)"])
        #expect(lines[1].propertyIDs == ["frame.width", "frame.height"])
        #expect(lines.map(\.isChanged) == [false, true, false])

        let heightOnly = CodeGenerator.lines(
            template: CodeTemplate(call: "Rectangle"), properties: frame,
            values: PropertyValues(["frame.height": .number(80)]))
        #expect(heightOnly.map(\.text) == ["Rectangle()", "    .frame(height: 80)"])
    }

    @Test func requiredModifierArgumentIsWrittenOnlyWithOtherArgumentsOfSameModifier() {
        let shadow: [PropertySpec] = [
            .modifier("shadow", id: "shadow.color", label: "color", .color(initial: 7), summary: ""),
            .modifier(
                "shadow", id: "shadow.radius", label: "radius", .slider(range: 0...20, step: 1, initial: 4),
                required: true, summary: ""),
        ]
        #expect(shadow[1].isRequired && shadow[1].initiallyOn)
        let template = CodeTemplate(call: "Circle")
        let off = CodeGenerator.lines(
            template: template, properties: shadow, values: PropertyValues(["shadow.radius": .number(4)]))
        #expect(off.map(\.text) == ["Circle()"])
        let on = CodeGenerator.lines(
            template: template, properties: shadow,
            values: PropertyValues(["shadow.color": .color(7), "shadow.radius": .number(4)]))
        #expect(on.map(\.text) == ["Circle()", "    .shadow(color: .gray, radius: 4)"])
    }

    @Test func labeledModifierWritesLabel() {
        let spec = PropertySpec.modifier("frame", label: "maxWidth", .fixed(code: ".infinity"), summary: "")
        #expect(spec.id == "frame")
        #expect(spec.displayName == ".frame")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "Text", fixedArguments: ["\"A\""]), properties: [spec],
            values: PropertyValues(["frame": .flag(true)]))
        #expect(lines.map(\.text) == ["Text(\"A\")", "    .frame(maxWidth: .infinity)"])
    }
```

- [ ] **Step 2: 落ちることを確かめる**

Run: 確かめのコマンドの `xcodebuild test ... -only-testing:WidgetLabTests/CodeGeneratorTests`
Expected: ビルドが失敗する（`extra arguments at positions #2, #6 in call` など。`modifier` に `id:`・`required:` がない）

- [ ] **Step 3: `PropertySpec` を直す**

`WidgetLab/Catalog/Model/PropertySpec.swift` の `displayName` を置き換える:

```swift
    /// チップと編集パネルに出す名前（例: "role"、".tint"）。同じ modifier に複数のプロパティを付けるとき
    /// （id が modifier の名前と違うとき）は、引数のラベルまで出す（例: ".frame(width:)"）
    var displayName: String {
        switch placement {
        case .argument: id
        case .modifier(let name, let label): id == name ? "." + name : ".\(name)(\(label ?? "_"):)"
        case .wrapper: "@" + id
        }
    }
```

`static func modifier(...)` を置き換える:

```swift
    /// modifier のプロパティ。id を省くと modifier の名前を id にする。同じ modifier に複数のプロパティを付けるときは
    /// id を分ける（例: "frame.width"・"frame.height"）。コードでは同じ modifier のプロパティを 1 行にまとめる。
    /// required の引数は、OFF にできず、同じ modifier のほかのプロパティが ON のときだけコードに書く
    static func modifier(
        _ name: String, id: String? = nil, label: String? = nil, _ control: PropertyControl, on: Bool = false,
        required: Bool = false, summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id ?? name, placement: .modifier(name: name, label: label), control: control,
            initiallyOn: on || required, isRequired: required, summary: summary)
    }
```

- [ ] **Step 4: `CodeGenerator` を直す**

`WidgetLab/Catalog/Model/CodeTemplate.swift` の `CodeGenerator.lines` で、次のループ:

```swift
        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement, let value = values[spec.id] else { continue }
            let text = "    .\(name)(" + argument(label: label, code: spec.control.code(for: value)) + ")"
            result.append(CodeLine(text: text, propertyIDs: [spec.id], isChanged: changed.contains(spec.id)))
        }
```

を 1 行に置き換える:

```swift
        result += modifierLines(properties: properties, values: values, changed: changed)
```

`wrapperLines` の前に足す:

```swift
    /// modifier のプロパティを、modifier の名前ごとに 1 行にまとめる（並びは最初に出てきた順、引数は定義の順）。
    /// required でない引数が 1 つも ON でない modifier は書かない
    private static func modifierLines(properties: [PropertySpec], values: PropertyValues, changed: Set<String>)
        -> [CodeLine]
    {
        var names: [String] = []
        var groups: [String: [(spec: PropertySpec, label: String?)]] = [:]
        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement else { continue }
            if groups[name] == nil { names.append(name) }
            groups[name, default: []].append((spec, label))
        }
        return names.compactMap { name in
            let members = groups[name, default: []].compactMap { member in
                values[member.spec.id].map { (spec: member.spec, label: member.label, value: $0) }
            }
            guard members.contains(where: { !$0.spec.isRequired }) else { return nil }
            let arguments = members.map { argument(label: $0.label, code: $0.spec.control.code(for: $0.value)) }
            let ids = members.map(\.spec.id)
            return CodeLine(
                text: "    .\(name)(" + arguments.joined(separator: ", ") + ")", propertyIDs: ids,
                isChanged: !changed.isDisjoint(with: ids))
        }
    }
```

- [ ] **Step 5: 整形して確かめる**

`xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` のあと、Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`（今の収録 7 件のコードも変わらない。`fillsArgumentsAndModifiersInDefinitionOrder` が通る）

- [ ] **Step 6: コミット**

```bash
git add WidgetLab/Catalog/Model/PropertySpec.swift WidgetLab/Catalog/Model/CodeTemplate.swift WidgetLabTests/Catalog/CodeGeneratorTests.swift
git commit -m "feat: modifier のプロパティの id を名前と分け、同じ modifier の引数を 1 行にまとめる"
```

---

### Task 4: スライダーの値を step の桁数で書く

今は `%.1f` なので 0.25 が "0.2" になる（`opacity`・`scaleEffect` で要る）。

**Files:**
- Modify: `WidgetLab/Catalog/Model/PropertySpec.swift`（`PropertyControl.code(for:)` と private extension）
- Test: `WidgetLabTests/Catalog/CodeGeneratorTests.swift`（`formatsValues`）

**Interfaces:**
- Produces: `.slider` の値のコードは、step の小数の桁数（最大 6）までで書き、末尾の 0 と小数点を省く。`-0` は `0`

- [ ] **Step 1: 失敗するテストを書く**

`formatsValues` の 2 行目（`step: 0.1 ... == "0.5"`）のあとに足す:

```swift
        #expect(PropertyControl.slider(range: 0...1, step: 0.1, initial: 0).code(for: .number(0.1 + 0.2)) == "0.3")
        #expect(PropertyControl.slider(range: 0...1, step: 0.25, initial: 0).code(for: .number(0.25)) == "0.25")
        #expect(PropertyControl.slider(range: 0...1, step: 0.25, initial: 0).code(for: .number(0.5)) == "0.5")
        #expect(PropertyControl.slider(range: 0...1, step: 0.25, initial: 0).code(for: .number(1)) == "1")
        #expect(PropertyControl.slider(range: -10...10, step: 0.5, initial: 0).code(for: .number(-2.5)) == "-2.5")
```

- [ ] **Step 2: 落ちることを確かめる**

Run: `xcodebuild test ... -only-testing:WidgetLabTests/CodeGeneratorTests`
Expected: FAIL（`"0.2" == "0.25"` など）

- [ ] **Step 3: 直す**

`PropertyControl.code(for:)` の slider の case を置き換える:

```swift
        case (.slider(_, let step, _), .number(let n)):
            Self.decimal(n, digits: Self.fractionDigits(of: step))
```

`PropertyControl` の宣言の閉じ括弧のあと（`/// 選択肢 1 つ。` の前）に足す。`nonisolated` を付けないと、既定の MainActor に属して `code(for:)` から呼べない:

```swift
nonisolated private extension PropertyControl {
    /// step の小数の桁数（1 → 0、0.1 → 1、0.25 → 2）
    static func fractionDigits(of step: Double) -> Int {
        var digits = 0
        var scaled = step
        while digits < 6, (scaled - scaled.rounded()).magnitude > 1e-9 {
            digits += 1
            scaled *= 10
        }
        return digits
    }

    /// digits 桁までの小数で書き、末尾の 0 は省く（0.50 → "0.5"、2.0 → "2"）
    static func decimal(_ n: Double, digits: Int) -> String {
        var text = String(format: "%.\(digits)f", n)
        if text.contains(".") {
            while text.hasSuffix("0") { text.removeLast() }
            if text.hasSuffix(".") { text.removeLast() }
        }
        return text == "-0" ? "0" : text
    }
}
```

- [ ] **Step 4: 確かめる**

Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`

- [ ] **Step 5: コミット**

```bash
git add WidgetLab/Catalog/Model/PropertySpec.swift WidgetLabTests/Catalog/CodeGeneratorTests.swift
git commit -m "fix: スライダーの値を step の小数の桁数で書く"
```

---

### Task 5: 説明だけの stage（`.note`）を足す

アプリの画面では試せないもの（アプリ拡張の中で効く・iOS では効かない窓の modifier・Core Data が要るなど）を、見本の代わりに理由を出して収録する。チップとコードはふつうの収録と同じに動く。

**Files:**
- Modify: `WidgetLab/Catalog/Model/CatalogEntry.swift`（`DemoStage`・初期化を足す）
- Modify: `WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`（`canCompare`）
- Modify: `WidgetLab/Features/Detail/UI/PreviewArea.swift`（`NoteView`）
- Modify: `WidgetLab/Features/Catalog/UI/TopicScreen.swift`（一覧の行の絵）
- Test: `WidgetLabTests/Features/Detail/DetailViewModelTests.swift`

**Interfaces:**
- Produces:
  - `DemoStage` は `Equatable` になり、`case note(reason: String)` を持つ
  - `CatalogEntry.init(id:kind:topic:summary:docURL:noteReason:properties:code:)`（`build` を書かない。stage は `.note(reason: noteReason)`）
  - `DetailViewModel.canCompare` は `.note` なら false（`comparison` も nil）

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Features/Detail/DetailViewModelTests.swift` の先頭の `import Testing` の前に `import Foundation` を足し、`requiredPropertyCannotBeTurnedOff` の前に足す:

```swift
    @Test func noteEntryCannotCompareButWritesCode() {
        let entry = CatalogEntry(
            id: "widgetLabel", kind: .modifier, topic: .appExtensions, summary: "テスト用",
            docURL: URL(string: "https://example.com")!, noteReason: "ウィジェットの中で効く",
            properties: [.argument("label", unlabeled: true, .text(initial: "見出し"), on: true, summary: "")],
            code: CodeTemplate(prefix: ["Gauge(value: 0.5) { }"], call: ".widgetLabel"))
        #expect(entry.stage == .note(reason: "ウィジェットの中で効く"))
        let viewModel = DetailViewModel(entry: entry, clipboard: clipboard)
        #expect(viewModel.canCompare == false)
        viewModel.isComparing = true
        #expect(viewModel.comparison == nil)
        #expect(viewModel.codeText == "Gauge(value: 0.5) { }\n    .widgetLabel(\"見出し\")")
    }
```

- [ ] **Step 2: 落ちることを確かめる**

Run: `xcodebuild test ... -only-testing:WidgetLabTests/DetailViewModelTests`
Expected: ビルドが失敗する（`noteReason` の初期化と `.note` がない）

- [ ] **Step 3: 収録データの型を直す**

`WidgetLab/Catalog/Model/CatalogEntry.swift` で:
- `nonisolated enum DemoStage: Sendable {` → `nonisolated enum DemoStage: Equatable, Sendable {`
- `case behavior` のあとに足す:

```swift
    /// アプリの画面では試せないもの（アプリ拡張の中で効く・iOS では効かないなど）。見本の代わりに reason を出す
    case note(reason: String)
```

ファイルの末尾に足す（extension に書くので、memberwise の初期化はそのまま残る）:

```swift

nonisolated extension CatalogEntry {
    /// 説明だけの収録（stage は .note）。見本を組み立てないので build を書かない
    init(
        id: String, kind: EntryKind, topic: Topic, summary: String, docURL: URL, noteReason: String,
        properties: [PropertySpec], code: CodeTemplate
    ) {
        self.init(
            id: id, kind: kind, topic: topic, summary: summary, docURL: docURL, stage: .note(reason: noteReason),
            properties: properties, code: code, build: { _ in AnyView(EmptyView()) })
    }
}
```

- [ ] **Step 4: 比べるを止める**

`WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift` の `canCompare` を置き換える:

```swift
    /// 選んでいるプロパティを比べられるか（required は付けない状態がないので比べられない。説明だけの収録は見本がない）
    var canCompare: Bool {
        if case .note = entry.stage { return false }
        return selected.map { !$0.isRequired } ?? false
    }
```

- [ ] **Step 5: プレビューと一覧の行**

`WidgetLab/Features/Detail/UI/PreviewArea.swift`:
- 型のコメントの 2 行目のあとに `/// 説明だけのもの（.note）は、見本の代わりに試せない理由を出す` を足す
- `content` の先頭の `if viewModel.entry.stage == .behavior {` を次に置き換える（比べるの切り替えは `canCompare` が false なので出ない）:

```swift
        if case .note(let reason) = viewModel.entry.stage {
            NoteView(reason: reason)
        } else if viewModel.entry.stage == .behavior {
```

- `/// 側 1 つの、見本の body を評価した回数` の `BodyCountLabel` の前に足す:

```swift
/// 説明だけの収録で、見本の代わりに出す。ここで試せない理由
private struct NoteView: View {
    let reason: String

    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("note")
    }
}
```

`WidgetLab/Features/Catalog/UI/TopicScreen.swift` の `thumbnail`:
- コメントを `/// .full・.behavior・.note は行で組み立てない（.note は見本がない。sheet が行から出る・NavigationStack が入れ子になる・記録の窓口がない）` にする
- `case .behavior:` の行のあとに足す:

```swift
        case .note:
            symbol("text.page")
```

- [ ] **Step 6: 確かめる**

整形のあと、Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Catalog/Model/CatalogEntry.swift WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift WidgetLab/Features/Detail/UI/PreviewArea.swift WidgetLab/Features/Catalog/UI/TopicScreen.swift WidgetLabTests/Features/Detail/DetailViewModelTests.swift
git commit -m "feat: アプリの画面では試せないものを、説明だけの stage で収録できるようにする"
```

---

### Task 6: ラッパーと選択肢の取り違えを見つけ、`.behavior` も描いて確かめる

**Files:**
- Modify: `WidgetLab/Catalog/Model/CodeTemplate.swift`（`wrapperLines` の宣言の探し方）
- Modify: `WidgetLab/Catalog/Model/PropertyValues.swift`（`pick`）
- Test: `WidgetLabTests/Catalog/CodeGeneratorTests.swift`、`WidgetLabTests/Catalog/CatalogTests.swift`

**Interfaces:**
- Consumes: `DemoStage.note`（Task 5）
- Produces: `pick(_:from:)` は、選択肢の番号が options の外なら DEBUG で `assertionFailure`（メッセージに id と件数）、リリースでは nil。`CatalogTests.buildsAllCombinations` は選択肢ごとの値で組み立てるので、options が選択肢より少ない収録はここで止まる

- [ ] **Step 1: 失敗するテストを書く**

`WidgetLabTests/Catalog/CodeGeneratorTests.swift` の `private let wrapperCode = ...` の前に足す:

```swift
    @Test func wrapperDeclarationMatchesWholeWord() {
        let code = WrapperCode(
            withWrapper: ["@StateObject private var model = Model()", "@State private var count = 0"],
            withoutWrapper: ["@StateObject private var model = Model()", "private var count = 0"])
        let spec = PropertySpec.wrapper("State", summary: "")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "State", wrapper: code), properties: [spec],
            values: PropertyValues(["State": spec.control.initialValue]))
        #expect(lines.map(\.propertyIDs) == [[], ["State"]])
    }
```

`WidgetLabTests/Catalog/CatalogTests.swift` の `@Test(arguments: Catalog.all.map(\.id))` の前に足す:

```swift
    @Test func wrapperCodeGoesWithWrapperProperty() {
        for entry in Catalog.all {
            let hasWrapperProperty = entry.properties.contains { $0.placement == .wrapper }
            #expect(
                (entry.code.wrapper != nil) == hasWrapperProperty,
                "\(entry.id): CodeTemplate.wrapper と .wrapper のプロパティは、両方あるか両方ないかにする")
        }
    }
```

- [ ] **Step 2: 落ちることを確かめる**

Run: `xcodebuild test ... -only-testing:WidgetLabTests/CodeGeneratorTests -only-testing:WidgetLabTests/CatalogTests`
Expected: `wrapperDeclarationMatchesWholeWord` が FAIL（`[["State"], ["State"]]`）。`wrapperCodeGoesWithWrapperProperty` は今の収録では通る（これからの収録の取り違えを見つけるためのもの）

- [ ] **Step 3: 宣言の行を語で探す**

`WidgetLab/Catalog/Model/CodeTemplate.swift` の `wrapperLines` で:

```swift
                let isDeclaration = text.contains("@" + id)
```

を置き換える:

```swift
                // 語として一致させる（@State で @StateObject の行に当たらないように）
                let isDeclaration = text.range(of: "@\(id)\\b", options: .regularExpression) != nil
```

- [ ] **Step 4: `pick` で選択肢の数の取り違えを見つける**

`WidgetLab/Catalog/Model/PropertyValues.swift` の `pick` を置き換える:

```swift
    /// 選択肢の番号に合う値を options から取り出す（options は選択肢と同じ並び）。
    /// options が選択肢より少ないのは収録データの誤りなので、デバッグのときは止める
    func pick<T>(_ id: String, from options: [T]) -> T? {
        guard case .choice(let i) = storage[id] else { return nil }
        guard options.indices.contains(i) else {
            assertionFailure("\(id) の選択肢 \(i) 番に合う値が options（\(options.count) 件）にない")
            return nil
        }
        return options[i]
    }
```

- [ ] **Step 5: `.behavior` も描いて確かめる**

`WidgetLabTests/Catalog/CatalogTests.swift` の `buildsAllCombinations` の中の次の部分:

```swift
            // .full・.behavior は組み立てだけ（全画面や記録の窓口がないと、描いても確かめられない）
            if entry.stage == .card {
                let renderer = ImageRenderer(content: view.frame(width: 320, height: 240))
                #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            }
```

を置き換える:

```swift
            // .full は組み立てだけ（全画面で開くもので、枠の中に描いても確かめられない）。.note は見本がない。
            // .behavior は記録の窓口が nil なら記録しないので、そのまま描ける
            switch entry.stage {
            case .card, .behavior:
                let renderer = ImageRenderer(content: view.frame(width: 320, height: 240))
                #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            case .full, .note:
                break
            }
```

- [ ] **Step 6: 確かめる**

整形のあと、Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`（`State`・`Binding`・`TapGesture` の `buildsAllCombinations` も描いて通る）

- [ ] **Step 7: コミット**

```bash
git add WidgetLab/Catalog/Model/CodeTemplate.swift WidgetLab/Catalog/Model/PropertyValues.swift WidgetLabTests/Catalog/CodeGeneratorTests.swift WidgetLabTests/Catalog/CatalogTests.swift
git commit -m "fix: ラッパーの宣言を語で探し、選択肢の取り違えを止め、.behavior の見本も描いて確かめる"
```

---

### Task 7: ホームの節を 1 回だけ作り、テストの抜けを埋める

**Files:**
- Modify: `WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`（`sections`）
- Test: `WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift`、`WidgetLabTests/Catalog/CodeGeneratorTests.swift`、`WidgetLabTests/Features/Detail/DetailViewModelTests.swift`

**Interfaces:**
- Produces: `CatalogViewModel.sections` は `let`（init で作る）。型と中身は今と同じ

- [ ] **Step 1: テストの抜けを書く**

これらは今のコードの振る舞いを固めるテストで、書いた時点で通る（落ちることは確かめない）。

`WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift` の `searchMatchesPartOfNameIgnoringCaseInAlphabeticalOrder` の前に:

```swift
    @Test func findsEntryByID() {
        let viewModel = makeViewModel()
        #expect(viewModel.entry(id: "padding")?.kind == .modifier)
        #expect(viewModel.entry(id: "Nope") == nil)
    }
```

`WidgetLabTests/Catalog/CodeGeneratorTests.swift` の `private let wrapperCode = ...` の前に:

```swift
    @Test func multilineTrailingClosureMarksOnlyCallLine() {
        let spec = PropertySpec.argument("spacing", .slider(range: 0...20, step: 1, initial: 8), summary: "")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "VStack", trailing: " {\n    Text(\"A\")\n}"), properties: [spec],
            values: PropertyValues(["spacing": .number(12)]), changed: ["spacing"])
        #expect(lines.map(\.text) == ["VStack(spacing: 12) {", "    Text(\"A\")", "}"])
        #expect(lines.map(\.isChanged) == [true, false, false])
        #expect(lines.map(\.propertyIDs) == [["spacing"], [], []])
    }

    @Test func nothingIsMarkedWhenNothingChanged() {
        let values = PropertyValues(["role": .choice(0), "title": .text("保存"), "tint": .color(4)])
        let lines = CodeGenerator.lines(template: CodeTemplate(call: "Button"), properties: properties, values: values)
        #expect(lines.allSatisfy { !$0.isChanged })
    }
```

`WidgetLabTests/Features/Detail/DetailViewModelTests.swift` の `noteEntryCannotCompareButWritesCode` の前に:

```swift
    @Test func selectedLineFallsBackToCallLineWhenSelectedPropertyIsOff() {
        let viewModel = makeViewModel()
        viewModel.selectedID = "tint"
        #expect(viewModel.selectedLine?.text == "Sample(size: 4)")
    }

    @Test func tapGestureCodeWritesCountAndOmitsItWhenOff() {
        let viewModel = DetailViewModel(entry: .tapGesture, clipboard: clipboard)
        #expect(viewModel.codeLines.map(\.text).last == "    .gesture(TapGesture(count: 2).onEnded { })")
        viewModel.setOn("count", false)
        #expect(viewModel.codeLines.map(\.text).last == "    .gesture(TapGesture().onEnded { })")
    }
```

- [ ] **Step 2: `sections` を init で作る**

`WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift` の `init` と `sections` を置き換える:

```swift
    /// 収録が 1 件以上あるトピックを、大分類ごとに並べる（並びは TopicCategory・Topic の宣言の順）。
    /// 収録は変わらないので、init で 1 回だけ作る
    let sections: [CategorySection]

    init(repository: any CatalogRepository) {
        let entries = repository.allEntries()
        self.entries = entries
        sections = TopicCategory.allCases.compactMap { category in
            let topics = Topic.allCases.filter { $0.category == category }.compactMap { topic -> TopicSummary? in
                let names = entries.filter { $0.topic == topic }.map(\.displayName)
                return names.isEmpty
                    ? nil : TopicSummary(topic: topic, count: names.count, sampleNames: Array(names.prefix(3)))
            }
            return topics.isEmpty ? nil : CategorySection(category: category, topics: topics)
        }
    }
```

（`private let entries: [CatalogEntry]` の宣言はそのまま、`sections` の宣言の前に残す）

- [ ] **Step 3: 確かめる**

整形のあと、Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`

- [ ] **Step 4: コミット**

```bash
git add WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift WidgetLabTests/Catalog/CodeGeneratorTests.swift WidgetLabTests/Features/Detail/DetailViewModelTests.swift
git commit -m "refactor: ホームの節を 1 回だけ作り、コード生成と詳細のテストの抜けを埋める"
```

---

### Task 8: ドキュメントを直す

**Files:**
- Modify: `docs/adr/ADR-0002-data-driven-demos.md`
- Modify: `docs/architecture.md`
- Modify: `docs/superpowers/specs/2026-10-31-swiftui-app-design.md`（「テスト」の節）
- Modify: `docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md`

- [ ] **Step 1: ADR-0002 に節を足す**

「## 見た目を持たないもの（2026-11-02 追加）」の節のあと、「## 結果」の前に足す:

```markdown
## 全トピックの収録に向けて（2026-11-02 追加）
- modifier のプロパティは id を名前と分けられる（`PropertySpec.modifier(_:id:label:...)`、例: `frame.width`・`frame.height`）。同じ modifier のプロパティは、コードで 1 行にまとめる（`.frame(width: 120, height: 80)`）。チップと ON / OFF は引数ごと。required の引数は、同じ modifier のほかの引数が ON のときだけ書く
- 引数の並びは、定義の順 = Swift の引数の順 = チップの順のまま。分けると収録を書く手間と間違いが増えるため
- アプリの画面では試せないもの（アプリ拡張の中で効く・iOS では効かない・外の仕組みが要る）は、`DemoStage.note(reason:)` で収録する。見本の代わりに理由を出し、チップとコードはふつうに動く。manifest の数は変えない
- 選ばなかった案: 1 つのプロパティに複数の値を持たせる（操作部品が増え、編集パネルが複雑になる）／試せないものを manifest から外す（数え方と PRD を直すことになる）／試せないものも本物を作る（Core Data の土台・拡張のターゲットが増える）
```

「## 結果」の「見直すきっかけ」の行の末尾（`…が要るとき`）のあとに、次を続ける:

```markdown
、チップの順を Swift の引数の順と変えたい収録が多く出てきたとき、`.note` の収録が 1 割を超えたとき
```

- [ ] **Step 2: architecture.md を直す**

`docs/architecture.md` の `CodeGenerator.lines` の段落（「`CodeGenerator.lines` が、`CodeTemplate`（…）に、付けた引数と modifier を定義の順で埋めて、…」）の末尾に足す:

```markdown
同じ modifier の名前を持つプロパティは 1 行にまとめる（`.frame(width:height:)` など）。
```

その段落のあと（空行を挟んで）に、プレビューの出し方の段落を足す（今の architecture.md には `DemoStage` の説明がない）:

```markdown
プレビューの出し方は `DemoStage` で決める。`.card` は枠に収まる見本、`.full` は全画面で開くもの、`.behavior` は見た目を持たないもの（左右に並べて記録を出す）、`.note` はアプリの画面では試せないもの（見本の代わりに理由を出し、比べるは出さない）。
```

- [ ] **Step 3: 全体の spec の「テスト」の節を直す**

`docs/superpowers/specs/2026-10-31-swiftui-app-design.md` の「## テスト」で:
- 「manifest の突き合わせ」の行の `まだ収録していないものは、進み具合として件数を出す（失敗にしない）。` → `まだ収録していないものは失敗にしない（進み具合は tools/catalog_progress.py で出す）。`
- 「全件の組み立て」の行の `（`.full`・`.behavior` は組み立てだけ）` → `（`.full` は組み立てだけ、`.note` は見本がないので組み立てない）`

- [ ] **Step 4: followups に済んだ印を付ける**

`docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md` で、次の行の「こと」の列の頭に `済: ` を付け、「中身」の列の末尾に `→ <何をしたか>` を足す（Phase 2 の表の書き方に合わせる）:

| 表 | こと | 足す「→ …」 |
|---|---|---|
| Phase 3 の最初の PR の前 | プロパティの id を名前と分ける | → `PropertySpec.modifier` に `id:` を足した |
| 同 | 引数の並びと、複数の引数を持つ modifier | → 同じ modifier のプロパティを 1 行にまとめた。並びは定義の順のまま（ADR-0002） |
| 同 | スライダーの値の書き方 | → step の小数の桁数で書く |
| 同 | 生成する `Category` の名前 | → `TopicCategory` にした |
| 同 | 収録の進み具合の出し方 | → `tools/catalog_progress.py`。「抜け 0」をテストの条件にするのは Phase 3 の束 11 |
| 同 | `sections` の作り直し | → init で 1 回だけ作る |
| 同 | `pick` の選択肢の数の確認 | → 番号が options の外なら DEBUG で止める。全件の組み立てのテストが選択肢ごとに通す |
| 同 | テストの抜け | → 足した |
| Phase 2 のレビューで回したこと | ラッパーの宣言の行の見つけ方 | → 語として一致させた |
| 同 | ラッパーのコードとプロパティの組み合わせの確認 | → `CatalogTests.wrapperCodeGoesWithWrapperProperty` |
| 同 | `.behavior` の見本も描いて確かめる | → 描いて確かめる。spec も直した |
| 同 | TapGesture のコードの行のテスト | → `DetailViewModelTests.tapGestureCodeWritesCountAndOmitsItWhenOff` |

Phase 2 のレビューの表の残り（VoiceOver での複数回のタップ・UI テストで左右を確かめる・記録の欄の高さ）は、「中身」の末尾に `→ Phase 3 の束 12（仕上げ）で扱う` を足す。冒頭の要約の「お願い」の行はそのまま。

- [ ] **Step 5: 確かめる**

Run: `grep -c "済: " docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md`
Expected: `16`（Phase 2 の前の 4 件 + この計画の 12 件）

Global Constraints の確かめのコマンドを実行する。Expected: `** TEST SUCCEEDED **`

- [ ] **Step 6: コミット**

```bash
git add docs/adr/ADR-0002-data-driven-demos.md docs/architecture.md docs/superpowers/specs/2026-10-31-swiftui-app-design.md docs/superpowers/plans/2026-11-02-swiftui-phase1-followups.md
git commit -m "docs: modifier のまとめと説明だけの stage を ADR・architecture・spec に書き、followups に済んだ印を付ける"
```
