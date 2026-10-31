import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final listViewEntry = WidgetEntry(
  id: 'listView',
  name: 'ListView',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を一列に並べてスクロールする',
  description:
      '子を一列に並べ、はみ出す分はスクロールします。'
      '子がたくさんあるときは、見える分だけを作る ListView.builder を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ListView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: 'スクロールの向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '逆の端（下・右）から並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '並びのまわりの余白。余白もスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      excludes: ['itemExtentBuilder', 'prototypeItem'],
      typeLabel: 'double?',
      description: '子 1 つのスクロールの向きの長さ。決めると子の大きさを調べずに済み、速くなる',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 6,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'physics',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollPhysics?',
      description: 'スクロールの手ざわり。端で跳ね返るか、止まるか、スクロールさせないか。既定は機種に合わせる',
      initiallyOn: false,
      control: ChoiceControl(choices: _physicsChoices),
    ),
    PropertySpec(
      name: 'itemExtentBuilder',
      group: PropertyGroup.size,
      excludes: const ['itemExtent', 'prototypeItem'],
      omitIf: (settings) => settings['itemExtent']?.on ?? false,
      typeLabel: 'ItemExtentBuilder?',
      description: '子 1 つのスクロールの向きの長さを、番号ごとに決める関数',
      initiallyOn: false,
      control: const ChoiceControl(
        choices: [
          Choice(
            '24 と 48 を交互',
            _alternateExtent,
            '(index, dimensions) => index.isEven ? 24 : 48',
          ),
          Choice(
            '順に 8 ずつ長く',
            _growingExtent,
            '(index, dimensions) => 16.0 + index * 8',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'prototypeItem',
      group: PropertyGroup.size,
      excludes: const ['itemExtent', 'itemExtentBuilder'],
      omitIf: (settings) =>
          (settings['itemExtent']?.on ?? false) ||
          (settings['itemExtentBuilder']?.on ?? false),
      typeLabel: 'Widget?',
      description: '子のスクロールの向きの長さを、この見本の Widget の長さにそろえる。見本は描かない',
      initiallyOn: false,
      control: const FixedControl(
        value: SizedBox.square(dimension: 48),
        source: 'SizedBox.square(dimension: 48)',
      ),
    ),
    const PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出した子を切るか。既定は hardEdge（切る）',
      initiallyOn: false,
      control: ChoiceControl(choices: _clipChoices),
    ),
    PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '並べる子',
      control: FixedControl(
        value: <Widget>[
          for (var i = 1; i <= 12; i++) DemoTile(i, width: 64, height: 32),
        ],
        source: 'List.generate(12, (i) => Tile(i + 1))',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: 'スクロールの位置を読んだり、動かしたりする。primary が true のときは渡せない',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool?',
      description:
          '画面の主なスクロールとして、PrimaryScrollController を使うか。iOS でステータスバーを押すと先頭に戻る',
    ),
    ReferenceArg(
      name: 'shrinkWrap',
      typeLabel: 'bool',
      description: 'スクロールの向きの長さを、中身の長さに合わせて縮めるか。中身がはみ出す見本では違いが見えない',
    ),
    ReferenceArg(
      name: 'addAutomaticKeepAlives',
      typeLabel: 'bool',
      description: '見えなくなった子の状態を、子が求めれば捨てずに残すか。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'addRepaintBoundaries',
      typeLabel: 'bool',
      description: '子ごとに RepaintBoundary で包み、描き直しを子の中に閉じるか。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'addSemanticIndexes',
      typeLabel: 'bool',
      description: '読み上げに、子の番号を伝えるか',
    ),
    ReferenceArg(
      name: 'cacheExtent',
      typeLabel: 'double?',
      description: '非推奨。代わりに scrollCacheExtent を使う',
    ),
    ReferenceArg(
      name: 'scrollCacheExtent',
      typeLabel: 'ScrollCacheExtent?',
      description: '見える範囲の前後に、先に組んでおく範囲。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'semanticChildCount',
      typeLabel: 'int?',
      description: '読み上げに伝える、中身の項目の数。既定は children の数',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグを、指が触れた所と動き始めた所のどちらから数えるか',
    ),
    ReferenceArg(
      name: 'keyboardDismissBehavior',
      typeLabel: 'ScrollViewKeyboardDismissBehavior?',
      description: 'スクロールしたときに、キーボードを閉じるか',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、スクロールの位置を戻すための名前',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: '中身のない所への指の当たりを、どう受け取るか',
    ),
  ],
  build: _build,
  codeName: 'ListView',
);

Widget _build(DemoArgs args) {
  // itemExtent・itemExtentBuilder・prototypeItem は 1 つしか渡せない（assert）。
  // omitIf と同じく、itemExtent・itemExtentBuilder・prototypeItem の順に優先する。
  final itemExtent = args.valueOf<double>('itemExtent');
  final itemExtentBuilder = itemExtent == null
      ? args.valueOf<ItemExtentBuilder>('itemExtentBuilder')
      : null;
  final prototypeItem = itemExtent == null && itemExtentBuilder == null
      ? args.valueOf<Widget>('prototypeItem')
      : null;
  return ListView(
    scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
    reverse: args.valueOf<bool>('reverse') ?? false,
    physics: args.valueOf<ScrollPhysics>('physics'),
    padding: args.valueOf<EdgeInsetsGeometry>('padding'),
    itemExtent: itemExtent,
    itemExtentBuilder: itemExtentBuilder,
    prototypeItem: prototypeItem,
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
    children: args.valueOf<List<Widget>>('children') ?? const [],
  );
}

double? _alternateExtent(int index, SliverLayoutDimensions dimensions) =>
    index.isEven ? 24 : 48;

double? _growingExtent(int index, SliverLayoutDimensions dimensions) =>
    16.0 + index * 8;

const _physicsChoices = [
  Choice('跳ね返る', BouncingScrollPhysics(), 'BouncingScrollPhysics()'),
  Choice('端で止まる', ClampingScrollPhysics(), 'ClampingScrollPhysics()'),
  Choice(
    'スクロールしない',
    NeverScrollableScrollPhysics(),
    'NeverScrollableScrollPhysics()',
  ),
];

const _clipChoices = [
  Choice('none', Clip.none, 'Clip.none'),
  Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
  Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
];
