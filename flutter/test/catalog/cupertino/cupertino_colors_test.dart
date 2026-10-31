import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_colors.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Future<ColoredBox> _pump(WidgetTester tester, Brightness brightness) async {
  await tester.pumpWidget(
    CupertinoApp(
      theme: CupertinoThemeData(brightness: brightness),
      home: Center(
        child: cupertinoColorsEntry.build(
          DemoArgs(cupertinoColorsEntry, allOff(cupertinoColorsEntry)),
        ),
      ),
    ),
  );
  return tester.widget<ColoredBox>(find.byType(ColoredBox).last);
}

void main() {
  testWidgets('TC-18: 全部 OFF でも必須の color（systemBlue）を、今の明るさで resolve して塗る', (
    tester,
  ) async {
    final light = await _pump(tester, Brightness.light);
    expect(light.color.toARGB32(), CupertinoColors.systemBlue.color.toARGB32());

    final dark = await _pump(tester, Brightness.dark);
    expect(
      dark.color.toARGB32(),
      CupertinoColors.systemBlue.darkColor.toARGB32(),
    );
  });
}
