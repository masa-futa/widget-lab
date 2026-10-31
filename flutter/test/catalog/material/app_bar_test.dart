import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/app_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら AppBar の既定値で組み立てる', () {
    final appBar =
        appBarEntry.build(DemoArgs(appBarEntry, allOff(appBarEntry))) as AppBar;

    expect(appBar.leading, isNull);
    expect(appBar.title, isNull);
    expect(appBar.actions, isNull);
    expect(appBar.centerTitle, isNull);
    expect(appBar.backgroundColor, isNull);
    expect(appBar.elevation, isNull);
  });
}
