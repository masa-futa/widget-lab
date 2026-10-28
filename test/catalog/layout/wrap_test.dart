import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/wrap.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Wrap の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, wrapEntry);
    final built = demoWidget<Wrap>(tester);

    expect(built.spacing, 0);
    expect(built.runSpacing, 0);
    expect(built.alignment, WrapAlignment.start);
    expect(built.direction, Axis.horizontal);
    expect(built.children, isEmpty);
  });
}
