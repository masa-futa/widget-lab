import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverGridEntry = WidgetEntry(
  id: 'sliverGrid',
  name: 'SliverGrid',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を格子に並べる sliver',
  description:
      'CustomScrollView の中で、子を格子に並べます（GridView の中身）。'
      '格子の形は gridDelegate で、1 行の数か 1 つの幅の上限で決めます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverGrid-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'gridDelegate',
      group: PropertyGroup.layout,
      typeLabel: 'SliverGridDelegate',
      description: '格子の形',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '1 行に 4 つ',
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            'SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4)',
          ),
          Choice(
            '1 行に 6 つ・間 4',
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            'SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, '
                'mainAxisSpacing: 4, crossAxisSpacing: 4)',
          ),
          Choice(
            '横長（比 2）',
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            'SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, '
                'childAspectRatio: 2)',
          ),
          Choice(
            '幅 48 まで',
            SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 48),
            'SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 48)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'delegate',
      group: PropertyGroup.content,
      typeLabel: 'SliverChildDelegate',
      description: '子の渡し方（24 件）',
      required: true,
      control: FixedControl(
        value: SliverChildBuilderDelegate(
          (context, index) => DemoTile(index + 1),
          childCount: 24,
        ),
        source:
            'SliverChildBuilderDelegate((context, index) => Tile(index + 1), '
            'childCount: 24)',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'SliverGrid',
);

// どちらも必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverGrid(
      gridDelegate: args.valueOf<SliverGridDelegate>('gridDelegate')!,
      delegate: args.valueOf<SliverChildDelegate>('delegate')!,
    ),
  ],
);
