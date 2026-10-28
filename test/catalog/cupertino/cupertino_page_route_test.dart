import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_route.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら題なし・fullscreenDialog は false で開く', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoPageRouteEntry.build(
            DemoArgs(cupertinoPageRouteEntry, allOff(cupertinoPageRouteEntry)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    final route =
        ModalRoute.of(tester.element(find.text('次の画面')))!
            as CupertinoPageRoute<void>;
    expect(route.title, isNull);
    expect(route.fullscreenDialog, isFalse);
  });

  testWidgets('題を渡すと、開いた画面のナビゲーションバーに出る', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoPageRouteEntry.build(
            DemoArgs(
              cupertinoPageRouteEntry,
              cupertinoPageRouteEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    expect(find.text('設定'), findsOneWidget);
  });
}
