import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/sliver_app_bar.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら SliverAppBar の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, sliverAppBarEntry);
    final built = demoWidget<SliverAppBar>(tester);

    expect(built.title, isNull);
    expect(built.pinned, isFalse);
    expect(built.floating, isFalse);
    expect(built.expandedHeight, isNull);
    expect(built.backgroundColor, isNull);
    expect(built.leading, isNull);
    expect(built.automaticallyImplyLeading, isTrue);
    expect(built.actions, isNull);
    expect(built.flexibleSpace, isNull);
    expect(built.bottom, isNull);
    expect(built.forceElevated, isFalse);
    expect(built.snap, isFalse);
    expect(built.stretch, isFalse);
    expect(built.toolbarHeight, kToolbarHeight);
    expect(built.collapsedHeight, isNull);
    expect(built.forceMaterialTransparency, isFalse);
    expect(built.clipBehavior, isNull);
  });
}
