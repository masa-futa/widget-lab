import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/scrollbar.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Scrollbar の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, scrollbarEntry);
    final built = demoWidget<Scrollbar>(tester);

    expect(built.thumbVisibility, isNull);
    expect(built.trackVisibility, isNull);
    expect(built.thickness, isNull);
    expect(built.interactive, isNull);
  });
}
