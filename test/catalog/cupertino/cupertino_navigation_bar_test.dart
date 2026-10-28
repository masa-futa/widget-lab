import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_navigation_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoNavigationBarEntry.build(
      DemoArgs(
        cupertinoNavigationBarEntry,
        allOff(cupertinoNavigationBarEntry),
      ),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoNavigationBar の既定値で組み立て、Hero で飛ばさない', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoNavigationBar>(
      find.byType(CupertinoNavigationBar),
    );
    expect(built.leading, isNull);
    expect(built.middle, isNull);
    expect(built.trailing, isNull);
    expect(built.backgroundColor, isNull);
    expect(built.transitionBetweenRoutes, isFalse);
  });
}
