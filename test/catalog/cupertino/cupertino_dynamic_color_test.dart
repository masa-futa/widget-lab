import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dynamic_color.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF でも必須の 2 色で、明るい下は color・暗い下は darkColor を塗る', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoDynamicColorEntry.build(
            DemoArgs(
              cupertinoDynamicColorEntry,
              allOff(cupertinoDynamicColorEntry),
            ),
          ),
        ),
      ),
    );

    final colors = tester
        .widgetList<ColoredBox>(find.byType(ColoredBox))
        .map((box) => box.color.toARGB32())
        .toList();
    expect(colors, containsAllInOrder([0xFF1E50A2, 0xFFF8B500]));
  });
}
