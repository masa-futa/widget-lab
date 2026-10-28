import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_magnifier.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoMagnifier の既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoMagnifierEntry.build(
            DemoArgs(cupertinoMagnifierEntry, allOff(cupertinoMagnifierEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoMagnifier>(
      find.byType(CupertinoMagnifier),
    );
    const defaults = CupertinoMagnifier();
    expect(built.magnificationScale, defaults.magnificationScale);
    expect(built.borderSide, defaults.borderSide);
    expect(built.size, defaults.size);
  });
}
