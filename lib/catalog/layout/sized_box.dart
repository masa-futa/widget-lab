import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sizedBoxEntry = WidgetEntry(
  id: 'sizedBox',
  name: 'SizedBox',
  genreIds: const ['layout'],
  summary: '幅・高さを決めた箱。子をその大きさにする',
  description:
      'width・height を指定した向きは、子をちょうどその大きさにします。'
      '指定しない向きは子の大きさに合わせます。子がなければ、余白として使えます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SizedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'width',
      typeLabel: 'double?',
      description: '幅。指定しないと子の幅（24）',
      control: SliderControl(
        min: 0,
        max: 240,
        divisions: 12,
        initialValue: 160,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'height',
      typeLabel: 'double?',
      description: '高さ。指定しないと子の高さ（24）',
      control: SliderControl(
        min: 0,
        max: 56,
        divisions: 7,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'その大きさにする Widget（ふだん 24×24）',
      control: FixedControl(
        value: DemoTile(1, width: 24, height: 24),
        source: 'Tile(1)',
      ),
    ),
  ],
  build: _build,
  codeName: 'SizedBox',
);

Widget _build(DemoArgs args) => SizedBox(
  width: args.valueOf<double>('width'),
  height: args.valueOf<double>('height'),
  child: args.valueOf<Widget>('child'),
);
