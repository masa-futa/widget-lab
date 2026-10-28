import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/drag_target.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../demo_pump.dart';

void main() {
  Future<void> dragOnto(WidgetTester tester, String number) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(number).first),
    );
    await gesture.moveTo(tester.getCenter(find.byType(DragTarget<int>).first));
    await tester.pump();
    await gesture.up();
    await tester.pump();
  }

  testWidgets('TC-18: 全部 OFF なら DragTarget の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, dragTargetEntry);
    final built = demoWidget<DragTarget<int>>(tester);

    expect(built.onWillAcceptWithDetails, isNull);
    expect(built.onAcceptWithDetails, isNull);
  });

  testWidgets('DragTarget: 偶数だけ受けるなら、1 は断り 2 を受け取る', (tester) async {
    final args = DemoArgs(dragTargetEntry, dragTargetEntry.initialSettings());
    await pumpDemo(tester, dragTargetEntry.build(args));

    await dragOnto(tester, '1');
    expect(find.text('ここへ落とす'), findsOneWidget);

    await dragOnto(tester, '2');
    expect(find.text('受け取った: 2'), findsOneWidget);
  });
}
