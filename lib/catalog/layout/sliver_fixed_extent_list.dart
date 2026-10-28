import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverFixedExtentListEntry = WidgetEntry(
  id: 'sliverFixedExtentList',
  name: 'SliverFixedExtentList',
  genreIds: const ['layout', 'scrolling'],
  summary: '同じ高さの子を並べる sliver のリスト',
  description:
      '子を全部 itemExtent の高さにして並べる SliverList。'
      '子の大きさを調べずに位置が分かるので、たくさんの子でも速く飛べます。'
      'ここでは CustomScrollView の中に置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverFixedExtentList-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'itemExtent',
      typeLabel: 'double',
      description: '子 1 つの高さ',
      required: true,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 6,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'delegate',
      typeLabel: 'SliverChildDelegate',
      description: '子の渡し方（20 件）',
      required: true,
      control: FixedControl(
        value: SliverChildBuilderDelegate(
          (context, index) => DemoTile(index + 1),
          childCount: 20,
        ),
        source:
            'SliverChildBuilderDelegate((context, index) => Tile(index + 1), '
            'childCount: 20)',
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverFixedExtentList',
);

// どちらも必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverFixedExtentList(
      itemExtent: args.valueOf<double>('itemExtent')!,
      delegate: args.valueOf<SliverChildDelegate>('delegate')!,
    ),
  ],
);
