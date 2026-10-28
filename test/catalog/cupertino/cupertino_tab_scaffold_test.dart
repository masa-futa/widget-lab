import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_scaffold.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoTabScaffoldEntry.build(
      DemoArgs(cupertinoTabScaffoldEntry, allOff(cupertinoTabScaffoldEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の tabBar だけを渡し、地の色は既定値で組み立てる', (tester) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoTabScaffold>(
      find.byType(CupertinoTabScaffold),
    );
    expect(built.backgroundColor, isNull);
    expect(find.text('タブ 1'), findsOneWidget);
  });

  testWidgets('タブを押すと、tabBuilder の中身が切り替わる', (tester) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.text('探す'));
    await tester.pump();

    expect(find.text('タブ 2'), findsOneWidget);
  });
}
