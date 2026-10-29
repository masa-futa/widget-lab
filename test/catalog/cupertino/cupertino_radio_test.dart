import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_radio.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoRadio の既定値で組み立て、value の 1 を選んでいる', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoRadioEntry.build(
            DemoArgs(cupertinoRadioEntry, allOff(cupertinoRadioEntry)),
          ),
        ),
      ),
    );

    final radio = tester.widget<CupertinoRadio<int>>(
      find.byType(CupertinoRadio<int>).first,
    );
    const defaults = CupertinoRadio<int>(value: 0);
    expect(radio.activeColor, defaults.activeColor);
    expect(radio.inactiveColor, defaults.inactiveColor);
    expect(radio.fillColor, defaults.fillColor);
    expect(radio.useCheckmarkStyle, defaults.useCheckmarkStyle);
    expect(radio.toggleable, defaults.toggleable);
    expect(radio.enabled, defaults.enabled);
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      1,
    );
  });

  testWidgets('押すと選んだ値が変わる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoRadioEntry.build(
            DemoArgs(
              cupertinoRadioEntry,
              cupertinoRadioEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoRadio<int>).at(2));
    await tester.pumpAndSettle();

    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      2,
    );
  });
}
