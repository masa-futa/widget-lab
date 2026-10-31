import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/snack_bar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら SnackBar の既定値（操作なし・閉じるボタンなし）で組み立てる', () {
    final snackBar = snackBarEntry.build(
      DemoArgs(snackBarEntry, allOff(snackBarEntry)),
    ) as SnackBar;

    expect(snackBar.action, isNull);
    expect(snackBar.showCloseIcon, isNull);
    expect(snackBar.behavior, isNull);
    expect(snackBar.backgroundColor, isNull);
    // content は必須なので OFF にしても渡る
    expect(snackBar.content, isA<Text>());
  });
}
