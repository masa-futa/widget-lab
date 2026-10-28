import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/gesture_detector.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../demo_pump.dart';

void main() {
  DemoArgs argsWith({int? behavior}) => DemoArgs(gestureDetectorEntry, {
    ...gestureDetectorEntry.initialSettings(),
    if (behavior != null)
      'behavior': PropertySetting(on: true, value: ChoiceValue(behavior)),
  });

  /// 文字の右の、何も描いていない所。
  Offset emptyArea(WidgetTester tester) {
    final rect = tester.getRect(
      find
          .ancestor(of: find.text('文字のところ'), matching: find.byType(SizedBox))
          .first,
    );
    return rect.centerRight - const Offset(8, 0);
  }

  testWidgets('GestureDetector: 文字を押すと onTap、何も描いていない所は既定では受け取らない', (
    tester,
  ) async {
    final recorder = await pumpDemo(
      tester,
      gestureDetectorEntry.build(argsWith()),
    );
    await tester.tap(find.text('文字のところ'));
    await tester.tapAt(emptyArea(tester));

    expect(recorder.logs, ['onTap']);
  });

  testWidgets('GestureDetector: behavior を opaque にすると、何も描いていない所でも受け取る', (
    tester,
  ) async {
    final recorder = await pumpDemo(
      tester,
      gestureDetectorEntry.build(argsWith(behavior: 1)),
    );
    await tester.tapAt(emptyArea(tester));

    expect(recorder.logs, ['onTap']);
  });

  testWidgets('GestureDetector: 使わない側は押しても何も起きない', (tester) async {
    final recorder = await pumpDemo(
      tester,
      gestureDetectorEntry.buildWithout!(argsWith()),
    );
    await tester.tap(find.text('文字のところ'));

    expect(recorder.logs, isEmpty);
  });
}
