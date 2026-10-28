import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliver_navigation_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら既定値で組み立てる（Hero では飛ばさない）', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoSliverNavigationBarEntry.build(
            DemoArgs(
              cupertinoSliverNavigationBarEntry,
              allOff(cupertinoSliverNavigationBarEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoSliverNavigationBar>(
      find.byType(CupertinoSliverNavigationBar),
    );
    const defaults = CupertinoSliverNavigationBar();
    expect(built.largeTitle, isNull);
    expect(built.middle, isNull);
    expect(built.alwaysShowMiddle, defaults.alwaysShowMiddle);
    expect(built.trailing, isNull);
    expect(built.backgroundColor, isNull);
    expect(built.stretch, defaults.stretch);
    expect(built.transitionBetweenRoutes, isFalse);
  });
}
