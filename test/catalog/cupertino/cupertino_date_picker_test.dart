import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_date_picker.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の日時と関数だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoDatePickerEntry.build(
            DemoArgs(
              cupertinoDatePickerEntry,
              allOff(cupertinoDatePickerEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(built.mode, CupertinoDatePickerMode.dateAndTime);
    expect(built.initialDateTime, DateTime(2026, 10, 28, 9, 30));
    expect(built.use24hFormat, isFalse);
    expect(built.minuteInterval, 1);
  });
}
