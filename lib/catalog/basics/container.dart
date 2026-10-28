import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

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
      typeLabel: 'AlignmentGeometry?',
      description: '箱の中での子の位置。指定すると箱は使える広さいっぱいに広がる',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 4,
        choices: [
          for (final (name, value) in const [
            ('topLeft', Alignment.topLeft),
            ('topCenter', Alignment.topCenter),
            ('topRight', Alignment.topRight),
            ('centerLeft', Alignment.centerLeft),
            ('center', Alignment.center),
            ('centerRight', Alignment.centerRight),
            ('bottomLeft', Alignment.bottomLeft),
            ('bottomCenter', Alignment.bottomCenter),
            ('bottomRight', Alignment.bottomRight),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
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
      name: 'width',
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
      name: 'child',
      typeLabel: 'Widget?',
      description: '箱の中に置く Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  build: _build,
  codeName: 'Container',
);

Widget _build(DemoArgs args) => Container(
  alignment: args.valueOf<AlignmentGeometry>('alignment'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  color: args.valueOf<Color>('color'),
  width: args.valueOf<double>('width'),
  height: args.valueOf<double>('height'),
  margin: args.valueOf<EdgeInsetsGeometry>('margin'),
  child: args.valueOf<Widget>('child'),
);
