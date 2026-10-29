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
    PropertySpec(
      name: 'slivers',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: 'つなぐ sliver',
      control: FixedControl(
        value: <Widget>[
          const SliverToBoxAdapter(child: DemoTile(1, width: 96, height: 32)),
          SliverGrid.count(
            key: const ValueKey('grid'),
            crossAxisCount: 4,
            children: [for (var i = 2; i <= 9; i++) DemoTile(i)],
          ),
          SliverList.list(
            key: const ValueKey('list'),
            children: [
              for (var i = 2; i <= 6; i++) DemoTile(i, width: 64, height: 24),
            ],
          ),
        ],
        source:
            '[SliverToBoxAdapter(child: Tile(1)), '
            "SliverGrid.count(key: ValueKey('grid'), crossAxisCount: 4, children: tiles), "
            "SliverList.list(key: ValueKey('list'), children: tiles)]",
      ),
    ),
    PropertySpec(
      name: 'center',
      group: PropertyGroup.layout,
      pairsWith: const ['anchor'],
      requires: 'slivers',
      omitIf: (settings) => !(settings['slivers']?.on ?? false),
      typeLabel: 'Key?',
      description: 'スクロールの位置 0 に置く sliver の key。それより前の sliver は逆の向きに並ぶ',
      initiallyOn: false,
      control: const ChoiceControl(
        choices: [
          Choice('SliverGrid', ValueKey('grid'), "ValueKey('grid')"),
          Choice('SliverList', ValueKey('list'), "ValueKey('list')"),
        ],
      ),
    ),
    const PropertySpec(
      name: 'anchor',
      group: PropertyGroup.layout,
      pairsWith: ['center'],
      typeLabel: 'double',
      description: 'スクロールの位置 0（center の sliver の始まり）を、見える範囲のどこに置くか。0 は始まりの端、0.5 は真ん中。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 4,
        initialValue: 0.5,
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
    const PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出した sliver を切るか。既定は hardEdge（切る）',
      initiallyOn: false,
      control: ChoiceControl(choices: _clipChoices),
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
      name: 'scrollBehavior',
      typeLabel: 'ScrollBehavior?',
      description: 'スクロールバーや端の効果、受け付ける入力の種類を、この中だけ差し替える',
    ),
    ReferenceArg(
      name: 'shrinkWrap',
      typeLabel: 'bool',
      description:
          'スクロールの向きの長さを、中身の長さに合わせて縮めるか。center とは同時に使えない。中身がはみ出す見本では違いが見えない',
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
      name: 'paintOrder',
      typeLabel: 'SliverPaintOrder',
      description: 'sliver が重なったとき、どちらを上に描くか。重ならない見本では違いが見えない',
    ),
    ReferenceArg(
      name: 'semanticChildCount',
      typeLabel: 'int?',
      description: '読み上げに伝える、中身の項目の数',
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
  codeName: 'CustomScrollView',
);

Widget _build(DemoArgs args) {
  final slivers = args.valueOf<List<Widget>>('slivers');
  return CustomScrollView(
    scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
    reverse: args.valueOf<bool>('reverse') ?? false,
    // center は slivers の中の key なので、slivers が OFF の間は渡さない（omitIf と同じ条件）
    center: slivers == null ? null : args.valueOf<Key>('center'),
    anchor: args.valueOf<double>('anchor') ?? 0,
    physics: args.valueOf<ScrollPhysics>('physics'),
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
    slivers: slivers ?? const [],
  );
}

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
