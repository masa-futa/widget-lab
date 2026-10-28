import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_scrollbar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoScrollbarEntry.build(
            DemoArgs(cupertinoScrollbarEntry, allOff(cupertinoScrollbarEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoScrollbar>(
      find.byType(CupertinoScrollbar),
    );
    expect(built.thumbVisibility, isFalse);
    expect(built.thickness, CupertinoScrollbar.defaultThickness);
    expect(built.radius, CupertinoScrollbar.defaultRadius);
  });
}
