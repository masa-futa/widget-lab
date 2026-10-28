import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_persistent_header.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverPersistentHeader の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, sliverPersistentHeaderEntry);
    final built = demoWidget<SliverPersistentHeader>(tester);

    expect(built.pinned, isFalse);
    expect(built.floating, isFalse);
  });
}
