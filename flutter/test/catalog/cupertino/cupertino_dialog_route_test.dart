import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dialog_route.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoDialogRouteEntry.build(
      DemoArgs(cupertinoDialogRouteEntry, allOff(cupertinoDialogRouteEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoDialogRoute の既定値（外を押すと閉じる・既定の色）で開く', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    final route =
        ModalRoute.of(tester.element(find.text('ダイアログ')))!
            as CupertinoDialogRoute<void>;
    expect(route.barrierDismissible, isTrue);
    expect(
      route.barrierColor?.toARGB32(),
      (kCupertinoModalBarrierColor as CupertinoDynamicColor).color.toARGB32(),
    );
  });
}
