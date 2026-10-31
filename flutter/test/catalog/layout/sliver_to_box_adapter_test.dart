import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_to_box_adapter.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverToBoxAdapter の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sliverToBoxAdapterEntry);
    final built = demoWidget<SliverToBoxAdapter>(tester);

    expect(built.child, isNull);
  });
}
