# プロパティの選ぶ欄 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 詳細画面の「仲間のタブ＋チップの列」を、「丸い ‹ › とカード＋インジケーターの点」の選ぶ欄と、全プロパティを仲間ごとの見出しで並べた一覧のシートに置き換える。

**Architecture:** 送る順番（プロパティ → 補足）を `DetailState.pickerItems` として ViewModel に持たせ、‹ › は `DetailNotifier.previousTapped` / `nextTapped` で前後を選ぶ。UI は `PropertyPicker`（カード・丸いボタン・点）と `PropertyListSheet`（一覧）の 2 部品を足し、`GroupTabs`・`PropertyChips` を消す。チップ（`PropertyChip`）は入れ子の子に残す。

**Tech Stack:** Flutter 3.47.8（FVM）/ Dart 3.13.7 / Riverpod（riverpod_generator）/ gen-l10n（ARB）/ flutter_test

**設計:** docs/design/functions/property-picker.md（この計画の正）

## Global Constraints

- コマンドは必ず `fvm` 経由: `fvm flutter test`、`fvm flutter analyze`、`fvm dart format`
- 確かめ: `fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`（今の基準は 2153 件成功・0 skip。この計画で件数は変わるが、失敗 0・skip 0 を保つ）
- 文言は日本語のみ。ARB（`lib/l10n/app_ja.arb`）に足し、`fvm flutter gen-l10n` で `lib/l10n/gen/` を作り直す（生成物もコミットする）
- riverpod の生成物は `fvm dart run build_runner build --delete-conflicting-outputs` で作り直す（`@riverpod` の関数・クラスのシグネチャを変えたとき）
- 色・余白・角丸は `Theme.of(context).colorScheme`・`NimiSpacing.of(context)`（xxs 4 / xs 8 / sm 12 / md 16）・`NimiRadius.of(context)`（sm 8 / md 12 / lg 20）を使い、数値を直書きしない（点の大きさ 6・18 のような部品固有の寸法は名前つきの定数にする）
- コメントとテスト名は日本語。周りのコードの書き方（`///` の短い説明、`switch` 式、`final (a, b) = ...`）に合わせる
- 押せる範囲は 48×48 以上
- コミットは Task ごと。メッセージは日本語の Conventional Commits、末尾に `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
- 作業ブランチは `docs/property-picker`（設計書のコミット済み）。push と PR は最後にまとめて行う

---

## ファイルの地図

| ファイル | 役割 | Task |
|---|---|---|
| `lib/features/detail/view_model/value_label.dart` | 値の短い表示（長い書き方を型の名前に） | 1 |
| `lib/features/detail/view_model/picker_item.dart`（新） | 選ぶ欄の 1 か所（プロパティか補足） | 2 |
| `lib/features/detail/view_model/detail_state.dart` | 送る順番・今の位置・前後の有無・ON の数 | 2, 4 |
| `lib/features/detail/view_model/detail_notifier.dart` | ‹ › の操作 | 2, 4 |
| `lib/features/detail/ui/widgets/property_group_label.dart`（新） | 仲間の名前とアイコン（`group_tabs.dart` から移す） | 3 |
| `lib/features/detail/ui/widgets/property_picker.dart`（新） | 選ぶ欄（カード・‹ ›・点） | 3 |
| `lib/features/detail/ui/widgets/property_list_sheet.dart`（新） | 一覧のシート | 3 |
| `lib/l10n/app_ja.arb` と `lib/l10n/gen/*` | 文言 | 3, 4 |
| `lib/features/detail/ui/detail_screen.dart` | 画面の並びの差し替え | 4 |
| `lib/features/detail/ui/widgets/group_tabs.dart`・`property_chips.dart` | 消す | 4 |
| `test/features/detail/...` | テスト | 1〜4 |
| `docs/design/screens/cb_dtl_詳細画面.md` ほか | 文書 | 5 |

---

### Task 0: Figma に v4 を描く（メインのセッションで行う。サブエージェントに渡さない）

**Files:** Figma https://www.figma.com/design/W9DAjjGAmMzNhnCQu0BLo7/Widget-Lab （v3 のフレームの右に足す）

- [ ] **Step 1:** `figma-use` スキルを読み、`create_session`（fileKey `W9DAjjGAmMzNhnCQu0BLo7`）→ `search_design_system` で既存のコンポーネントと変数を確かめる
- [ ] **Step 2:** 「cb_dtl v4 / 選ぶ欄（指定中）」「cb_dtl v4 / 選ぶ欄（既定）」「cb_dtl v4 / 選ぶ欄（先頭）」「cb_dtl v4 / 一覧のシート」の 4 枚を、v3 の「仲間のタブ」（`47:1569`）を複製して直す形で描く。中身は設計書の「選ぶ欄（ps）」「一覧のシート（pss）」のとおり（例は Container）
- [ ] **Step 3:** `get_screenshot` で 4 枚を確かめ、ノード ID を控える（Task 5 で設計書に書く）

---

### Task 1: 値の短い表示（長い書き方を型の名前に）

**Files:**
- Modify: `lib/features/detail/view_model/value_label.dart`
- Test: `test/features/detail/view_model/value_label_test.dart`

**Interfaces:**
- Produces: `String chipValueLabel(PropertyControl control, ControlValue value)`（シグネチャは今のまま。`FixedControl` の扱いだけ変わる）

- [ ] **Step 1: 失敗するテストを書く**

`test/features/detail/view_model/value_label_test.dart` の 2 つ目の `for`（`chipValueLabel` の表）の最後に足す:

```dart
    (
      const FixedControl(
        value: SizedBox(),
        source: 'OverflowBox(maxWidth: 120, maxHeight: 56, child: Tile(1))',
      ),
      const FixedValue(),
      'OverflowBox',
    ),
    (
      const FixedControl(
        value: SizedBox(),
        source:
            '[BoxShadow(blurRadius: 12, color: Color(0x40000000), offset: Offset(0, 4))]',
      ),
      const FixedValue(),
      '[BoxShadow]',
    ),
    (
      const FixedControl(value: SizedBox(), source: 'Color(0x40000000)'),
      const FixedValue(),
      'Color(0x40000000)',
    ),
    (
      const FixedControl(
        value: SizedBox(),
        source: 'EdgeInsets.symmetric(horizontal: 24, vertical: 12)',
      ),
      const FixedValue(),
      'EdgeInsets.symmetric',
    ),
    (
      const FixedControl(
        value: SizedBox(),
        source: "'とても長い文字の値で、型の名前が取れないもの'",
      ),
      const FixedValue(),
      "'とても長い文字の値で、型の名前が取れないもの'",
    ),
```

その表のテスト名が `TC-19` 以外なら合わせる必要はない。新しいケースは `TC-93` として名前に出したいので、表のテスト名の書式が `'TC-xx: ... $expected'` なら、この 5 件だけを別の `for` に分けて `'TC-93: 長い書き方は型の名前だけ $expected'` にする。

- [ ] **Step 2: 失敗を確かめる**

Run: `fvm flutter test test/features/detail/view_model/value_label_test.dart`
Expected: `OverflowBox`・`[BoxShadow]`・`EdgeInsets.symmetric` の 3 件が FAIL（書き方のまま返るため）。ほかは PASS

- [ ] **Step 3: 実装する**

`lib/features/detail/view_model/value_label.dart` の `chipValueLabel` を次に置き換え、下に関数と定数を足す:

```dart
/// チップに出す、さらに短い値の文字。
///
/// スライダーは整数なら小数点を省き（例: `16`）、[FixedControl] は末尾の `()` を省く
/// （例: `FlutterLogo`）。[FixedControl] の書き方が長いときは先頭の型の名前だけにする
/// （例: `OverflowBox`・`[BoxShadow]`）。ほかは [valueLabel] と同じ。
String chipValueLabel(PropertyControl control, ControlValue value) =>
    switch ((control, value)) {
      (SliderControl(), SliderValue()) => valueLabel(
        control,
        value,
      ).replaceFirst(RegExp(r'\.0$'), ''),
      (FixedControl(:final source), FixedValue()) => _shortSource(source),
      _ => valueLabel(control, value),
    };

/// 書き方のまま出す長さの上限。超えたら型の名前だけにする。
const _maxSourceLength = 20;

/// 先頭の型の名前（`Padding`・`EdgeInsets.symmetric`）。リストの `[` と `const` は飛ばす。
final _leadingType = RegExp(r'^\[?(?:const )?([A-Za-z_][\w.]*)');

String _shortSource(String source) {
  final trimmed = source.replaceFirst(RegExp(r'\(\)$'), '');
  if (trimmed.length <= _maxSourceLength) return trimmed;
  final type = _leadingType.firstMatch(source)?.group(1);
  // 型の名前が取れない（文字の値など）ときは、表示の側で「…」にする
  if (type == null) return trimmed;
  return source.startsWith('[') ? '[$type]' : type;
}
```

- [ ] **Step 4: 通ることを確かめる**

Run: `fvm flutter test test/features/detail/view_model/value_label_test.dart`
Expected: 全部 PASS

- [ ] **Step 5: 画面のテストで値の表示に頼るものが壊れていないか確かめる**

Run: `fvm flutter test test/features/detail`
Expected: 全部 PASS（チップに長い書き方を期待しているテストがあれば、期待を型の名前に直す）

- [ ] **Step 6: コミット**

```bash
fvm dart format lib/features/detail/view_model/value_label.dart test/features/detail/view_model/value_label_test.dart
git add lib/features/detail/view_model/value_label.dart test/features/detail/view_model/value_label_test.dart
git commit -m "feat: チップの値で、長い書き方は型の名前だけにする

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: 送る順番と ‹ › の操作（ViewModel）

**Files:**
- Create: `lib/features/detail/view_model/picker_item.dart`
- Modify: `lib/features/detail/view_model/detail_state.dart`
- Modify: `lib/features/detail/view_model/detail_notifier.dart`
- Test: `test/features/detail/view_model/detail_notifier_test.dart`
- Test: `test/catalog/catalog_test.dart`（全件の送る順番）

**Interfaces:**
- Produces（Task 3・4 が使う）:
  - `sealed class PickerItem { Object? get section; }`、`final class PickerProperty extends PickerItem { final PropertySpec spec; }`、`final class PickerReferences extends PickerItem { const PickerReferences(); }`
  - `DetailState.pickerItems → List<PickerItem>`、`DetailState.pickerIndex → int`（今の位置。どこでもなければ `-1`）、`DetailState.hasPrevious → bool`、`DetailState.hasNext → bool`、`DetailState.onCount → int`
  - `DetailNotifier.previousTapped() → void`、`DetailNotifier.nextTapped() → void`
- この Task では仲間のタブの API（`selectedGroup` など）は消さない（Task 4 で消す。ここで消すと `GroupTabs` が組み立たない）

- [ ] **Step 1: `PickerItem` を作る**

`lib/features/detail/view_model/picker_item.dart`:

```dart
import 'package:widget_lab/catalog/model/property_spec.dart';

/// 選ぶ欄の 1 か所。プロパティか、最後の補足。
sealed class PickerItem {
  const PickerItem();

  /// 一覧の見出しと点の間を分ける区切り。プロパティは仲間（なければ `null`）、補足は補足そのもの。
  Object? get section;
}

/// 1 つのプロパティ。
final class PickerProperty extends PickerItem {
  const PickerProperty(this.spec);

  final PropertySpec spec;

  @override
  Object? get section => spec.group;

  @override
  bool operator ==(Object other) =>
      other is PickerProperty && other.spec.name == spec.name;

  @override
  int get hashCode => spec.name.hashCode;

  @override
  String toString() => 'PickerProperty(${spec.name})';
}

/// 補足（見た目が変わらない引数の一覧）。
final class PickerReferences extends PickerItem {
  const PickerReferences();

  @override
  Object? get section => this;

  @override
  bool operator ==(Object other) => other is PickerReferences;

  @override
  int get hashCode => (PickerReferences).hashCode;

  @override
  String toString() => 'PickerReferences()';
}
```

- [ ] **Step 2: 失敗するテストを書く**

`test/features/detail/view_model/detail_notifier_test.dart` の `group('仲間のタブ（TC-84）', ...)` の後ろに足す（`relationEntry` の並び: width・height〔大きさ〕、color・decoration〔色と装飾〕、transform・transformAlignment〔変形〕、補足 key。開いたときは width）:

```dart
  group('選ぶ欄（TC-91）', () {
    DetailNotifier notifierOf(ProviderContainer c) =>
        c.read(detailProvider('relation').notifier);
    DetailState stateOf(ProviderContainer c) =>
        c.read(detailProvider('relation'));
    ProviderContainer open() =>
        makeContainer(repository: FakeCatalogRepository([relationEntry]));

    test('送る順番は、仲間の語彙の順・中は収録の順・最後に補足', () {
      final c = open();
      expect(
        stateOf(c).pickerItems.map(
          (item) => switch (item) {
            PickerProperty(:final spec) => spec.name,
            PickerReferences() => '補足',
          },
        ),
        [
          'width',
          'height',
          'color',
          'decoration',
          'transform',
          'transformAlignment',
          '補足',
        ],
      );
    });

    test('開いたときは先頭なので、前はなく次はある', () {
      final c = open();
      expect(stateOf(c).pickerIndex, 0);
      expect(stateOf(c).hasPrevious, isFalse);
      expect(stateOf(c).hasNext, isTrue);
    });

    test('次・前で隣のプロパティを選ぶ。仲間をまたいでも送れる', () {
      final c = open();
      notifierOf(c).nextTapped();
      expect(stateOf(c).selected, 'height');
      notifierOf(c).nextTapped();
      expect(stateOf(c).selected, 'color');
      notifierOf(c).previousTapped();
      expect(stateOf(c).selected, 'height');
    });

    test('最後のプロパティの次は補足。補足の前で最後のプロパティに戻る', () {
      final c = open();
      notifierOf(c).propertySelected('transformAlignment');
      notifierOf(c).nextTapped();
      expect(stateOf(c).showsReferences, isTrue);
      expect(stateOf(c).hasNext, isFalse);
      notifierOf(c).nextTapped();
      expect(stateOf(c).showsReferences, isTrue);
      notifierOf(c).previousTapped();
      expect(stateOf(c).showsReferences, isFalse);
      expect(stateOf(c).selected, 'transformAlignment');
    });

    test('先頭の前は何もしない', () {
      final c = open();
      notifierOf(c).previousTapped();
      expect(stateOf(c).selected, 'width');
    });

    test('送るとプロパティの比較をやめる', () {
      final c = open();
      notifierOf(c).compareTapped('width');
      notifierOf(c).nextTapped();
      expect(stateOf(c).comparing, isNull);
    });

    test('ON の数は全部のプロパティで数える', () {
      final c = open();
      final on = relationEntry.properties
          .where((s) => s.isOnIn(relationEntry.initialSettings()))
          .length;
      expect(stateOf(c).onCount, on);
    });
  });
```

ファイルの先頭に `import 'package:widget_lab/features/detail/view_model/picker_item.dart';` を足す。

`test/catalog/catalog_test.dart` の `group('TC-06: ...')` の後ろに足す（全件で、送る順番がプロパティを 1 回ずつと補足を含むこと。画面を開く代わりに状態で確かめる）:

```dart
  group('TC-92: 全件で、選ぶ欄の送る順番がプロパティを 1 回ずつ通り、最後が補足', () {
    for (final entry in allEntries) {
      test(entry.id, () {
        final items = DetailState.initial(entry, const []).pickerItems;
        expect(
          [
            for (final item in items)
              if (item case PickerProperty(:final spec)) spec.name,
          ]..sort(),
          [for (final spec in entry.properties) spec.name]..sort(),
        );
        expect(
          items.whereType<PickerReferences>().length,
          entry.references.isEmpty ? 0 : 1,
        );
        if (entry.references.isNotEmpty) {
          expect(items.last, const PickerReferences());
        }
      });
    }
  });
```

ファイルの先頭に `detail_state.dart` と `picker_item.dart` の import を足す。

- [ ] **Step 3: 失敗を確かめる**

Run: `fvm flutter test test/features/detail/view_model/detail_notifier_test.dart test/catalog/catalog_test.dart`
Expected: コンパイルエラー（`pickerItems`・`nextTapped` などがない）

- [ ] **Step 4: `DetailState` に足す**

`lib/features/detail/view_model/detail_state.dart` に `import 'package:widget_lab/features/detail/view_model/picker_item.dart';` を足し、`isEffective` の前に足す:

```dart
  /// 選ぶ欄の送る順番。仲間のないもの → 仲間の語彙の順（中は収録の順）→ 補足。
  /// 一覧のシートの並びと同じ。
  List<PickerItem> get pickerItems => [
    for (final group in entry.groups)
      for (final spec in entry.properties)
        if (spec.group == group) PickerProperty(spec),
    if (entry.references.isNotEmpty) const PickerReferences(),
  ];

  /// 選ぶ欄の今の位置。どこでもなければ `-1`（プロパティのない Widget）。
  int get pickerIndex {
    final items = pickerItems;
    if (showsReferences) return items.indexOf(const PickerReferences());
    return items.indexWhere(
      (item) => item is PickerProperty && item.spec.name == selected,
    );
  }

  /// ‹ で前に送れるか。
  bool get hasPrevious => pickerIndex > 0;

  /// › で次に送れるか。
  bool get hasNext {
    final index = pickerIndex;
    return index >= 0 && index < pickerItems.length - 1;
  }

  /// ON のプロパティの数（一覧のシートの「指定中」）。
  int get onCount =>
      entry.properties.where((spec) => spec.isOnIn(settings)).length;
```

- [ ] **Step 5: `DetailNotifier` に足す**

`lib/features/detail/view_model/detail_notifier.dart` に `import 'package:widget_lab/features/detail/view_model/picker_item.dart';` を足し、`referencesSelected` の後ろに足す:

```dart
  /// 選ぶ欄の ‹。前のプロパティ（または補足）を選ぶ。先頭なら何もしない。
  void previousTapped() => _moveBy(-1);

  /// 選ぶ欄の ›。次のプロパティ（または補足）を選ぶ。最後なら何もしない。
  void nextTapped() => _moveBy(1);

  void _moveBy(int delta) {
    final items = state.pickerItems;
    final from = state.pickerIndex;
    final to = from + delta;
    if (from < 0 || to < 0 || to >= items.length) return;
    switch (items[to]) {
      case PickerProperty(:final spec):
        propertySelected(spec.name);
      case PickerReferences():
        referencesSelected();
    }
  }
```

- [ ] **Step 6: 通ることを確かめる**

Run: `fvm flutter test test/features/detail/view_model/detail_notifier_test.dart test/catalog/catalog_test.dart`
Expected: 全部 PASS

- [ ] **Step 7: コミット**

```bash
fvm dart format lib/features/detail/view_model test/features/detail/view_model test/catalog/catalog_test.dart
git add lib/features/detail/view_model test/features/detail/view_model test/catalog/catalog_test.dart
git commit -m "feat: 選ぶ欄の送る順番と、前後に送る操作を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: 選ぶ欄と一覧のシートの部品（UI）

**Files:**
- Create: `lib/features/detail/ui/widgets/property_group_label.dart`
- Create: `lib/features/detail/ui/widgets/property_picker.dart`
- Create: `lib/features/detail/ui/widgets/property_list_sheet.dart`
- Modify: `lib/features/detail/ui/widgets/group_tabs.dart`（`groupLabel` を消し、新しいファイルを import する）
- Modify: `lib/l10n/app_ja.arb`（足す）と `lib/l10n/gen/*`（作り直す）
- Test: `test/features/detail/ui/widgets/property_picker_test.dart`（新）
- Test: `test/features/detail/ui/widgets/property_list_sheet_test.dart`（新）

**Interfaces:**
- Consumes: Task 1 の `chipValueLabel`、Task 2 の `pickerItems`・`pickerIndex`・`hasPrevious`・`hasNext`・`onCount`・`previousTapped`・`nextTapped`、既存の `propertySelected`・`referencesSelected`・`isEffective`・`showDetailSheet`
- Produces（Task 4 が使う）:
  - `class PropertyPicker extends ConsumerWidget { const PropertyPicker({required String entryId}); static const cardHeight = 56.0; static const dotsHeight = 16.0; static const cardKey = Key('pickerCard'); }`
  - `class PropertyListSheet extends ConsumerStatefulWidget { const PropertyListSheet({required String entryId}); }`
  - `String groupLabel(AppLocalizations l10n, PropertyGroup? group)`、`IconData groupIcon(PropertyGroup? group)`、`const IconData referencesIcon`

- [ ] **Step 1: 文言を足す**

`lib/l10n/app_ja.arb` の `detailTabOnCount` の定義（`@detailTabOnCount` の閉じ）の後ろに足す:

```json
  "detailReferencesLabel": "補足",
  "@detailReferencesLabel": { "description": "見た目が変わらない引数（選ぶ欄のカードと一覧のシートの見出し）" },
  "detailPickerPrevious": "前のプロパティ",
  "@detailPickerPrevious": { "description": "選ぶ欄の ‹" },
  "detailPickerNext": "次のプロパティ",
  "@detailPickerNext": { "description": "選ぶ欄の ›" },
  "detailPickerSemantics": "{name}、{detail}、{index} / {count}",
  "@detailPickerSemantics": {
    "description": "選ぶ欄のカードの読み上げ",
    "placeholders": {
      "name": { "type": "String", "example": "color" },
      "detail": { "type": "String", "example": "色と装飾、若竹" },
      "index": { "type": "int", "example": "7" },
      "count": { "type": "int", "example": "15" }
    }
  },
  "detailPickerReferencesValue": "{count} 件 ・ 読むだけ",
  "@detailPickerReferencesValue": {
    "description": "補足を選んでいるときのカードの 2 行目",
    "placeholders": { "count": { "type": "int", "example": "1" } }
  },
  "detailPickerSheetTitle": "プロパティ（{count}）",
  "@detailPickerSheetTitle": {
    "description": "一覧のシートの題",
    "placeholders": { "count": { "type": "int", "example": "14" } }
  },
  "detailPickerSheetOnCount": "指定中 {count}",
  "@detailPickerSheetOnCount": {
    "description": "一覧のシートの題の横",
    "placeholders": { "count": { "type": "int", "example": "3" } }
  },
  "detailPickerReferencesCount": "{count} 件",
  "@detailPickerReferencesCount": {
    "description": "一覧のシートの補足の行の値",
    "placeholders": { "count": { "type": "int", "example": "1" } }
  },
```

`detailGroup*` の 9 つの `description` を `"仲間の名前（選ぶ欄のカードと一覧のシートの見出し）"` に直す（`detailGroupAll` は `"仲間を決めていない収録の見出し"`）。

Run: `fvm flutter gen-l10n`
Expected: `lib/l10n/gen/app_localizations*.dart` が更新され、エラーなし

- [ ] **Step 2: 仲間の名前とアイコンを移す**

`lib/features/detail/ui/widgets/property_group_label.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 仲間の名前。仲間を決めていない収録は「プロパティ」。
String groupLabel(AppLocalizations l10n, PropertyGroup? group) =>
    switch (group) {
      PropertyGroup.size => l10n.detailGroupSize,
      PropertyGroup.spacing => l10n.detailGroupSpacing,
      PropertyGroup.layout => l10n.detailGroupLayout,
      PropertyGroup.paint => l10n.detailGroupPaint,
      PropertyGroup.transform => l10n.detailGroupTransform,
      PropertyGroup.text => l10n.detailGroupText,
      PropertyGroup.behavior => l10n.detailGroupBehavior,
      PropertyGroup.content => l10n.detailGroupContent,
      null => l10n.detailGroupAll,
    };

/// 仲間のアイコン（選ぶ欄のカードと一覧のシートの見出し）。
IconData groupIcon(PropertyGroup? group) => switch (group) {
  PropertyGroup.size => Icons.aspect_ratio,
  PropertyGroup.spacing => Icons.padding,
  PropertyGroup.layout => Icons.align_horizontal_center,
  PropertyGroup.paint => Icons.palette_outlined,
  PropertyGroup.transform => Icons.transform,
  PropertyGroup.text => Icons.text_fields,
  PropertyGroup.behavior => Icons.touch_app_outlined,
  PropertyGroup.content => Icons.widgets_outlined,
  null => Icons.tune,
};

/// 補足のアイコン。
const referencesIcon = Icons.notes;
```

`lib/features/detail/ui/widgets/group_tabs.dart` から `groupLabel` 関数（`/// 仲間の名前。` から `};` まで）を消し、`import 'package:widget_lab/features/detail/ui/widgets/property_group_label.dart';` を足す。ほかに `groupLabel` を `group_tabs.dart` から import しているファイルがあれば（`grep -rn "groupLabel" lib test`）、import を新しいファイルに替える。

Run: `fvm flutter analyze`
Expected: No issues found

- [ ] **Step 3: 選ぶ欄の失敗するテストを書く**

`test/features/detail/ui/widgets/property_picker_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_picker.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../../fakes.dart';

void main() {
  late ProviderContainer container;

  /// relationEntry の選ぶ欄を出す（並び: width・height・color・decoration・
  /// transform・transformAlignment・補足。開いたときは width）。
  Future<void> pumpPicker(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          FakeCatalogRepository([relationEntry]),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Center(child: PropertyPicker(entryId: 'relation')),
          ),
        ),
      ),
    );
  }

  final card = find.byKey(PropertyPicker.cardKey);
  Finder inCard(String text) =>
      find.descendant(of: card, matching: find.text(text));
  IconButton button(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(find.widgetWithIcon(IconButton, switch (tooltip) {
        '前のプロパティ' => Icons.chevron_left,
        _ => Icons.chevron_right,
      }));

  testWidgets('TC-91: カードに名前と「仲間 ・ 値」、先頭では ‹ が押せない', (tester) async {
    await pumpPicker(tester);
    expect(inCard('width'), findsOneWidget);
    expect(inCard('大きさ ・ true'), findsOneWidget);
    expect(button(tester, '前のプロパティ').onPressed, isNull);
    expect(button(tester, '次のプロパティ').onPressed, isNotNull);
  });

  testWidgets('TC-91: › で次へ、‹ で前へ送る', (tester) async {
    await pumpPicker(tester);
    await tester.tap(find.byTooltip('次のプロパティ'));
    await tester.pumpAndSettle();
    expect(inCard('height'), findsOneWidget);
    // height は既定（OFF）
    expect(inCard('大きさ ・ 既定'), findsOneWidget);
    await tester.tap(find.byTooltip('前のプロパティ'));
    await tester.pumpAndSettle();
    expect(inCard('width'), findsOneWidget);
  });

  testWidgets('TC-91: 最後は補足で、› が押せない', (tester) async {
    await pumpPicker(tester);
    container
        .read(detailProvider('relation').notifier)
        .referencesSelected();
    await tester.pumpAndSettle();
    expect(inCard('補足'), findsOneWidget);
    expect(inCard('1 件 ・ 読むだけ'), findsOneWidget);
    expect(button(tester, '次のプロパティ').onPressed, isNull);
  });

  testWidgets('TC-91: requires の相手が OFF のプロパティは、カードを薄く出す', (tester) async {
    await pumpPicker(tester);
    container
        .read(detailProvider('relation').notifier)
        .propertySelected('transformAlignment');
    await tester.pumpAndSettle();
    final opacity = tester.widget<Opacity>(
      find.descendant(of: card, matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('TC-91: 点はプロパティと補足の数だけ並び、読み上げない', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    expect(find.byKey(const ValueKey('pickerDot-6')), findsOneWidget);
    expect(find.byKey(const ValueKey('pickerDot-7')), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('pickerDot-0')),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('TC-91: 読み上げの上下の操作で前後に送れる', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    tester.semantics.increase(find.semantics.byLabel(RegExp('^width、')));
    await tester.pumpAndSettle();
    expect(inCard('height'), findsOneWidget);
    tester.semantics.decrease(find.semantics.byLabel(RegExp('^height、')));
    await tester.pumpAndSettle();
    expect(inCard('width'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('TC-91: カードを押すと一覧のシートが開く', (tester) async {
    await pumpPicker(tester);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsOneWidget);
  });

  testWidgets('TC-91: 文字を 2 倍にしてもはみ出さない', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpPicker(tester);
    expect(tester.takeException(), isNull);
  });
}
```

`relationEntry` の width は `SwitchControl(initialValue: true)` なので、値の表示は `true`。

- [ ] **Step 4: 一覧のシートの失敗するテストを書く**

`test/features/detail/ui/widgets/property_list_sheet_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../../fakes.dart';

void main() {
  late ProviderContainer container;

  /// relationEntry の一覧のシートを開く。
  Future<void> openSheet(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          FakeCatalogRepository([relationEntry]),
        ),
      ],
    );
    addTearDown(container.dispose);
    // 画面が見ている間と同じく、状態を持ち続ける
    final subscription = container.listen(
      detailProvider('relation'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDetailSheet(
                  context,
                  (_) => const PropertyListSheet(entryId: 'relation'),
                ),
                child: const Text('開く'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
  }

  Finder inSheet(Finder matching) =>
      find.descendant(of: find.byType(PropertyListSheet), matching: matching);

  testWidgets('TC-94: 題と指定中の数、仲間の見出しが語彙の順で、最後に補足', (tester) async {
    await openSheet(tester);
    expect(inSheet(find.text('プロパティ（6）')), findsOneWidget);
    final on = container.read(detailProvider('relation')).onCount;
    expect(inSheet(find.text('指定中 $on')), findsOneWidget);
    final size = tester.getTopLeft(inSheet(find.text('大きさ'))).dy;
    final paint = tester.getTopLeft(inSheet(find.text('色と装飾'))).dy;
    final transform = tester.getTopLeft(inSheet(find.text('変形'))).dy;
    expect(size, lessThan(paint));
    expect(paint, lessThan(transform));
    await tester.scrollUntilVisible(
      inSheet(find.text('補足')),
      100,
      scrollable: inSheet(find.byType(Scrollable)).first,
    );
    expect(inSheet(find.text('1 件')), findsOneWidget);
  });

  testWidgets('TC-94: 今選んでいる行に ✓', (tester) async {
    await openSheet(tester);
    expect(
      find.descendant(
        of: find.ancestor(
          of: inSheet(find.text('width')),
          matching: find.byType(InkWell),
        ),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('TC-94: 行を押すと、そのプロパティを選んで閉じる', (tester) async {
    await openSheet(tester);
    await tester.tap(inSheet(find.text('color')));
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsNothing);
    expect(container.read(detailProvider('relation')).selected, 'color');
  });

  testWidgets('TC-94: 補足の行を押すと、補足を選んで閉じる', (tester) async {
    await openSheet(tester);
    await tester.scrollUntilVisible(
      inSheet(find.text('1 件')),
      100,
      scrollable: inSheet(find.byType(Scrollable)).first,
    );
    await tester.tap(inSheet(find.text('1 件')));
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsNothing);
    expect(
      container.read(detailProvider('relation')).showsReferences,
      isTrue,
    );
  });
}
```

`showDetailSheet` はシートの中身を `SingleChildScrollView` に入れるので、`inSheet(find.byType(Scrollable))` で縦にスクロールできる。`find.byType(PropertyListSheet)` の外側にスクロールがあるときは、`find.ancestor(of: find.byType(PropertyListSheet), matching: find.byType(Scrollable))` に替える。

- [ ] **Step 5: 失敗を確かめる**

Run: `fvm flutter test test/features/detail/ui/widgets/property_picker_test.dart test/features/detail/ui/widgets/property_list_sheet_test.dart`
Expected: コンパイルエラー（`PropertyPicker`・`PropertyListSheet` がない）

- [ ] **Step 6: 選ぶ欄を作る**

`lib/features/detail/ui/widgets/property_picker.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_group_label.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// プロパティの選ぶ欄。真ん中に今のプロパティのカード、左右に丸い ‹ ›、下に点。
/// カードを押すと一覧のシートを開く。1 か所しかなければカードだけを出す。
class PropertyPicker extends ConsumerWidget {
  const PropertyPicker({required this.entryId, super.key});

  final String entryId;

  /// カードの高さ。文字を大きくしたら中身に合わせて高くする。
  static const cardHeight = 56.0;

  /// 点の行の高さ。
  static const dotsHeight = 16.0;

  /// カード（テストで探す）。
  static const cardKey = Key('pickerCard');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detailProvider(entryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    final items = state.pickerItems;
    final index = state.pickerIndex;
    if (index < 0) return const SizedBox.shrink();
    final settings = state.settings;
    final (icon, name, value, fullValue, on, dimmed) = switch (items[index]) {
      PickerProperty(:final spec) => (
        groupIcon(spec.group),
        spec.name,
        '${groupLabel(l10n, spec.group)} ・ '
            '${spec.isOnIn(settings) ? chipValueLabel(spec.control, spec.valueIn(settings)) : l10n.detailChipDefault}',
        '${groupLabel(l10n, spec.group)}、'
            '${spec.isOnIn(settings) ? valueLabel(spec.control, spec.valueIn(settings)) : l10n.detailChipDefault}',
        spec.isOnIn(settings),
        !state.isEffective(spec.name),
      ),
      PickerReferences() => (
        referencesIcon,
        l10n.detailReferencesLabel,
        l10n.detailPickerReferencesValue(state.entry.references.length),
        l10n.detailPickerReferencesValue(state.entry.references.length),
        false,
        false,
      ),
    };
    final card = _PickerCard(
      key: cardKey,
      icon: icon,
      name: name,
      value: value,
      on: on,
      dimmed: dimmed,
      semanticsLabel: l10n.detailPickerSemantics(
        name,
        fullValue,
        index + 1,
        items.length,
      ),
      onTap: () => showDetailSheet(
        context,
        (_) => PropertyListSheet(entryId: entryId),
      ),
      onIncrease: state.hasNext ? notifier.nextTapped : null,
      onDecrease: state.hasPrevious ? notifier.previousTapped : null,
    );
    if (items.length == 1) return card;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: l10n.detailPickerPrevious,
              onPressed: state.hasPrevious ? notifier.previousTapped : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Gap(spacing.xxs),
            Expanded(child: card),
            Gap(spacing.xxs),
            IconButton.filledTonal(
              tooltip: l10n.detailPickerNext,
              onPressed: state.hasNext ? notifier.nextTapped : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        SizedBox(
          height: dotsHeight,
          child: _PickerDots(
            items: items,
            index: index,
            on: [
              for (final item in items)
                item is PickerProperty && item.spec.isOnIn(settings),
            ],
          ),
        ),
      ],
    );
  }
}

/// 今のプロパティのカード。指定中は塗り、既定は枠だけ、効かないものは薄く出す。
class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.icon,
    required this.name,
    required this.value,
    required this.on,
    required this.dimmed,
    required this.semanticsLabel,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  final IconData icon;
  final String name;

  /// 2 行目（「仲間 ・ 短い値」）。
  final String value;
  final bool on;
  final bool dimmed;
  final String semanticsLabel;
  final VoidCallback onTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final radius = BorderRadius.circular(NimiRadius.of(context).md);
    final (background, foreground, secondary) = on
        ? (scheme.primary, scheme.onPrimary, scheme.onPrimary)
        : (null, scheme.onSurface, scheme.onSurfaceVariant);
    return Semantics(
      label: semanticsLabel,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Ink(
              decoration: ShapeDecoration(
                color: background,
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: background == null
                      ? BorderSide(color: scheme.outline)
                      : BorderSide.none,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PropertyPicker.cardHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: foreground),
                      Gap(spacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: foreground,
                              ),
                            ),
                            Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.expand_more, color: foreground),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 位置と指定中を示す点。仲間の境目で間を空け、補足は輪で出す。飾りなので読み上げない。
class _PickerDots extends StatelessWidget {
  const _PickerDots({required this.items, required this.index, required this.on});

  final List<PickerItem> items;
  final int index;

  /// [items] と同じ順の、指定中か。
  final List<bool> on;

  /// 点の直径と、今の位置の点の横幅。
  static const _size = 6.0;
  static const _currentWidth = 18.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spacing = NimiSpacing.of(context);
    return ExcludeSemantics(
      child: Center(
        // 21 件と補足でも画面の幅に収まらなければ、全体を縮める
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, item) in items.indexed) ...[
                if (i > 0)
                  Gap(
                    item.section == items[i - 1].section
                        ? spacing.xxs
                        : spacing.xs,
                  ),
                Container(
                  key: ValueKey('pickerDot-$i'),
                  width: i == index ? _currentWidth : _size,
                  height: _size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_size / 2),
                    color: switch ((i == index, item, on[i])) {
                      (true, _, _) => scheme.primary,
                      (false, PickerReferences(), _) => null,
                      (false, _, true) => scheme.primary.withValues(alpha: 0.4),
                      (false, _, false) => scheme.outlineVariant,
                    },
                    border: item is PickerReferences && i != index
                        ? Border.all(color: scheme.outline)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: 一覧のシートを作る**

`lib/features/detail/ui/widgets/property_list_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_group_label.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 一覧のシート。全部のプロパティを仲間ごとの見出しで並べ、最後に補足を置く。
/// 行を押すとそれを選んで閉じる。開いたら今選んでいる行を見える位置まで送る。
class PropertyListSheet extends ConsumerStatefulWidget {
  const PropertyListSheet({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<PropertyListSheet> createState() => _PropertyListSheetState();
}

class _PropertyListSheetState extends ConsumerState<PropertyListSheet> {
  final _currentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _currentKey.currentContext;
      if (context == null || !context.mounted) return;
      Scrollable.ensureVisible(context, alignment: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = detailProvider(widget.entryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final items = state.pickerItems;
    final current = state.pickerIndex;
    final settings = state.settings;

    void choose(PickerItem item) {
      switch (item) {
        case PickerProperty(:final spec):
          notifier.propertySelected(spec.name);
        case PickerReferences():
          notifier.referencesSelected();
      }
      Navigator.of(context).pop();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.detailPickerSheetTitle(state.entry.properties.length),
                style: theme.textTheme.titleMedium,
              ),
              Gap(spacing.xs),
              Text(
                l10n.detailPickerSheetOnCount(state.onCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        for (final (i, item) in items.indexed) ...[
          if (i == 0 || items[i - 1].section != item.section)
            _SectionHeader(
              icon: switch (item) {
                PickerProperty(:final spec) => groupIcon(spec.group),
                PickerReferences() => referencesIcon,
              },
              label: switch (item) {
                PickerProperty(:final spec) => groupLabel(l10n, spec.group),
                PickerReferences() => l10n.detailReferencesLabel,
              },
            ),
          switch (item) {
            PickerProperty(:final spec) => _Row(
              key: i == current ? _currentKey : null,
              name: spec.name,
              value: spec.isOnIn(settings)
                  ? chipValueLabel(spec.control, spec.valueIn(settings))
                  : l10n.detailChipDefault,
              on: spec.isOnIn(settings),
              dimmed: !state.isEffective(spec.name),
              selected: i == current,
              onTap: () => choose(item),
            ),
            PickerReferences() => _Row(
              key: i == current ? _currentKey : null,
              name: l10n.detailReferencesLabel,
              value: l10n.detailPickerReferencesCount(
                state.entry.references.length,
              ),
              on: false,
              dimmed: false,
              selected: i == current,
              onTap: () => choose(item),
            ),
          },
        ],
      ],
    );
  }
}

/// 仲間の見出し（アイコンと名前）。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final color = theme.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.xxs),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            Gap(spacing.xxs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 行。● は指定中、○ は既定。今選んでいる行は地を塗り ✓ を付ける。
class _Row extends StatelessWidget {
  const _Row({
    required this.name,
    required this.value,
    required this.on,
    required this.dimmed,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String name;
  final String value;
  final bool on;
  final bool dimmed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final radius = BorderRadius.circular(NimiRadius.of(context).sm);
    return Semantics(
      label: [
        name,
        value,
        if (selected) l10n.detailChipSelected,
        if (dimmed) l10n.detailChipInactive,
      ].join('、'),
      button: true,
      selected: selected,
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : null,
              borderRadius: radius,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                child: Row(
                  children: [
                    Icon(
                      on ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      color: on ? scheme.primary : scheme.outline,
                    ),
                    Gap(spacing.xs),
                    Text(name, style: theme.textTheme.titleSmall),
                    Gap(spacing.sm),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      Gap(spacing.xs),
                      Icon(Icons.check, size: 18, color: scheme.primary),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: 通ることを確かめる**

Run: `fvm flutter test test/features/detail/ui/widgets/property_picker_test.dart test/features/detail/ui/widgets/property_list_sheet_test.dart`
Expected: 全部 PASS。`tester.semantics.increase` がこの Flutter にないときは、`tester.semantics` の代わりに `tester.binding.pipelineOwner.semanticsOwner!.performAction(id, SemanticsAction.increase)` で送る（`find.semantics.byLabel(...).evaluate().single.id` で id を取る）

- [ ] **Step 9: 全体を確かめてコミット**

Run: `fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`
Expected: 失敗 0・skip 0（この時点では画面はまだタブとチップのまま）

```bash
git add lib/features/detail/ui/widgets lib/l10n test/features/detail/ui/widgets
git commit -m "feat: プロパティの選ぶ欄と一覧のシートの部品を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: 画面を選ぶ欄に差し替え、仲間のタブとチップの列を消す

**Files:**
- Modify: `lib/features/detail/ui/detail_screen.dart`
- Delete: `lib/features/detail/ui/widgets/group_tabs.dart`、`lib/features/detail/ui/widgets/property_chips.dart`
- Modify: `lib/features/detail/view_model/detail_state.dart`・`detail_notifier.dart`（仲間のタブの API を消す）
- Modify: `lib/l10n/app_ja.arb`・`lib/l10n/gen/*`（`detailTabReferences`・`detailTabOnCount` を消す）
- Test: `test/features/detail/ui/detail_screen_test.dart`、`test/features/detail/view_model/detail_notifier_test.dart`

**Interfaces:**
- Consumes: Task 3 の `PropertyPicker`（`cardHeight`・`dotsHeight`・`cardKey`）・`PropertyListSheet`、Task 2 の API
- Produces: なし（画面の完成）

- [ ] **Step 1: 画面のテストの道具を選ぶ欄に合わせる（失敗するテストにする）**

`test/features/detail/ui/detail_screen_test.dart`:

1. import の `group_tabs.dart` を消し、`property_picker.dart` と `property_list_sheet.dart` を足す。`property_group.dart` が使われなくなったら消す
2. `chip`・`chipValue`・`openTabOf`・`select` の 4 つ（83〜116 行あたり）を次に置き換える:

```dart
  /// 選ぶ欄のカード。
  final pickerCard = find.byKey(PropertyPicker.cardKey);

  /// カードに [name] のプロパティが出ているか。
  Finder inCard(String text) =>
      find.descendant(of: pickerCard, matching: find.text(text));

  /// カードの 2 行目の値（「仲間 ・ 値」の値の側）。
  String cardValue(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(of: pickerCard, matching: find.byType(Text)),
      )
      .last
      .data!
      .split(' ・ ')
      .last;

  /// 一覧のシートから [name] を選ぶ（補足は「補足」）。
  Future<void> select(WidgetTester tester, String name) async {
    await tester.tap(pickerCard);
    await tester.pumpAndSettle();
    final row = find.descendant(
      of: find.byType(PropertyListSheet),
      matching: find.text(name),
    );
    // 「補足」は見出しと行の 2 か所にあるので、行（最後）を押す
    await tester.ensureVisible(row.last);
    await tester.pumpAndSettle();
    await tester.tap(row.last);
    await tester.pumpAndSettle();
  }
```

3. 置き換えの対応（行番号は今のファイル。ずれていたら内容で探す）:
   - TC-61（164〜171 行）: `expect(tester.widget<PropertyChip>(chip('padding')).selected, isTrue);` を `expect(inCard('padding'), findsOneWidget);` にし、`spacingCount` の 4 行を消す
   - TC-17・TC-19・TC-23（182・195・241・251 行）: `chipValue(tester, 'xxx')` を `cardValue(tester)` に替える（どれも今選んでいるプロパティ）。テスト名の「チップ」を「カード」に直す
   - 605 行: `find.byType(PropertyChip)` を `find.byType(PropertyPicker)` に替える
   - 「仲間のタブがある Container を低い画面で開いても…」（646〜658 行）: 名前を「Container を低い画面で開いても、はみ出さず編集パネルが残る」にし、`find.byType(GroupTabs)` を `find.byType(PropertyPicker)` に替える
   - `group('仲間のタブ（TC-84）', ...)`（1330〜1381 行）を丸ごと次に置き換える:

```dart
  group('選ぶ欄（TC-91）', () {
    testWidgets('開いたときは padding。› で margin、‹ で constraints', (tester) async {
      await pumpDetail(tester, 'container');
      expect(inCard('padding'), findsOneWidget);
      await tester.tap(find.byTooltip('次のプロパティ'));
      await tester.pumpAndSettle();
      expect(inCard('margin'), findsOneWidget);
      expect(inPanel(find.text('margin')), findsOneWidget);
      await tester.tap(find.byTooltip('前のプロパティ'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('前のプロパティ'));
      await tester.pumpAndSettle();
      expect(inCard('constraints'), findsOneWidget);
    });

    testWidgets('先頭の width では ‹ が押せない', (tester) async {
      await pumpDetail(tester, 'container');
      await select(tester, 'width');
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_left),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('最後のプロパティの › で補足に入り、› が押せなくなる', (tester) async {
      await pumpDetail(tester, 'container');
      await select(tester, 'child');
      await tester.tap(find.byTooltip('次のプロパティ'));
      await tester.pumpAndSettle();
      expect(find.text('見た目が変わらない引数'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_right),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('requires の相手が OFF なら、カードは薄い', (tester) async {
      await pumpDetail(tester, 'container');
      await select(tester, 'transformAlignment');
      final opacity = tester.widget<Opacity>(
        find.descendant(of: pickerCard, matching: find.byType(Opacity)).first,
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('長い値はカードで型の名前だけ', (tester) async {
      await pumpDetail(tester, 'clipRect');
      await select(tester, 'child');
      // ClipRect の child は OverflowBox(maxWidth: 120, ...) の書き方
      expect(cardValue(tester), 'OverflowBox');
    });

    testWidgets('キーボードが出ていても選ぶ欄は出たまま', (tester) async {
      await pumpDetail(tester, 'text');
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byType(PropertyPicker), findsOneWidget);
    });
  });
```

`clipRect` は `lib/catalog/painting/clip_rect.dart` の収録（child の `source` は `'OverflowBox(maxWidth: 120, maxHeight: 56, child: Tile(1))'`）。

   - 関係の行（TC-85）の 2 か所（1390〜1393・1407〜1411 行）: `tester.widget<PropertyChip>(find.widgetWithText(PropertyChip, 'height'))` で `selected` を見ている所は `expect(inCard('height'), findsOneWidget);` に、transformAlignment の `chip.selected`／`chip.dimmed` は次に替える:

```dart
      expect(inCard('transformAlignment'), findsOneWidget);
      expect(
        tester
            .widget<Opacity>(
              find.descendant(of: pickerCard, matching: find.byType(Opacity)).first,
            )
            .opacity,
        1,
      );
```

   テスト名の「相手のタブとチップに移る」は「相手に移る」に直す
   - 入れ子（TC-86）の 1447〜1450 行: `await tester.tap(find.text('色と装飾')); await tester.pumpAndSettle(); await tester.tap(find.widgetWithText(PropertyChip, 'decoration')); await tester.pumpAndSettle();` を `await select(tester, 'decoration');` に替える。入れ子の親が OFF（TC-86）の group にも同じ形があれば同じく替える。子のチップ（`borderRadius` など）の `PropertyChip` はそのまま
   - 補足（TC-89）: `scrollUntilVisible`〜`tap(find.text('補足'))` を `await select(tester, '補足');` に替え、テスト名の「補足のタブで」を「補足を選ぶと」に直す。`find.byType(PropertyChip), findsNothing` は消す（編集パネルに入れ子がないので元から 0）

- [ ] **Step 2: ViewModel のテストから仲間のタブを消す**

`test/features/detail/view_model/detail_notifier_test.dart` の `group('仲間のタブ（TC-84）', ...)` から、`selectedGroup`・`showsTabs`・`groupSelected`・`specsInSelectedGroup` を使う 3 つのテストを消し、残る「補足を開くと比較をやめ、チップを選ぶと補足を閉じる」を `group('選ぶ欄（TC-91）', ...)` に移す（group の題と `notifierOf`・`stateOf` は TC-91 のものを使う）。空になった TC-84 の group を消し、使われなくなった `property_group.dart` の import を消す

- [ ] **Step 3: 失敗を確かめる**

Run: `fvm flutter test test/features/detail`
Expected: 画面のテストが FAIL（画面にまだ `PropertyPicker` がない）

- [ ] **Step 4: 画面を差し替える**

`lib/features/detail/ui/detail_screen.dart`:

1. import の `group_tabs.dart`・`property_chips.dart` を消し、`property_picker.dart` を足す
2. クラスの説明を `/// 詳細画面（cb_dtl）。上にプレビューとコードの帯、その下にプロパティの選ぶ欄、` に直す
3. `static const _chipsHeight = 48.0;` と、その上の説明の「とチップの列」を消す（説明は「コードの帯の高さ（間の余白を除く）。文字の拡大に合わせて多めに見積もる。」）
4. `build` の中の次を

```dart
    // キーボードが出ている間（文字の入力中）は、仲間のタブを隠して編集パネルの高さを残す
    final showsTabs =
        ref.watch(provider.select((s) => s.showsTabs)) && !keyboardShown;
```

消し、`middleHeight` を次にする:

```dart
    final middleHeight =
        (hasProperties
            ? textScaler.scale(_stripHeight) +
                  textScaler.scale(PropertyPicker.cardHeight) +
                  PropertyPicker.dotsHeight +
                  spacing.xs * 3
            : spacing.xs) +
        (showsLogStrip ? textScaler.scale(LogStrip.height) + spacing.xs : 0);
```

5. `Column` の中の

```dart
                  if (showsTabs) GroupTabs(entryId: entryId),
                  if (hasProperties) ...[
                    Gap(spacing.xs),
                    PropertyChips(entryId: entryId),
                  ],
```

を次にする:

```dart
                  if (hasProperties) ...[
                    Gap(spacing.xs),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.md),
                      child: PropertyPicker(entryId: entryId),
                    ),
                  ],
```

6. ファイルを消す: `git rm lib/features/detail/ui/widgets/group_tabs.dart lib/features/detail/ui/widgets/property_chips.dart`

- [ ] **Step 5: 仲間のタブの API と文言を消す**

- `lib/features/detail/view_model/detail_state.dart`: `selectedGroup`・`showsTabs`・`specsInSelectedGroup`・`onCountIn` の 4 つを説明ごと消す。`property_group.dart` の import が要らなくなれば消す。`showsReferences` の説明を `/// 補足を選んでいるか。` に直す
- `lib/features/detail/view_model/detail_notifier.dart`: `groupSelected` を説明ごと消し、`property_group.dart` の import を消す。`referencesSelected` の説明を `/// 補足を選ぶ。補足は比べられないので比較をやめる。` に直す
- `lib/l10n/app_ja.arb`: `detailTabReferences`・`@detailTabReferences`・`detailTabOnCount`・`@detailTabOnCount` を消す
- Run: `fvm flutter gen-l10n && fvm dart run build_runner build --delete-conflicting-outputs`
- Run: `grep -rn "GroupTabs\|PropertyChips\|groupSelected\|selectedGroup\|showsTabs\|specsInSelectedGroup\|onCountIn\|detailTab" lib test`
  Expected: 何も出ない（出たら直す）

- [ ] **Step 6: 通ることを確かめる**

Run: `fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`
Expected: 失敗 0・skip 0。件数を控える（Task 5 で文書に書く）

- [ ] **Step 7: コミット**

```bash
git add -A lib test
git commit -m "feat: 詳細画面を選ぶ欄に替え、仲間のタブとチップの列をやめる

キーボードが出ている間にタブを隠す決まりも、タブがなくなったので消す。

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: 文書をそろえ、実機で確かめる

**Files:**
- Modify: `docs/design/screens/cb_dtl_詳細画面.md`
- Modify: `docs/design/functions/property-relations.md`
- Modify: `docs/design/functions/property-picker.md`（実装で決めた寸法に合わせる）
- Modify: `docs/test/test-cases.md`

- [ ] **Step 1: 詳細画面の設計書を v4 にする**

`docs/design/screens/cb_dtl_詳細画面.md`:
- 要約の「結論」を「上にプレビューとコードの帯、その下にプロパティの選ぶ欄（‹ カード › と点）、下半分に選んだ1つを大きく触る編集パネルを置く。カードを押すと全部を仲間ごとに並べた一覧のシート。比べるはプレビューを左右に分ける」に直す
- 「デザイン」に Task 0 で描いた v4 の 4 枚のリンクとノード ID を足す
- バージョン履歴に `| 2026/10/29 | 4.0.0 | v4: 仲間のタブ（gt）とチップの列（pc）をやめ、選ぶ欄（ps）と一覧のシート（pss）にする（docs/design/functions/property-picker.md）。値の長い書き方は型の名前だけにする | Claude（ブレインストーミング・Figma の v4） |` を足す
- 構成の mermaid 図で `GROUPS` と `CHIPS` の subgraph を 1 つの `PICKER["プロパティの選ぶ欄（固定）"]`（中身: `Card["‹ カード ›<br/>仲間のアイコン・名前・仲間 ・ 値<br/>指定中 / 既定 / 薄い"]` と `Dots["点<br/>位置と指定中。仲間の境目で間を空ける"]`）に替え、矢印を `APPBAR --> PREVIEW --> PICKER --> EDITOR` にする。Control の「入れ子は子のチップと子の操作」はそのまま
- 部品の説明の「仲間のタブは自前の横並び（押せる範囲 48×48）」を「選ぶ欄の ‹ › は `IconButton.filledTonal`、カードと点・一覧のシートの行は自前」に直し、「主な操作（チップを選ぶ・値を変える）」を「主な操作（プロパティを選ぶ・値を変える）」に直す
- 状態変化の図と説明の「別のチップを選ぶ」を「別のプロパティを選ぶ」に直す。基本方針の「全体の状態はチップの列で見渡す」を「全体の状態は選ぶ欄の点と一覧のシートで見渡す」に直す
- `### pc_プロパティのチップ` と `### gt_仲間のタブ` の節を、`### ps_選ぶ欄` と `### pss_一覧のシート` の節に置き換える。項目一覧・アクション一覧・表示パターンの表は、property-picker.md の「選ぶ欄（ps）」「一覧のシート（pss）」から、既存の表の書式（`| ID | 項目 | 内容 | 動的 | 初期 | データ取得元 |` など、今の pc の表と同じ列）で書く。項目 ID は `ps-prev`・`ps-card`・`ps-next`・`ps-dots`・`pss-head`・`pss-sect`・`pss-row`・`pss-refs`
- `rl` の「相手の名前をタップ」の動きを「相手を選ぶ（カードがそこへ移る）。比較中ならやめる」に直す
- `ne` の ne-chip の説明に「値は短い表示（長い書き方は型の名前だけ）」を足す
- `rf` の「補足のタブを開いている間は」を「補足を選んでいる間は」に直す

- [ ] **Step 2: ほかの文書を直す**

- `docs/design/functions/property-relations.md` の「決めたこと」の表の「画面の形」の行の後ろに 1 文足す: 「（2026-10-29 に、仲間のタブとチップの列は選ぶ欄と一覧のシートに置き換えた。docs/design/functions/property-picker.md）」
- `docs/design/functions/property-picker.md`: 実装で決めた所を合わせる。角丸は「`NimiRadius` の md（12）」、点の間は「4、仲間の境目は 8」、収まらないときは「全体を縮める（`FittedBox`）」、全件の確かめは「画面を開く代わりに状態で、212 件すべての送る順番を確かめる（TC-92）」
- `docs/test/test-cases.md`:
  - 要件の表に `| R-29 | 詳細で、プロパティを ‹ › と一覧のシートで選べ、長い値でも選ぶ欄が崩れない | TC-91, TC-92, TC-93, TC-94 |` を足す
  - TC-84 の行の結果の欄を「廃止（TC-91 に置き換え）」にする
  - ケースの表の TC-90 の後ろに足す:

```markdown
| TC-91 | R-29 | Container・relation の詳細 | 開く／‹ › で送る／先頭・最後・補足／読み上げの上下 | カードに名前と「仲間 ・ 値」。端の矢印は押せない。最後の次は補足。効かないものは薄い。点は数だけ並び読み上げない。キーボード中も出たまま | 画面 | ✅ |
| TC-92 | R-29 | 全収録データ | 送る順番を作る | プロパティを 1 回ずつ通り、補足があれば最後 | ロジック | ✅ |
| TC-93 | R-29 | 値の短い表示 | 長い書き方の FixedControl | 20 文字までは書き方のまま、超えたら先頭の型の名前（リストは `[型]`）。型が取れなければそのまま | ロジック | ✅ |
| TC-94 | R-29 | relation の一覧のシート | 開く／行を押す／補足の行 | 題と指定中の数。仲間の見出しは語彙の順で最後に補足。今の行に ✓。押すと選んで閉じる | 画面 | ✅ |
```

  - 結果の節（180 行あたり）に「段 3（選ぶ欄）: 全体で {Task 4 Step 6 の件数} 件成功・0 skip」を足す

- [ ] **Step 3: mermaid を確かめる**

`mermaid-lint` スキルで `docs/design/screens/cb_dtl_詳細画面.md` を検査する
Expected: NG なし

- [ ] **Step 4: 全体を確かめてコミット**

Run: `fvm dart format --set-exit-if-changed . && fvm flutter analyze && fvm flutter test`
Expected: 失敗 0・skip 0

```bash
git add docs
git commit -m "docs: 詳細画面の設計書を v4（選ぶ欄と一覧のシート）にし、テストケースを足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 5: 実機に入れる（メインのセッションで行う）**

CLAUDE.md・引き継ぎメモの手順で iPhone（00008160-001402CC0A600036）に入れて起動し、オーナーに触ってもらう:

```bash
fvm flutter build ios --release --no-codesign
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination id=00008160-001402CC0A600036 -allowProvisioningUpdates build
xcrun devicectl device install app --device 00008160-001402CC0A600036 <DerivedData の Release-iphoneos/Runner.app>
xcrun devicectl device process launch --device 00008160-001402CC0A600036 jp.nimi.widgetLab
```

- [ ] **Step 6: PR を作ってマージする（メインのセッションで行う）**

`git push -u origin docs/property-picker` → `gh pr create`（本文の最後に `🤖 Generated with [Claude Code](https://claude.com/claude-code)`）→ すぐマージ（ブランチは消さない）
