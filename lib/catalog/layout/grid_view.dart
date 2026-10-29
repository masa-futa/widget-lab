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

final gridViewEntry = WidgetEntry(
  id: 'gridView',
  name: 'GridView',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を格子に並べてスクロールする',
  description:
      '子を縦横の格子に並べ、はみ出す分はスクロールします。'
      'GridView.count は 1 行の数を決める書き方です。'
      '1 つの幅を決める GridView.extent、たくさんの子を必要な分だけ作る GridView.builder もあります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/GridView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'crossAxisCount',
      group: PropertyGroup.layout,
      typeLabel: 'int',
      description: '1 行（スクロールと直角の向き）に並べる数',
      required: true,
      control: SliderControl(
        min: 1,
        max: 6,
        divisions: 5,
        initialValue: 4,
        resolve: asInt,
        code: intCode,
      ),
    ),
    const PropertySpec(
      name: 'mainAxisSpacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double',
      description: 'スクロールの向きの、子と子のあいだ。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'crossAxisSpacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double',
      description: 'スクロールと直角の向きの、子と子のあいだ。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
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
      description: '格子のまわりの余白。余白もスクロールする',
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
      name: 'childAspectRatio',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description:
          '子 1 つの、直角の向きの長さ ÷ スクロールの向きの長さ。mainAxisExtent を決めると使われない。既定は 1.0',
      initiallyOn: false,
      control: SliderControl(
        min: 0.5,
        max: 2,
        divisions: 6,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'mainAxisExtent',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '子 1 つのスクロールの向きの長さ。決めると childAspectRatio より優先する',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 6,
        initialValue: 24,
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
        value: <Widget>[for (var i = 1; i <= 16; i++) DemoTile(i)],
        source: 'List.generate(16, (i) => Tile(i + 1))',
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
  codeName: 'GridView.count',
);

Widget _build(DemoArgs args) => GridView.count(
  // 必須のプロパティなので、常に値がある
  crossAxisCount: args.valueOf<int>('crossAxisCount')!,
  mainAxisSpacing: args.valueOf<double>('mainAxisSpacing') ?? 0,
  crossAxisSpacing: args.valueOf<double>('crossAxisSpacing') ?? 0,
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  reverse: args.valueOf<bool>('reverse') ?? false,
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  childAspectRatio: args.valueOf<double>('childAspectRatio') ?? 1.0,
  mainAxisExtent: args.valueOf<double>('mainAxisExtent'),
  physics: args.valueOf<ScrollPhysics>('physics'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);

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
