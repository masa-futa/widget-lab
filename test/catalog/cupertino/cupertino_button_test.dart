import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら必須の child だけを渡し、ほかは CupertinoButton の既定値で組み立てる', () {
    final built = cupertinoButtonEntry.build(
      DemoArgs(cupertinoButtonEntry, allOff(cupertinoButtonEntry)),
    ) as CupertinoButton;
    const defaults = CupertinoButton(onPressed: null, child: Text('保存'));

    expect(built.child, isA<Text>());
    expect(built.sizeStyle, defaults.sizeStyle);
    expect(built.color, defaults.color);
    expect(built.pressedOpacity, defaults.pressedOpacity);
    expect(built.borderRadius, defaults.borderRadius);
    expect(built.onPressed, isNull);
  });
}
