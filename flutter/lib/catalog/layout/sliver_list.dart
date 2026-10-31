import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverListEntry = WidgetEntry(
  id: 'sliverList',
  name: 'SliverList',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を一列に並べる sliver',
  description:
      'CustomScrollView の中で、子を一列に並べます（ListView の中身）。'
      '子の高さはそれぞれ違ってかまいません。'
      'SliverList.builder・SliverList.list の書き方もあります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverList-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'delegate',
      group: PropertyGroup.content,
      typeLabel: 'SliverChildDelegate',
      description: '子の渡し方。builder は見える分だけ作り、list は作っておいた子を渡す',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            'builder（20 件）',
            SliverChildBuilderDelegate(
              (context, index) => DemoTile(index + 1, height: 24),
              childCount: 20,
            ),
            'SliverChildBuilderDelegate((context, index) => Tile(index + 1), '
                'childCount: 20)',
          ),
          Choice(
            'list（3 件・高さ違い）',
            SliverChildListDelegate(const [
              DemoTile(1, height: 16),
              DemoTile(2, height: 32),
              DemoTile(3, height: 48),
            ]),
            'SliverChildListDelegate([Tile(1), Tile(2), Tile(3)])',
          ),
        ],
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
  codeName: 'SliverList',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    // 必須のプロパティなので、常に値がある
    SliverList(delegate: args.valueOf<SliverChildDelegate>('delegate')!),
  ],
);
