import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/clip_path.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら ClipPath の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, clipPathEntry);
    final built = demoWidget<ClipPath>(tester);

    expect(built.clipper, isNull);
    expect(built.clipBehavior, Clip.antiAlias);
    expect(built.child, isNull);
  });
}
