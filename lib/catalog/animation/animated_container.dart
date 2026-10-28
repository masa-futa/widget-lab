import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
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
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '箱の中に置く Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  build: _build,
  codeName: 'AnimatedContainer',
);

Widget _build(DemoArgs args) => AnimatedContainer(
  duration: durationOf(args),
  curve: curveOf(args),
  color: args.valueOf<Color>('color'),
  width: args.valueOf<double>('width'),
  height: args.valueOf<double>('height'),
  child: args.valueOf<Widget>('child'),
);
