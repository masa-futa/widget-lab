import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_magnifier.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoTextMagnifier の既定値で拡大鏡を作る', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTextMagnifierEntry.build(
            DemoArgs(
              cupertinoTextMagnifierEntry,
              allOff(cupertinoTextMagnifierEntry),
            ),
          ),
        ),
      ),
    );
    final field = tester.widget<CupertinoTextField>(
      find.byType(CupertinoTextField),
    );
    final controller = MagnifierController();
    final info = ValueNotifier(MagnifierInfo.empty);
    addTearDown(info.dispose);

    final magnifier =
        field.magnifierConfiguration!.magnifierBuilder(
              tester.element(find.byType(CupertinoTextField)),
              controller,
              info,
            )!
            as CupertinoTextMagnifier;
    final defaults = CupertinoTextMagnifier(
      controller: controller,
      magnifierInfo: info,
    );

    expect(magnifier.dragResistance, defaults.dragResistance);
    expect(magnifier.hideBelowThreshold, defaults.hideBelowThreshold);
    expect(
      magnifier.horizontalScreenEdgePadding,
      defaults.horizontalScreenEdgePadding,
    );
    expect(magnifier.animationCurve, defaults.animationCurve);
  });
}
