import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/features/detail/ui/widgets/editor_panel.dart';

import '../pump.dart';

PropertySpec _spec(WidgetEntry entry, String name) =>
    entry.properties.firstWhere((p) => p.name == name);

void main() {
  final padding = _spec(containerEntry, 'padding');

  Future<void> pumpPanel(
    WidgetTester tester, {
    PropertySpec? spec,
    PropertySetting setting = const PropertySetting(
      on: true,
      value: SliderValue(16),
    ),
    bool isComparing = false,
    bool isDefault = true,
    ValueChanged<bool>? onToggled,
    ValueChanged<ControlValue>? onValueChanged,
    VoidCallback? onCompareTapped,
    VoidCallback? onDefaultTapped,
  }) => pumpPart(
    tester,
    SingleChildScrollView(
      child: EditorPanel(
        spec: spec ?? padding,
        setting: setting,
        isComparing: isComparing,
        isDefault: isDefault,
        onToggled: onToggled ?? (_) {},
        onValueChanged: onValueChanged ?? (_) {},
        onCompareTapped: onCompareTapped ?? () {},
        onDefaultTapped: onDefaultTapped ?? () {},
      ),
    ),
  );

  testWidgets('TC-47: ON なら名前・型・説明と、使える値の操作を出す', (tester) async {
    await pumpPanel(tester);

    expect(find.text('padding'), findsOneWidget);
    expect(find.text('EdgeInsetsGeometry?'), findsOneWidget);
    expect(find.text(padding.description), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
    // つまみの上の吹き出し
    expect(find.text('16.0'), findsOneWidget);
    // 下に最小・途中・最大の値
    for (final label in ['0', '12', '24', '36', '48']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('TC-47: スイッチを押すと OFF の知らせが出る', (tester) async {
    bool? toggled;
    await pumpPanel(tester, onToggled: (on) => toggled = on);

    await tester.tap(find.byType(Switch));

    expect(toggled, isFalse);
  });

  testWidgets('TC-47: スライダーを動かすと値の知らせが出る', (tester) async {
    ControlValue? changed;
    await pumpPanel(tester, onValueChanged: (v) => changed = v);

    await tester.drag(find.byType(Slider), const Offset(600, 0));

    expect(changed, const SliderValue(48));
  });

  testWidgets('TC-47: スイッチは「padding を付ける」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPanel(tester);

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

  testWidgets('TC-48: OFF なら値の操作が使えない', (tester) async {
    await pumpPanel(
      tester,
      setting: const PropertySetting(on: false, value: SliderValue(16)),
    );

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('TC-26: 必須ならスイッチの代わりに「必須」を出す', (tester) async {
    await pumpPanel(
      tester,
      spec: _spec(textEntry, 'data'),
      setting: const PropertySetting(on: true, value: TextValue('こんにちは')),
    );

    expect(find.byType(Switch), findsNothing);
    expect(find.text('必須'), findsOneWidget);
  });

  testWidgets('TC-27: 比べるを押すと知らせが出て、比較中は「比べるのをやめる」', (tester) async {
    var tapped = false;
    await pumpPanel(tester, onCompareTapped: () => tapped = true);

    await tester.tap(find.text('比べる'));
    expect(tapped, isTrue);

    await pumpPanel(tester, isComparing: true);
    expect(find.text('比べるのをやめる'), findsOneWidget);
    expect(find.text('比べる'), findsNothing);
  });

  testWidgets('TC-65: 既定に戻すは最初の値のままなら押せず、変えたら押せる', (tester) async {
    var tapped = false;
    await pumpPanel(tester);
    TextButton button() => tester.widget<TextButton>(
      find.ancestor(of: find.text('既定に戻す'), matching: find.byType(TextButton)),
    );
    expect(button().onPressed, isNull);

    await pumpPanel(
      tester,
      isDefault: false,
      onDefaultTapped: () => tapped = true,
    );
    await tester.tap(find.text('既定に戻す'));

    expect(tapped, isTrue);
  });

  testWidgets('TC-66: Alignment の 9 つは 3×3 のマスで選び、名前とコードを出す', (tester) async {
    ControlValue? changed;
    await pumpPanel(
      tester,
      spec: _spec(containerEntry, 'alignment'),
      setting: const PropertySetting(on: true, value: ChoiceValue(4)),
      onValueChanged: (v) => changed = v,
    );

    expect(find.byType(DropdownMenu<int>), findsNothing);
    expect(find.text('center'), findsOneWidget);
    expect(find.text('Alignment.center'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('topLeft'));

    expect(changed, const ChoiceValue(0));
  });

  testWidgets('TC-66: 選択肢が別の順でも、マスの位置は Alignment の向きに合う', (tester) async {
    ControlValue? changed;
    final alignments = [
      for (final y in [1.0, 0.0, -1.0])
        for (final x in [1.0, 0.0, -1.0]) Alignment(x, y),
    ];
    final reversed = PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry?',
      description: '',
      control: ChoiceControl(
        initialIndex: 4,
        choices: [for (final a in alignments) Choice('$a', a, 'Alignment($a)')],
      ),
    );
    await pumpPanel(
      tester,
      spec: reversed,
      setting: const PropertySetting(on: true, value: ChoiceValue(4)),
      onValueChanged: (v) => changed = v,
    );
    final cells = find.bySemanticsLabel(RegExp(r'^Alignment'));
    final rects = [
      for (final element in cells.evaluate())
        tester.getRect(find.byWidget(element.widget)),
    ];
    final bottomRight = rects.reduce(
      (a, b) => a.left + a.top >= b.left + b.top ? a : b,
    );

    await tester.tapAt(bottomRight.center);

    // 右下のマスは Alignment(1, 1)（並びの最初）
    expect(changed, const ChoiceValue(0));
  });

  testWidgets('TC-23: 色見本は名前つきで、押すと選んだ知らせが出る', (tester) async {
    ControlValue? changed;
    await pumpPanel(
      tester,
      spec: _spec(containerEntry, 'color'),
      setting: const PropertySetting(on: true, value: ChoiceValue(0)),
      onValueChanged: (v) => changed = v,
    );

    expect(find.text('若竹'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('若竹'));

    expect(changed, const ChoiceValue(2));
  });

  testWidgets('TC-20: 真偽は値のスイッチと true / false の表示', (tester) async {
    await pumpPanel(
      tester,
      spec: _spec(textEntry, 'softWrap'),
      setting: const PropertySetting(on: true, value: SwitchValue(true)),
    );

    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.text('true'), findsOneWidget);
  });

  testWidgets('固定の値は操作の代わりに、コードでの書き方を出す', (tester) async {
    await pumpPanel(
      tester,
      spec: _spec(containerEntry, 'child'),
      setting: const PropertySetting(on: true, value: FixedValue()),
    );

    expect(find.text('FlutterLogo()'), findsOneWidget);
  });
}
