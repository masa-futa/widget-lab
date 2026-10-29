import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedContainerEntry = WidgetEntry(
  id: 'animatedContainer',
  name: 'AnimatedContainer',
  genreIds: const ['animation'],
  summary: '色・大きさ・余白などが変わると、新しい値へ動かす Container',
  description:
      'Container と同じ値を持ち、どれかが変わると duration の時間をかけて新しい値へ動かします。'
      '色・大きさ・余白・角丸などをまとめて動かせます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html',
  ),
  properties: [
    durationSpec,
    curveSpec,
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      excludes: const ['decoration'],
      omitIf: (settings) => settings['decoration']?.on ?? false,
      typeLabel: 'Color?',
      description: '箱の地の色。変えると色が移り変わる',
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'width',
      group: PropertyGroup.size,
      pairsWith: const ['height'],
      typeLabel: 'double?',
      description: '箱の幅。指定しないと子の大きさに合わせる',
      control: SliderControl(
        min: 40,
        max: 240,
        divisions: 10,
        initialValue: 120,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'height',
      group: PropertyGroup.size,
      pairsWith: const ['width'],
      typeLabel: 'double?',
      description: '箱の高さ。指定しないと子の大きさに合わせる',
      control: SliderControl(
        min: 40,
        max: 200,
        divisions: 8,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'decoration',
      typeLabel: 'Decoration?',
      description: '箱の地に描く飾り。中の値を変えると、新しい飾りへ移り変わる',
      initiallyOn: false,
      group: PropertyGroup.paint,
      excludes: const ['color'],
      control: NestedControl(
        typeName: 'BoxDecoration',
        children: [
          PropertySpec(
            name: 'color',
            typeLabel: 'Color?',
            description: '飾りの地の色',
            control: _colorControl(),
          ),
          PropertySpec(
            name: 'borderRadius',
            typeLabel: 'BorderRadiusGeometry?',
            description: '角の丸み。shape が circle のときは使えない',
            initiallyOn: false,
            omitIf: (settings) => _isCircle(settings['shape']),
            control: SliderControl(
              min: 0,
              max: 32,
              divisions: 8,
              initialValue: 12,
              resolve: BorderRadius.circular,
              code: (v) => 'BorderRadius.circular($v)',
            ),
          ),
          PropertySpec(
            name: 'border',
            typeLabel: 'BoxBorder?',
            description: '箱のふちの線',
            initiallyOn: false,
            control: ChoiceControl(choices: _borderChoices()),
          ),
          const PropertySpec(
            name: 'boxShadow',
            typeLabel: 'List<BoxShadow>?',
            description: '箱の下に落とす影',
            initiallyOn: false,
            control: FixedControl(
              value: [
                BoxShadow(
                  blurRadius: 12,
                  color: Color(0x40000000),
                  offset: Offset(0, 4),
                ),
              ],
              source: '[BoxShadow(blurRadius: 12, color: Color(0x40000000), offset: Offset(0, 4))]',
            ),
          ),
          PropertySpec(
            name: 'shape',
            typeLabel: 'BoxShape',
            description: '箱の形。circle にすると丸く描かれる',
            initiallyOn: false,
            control: ChoiceControl(
              choices: [
                for (final shape in BoxShape.values)
                  Choice(shape.name, shape, 'BoxShape.${shape.name}'),
              ],
            ),
          ),
        ],
        build: _buildDecoration,
      ),
    ),
    PropertySpec(
      name: 'foregroundDecoration',
      typeLabel: 'Decoration?',
      description: '子の上に重ねて描く飾り',
      initiallyOn: false,
      group: PropertyGroup.paint,
      control: ChoiceControl(
        choices: [
          const Choice(
            '墨（半透明）',
            BoxDecoration(color: Color(0x6618181B)),
            'BoxDecoration(color: Color(0x6618181B))',
          ),
          for (final choice in _borderChoices())
            Choice(
              choice.label,
              BoxDecoration(border: choice.value as BoxBorder),
              'BoxDecoration(border: ${choice.code})',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'constraints',
      typeLabel: 'BoxConstraints?',
      description: '箱の大きさの上限と下限。width・height と一緒に指定すると、その中で決まる',
      initiallyOn: false,
      group: PropertyGroup.size,
      control: ChoiceControl(
        choices: [
          Choice(
            'minWidth 160',
            BoxConstraints(minWidth: 160),
            'BoxConstraints(minWidth: 160)',
          ),
          Choice(
            'maxWidth 80',
            BoxConstraints(maxWidth: 80),
            'BoxConstraints(maxWidth: 80)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '箱の内側、子のまわりの余白。変えると新しい余白へ動く',
      initiallyOn: false,
      group: PropertyGroup.spacing,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'margin',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '箱の外側の余白。色は塗られない',
      initiallyOn: false,
      group: PropertyGroup.spacing,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry?',
      description: '箱の中での子の位置。変えると新しい位置へ動く',
      initiallyOn: false,
      group: PropertyGroup.layout,
      control: ChoiceControl(
        initialIndex: alignmentCenter,
        choices: alignmentChoices,
      ),
    ),
    PropertySpec(
      name: 'transform',
      typeLabel: 'Matrix4?',
      description: '箱を描くときの変形（回転・拡大・移動）。変えると新しい形へ動く',
      initiallyOn: false,
      group: PropertyGroup.transform,
      pairsWith: const ['transformAlignment'],
      control: ChoiceControl(
        choices: [
          Choice('回転', Matrix4.rotationZ(0.2), 'Matrix4.rotationZ(0.2)'),
          Choice(
            '拡大',
            Matrix4.diagonal3Values(1.2, 1.2, 1),
            'Matrix4.diagonal3Values(1.2, 1.2, 1)',
          ),
          Choice(
            '移動',
            Matrix4.translationValues(16, 0, 0),
            'Matrix4.translationValues(16, 0, 0)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'transformAlignment',
      typeLabel: 'AlignmentGeometry?',
      description: 'transform で変形するときの中心の位置',
      initiallyOn: false,
      group: PropertyGroup.transform,
      requires: 'transform',
      control: ChoiceControl(
        initialIndex: alignmentCenter,
        choices: alignmentChoices,
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: 'decoration の形で中身を切り抜くか',
      initiallyOn: false,
      group: PropertyGroup.transform,
      requires: 'decoration',
      omitIf: (settings) => !(settings['decoration']?.on ?? false),
      control: ChoiceControl(
        choices: [
          for (final clip in const [
            Clip.hardEdge,
            Clip.antiAlias,
            Clip.antiAliasWithSaveLayer,
          ])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '箱の中に置く Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  references: const [keyReference, onEndReference],
  build: _build,
  codeName: 'AnimatedContainer',
);

ColorControl _colorControl() => ColorControl(
  palette: [
    Choice.color('瑠璃', const Color(0xFF1E50A2)),
    Choice.color('山吹', const Color(0xFFF8B500)),
    Choice.color('若竹', const Color(0xFF68BE8D)),
    Choice.color('紅', const Color(0xFFD7003A)),
  ],
);

List<Choice> _borderChoices() => [
  Choice('細い線', Border.all(width: 2), 'Border.all(width: 2)'),
  Choice(
    '太い赤線',
    Border.all(width: 4, color: const Color(0xFFD7003A)),
    'Border.all(width: 4, color: Color(0xFFD7003A))',
  ),
];

/// shape の子が ON で circle か（このとき borderRadius は渡せない）。
bool _isCircle(PropertySetting? shape) {
  if (shape == null || !shape.on) return false;
  final value = shape.value;
  return value is ChoiceValue &&
      BoxShape.values[value.index] == BoxShape.circle;
}

BoxDecoration _buildDecoration(Map<String, Object> values) => BoxDecoration(
  color: values['color'] as Color?,
  borderRadius: values['borderRadius'] as BorderRadiusGeometry?,
  border: values['border'] as BoxBorder?,
  boxShadow: values['boxShadow'] as List<BoxShadow>?,
  shape: values['shape'] as BoxShape? ?? BoxShape.rectangle,
);

Widget _build(DemoArgs args) {
  final decoration = args.valueOf<Decoration>('decoration');
  return AnimatedContainer(
    duration: durationOf(args),
    curve: curveOf(args),
    alignment: args.valueOf<AlignmentGeometry>('alignment'),
    padding: args.valueOf<EdgeInsetsGeometry>('padding'),
    color: decoration == null ? args.valueOf<Color>('color') : null,
    decoration: decoration,
    foregroundDecoration: args.valueOf<Decoration>('foregroundDecoration'),
    width: args.valueOf<double>('width'),
    height: args.valueOf<double>('height'),
    constraints: args.valueOf<BoxConstraints>('constraints'),
    margin: args.valueOf<EdgeInsetsGeometry>('margin'),
    transform: args.valueOf<Matrix4>('transform'),
    transformAlignment: args.valueOf<AlignmentGeometry>('transformAlignment'),
    clipBehavior: decoration == null
        ? Clip.none
        : args.valueOf<Clip>('clipBehavior') ?? Clip.none,
    child: args.valueOf<Widget>('child'),
  );
}
