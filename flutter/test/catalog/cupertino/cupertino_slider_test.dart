import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_slider.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の value と onChanged だけを渡し、ほかは既定値で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoSliderEntry.build(
            DemoArgs(cupertinoSliderEntry, allOff(cupertinoSliderEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoSlider>(find.byType(CupertinoSlider));
    final defaults = CupertinoSlider(value: 0, onChanged: (_) {});
    expect(built.value, 0.5);
    expect(built.divisions, defaults.divisions);
    expect(built.activeColor, defaults.activeColor);
    expect(built.thumbColor, defaults.thumbColor);
    expect(built.onChanged, isNotNull);
  });
}
