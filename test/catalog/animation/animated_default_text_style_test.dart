import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_default_text_style.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test(
    'TC-18: 全部 OFF なら AnimatedDefaultTextStyle の既定値（curve は linear）で組み立てる',
    () {
      final style = animatedDefaultTextStyleEntry.build(
        DemoArgs(
          animatedDefaultTextStyleEntry,
          allOff(animatedDefaultTextStyleEntry),
        ),
      ) as AnimatedDefaultTextStyle;

      // style・duration・child は必須なので OFF にしても渡る
      expect(style.style.fontSize, 16);
      expect(style.duration, const Duration(milliseconds: 600));
      expect(style.curve, Curves.linear);
      expect(style.child, isA<Text>());
    },
  );
}
