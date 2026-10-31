import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliding_segmented_control.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

CupertinoSlidingSegmentedControl<int> _control(WidgetTester tester) =>
    tester.widget(find.byType(CupertinoSlidingSegmentedControl<int>));

Widget _app(Widget child) => CupertinoApp(home: Center(child: child));

void main() {
  testWidgets('TC-18: 全部 OFF なら選ばない状態で、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      _app(
        cupertinoSlidingSegmentedControlEntry.build(
          DemoArgs(
            cupertinoSlidingSegmentedControlEntry,
            allOff(cupertinoSlidingSegmentedControlEntry),
          ),
        ),
      ),
    );

    final built = _control(tester);
    final defaults = CupertinoSlidingSegmentedControl<int>(
      children: const {0: Text('a'), 1: Text('b')},
      onValueChanged: (_) {},
    );
    expect(built.groupValue, isNull);
    expect(built.thumbColor, defaults.thumbColor);
    expect(built.backgroundColor, defaults.backgroundColor);
    expect(built.padding, defaults.padding);
    expect(built.proportionalWidth, defaults.proportionalWidth);
  });

  testWidgets('押すと選んだ値が変わる', (tester) async {
    await tester.pumpWidget(
      _app(
        cupertinoSlidingSegmentedControlEntry.build(
          DemoArgs(
            cupertinoSlidingSegmentedControlEntry,
            cupertinoSlidingSegmentedControlEntry.initialSettings(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('月'));
    await tester.pumpAndSettle();

    expect(_control(tester).groupValue, 2);
  });
}
