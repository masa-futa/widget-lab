import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_child_list_delegate.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverChildListDelegate の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, sliverChildListDelegateEntry);
    final built = demoWidget<SliverList>(tester);

    // children は必須なので最初の値
    final delegate = built.delegate as SliverChildListDelegate;
    expect(delegate.children, hasLength(5));
  });
}
