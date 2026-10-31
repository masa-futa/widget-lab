import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_theme.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら親のテーマをそのまま配る', (tester) async {
    const parent = CupertinoThemeData(primaryColor: CupertinoColors.systemTeal);
    await tester.pumpWidget(
      CupertinoApp(
        theme: parent,
        home: cupertinoThemeEntry.build(
          DemoArgs(cupertinoThemeEntry, allOff(cupertinoThemeEntry)),
        ),
      ),
    );

    final theme = tester.widget<CupertinoTheme>(
      find.byType(CupertinoTheme).last,
    );
    expect(theme.data.primaryColor, CupertinoColors.systemTeal);
  });
}
