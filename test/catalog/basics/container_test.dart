import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

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
    expect((built.decoration! as BoxDecoration).color, const Color(0xFF1E50A2));
  });

  test('TC-88: 仲間と関係', () {
    PropertySpec spec(String name) =>
        containerEntry.properties.singleWhere((s) => s.name == name);
    expect(spec('width').group, PropertyGroup.size);
    expect(spec('color').excludes, ['decoration']);
    expect(spec('transformAlignment').requires, 'transform');
    expect(containerEntry.references.map((r) => r.name), ['key']);
  });

  group('TC-88: プレビューとコードがそろう', () {
    PropertySetting decorationOn({bool circle = false, bool radius = false}) {
      final decoration = containerEntry.properties.singleWhere(
        (s) => s.name == 'decoration',
      );
      final control = decoration.control as NestedControl;
      var value = control.initial;
      value = value.copyWithChild(
        'shape',
        value.settings['shape']!.copyWith(
          on: circle,
          value: const ChoiceValue(1),
        ),
      );
      value = value.copyWithChild(
        'borderRadius',
        value.settings['borderRadius']!.copyWith(on: radius),
      );
      return PropertySetting(on: true, value: value);
    }

    test('円と borderRadius が両方 ON でも、渡さず書かない', () {
      final settings = {
        ...allOff(containerEntry),
        'decoration': decorationOn(circle: true, radius: true),
      };
      final built =
          containerEntry.build(DemoArgs(containerEntry, settings)) as Container;
      final decoration = built.decoration! as BoxDecoration;
      final code = const CodeGenerator().generate(containerEntry, settings);

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.borderRadius, isNull);
      expect(code, contains('shape: BoxShape.circle'));
      expect(code, isNot(contains('borderRadius')));
    });

    test('decoration が ON なら、ON の color は渡さず書かない', () {
      final settings = {
        ...allOff(containerEntry),
        'color': containerEntry.initialSettings()['color']!.copyWith(on: true),
        'decoration': decorationOn(),
      };
      final built =
          containerEntry.build(DemoArgs(containerEntry, settings)) as Container;
      final code = const CodeGenerator().generate(containerEntry, settings);

      expect(built.decoration, isA<BoxDecoration>());
      expect(built.color, isNull);
      expect(code, isNot(contains('\n  color:')));
      expect(code, contains('\n    color:'));
    });

    test('decoration が OFF なら、ON の clipBehavior は渡さず書かない', () {
      final settings = {
        ...allOff(containerEntry),
        'clipBehavior': containerEntry
            .initialSettings()['clipBehavior']!
            .copyWith(on: true),
      };
      late final Widget built;
      expect(
        () => built = containerEntry.build(DemoArgs(containerEntry, settings)),
        returnsNormally,
      );
      expect((built as Container).clipBehavior, Clip.none);
      expect(
        const CodeGenerator().generate(containerEntry, settings),
        isNot(contains('clipBehavior')),
      );
    });
  });
}
