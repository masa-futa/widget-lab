import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/navigation_rail.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら NavigationRail の既定値（未選択・名前なし・広げない）で組み立てる', () {
    final built = navigationRailEntry.build(
      DemoArgs(navigationRailEntry, allOff(navigationRailEntry)),
    );
    final align = (built as DemoStage).child as Align;
    final rail = align.child! as NavigationRail;

    expect(rail.destinations, hasLength(3));
    expect(rail.selectedIndex, isNull);
    expect(rail.labelType, isNull);
    expect(rail.extended, isFalse);
    expect(rail.backgroundColor, isNull);
  });

  test('TC-41: extended の間は、プレビューに渡さない labelType をコードにも書かない', () {
    final settings = {
      ...navigationRailEntry.initialSettings(),
      'extended': const PropertySetting(on: true, value: SwitchValue(true)),
    };
    final code = const CodeGenerator().generate(navigationRailEntry, settings);

    expect(code, isNot(contains('labelType')));
    expect(code, contains('extended: true'));
  });
}
