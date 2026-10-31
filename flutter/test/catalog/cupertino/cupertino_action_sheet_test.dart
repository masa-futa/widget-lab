import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_action_sheet.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の actions だけを渡し、ほかは既定値（null）で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: cupertinoActionSheetEntry.build(
          DemoArgs(
            cupertinoActionSheetEntry,
            allOff(cupertinoActionSheetEntry),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoActionSheet>(
      find.byType(CupertinoActionSheet),
    );
    expect(built.actions, hasLength(2));
    expect(built.title, isNull);
    expect(built.message, isNull);
    expect(built.cancelButton, isNull);
  });
}
