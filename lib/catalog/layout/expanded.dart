import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final expandedEntry = WidgetEntry(
  id: 'expanded',
  name: 'Expanded',
  genreIds: const ['layout'],
  summary: 'Row・Column の余った長さを、子に分けて埋める',
  description:
      'Row・Column・Flex の子に使います。ほかの子を並べた残りの長さを、'
      'Expanded の子どうしで flex の比で分け合います。'
      'ここでは右に Expanded(child: Tile(2))（flex 1）を並べています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Expanded-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'flex',
      typeLabel: 'int',
      description: '残りの長さを分ける比。右の子（1）と比べてこの倍の長さになる',
      control: SliderControl(
        min: 1,
        max: 4,
        divisions: 3,
        initialValue: 2,
        resolve: asInt,
        code: intCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '残りの長さに広げる Widget',
      required: true,
      control: FixedControl(value: DemoTile(1, height: 40), source: 'Tile(1)'),
    ),
  ],
  build: _build,
  codeName: 'Expanded',
);

Widget _build(DemoArgs args) => Row(
  children: [
    Expanded(
      flex: args.valueOf<int>('flex') ?? 1,
      // 必須のプロパティなので、常に値がある
      child: args.valueOf<Widget>('child')!,
    ),
    const Expanded(child: DemoTile(2, height: 40)),
  ],
);
