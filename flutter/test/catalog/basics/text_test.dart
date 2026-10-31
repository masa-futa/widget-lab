import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら必須の文字だけを渡し、ほかは Text の既定値で組み立てる', () {
    final built =
        textEntry.build(DemoArgs(textEntry, allOff(textEntry))) as Text;
    const defaults = Text('こんにちは');

    expect(built.data, 'こんにちは');
    expect(built.style, defaults.style);
    expect(built.textAlign, defaults.textAlign);
    expect(built.maxLines, defaults.maxLines);
    expect(built.softWrap, defaults.softWrap);
    expect(built.overflow, defaults.overflow);
  });
}
