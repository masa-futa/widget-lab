import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_view.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoTabViewEntry.build(
      DemoArgs(cupertinoTabViewEntry, allOff(cupertinoTabViewEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら題なし（defaultTitle の既定値 null）で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoTabView>(
      find.byType(CupertinoTabView),
    );
    expect(built.defaultTitle, isNull);
  });

  testWidgets('「次へ」で、タブの中の Navigator だけが遷移する', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTabViewEntry.build(
            DemoArgs(
              cupertinoTabViewEntry,
              cupertinoTabViewEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();

    expect(find.text('次の画面'), findsWidgets);
    // 戻るボタンに最初の画面の題が出る
    expect(find.text('ホーム'), findsOneWidget);
    // アプリの Navigator は最初の画面のまま
    expect(find.byType(CupertinoTabView), findsOneWidget);
  });
}
