import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/icon_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら IconButton の既定値（押せない・トグルでない）で組み立てる', () {
    final button = iconButtonEntry.build(
      DemoArgs(iconButtonEntry, allOff(iconButtonEntry)),
    ) as IconButton;

    expect(button.onPressed, isNull);
    expect(button.iconSize, isNull);
    expect(button.color, isNull);
    expect(button.isSelected, isNull);
    expect(button.selectedIcon, isNull);
    // icon は必須なので OFF にしても渡る
    expect(button.icon, isA<Icon>());
  });
}
