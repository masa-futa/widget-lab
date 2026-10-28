import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/implicitly_animated_widget.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら curve は既定の linear で組み立てる', () {
    final widget = implicitlyAnimatedWidgetEntry.build(
      DemoArgs(
        implicitlyAnimatedWidgetEntry,
        allOff(implicitlyAnimatedWidgetEntry),
      ),
    ) as ImplicitlyAnimatedWidget;

    expect(widget.curve, Curves.linear);
    expect(widget.duration, const Duration(milliseconds: 600));
  });

  testWidgets('radius を変えると、duration をかけて新しい角丸へ動く', (tester) async {
    Widget build(double radius) => implicitlyAnimatedWidgetEntry.build(
      DemoArgs(implicitlyAnimatedWidgetEntry, {
        ...implicitlyAnimatedWidgetEntry.initialSettings(),
        'radius': PropertySetting(on: true, value: SliderValue(radius)),
      }),
    );
    double radiusNow() =>
        (tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius
                as BorderRadius)
            .topLeft
            .x;

    await tester.pumpWidget(Center(child: build(0)));
    expect(radiusNow(), 0);

    await tester.pumpWidget(Center(child: build(60)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(radiusNow(), inExclusiveRange(0, 60));

    await tester.pumpAndSettle();
    expect(radiusNow(), 60);
  });
}
