import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_list.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverList の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sliverListEntry);
    final built = demoWidget<SliverList>(tester);

    // delegate は必須なので最初の値
    expect(built.delegate, isA<SliverChildBuilderDelegate>());
  });
}
