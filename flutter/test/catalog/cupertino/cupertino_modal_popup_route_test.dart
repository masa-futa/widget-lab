import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_modal_popup_route.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoModalPopupRouteEntry.build(
      DemoArgs(
        cupertinoModalPopupRouteEntry,
        allOff(cupertinoModalPopupRouteEntry),
      ),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoModalPopupRoute の既定値で開く', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    final route =
        ModalRoute.of(tester.element(find.text('シート')))!
            as CupertinoModalPopupRoute<void>;
    expect(route.barrierDismissible, isTrue);
    expect(route.barrierColor, kCupertinoModalBarrierColor);
    expect(route.filter, isNull);
  });
}
