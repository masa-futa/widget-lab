import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_row.dart';

import '../pump.dart';

PropertySpec _spec(WidgetEntry entry, String name) =>
    entry.properties.firstWhere((p) => p.name == name);

void main() {
  final padding = _spec(paddingEntry, 'padding');

  Future<void> pumpRow(
    WidgetTester tester, {
    PropertySpec? spec,
    PropertySetting setting = const PropertySetting(
      on: true,
      value: SliderValue(16),
    ),
    bool isComparing = false,
    ValueChanged<bool>? onToggled,
    ValueChanged<ControlValue>? onValueChanged,
    VoidCallback? onCompareTapped,
  }) => pumpPart(
    tester,
    SingleChildScrollView(
      child: PropertyRow(
        spec: spec ?? padding,
        setting: setting,
        isComparing: isComparing,
        onToggled: onToggled ?? (_) {},
        onValueChanged: onValueChanged ?? (_) {},
        onCompareTapped: onCompareTapped ?? () {},
      ),
    ),
  );

  testWidgets('TC-47: ON の行は名前・型・説明と使える値の操作を出す', (tester) async {
    await pumpRow(tester);

    expect(find.text('padding'), findsOneWidget);
    expect(find.text('EdgeInsetsGeometry'), findsOneWidget);
    expect(find.text(padding.description), findsOneWidget);
    expect(find.text('16.0'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
  });

  testWidgets('TC-47: スイッチを押すと OFF の知らせが出る', (tester) async {
    bool? toggled;
    await pumpRow(tester, onToggled: (on) => toggled = on);

    await tester.tap(find.byType(Switch));

    expect(toggled, isFalse);
  });

  testWidgets('TC-47: スライダーを動かすと値の知らせが出る', (tester) async {
    ControlValue? changed;
    await pumpRow(tester, onValueChanged: (v) => changed = v);

    await tester.drag(find.byType(Slider), const Offset(400, 0));

    expect(changed, const SliderValue(48));
  });

  testWidgets('TC-47: スイッチは「padding を付ける」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRow(tester);

    expect(
      tester.getSemantics(find.byType(Switch)),
      matchesSemantics(
        label: 'padding を付ける',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('TC-48: OFF の行は値の操作が使えない', (tester) async {
    await pumpRow(
      tester,
      setting: const PropertySetting(on: false, value: SliderValue(16)),
    );

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('TC-26: 必須の行はスイッチの代わりに「必須」を出す', (tester) async {
    await pumpRow(
      tester,
      spec: _spec(textEntry, 'data'),
      setting: const PropertySetting(on: true, value: TextValue('こんにちは')),
    );

    expect(find.byType(Switch), findsNothing);
    expect(find.text('必須'), findsOneWidget);
  });

  testWidgets('TC-49: 比べるを押すと知らせが出る', (tester) async {
    var tapped = false;
    await pumpRow(tester, onCompareTapped: () => tapped = true);

    await tester.tap(find.byTooltip('付けた／付けないを比べる'));

    expect(tapped, isTrue);
  });

  testWidgets('TC-49: 比較中は選択中の見た目で「比較中」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpRow(tester, isComparing: true);

    final button = find.byType(IconButton);
    expect(tester.widget<IconButton>(button).isSelected, isTrue);
    expect(
      tester.getSemantics(button),
      isSemantics(label: '比較中', isSelected: true),
    );
    semantics.dispose();
  });

  group('値の操作は型に合わせた部品を出す', () {
    testWidgets('TC-21: 選択肢が 4 つまでならセグメント', (tester) async {
      ControlValue? changed;
      await pumpRow(
        tester,
        spec: _spec(rowEntry, 'crossAxisAlignment'),
        setting: const PropertySetting(on: true, value: ChoiceValue(2)),
        onValueChanged: (v) => changed = v,
      );

      await tester.tap(find.text('start'));

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(changed, const ChoiceValue(0));
    });

    testWidgets('TC-22: 選択肢が 5 つ以上ならドロップダウン', (tester) async {
      ControlValue? changed;
      await pumpRow(
        tester,
        spec: _spec(rowEntry, 'mainAxisAlignment'),
        setting: const PropertySetting(on: true, value: ChoiceValue(0)),
        onValueChanged: (v) => changed = v,
      );

      await tester.tap(find.byType(DropdownMenu<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('center').last);
      await tester.pumpAndSettle();

      expect(changed, const ChoiceValue(2));
    });

    testWidgets('TC-20: 真偽はスイッチ', (tester) async {
      ControlValue? changed;
      await pumpRow(
        tester,
        spec: _spec(textEntry, 'softWrap'),
        setting: const PropertySetting(on: true, value: SwitchValue(true)),
        onValueChanged: (v) => changed = v,
      );

      // 1 つ目は ON/OFF、2 つ目が値のスイッチ
      await tester.tap(find.byType(Switch).last);

      expect(changed, const SwitchValue(false));
    });

    testWidgets('TC-23: 色は色見本で、名前で読み上げ、選んだものが選択中', (tester) async {
      ControlValue? changed;
      await pumpRow(
        tester,
        spec: _spec(containerEntry, 'color'),
        setting: const PropertySetting(on: true, value: ChoiceValue(0)),
        onValueChanged: (v) => changed = v,
      );

      await tester.tap(find.bySemanticsLabel('若竹'));

      expect(changed, const ChoiceValue(2));
      expect(
        tester.getSemantics(find.bySemanticsLabel('瑠璃')),
        isSemantics(isSelected: true),
      );
    });

    testWidgets('TC-23: 文字は入力欄で、入れるたびに知らせる', (tester) async {
      ControlValue? changed;
      await pumpRow(
        tester,
        spec: _spec(textEntry, 'data'),
        setting: const PropertySetting(on: true, value: TextValue('こんにちは')),
        onValueChanged: (v) => changed = v,
      );

      await tester.enterText(find.byType(TextField), 'さようなら');

      expect(changed, const TextValue('さようなら'));
    });
  });

  testWidgets('値の操作を「padding の値」と読み上げる', (tester) async {
    await pumpRow(tester);

    // 値の操作の読み上げ（今の値）が後ろに続く
    expect(find.bySemanticsLabel(RegExp('^padding の値')), findsOneWidget);
  });

  testWidgets('色見本は 48dp 四方より小さくない', (tester) async {
    await pumpRow(
      tester,
      spec: _spec(containerEntry, 'color'),
      setting: const PropertySetting(on: true, value: ChoiceValue(0)),
    );

    final size = tester.getSize(find.bySemanticsLabel('瑠璃'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
