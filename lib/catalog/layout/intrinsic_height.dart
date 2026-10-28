import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final intrinsicHeightEntry = WidgetEntry(
  id: 'intrinsicHeight',
  name: 'IntrinsicHeight',
  genreIds: const ['layout'],
  summary: '子の高さを、子が本来ほしい高さに揃える',
  description:
      '子に「本来ほしい高さ」を先に尋ね、その高さで組みます。'
      'Row の crossAxisAlignment を stretch にしたとき、一番高い子に揃えるのによく使います'
      '（ないと使える高さいっぱいまで伸びます）。尋ねる分だけ組み立てが重くなります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/IntrinsicHeight-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '高さを揃える Widget。ここでは高さの違う 2 つの子を stretch で並べた Row',
      control: FixedControl(
        value: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DemoTile(1, width: 48),
            DemoTile(2, width: 48, height: 48),
          ],
        ),
        source:
            'Row(crossAxisAlignment: CrossAxisAlignment.stretch, '
            'children: [Tile(1), Tile(2)])',
      ),
    ),
  ],
  build: _build,
  codeName: 'IntrinsicHeight',
);

Widget _build(DemoArgs args) =>
    IntrinsicHeight(child: args.valueOf<Widget>('child'));
