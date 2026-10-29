import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedPositionedEntry = WidgetEntry(
  id: 'animatedPositioned',
  name: 'AnimatedPositioned',
  genreIds: const ['animation'],
  summary: 'Stack の中の子の位置が変わると、新しい位置へ動かす',
  description:
      'Positioned と同じく、Stack の中で子の位置（左・上からの距離など）を決めます。'
      '位置が変わると、duration の時間をかけて新しい位置へ動かします。Stack の直下に置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'left',
      group: PropertyGroup.layout,
      typeLabel: 'double?',
      description: 'Stack の左端からの距離',
      control: SliderControl(
        min: 0,
        max: 160,
        divisions: 8,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'top',
      group: PropertyGroup.layout,
      typeLabel: 'double?',
      description: 'Stack の上端からの距離',
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'right',
      typeLabel: 'double?',
      description: 'Stack の右端からの距離。left と width の 3 つのうち 2 つまでしか効かない',
      initiallyOn: false,
      group: PropertyGroup.layout,
      control: SliderControl(
        min: 0,
        max: 160,
        divisions: 8,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'bottom',
      typeLabel: 'double?',
      description: 'Stack の下端からの距離。top と height の 3 つのうち 2 つまでしか効かない',
      initiallyOn: false,
      group: PropertyGroup.layout,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 20,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'width',
      typeLabel: 'double?',
      description: '子の幅。left と right が両方 ON の間は渡さない（3 つ全部は渡せない）',
      initiallyOn: false,
      group: PropertyGroup.size,
      omitIf: (settings) => _both(settings, 'left', 'right'),
      control: const SliderControl(
        min: 0,
        max: 160,
        divisions: 8,
        initialValue: 80,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'height',
      typeLabel: 'double?',
      description: '子の高さ。top と bottom が両方 ON の間は渡さない（3 つ全部は渡せない）',
      initiallyOn: false,
      group: PropertyGroup.size,
      omitIf: (settings) => _both(settings, 'top', 'bottom'),
      control: const SliderControl(
        min: 0,
        max: 120,
        divisions: 6,
        initialValue: 60,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '動かす Widget',
      required: true,
      control: FixedControl(
        value: FlutterLogo(size: 64),
        source: 'FlutterLogo(size: 64)',
      ),
    ),
  ],
  references: const [keyReference, onEndReference],
  build: _build,
  codeName: 'AnimatedPositioned',
);

/// [a] と [b] が両方 ON か（このとき width・height は渡せない）。
bool _both(Map<String, PropertySetting> settings, String a, String b) =>
    (settings[a]?.on ?? false) && (settings[b]?.on ?? false);

/// AnimatedPositioned は Stack の直下にしか置けないので、デモの Stack で包む（コードには出さない）。
Widget _build(DemoArgs args) {
  final left = args.valueOf<double>('left');
  final top = args.valueOf<double>('top');
  final right = args.valueOf<double>('right');
  final bottom = args.valueOf<double>('bottom');
  return SizedBox(
    width: 240,
    height: 160,
    child: Stack(
      children: [
        AnimatedPositioned(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          // omitIf と同じ条件で渡さない（3 つ全部は assert で落ちる）
          width: left != null && right != null
              ? null
              : args.valueOf<double>('width'),
          height: top != null && bottom != null
              ? null
              : args.valueOf<double>('height'),
          duration: durationOf(args),
          curve: curveOf(args),
          child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
        ),
      ],
    ),
  );
}
