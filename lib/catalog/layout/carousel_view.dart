import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final carouselViewEntry = WidgetEntry(
  id: 'carouselView',
  name: 'CarouselView',
  genreIds: const ['layout', 'scrolling'],
  summary: '角の丸い項目を横に並べ、送って見るカルーセル',
  description:
      'Material 3 のカルーセル。項目を itemExtent の幅で並べ、横にスクロールします。'
      '端に出ていく項目は shrinkExtent まで縮みます。項目は押せます（onTap）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/CarouselView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'itemExtent',
      typeLabel: 'double',
      description: '1 つの項目の幅',
      required: true,
      control: SliderControl(
        min: 80,
        max: 240,
        divisions: 8,
        initialValue: 160,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'shrinkExtent',
      typeLabel: 'double',
      description: '端に出ていく項目が縮む下限の幅。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'itemSnapping',
      typeLabel: 'bool',
      description: '指を離したら、項目の端にぴったり止めるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる項目',
      required: true,
      control: FixedControl(
        value: <Widget>[
          DemoTile(1),
          DemoTile(2),
          DemoTile(3),
          DemoTile(4),
          DemoTile(5),
          DemoTile(6),
        ],
        source: 'List.generate(6, (i) => Tile(i + 1))',
      ),
    ),
  ],
  build: _build,
  codeName: 'CarouselView',
);

// itemExtent・children は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => CarouselView(
  itemExtent: args.valueOf<double>('itemExtent')!,
  shrinkExtent: args.valueOf<double>('shrinkExtent') ?? 0,
  itemSnapping: args.valueOf<bool>('itemSnapping') ?? false,
  children: args.valueOf<List<Widget>>('children')!,
);
