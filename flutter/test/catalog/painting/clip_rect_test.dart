import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/clip_rect.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ClipRect の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, clipRectEntry);
    final built = demoWidget<ClipRect>(tester);

    expect(built.clipper, isNull);
    expect(built.clipBehavior, Clip.hardEdge);
    expect(built.child, isNull);
  });
}
