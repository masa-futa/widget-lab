import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Container() の既定値で組み立てる', () {
    final built = containerEntry.build(
      DemoArgs(containerEntry, allOff(containerEntry)),
    ) as Container;
    final defaults = Container();

    expect(built.alignment, defaults.alignment);
    expect(built.padding, defaults.padding);
    expect(built.color, defaults.color);
    expect(built.constraints, defaults.constraints);
    expect(built.margin, defaults.margin);
    expect(built.child, defaults.child);
  });
}
