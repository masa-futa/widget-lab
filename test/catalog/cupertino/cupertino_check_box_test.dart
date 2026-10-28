import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_check_box.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../all_off.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, PropertySetting> settings,
) => tester.pumpWidget(
  CupertinoApp(
    home: Center(
      child: cupertinoCheckBoxEntry.build(
        DemoArgs(cupertinoCheckBoxEntry, settings),
      ),
    ),
  ),
);

CupertinoCheckbox _checkbox(WidgetTester tester) =>
    tester.widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox));

void main() {
  testWidgets('TC-18: 全部 OFF なら tristate と色は既定値で組み立てる', (tester) async {
    await _pump(tester, allOff(cupertinoCheckBoxEntry));

    final built = _checkbox(tester);
    expect(built.value, isTrue);
    expect(built.tristate, isFalse);
    expect(built.activeColor, isNull);
    expect(built.checkColor, isNull);
    expect(built.onChanged, isNotNull);
  });

  testWidgets('tristate なら、押すと オン → 未定 → オフ と変わる', (tester) async {
    await _pump(tester, {
      ...allOff(cupertinoCheckBoxEntry),
      'tristate': const PropertySetting(on: true, value: SwitchValue(true)),
    });

    await tester.tap(find.byType(CupertinoCheckbox));
    await tester.pumpAndSettle();
    expect(_checkbox(tester).value, isNull);

    await tester.tap(find.byType(CupertinoCheckbox));
    await tester.pumpAndSettle();
    expect(_checkbox(tester).value, isFalse);
  });
}
