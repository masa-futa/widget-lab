import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/aspect_ratio.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら AspectRatio の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, aspectRatioEntry);
    final built = demoWidget<AspectRatio>(tester);

    // aspectRatio は必須なので最初の値
    expect(built.aspectRatio, 2.0);
    expect(built.child, isNull);
  });
}
