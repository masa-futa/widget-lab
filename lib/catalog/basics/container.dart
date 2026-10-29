import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

const _alignmentNames = [
  ('topLeft', Alignment.topLeft),
  ('topCenter', Alignment.topCenter),
  ('topRight', Alignment.topRight),
  ('centerLeft', Alignment.centerLeft),
  ('center', Alignment.center),
  ('centerRight', Alignment.centerRight),
  ('bottomLeft', Alignment.bottomLeft),
  ('bottomCenter', Alignment.bottomCenter),
  ('bottomRight', Alignment.bottomRight),
];

List<Choice> _alignmentChoices() => [
  for (final (name, value) in _alignmentNames)
    Choice(name, value, 'Alignment.$name'),
];

List<Choice> _borderChoices() => [
  Choice('細い線', Border.all(width: 2), 'Border.all(width: 2)'),
  Choice(
    '太い赤線',
    Border.all(width: 4, color: const Color(0xFFD7003A)),
    'Border.all(width: 4, color: Color(0xFFD7003A))',
  ),
];

final containerEntry = WidgetEntry(
  id: 'container',
  name: 'Container',
  genreIds: const ['basics', 'layout'],
  summary: '色・余白・大きさ・配置をまとめて指定する箱',
  description:
      '余白・色・大きさ・子の配置を1つの Widget でまとめて指定できます。'
      '中では Padding・ColoredBox・Align・ConstrainedBox などを組み合わせています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Container-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry?',
      description: '箱の中での子の位置。指定すると箱は使える広さいっぱいに広がる',
      initiallyOn: false,
      control: ChoiceControl(initialIndex: 4, choices: _alignmentChoices()),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '箱の内側、子のまわりの余白。色はこの余白にも塗られる',
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      excludes: const ['decoration'],
      omitIf: (settings) => settings['decoration']?.on ?? false,
      typeLabel: 'Color?',
      description: '箱の地の色',
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'decoration',
      typeLabel: 'Decoration?',
      description: '箱の地に描く飾り。中の値を組み合わせて BoxDecoration を作る',
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
          const PropertySpec(
            name: 'gradient',
            typeLabel: 'Gradient?',
            description: '色が少しずつ変わる塗り。color より上に描かれる',
            initiallyOn: false,
            control: ChoiceControl(
              choices: [
                Choice(
                  '瑠璃から若竹',
                  LinearGradient(
                    colors: [Color(0xFF1E50A2), Color(0xFF68BE8D)],
                  ),
                  'LinearGradient(colors: [Color(0xFF1E50A2), Color(0xFF68BE8D)])',
                ),
              ],
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
      control: NestedControl(
        typeName: 'BoxDecoration',
        children: [
          PropertySpec(
            name: 'color',
            typeLabel: 'Color?',
            description: '重ねる色',
            control: ColorControl(
              palette: [Choice.color('墨（半透明）', const Color(0x6618181B))],
            ),
          ),
          PropertySpec(
            name: 'border',
            typeLabel: 'BoxBorder?',
            description: '箱のふちの線',
            initiallyOn: false,
            control: ChoiceControl(choices: _borderChoices()),
          ),
        ],
        build: _buildDecoration,
      ),
    ),
    const PropertySpec(
      name: 'isAntiAlias',
      typeLabel: 'bool',
      description: '切り抜きの縁をなめらかにするか',
      initiallyOn: false,
      group: PropertyGroup.paint,
      requires: 'clipBehavior',
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'width',
      group: PropertyGroup.size,
      pairsWith: const ['height'],
      typeLabel: 'double?',
      description: '箱の幅。指定しないと子の大きさに合わせる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 300,
        divisions: 30,
        initialValue: 200,
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
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 300,
        divisions: 30,
        initialValue: 120,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'margin',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '箱の外側の余白。色は塗られない',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'constraints',
      typeLabel: 'BoxConstraints?',
      description: '箱の大きさの上限と下限',
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
          Choice(
            'tightFor 120×120',
            BoxConstraints.tightFor(width: 120, height: 120),
            'BoxConstraints.tightFor(width: 120, height: 120)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'transform',
      typeLabel: 'Matrix4?',
      description: '箱を描くときの変形（回転・拡大・移動）',
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
    PropertySpec(
      name: 'transformAlignment',
      typeLabel: 'AlignmentGeometry?',
      description: 'transform で変形するときの中心の位置',
      initiallyOn: false,
      group: PropertyGroup.transform,
      requires: 'transform',
      control: ChoiceControl(initialIndex: 4, choices: _alignmentChoices()),
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
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'Container',
);

ColorControl _colorControl() => ColorControl(
  palette: [
    Choice.color('瑠璃', const Color(0xFF1E50A2)),
    Choice.color('山吹', const Color(0xFFF8B500)),
    Choice.color('若竹', const Color(0xFF68BE8D)),
    Choice.color('紅', const Color(0xFFD7003A)),
    Choice.color('墨', const Color(0xFF18181B)),
  ],
);

BoxDecoration _buildDecoration(Map<String, Object> values) {
  final shape = values['shape'] as BoxShape? ?? BoxShape.rectangle;
  return BoxDecoration(
    color: values['color'] as Color?,
    borderRadius: shape == BoxShape.circle
        ? null
        : values['borderRadius'] as BorderRadiusGeometry?,
    border: values['border'] as BoxBorder?,
    boxShadow: values['boxShadow'] as List<BoxShadow>?,
    gradient: values['gradient'] as Gradient?,
    shape: shape,
  );
}

Widget _build(DemoArgs args) {
  final decoration = args.valueOf<Decoration>('decoration');
  return Container(
    alignment: args.valueOf<AlignmentGeometry>('alignment'),
    padding: args.valueOf<EdgeInsetsGeometry>('padding'),
    color: decoration == null ? args.valueOf<Color>('color') : null,
    isAntiAlias: args.valueOf<bool>('isAntiAlias') ?? true,
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
