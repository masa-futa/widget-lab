import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final rotatedBoxEntry = WidgetEntry(
  id: 'rotatedBox',
  name: 'RotatedBox',
  genreIds: const ['painting'],
  summary: '子を 90° 単位で回し、場所の取り方も回す',
  description:
      '子を quarterTurns × 90° だけ時計回りに回します。'
      'Transform と違い、回した後の大きさで場所を取るので、まわりの並びも変わります。'
      'ここでは右に Tile(2) を並べています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RotatedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'quarterTurns',
      typeLabel: 'int',
      description: '時計回りに 90° 回す回数',
      control: SliderControl(
        min: 0,
        max: 3,
        divisions: 3,
        initialValue: 1,
        resolve: asInt,
        code: intCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '回す Widget',
      control: FixedControl(
        value: Text('RotatedBox', style: TextStyle(fontSize: 16)),
        source: "Text('RotatedBox', style: TextStyle(fontSize: 16))",
      ),
    ),
  ],
  build: _build,
  codeName: 'RotatedBox',
);

Widget _build(DemoArgs args) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    RotatedBox(
      // API では必須。Padding の padding と同じく、OFF は回さない値で組む
      quarterTurns: args.valueOf<int>('quarterTurns') ?? 0,
      child: args.valueOf<Widget>('child'),
    ),
    const DemoTile(2, width: 32, height: 32),
  ],
);
