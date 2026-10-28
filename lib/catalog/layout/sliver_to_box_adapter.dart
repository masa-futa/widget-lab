import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverToBoxAdapterEntry = WidgetEntry(
  id: 'sliverToBoxAdapter',
  name: 'SliverToBoxAdapter',
  genreIds: const ['layout', 'scrolling'],
  summary: 'ふつうの Widget を 1 つ、sliver として置く',
  description:
      'CustomScrollView の slivers には sliver しか置けません。'
      'ふつうの Widget（box）を 1 つ置くときは、これで包みます。'
      'ここでは下に SliverList をつないでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverToBoxAdapter-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'sliver として置く Widget（高さ 48）',
      control: FixedControl(value: DemoTile(1, height: 48), source: 'Tile(1)'),
    ),
  ],
  build: _build,
  codeName: 'SliverToBoxAdapter',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: args.valueOf<Widget>('child')),
    SliverList.list(
      children: [for (var i = 2; i <= 9; i++) DemoTile(i, height: 24)],
    ),
  ],
);
