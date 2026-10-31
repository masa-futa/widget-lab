import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_context_menu.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら必須の actions と child だけを渡し、ほかは既定値で組み立てる', () {
    final built = cupertinoContextMenuEntry.build(
      DemoArgs(cupertinoContextMenuEntry, allOff(cupertinoContextMenuEntry)),
    ) as CupertinoContextMenu;

    expect(built.actions, hasLength(2));
    expect(built.enableHapticFeedback, isFalse);
  });

  testWidgets('長押しするとメニューが開く', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoContextMenuEntry.build(
            DemoArgs(
              cupertinoContextMenuEntry,
              cupertinoContextMenuEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    // 開くまでの動きが終わるまで押し続ける
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('長押し')),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('共有'), findsOneWidget);
  });
}
