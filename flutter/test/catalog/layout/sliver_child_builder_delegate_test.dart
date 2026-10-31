import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_child_builder_delegate.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverChildBuilderDelegate の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, sliverChildBuilderDelegateEntry);
    final built = demoWidget<SliverList>(tester);

    final delegate = built.delegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, isNull);
  });
}
