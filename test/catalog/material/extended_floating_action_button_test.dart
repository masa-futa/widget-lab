import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/extended_floating_action_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test(
    'TC-18: 全部 OFF なら FloatingActionButton.extended の既定値（押せない・横に長い）で組み立てる',
    () {
      final fab = extendedFloatingActionButtonEntry.build(
        DemoArgs(
          extendedFloatingActionButtonEntry,
          allOff(extendedFloatingActionButtonEntry),
        ),
      ) as FloatingActionButton;

      expect(fab.onPressed, isNull);
      expect(fab.isExtended, isTrue);
      expect(fab.backgroundColor, isNull);
      expect(fab.heroTag, isNull);
    },
  );
}
