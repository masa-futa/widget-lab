import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_switch.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _app(Widget child) => CupertinoApp(home: Center(child: child));

void main() {
  testWidgets('TC-18: 全部 OFF なら色は既定値（null）で組み立てる', (tester) async {
    await tester.pumpWidget(
      _app(
        cupertinoSwitchEntry.build(
          DemoArgs(cupertinoSwitchEntry, allOff(cupertinoSwitchEntry)),
        ),
      ),
    );

    final built = tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch));
    expect(built.value, isTrue);
    expect(built.activeTrackColor, isNull);
    expect(built.inactiveTrackColor, isNull);
    expect(built.thumbColor, isNull);
    expect(built.onChanged, isNotNull);
  });

  testWidgets('プレビューで押すと値が変わる', (tester) async {
    await tester.pumpWidget(
      _app(
        cupertinoSwitchEntry.build(
          DemoArgs(
            cupertinoSwitchEntry,
            cupertinoSwitchEntry.initialSettings(),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    expect(
      tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
      isFalse,
    );
  });
}
