import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_modal_barrier.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら AnimatedModalBarrier の既定値（押すと閉じる）で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: animatedModalBarrierEntry.build(
          DemoArgs(
            animatedModalBarrierEntry,
            allOff(animatedModalBarrierEntry),
          ),
        ),
      ),
    );
    final barrier = tester.widget<AnimatedModalBarrier>(
      find.byType(AnimatedModalBarrier),
    );

    expect(barrier.dismissible, isTrue);
    // onDismiss は詳細画面が閉じないように必須にしている
    expect(barrier.onDismiss, isNotNull);
  });
}
