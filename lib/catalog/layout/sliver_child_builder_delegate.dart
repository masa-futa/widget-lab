import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverChildBuilderDelegateEntry = WidgetEntry(
  id: 'sliverChildBuilderDelegate',
  name: 'SliverChildBuilderDelegate',
  genreIds: const ['layout', 'scrolling'],
  summary: 'sliver の子を、見える分だけ関数で作って渡す',
  description:
      'SliverList・SliverGrid などに子を渡す delegate。'
      '子は builder で、画面に入る分だけ作ります（ListView.builder の中身）。'
      'ここでは CustomScrollView の SliverList に渡しています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverChildBuilderDelegate-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'builder',
      typeLabel: 'NullableIndexedWidgetBuilder',
      description: '番号（0 から）を受けて子を作る関数。null を返すとそこで終わる',
      required: true,
      arg: PropertyArg.positional,
      control: FixedControl(
        value: _tile,
        source: '(context, index) => Tile(index + 1)',
      ),
    ),
    PropertySpec(
      name: 'childCount',
      typeLabel: 'int?',
      description: '子の数。指定しないと builder が null を返すまで（ここでは限りなく）作る',
      control: SliderControl(
        min: 0,
        max: 30,
        divisions: 6,
        initialValue: 5,
        resolve: asInt,
        code: intCode,
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverChildBuilderDelegate',
);

Widget _tile(BuildContext context, int index) =>
    DemoTile(index + 1, height: 24);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        // 必須のプロパティなので、常に値がある
        args.valueOf<NullableIndexedWidgetBuilder>('builder')!,
        childCount: args.valueOf<int>('childCount'),
      ),
    ),
  ],
);
