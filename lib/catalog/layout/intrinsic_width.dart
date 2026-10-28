import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final intrinsicWidthEntry = WidgetEntry(
  id: 'intrinsicWidth',
  name: 'IntrinsicWidth',
  genreIds: const ['layout'],
  summary: '子の幅を、子が本来ほしい幅に揃える',
  description:
      '子に「本来ほしい幅」を先に尋ね、その幅で組みます。'
      'Column の crossAxisAlignment を stretch にしたとき、一番広い子に揃えるのによく使います'
      '（ないと使える幅いっぱいまで伸びます）。尋ねる分だけ組み立てが重くなります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/IntrinsicWidth-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'stepWidth',
      typeLabel: 'double?',
      description: '幅をこの値の倍数に切り上げる',
      initiallyOn: false,
      control: SliderControl(
        min: 8,
        max: 64,
        divisions: 7,
        initialValue: 64,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'stepHeight',
      typeLabel: 'double?',
      description: '高さをこの値の倍数に切り上げる',
      initiallyOn: false,
      control: SliderControl(
        min: 8,
        max: 32,
        divisions: 3,
        initialValue: 32,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '幅を揃える Widget。ここでは幅の違う 2 つの子（48 と 96）を stretch で並べた Column',
      control: FixedControl(
        value: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DemoTile(1, width: 48, height: 24),
            DemoTile(2, width: 96, height: 24),
          ],
        ),
        source:
            'Column(crossAxisAlignment: CrossAxisAlignment.stretch, '
            'children: [Tile(1), Tile(2)])',
      ),
    ),
  ],
  build: _build,
  codeName: 'IntrinsicWidth',
);

Widget _build(DemoArgs args) => IntrinsicWidth(
  stepWidth: args.valueOf<double>('stepWidth'),
  stepHeight: args.valueOf<double>('stepHeight'),
  child: args.valueOf<Widget>('child'),
);
