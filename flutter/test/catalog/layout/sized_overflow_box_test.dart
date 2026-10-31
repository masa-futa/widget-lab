import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sized_overflow_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SizedOverflowBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sizedOverflowBoxEntry);
    final built = demoWidget<SizedOverflowBox>(tester);

    // size は必須なので最初の値
    expect(built.size, const Size(32, 32));
    expect(built.alignment, Alignment.center);
    expect(built.child, isNull);
  });
}
