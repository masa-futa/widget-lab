import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/draggable.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Draggable の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, draggableEntry);
    final built = demoWidget<Draggable<int>>(tester);

    expect(built.data, isNull);
    expect(built.childWhenDragging, isNull);
    expect(built.axis, isNull);
  });

  testWidgets('Draggable: 受け取る場所へ運ぶと、data が渡る', (tester) async {
    final args = DemoArgs(draggableEntry, draggableEntry.initialSettings());
    await pumpDemo(tester, draggableEntry.build(args));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('1').first),
    );
    await gesture.moveTo(tester.getCenter(find.text('ここへ落とす')));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('受け取った: 1'), findsOneWidget);
  });
}
