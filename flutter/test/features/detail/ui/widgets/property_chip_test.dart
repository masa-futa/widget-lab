import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_chip.dart';

import '../pump.dart';

void main() {
  Future<void> pumpChip(
    WidgetTester tester, {
    bool on = true,
    bool selected = false,
    bool dimmed = false,
    VoidCallback? onTap,
  }) => pumpPart(
    tester,
    Center(
      child: PropertyChip(
        name: 'padding',
        value: '16',
        on: on,
        selected: selected,
        dimmed: dimmed,
        onTap: onTap ?? () {},
      ),
    ),
  );

  ShapeDecoration decorationOf(WidgetTester tester) =>
      tester.widget<Ink>(find.byType(Ink)).decoration! as ShapeDecoration;

  ColorScheme schemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(PropertyChip))).colorScheme;

  testWidgets('TC-49: 押すと知らせが出る', (tester) async {
    var tapped = false;
    await pumpChip(tester, onTap: () => tapped = true);

    await tester.tap(find.byType(PropertyChip));

    expect(tapped, isTrue);
  });

  testWidgets('TC-49: 選択中は accent の地で、「選択中」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpChip(tester, selected: true);

    expect(decorationOf(tester).color, schemeOf(tester).primary);
    expect(
      tester.getSemantics(find.byType(PropertyChip)),
      matchesSemantics(
        label: 'padding、16、選択中',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('効かないチップは「今は効かない」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpChip(tester, dimmed: true);

    expect(
      tester.getSemantics(find.byType(PropertyChip)),
      matchesSemantics(
        label: 'padding、16、今は効かない',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('TC-49: 指定中は accent-container の地で、名前と値を出す', (tester) async {
    await pumpChip(tester);

    expect(decorationOf(tester).color, schemeOf(tester).primaryContainer);
    expect(find.text('padding'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
  });

  testWidgets('TC-49: 既定は地なしの outline の枠で、値は「既定」', (tester) async {
    await pumpChip(tester, on: false);

    final decoration = decorationOf(tester);
    expect(decoration.color, isNull);
    expect(
      (decoration.shape as StadiumBorder).side.color,
      schemeOf(tester).outline,
    );
    expect(find.text('既定'), findsOneWidget);
    expect(find.text('16'), findsNothing);
  });

  testWidgets('TC-49: 見た目の 40 の外でも、高さ 48 の範囲なら押せる', (tester) async {
    var tapped = false;
    await pumpChip(tester, onTap: () => tapped = true);
    final chip = tester.getRect(find.byType(PropertyChip));
    expect(chip.height, 48);

    // 見た目（40）の上端より 2 だけ外
    await tester.tapAt(Offset(chip.center.dx, chip.top + 2));

    expect(tapped, isTrue);
  });
}
