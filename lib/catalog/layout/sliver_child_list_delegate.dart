import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverChildListDelegateEntry = WidgetEntry(
  id: 'sliverChildListDelegate',
  name: 'SliverChildListDelegate',
  genreIds: const ['layout', 'scrolling'],
  summary: 'sliver の子を、作っておいたリストで渡す',
  description:
      'SliverList・SliverGrid などに子を渡す delegate。'
      '子は先に全部作ったリストで渡します（ListView の children の中身）。'
      '数が少ないときに向きます。ここでは CustomScrollView の SliverList に渡しています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverChildListDelegate-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '渡す子',
      required: true,
      arg: PropertyArg.positional,
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, height: 24),
          DemoTile(2, height: 24),
          DemoTile(3, height: 24),
          DemoTile(4, height: 24),
          DemoTile(5, height: 24),
        ],
        source: '[Tile(1), Tile(2), Tile(3), Tile(4), Tile(5)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverChildListDelegate',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildListDelegate(
        // 必須のプロパティなので、常に値がある
        args.valueOf<List<Widget>>('children')!,
      ),
    ),
  ],
);
