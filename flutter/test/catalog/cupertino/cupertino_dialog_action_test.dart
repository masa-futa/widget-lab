import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dialog_action.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets(
    'TC-18: 全部 OFF なら必須の引数だけを渡し、ほかは CupertinoDialogAction の既定値で組み立てる',
    (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: cupertinoDialogActionEntry.build(
              DemoArgs(
                cupertinoDialogActionEntry,
                allOff(cupertinoDialogActionEntry),
              ),
            ),
          ),
        ),
      );

      final built = tester.widget<CupertinoDialogAction>(
        find.byType(CupertinoDialogAction),
      );
      expect(built.isDefaultAction, isFalse);
      expect(built.isDestructiveAction, isFalse);
    },
  );
}
