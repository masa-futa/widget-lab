import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_timer_picker.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の関数だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTimerPickerEntry.build(
            DemoArgs(
              cupertinoTimerPickerEntry,
              allOff(cupertinoTimerPickerEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoTimerPicker>(
      find.byType(CupertinoTimerPicker),
    );
    expect(built.mode, CupertinoTimerPickerMode.hms);
    expect(built.initialTimerDuration, Duration.zero);
    expect(built.minuteInterval, 1);
    expect(built.backgroundColor, isNull);
  });
}
