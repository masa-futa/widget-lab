import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';

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

  test('TC-88: 全部 ON にしても assert で落ちない（color と decoration は片方だけ）', () {
    final settings = {
      for (final spec in containerEntry.properties)
        spec.name: spec.initialSetting.copyWith(on: spec.name != 'color'),
    };
    expect(
      () => containerEntry.build(DemoArgs(containerEntry, settings)),
      returnsNormally,
    );
  });

  test('TC-88: decoration の中の値で BoxDecoration を組み立てる', () {
    final decoration = containerEntry.properties.singleWhere(
      (s) => s.name == 'decoration',
    );
    final control = decoration.control as NestedControl;
    final settings = {
      ...containerEntry.initialSettings(),
      'color': containerEntry.initialSettings()['color']!.copyWith(on: false),
      'decoration': PropertySetting(on: true, value: control.initial),
    };
    final built =
        containerEntry.build(DemoArgs(containerEntry, settings)) as Container;
    expect(built.decoration, isA<BoxDecoration>());
  });

  test('TC-88: 仲間と関係', () {
    PropertySpec spec(String name) =>
        containerEntry.properties.singleWhere((s) => s.name == name);
    expect(spec('width').group, PropertyGroup.size);
    expect(spec('color').excludes, ['decoration']);
    expect(spec('transformAlignment').requires, 'transform');
    expect(containerEntry.references.map((r) => r.name), ['key']);
  });
}
