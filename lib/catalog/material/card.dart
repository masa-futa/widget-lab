import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cardEntry = WidgetEntry(
  id: 'card',
  name: 'Card',
  genreIds: const ['material'],
  summary: '関係する内容を 1 つにまとめる、角の丸い面',
  description:
      '1 つの話題の内容と操作をまとめる、角の丸い面です。少し浮き上がって影が付きます。'
      'Card.filled・Card.outlined のコンストラクタで、影のない形も作れます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/material/Card-class.html'),
  properties: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '面の地の色。指定しないとテーマの surfaceContainerLow',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('生成', const Color(0xFFFBFAF5)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      typeLabel: 'double?',
      description: '面の浮き上がりの高さ。影の濃さが変わる。指定しないと 1',
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shape',
      typeLabel: 'ShapeBorder?',
      description: '面の形。ここでは角の丸みを変える。指定しないと 12',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 24,
        resolve: (v) =>
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(v)),
        code: (v) =>
            'RoundedRectangleBorder(borderRadius: BorderRadius.circular($v))',
      ),
    ),
    PropertySpec(
      name: 'margin',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '面の外側の余白。指定しないと 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '面の中に置く Widget',
      control: FixedControl(
        value: Padding(
          padding: EdgeInsets.all(16),
          child: Text('今日の予定は 3 件です'),
        ),
        source:
            "Padding(padding: EdgeInsets.all(16), child: Text('今日の予定は 3 件です'))",
      ),
    ),
  ],
  build: _build,
  codeName: 'Card',
);

Widget _build(DemoArgs args) => Card(
  color: args.valueOf<Color>('color'),
  elevation: args.valueOf<double>('elevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  margin: args.valueOf<EdgeInsetsGeometry>('margin'),
  child: args.valueOf<Widget>('child'),
);
