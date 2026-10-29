import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
  references: const [
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
