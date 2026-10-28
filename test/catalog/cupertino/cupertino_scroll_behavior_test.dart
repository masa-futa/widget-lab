import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_scroll_behavior.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら親の ScrollBehavior をそのまま渡す', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoScrollBehaviorEntry.build(
            DemoArgs(
              cupertinoScrollBehaviorEntry,
              allOff(cupertinoScrollBehaviorEntry),
            ),
          ),
        ),
      ),
    );

    final configurations = tester.widgetList<ScrollConfiguration>(
      find.byType(ScrollConfiguration),
    );
    expect(
      configurations.last.behavior,
      same(configurations.elementAt(configurations.length - 2).behavior),
    );
  });

  testWidgets('ON なら CupertinoScrollBehavior を渡す', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoScrollBehaviorEntry.build(
            DemoArgs(
              cupertinoScrollBehaviorEntry,
              cupertinoScrollBehaviorEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .widgetList<ScrollConfiguration>(find.byType(ScrollConfiguration))
          .last
          .behavior,
      isA<CupertinoScrollBehavior>(),
    );
  });
}
