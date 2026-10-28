import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final customScrollViewEntry = WidgetEntry(
  id: 'customScrollView',
  name: 'CustomScrollView',
  genreIds: const ['layout', 'scrolling'],
  summary: 'sliver（リスト・格子・見出しなど）をつないで 1 つのスクロールにする',
  description:
      'slivers に並べた sliver（SliverList・SliverGrid・SliverAppBar など）を、'
      'つないで 1 つのスクロールにします。'
      'ここでは SliverToBoxAdapter の見出しと SliverGrid と SliverList をつないでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/CustomScrollView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'scrollDirection',
      typeLabel: 'Axis',
      description: 'スクロールの向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'reverse',
      typeLabel: 'bool',
      description: '逆の端（下・右）から並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'slivers',
      typeLabel: 'List<Widget>',
      description: 'つなぐ sliver',
      control: FixedControl(
        value: <Widget>[
          const SliverToBoxAdapter(child: DemoTile(1, width: 96, height: 32)),
          SliverGrid.count(
            crossAxisCount: 4,
            children: [for (var i = 2; i <= 9; i++) DemoTile(i)],
          ),
          SliverList.list(
            children: [
              for (var i = 2; i <= 6; i++) DemoTile(i, width: 64, height: 24),
            ],
          ),
        ],
        source:
            '[SliverToBoxAdapter(child: Tile(1)), '
            'SliverGrid.count(crossAxisCount: 4, children: tiles), '
            'SliverList.list(children: tiles)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'CustomScrollView',
);

Widget _build(DemoArgs args) => CustomScrollView(
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  reverse: args.valueOf<bool>('reverse') ?? false,
  slivers: args.valueOf<List<Widget>>('slivers') ?? const [],
);
