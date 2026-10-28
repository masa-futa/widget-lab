import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/long_press_draggable.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら LongPressDraggable の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, longPressDraggableEntry);
    final built = demoWidget<LongPressDraggable<int>>(tester);

    expect(built.data, isNull);
    expect(built.delay, const Duration(milliseconds: 500));
    expect(built.hapticFeedbackOnStart, isTrue);
  });
}
