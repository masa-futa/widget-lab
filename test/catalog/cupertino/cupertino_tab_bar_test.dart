import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoTabBarEntry.build(
      DemoArgs(cupertinoTabBarEntry, allOff(cupertinoTabBarEntry)),
    ),
  ),
);

void main() {
  testWidgets(
    'TC-18: 全部 OFF なら必須の items だけを渡し、ほかは CupertinoTabBar の既定値で組み立てる',
    (tester) async {
      await tester.pumpWidget(_allOff());

      final built = tester.widget<CupertinoTabBar>(
        find.byType(CupertinoTabBar),
      );
      final defaults = CupertinoTabBar(items: built.items);
      expect(built.items, hasLength(3));
      expect(built.currentIndex, defaults.currentIndex);
      expect(built.activeColor, defaults.activeColor);
      expect(built.inactiveColor, defaults.inactiveColor);
      expect(built.backgroundColor, defaults.backgroundColor);
      expect(built.iconSize, defaults.iconSize);
      expect(built.onTap, isNull);
    },
  );

  testWidgets('onTap が ON なら、押したタブを選び直す', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTabBarEntry.build(
            DemoArgs(
              cupertinoTabBarEntry,
              cupertinoTabBarEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('設定'));
    await tester.pump();

    expect(
      tester.widget<CupertinoTabBar>(find.byType(CupertinoTabBar)).currentIndex,
      2,
    );
  });
}
