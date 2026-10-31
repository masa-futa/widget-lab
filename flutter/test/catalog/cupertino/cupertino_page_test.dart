import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoPageEntry.build(
      DemoArgs(cupertinoPageEntry, allOff(cupertinoPageEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら題なし・fullscreenDialog は false の 2 枚目を足す', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    final page =
        ModalRoute.of(tester.element(find.text('次の画面')))!.settings
            as CupertinoPage<void>;
    expect(page.title, isNull);
    expect(page.fullscreenDialog, isFalse);
    expect(page.canPop, isTrue);
  });

  testWidgets('戻るボタンで戻ると 2 枚目が外れ、もう一度開ける', (tester) async {
    await tester.pumpWidget(_allOff());
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.text('次の画面'), findsNothing);

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
    expect(find.text('次の画面'), findsOneWidget);
  });
}
