import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_navigation_bar_back_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoNavigationBarBackButtonEntry.build(
      DemoArgs(
        cupertinoNavigationBarBackButtonEntry,
        allOff(cupertinoNavigationBarBackButtonEntry),
      ),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら色と文字は既定値で、onPressed は渡す', (tester) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoNavigationBarBackButton>(
      find.byType(CupertinoNavigationBarBackButton),
    );
    expect(built.color, isNull);
    expect(built.previousPageTitle, isNull);
    expect(built.onPressed, isNotNull);
  });

  testWidgets('押してもアプリの Navigator を戻さない', (tester) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);
  });
}
