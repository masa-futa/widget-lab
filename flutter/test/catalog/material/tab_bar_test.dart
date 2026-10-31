import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/tab_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら TabBar の既定値で組み立てる（タブは必須）', () {
    final built = tabBarEntry.build(DemoArgs(tabBarEntry, allOff(tabBarEntry)));
    final tabBar = (built as DefaultTabController).child as TabBar;

    expect(tabBar.tabs, hasLength(3));
    expect(tabBar.isScrollable, isFalse);
    expect(tabBar.indicatorSize, isNull);
    expect(tabBar.indicatorColor, isNull);
    expect(tabBar.labelColor, isNull);
  });
}
