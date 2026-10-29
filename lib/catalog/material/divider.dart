import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final dividerEntry = WidgetEntry(
  id: 'divider',
  name: 'Divider',
  genreIds: const ['material'],
  summary: '内容と内容の間に引く、細い横線',
  description:
      '一覧の行の間などに引く細い横線です。height は線を含む枠の高さで、'
      '線は枠の上下の真ん中に引かれます。縦の線は VerticalDivider で引きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Divider-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'height',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '線を含む枠の高さ。線の上下の余白が変わる。指定しないと 16',
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 32,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'thickness',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '線の太さ。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 8,
        divisions: 7,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'indent',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '線の左の空き',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 8,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'endIndent',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '線の右の空き',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 8,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '線の色。指定しないとテーマの outlineVariant',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'radius',
      group: PropertyGroup.paint,
      typeLabel: 'BorderRadiusGeometry?',
      description: '線の角の丸み。thickness を太くすると見える。指定しないと角は丸まらない',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 4,
        divisions: 4,
        initialValue: 2,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
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
  codeName: 'Divider',
);

/// 線は幅いっぱいに広がるので、プレビューでは見やすい大きさに決め（低いカードでは縮める）、
/// 上下に文を置いて線との間が見えるようにする（コードには出さない）。
Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 112),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('上の文'),
      Divider(
        height: args.valueOf<double>('height'),
        thickness: args.valueOf<double>('thickness'),
        indent: args.valueOf<double>('indent'),
        endIndent: args.valueOf<double>('endIndent'),
        color: args.valueOf<Color>('color'),
        radius: args.valueOf<BorderRadiusGeometry>('radius'),
      ),
      const Text('下の文'),
    ],
  ),
);
