import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_transition.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoPageTransitionEntry.build(
      DemoArgs(
        cupertinoPageTransitionEntry,
        allOff(cupertinoPageTransitionEntry),
      ),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 必須のプロパティだけなので、全部 OFF でも最初の値で組み立てる', (tester) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoPageTransition>(
      find.byType(CupertinoPageTransition).last,
    );
    expect(built.primaryRouteAnimation.value, 0.5);
    expect(built.secondaryRouteAnimation.value, 0);
    expect(built.linearTransition, isFalse);
  });
}
