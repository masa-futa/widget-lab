import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_controller.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoTabControllerEntry.build(
      DemoArgs(
        cupertinoTabControllerEntry,
        allOff(cupertinoTabControllerEntry),
      ),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら最初のタブ（initialIndex の既定値 0）から始める', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoTabScaffold>(
      find.byType(CupertinoTabScaffold),
    );
    expect(built.controller?.index, 0);
    expect(find.text('タブ 1'), findsOneWidget);
  });

  testWidgets('「次のタブへ」で controller の index が進み、タブが切り替わる', (tester) async {
    await tester.pumpWidget(_allOff());

    await tester.tap(find.text('次のタブへ'));
    await tester.pump();

    expect(find.text('タブ 2'), findsOneWidget);
  });
}
