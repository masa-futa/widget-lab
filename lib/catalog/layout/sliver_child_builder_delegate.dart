import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
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
  references: const [
    ReferenceArg(
      name: 'findChildIndexCallback',
      typeLabel: 'ChildIndexGetter?',
      description: 'key から子の番号を探す関数。子を並べ替えたときに、状態を正しい子に引き継ぐために使う',
    ),
    ReferenceArg(
      name: 'addAutomaticKeepAlives',
      typeLabel: 'bool',
      description: '子を AutomaticKeepAlive で包み、画面の外に出ても状態を残せるようにするか。既定は true',
    ),
    ReferenceArg(
      name: 'addRepaintBoundaries',
      typeLabel: 'bool',
      description: '子を RepaintBoundary で包み、描き直しを子ごとに分けるか。既定は true',
    ),
    ReferenceArg(
      name: 'addSemanticIndexes',
      typeLabel: 'bool',
      description: '読み上げのために、子に何番目かの印（IndexedSemantics）を付けるか。既定は true',
    ),
    ReferenceArg(
      name: 'semanticIndexCallback',
      typeLabel: 'SemanticIndexCallback',
      description: '読み上げで数える番号を、子ごとに決める関数。区切り線などを数えないときに使う',
    ),
    ReferenceArg(
      name: 'semanticIndexOffset',
      typeLabel: 'int',
      description: '読み上げで数える番号の始まり。既定は 0',
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
