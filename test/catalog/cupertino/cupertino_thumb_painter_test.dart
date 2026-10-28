import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_thumb_painter.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら CupertinoThumbPainter() の既定値で描く', (
    tester,
  ) async {
    await tester.pumpWidget(
      Center(
        child: cupertinoThumbPainterEntry.build(
          DemoArgs(
            cupertinoThumbPainterEntry,
            allOff(cupertinoThumbPainterEntry),
          ),
        ),
      ),
    );

    final painter = tester.widget<CustomPaint>(find.byType(CustomPaint));
    expect(painter.painter, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
