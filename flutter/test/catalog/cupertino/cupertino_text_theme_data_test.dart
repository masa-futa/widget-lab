import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_theme_data.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoTextThemeData() の既定値で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTextThemeDataEntry.build(
            DemoArgs(
              cupertinoTextThemeDataEntry,
              allOff(cupertinoTextThemeDataEntry),
            ),
          ),
        ),
      ),
    );

    final theme = tester.widget<CupertinoTheme>(
      find.byType(CupertinoTheme).last,
    );
    const defaults = CupertinoTextThemeData();
    final textTheme = theme.data.textTheme;
    expect(textTheme.textStyle, defaults.textStyle);
    expect(textTheme.actionTextStyle, defaults.actionTextStyle);
    expect(textTheme.navTitleTextStyle, defaults.navTitleTextStyle);
  });
}
