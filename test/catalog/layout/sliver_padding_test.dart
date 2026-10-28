import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_padding.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverPadding の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sliverPaddingEntry);
    final built = demoWidget<SliverPadding>(tester);

    expect(built.padding, EdgeInsets.zero);
    expect(built.child, isNull);
  });
}
