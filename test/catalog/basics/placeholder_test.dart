import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/placeholder.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Placeholder() の既定値で組み立てる', () {
    final built = placeholderEntry.build(
      DemoArgs(placeholderEntry, allOff(placeholderEntry)),
    ) as Placeholder;
    const defaults = Placeholder();

    expect(built.color, defaults.color);
    expect(built.strokeWidth, defaults.strokeWidth);
    expect(built.child, defaults.child);
  });
}
