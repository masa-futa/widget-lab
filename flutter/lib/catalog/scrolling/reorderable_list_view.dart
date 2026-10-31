import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/catalog/scrolling/scroll_choices.dart';

final reorderableListViewEntry = WidgetEntry(
  id: 'reorderableListView',
  name: 'ReorderableListView',
  genreIds: const ['scrolling'],
  summary: '項目を長押しやつまみでドラッグして、並べ替えられるリスト',
  description:
      '項目をドラッグして並べ替えられる ListView。落とすと onReorder に元の位置と新しい位置が渡るので、'
      '自分のリストを並べ替えて組み直します。項目には key が要ります。'
      'プレビューの項目をドラッグしてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/ReorderableListView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'buildDefaultDragHandles',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '項目につまみを付けるか（スマートフォンでは長押しでドラッグ）。'
          'false にすると、自分で ReorderableDragStartListener を置く。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '並べる向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '逆の向き（下から・右から）に並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'anchor',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: 'スクロールの始まりを置く位置（0 で先頭の端、0.5 で真ん中）。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 0.5,
        divisions: 2,
        initialValue: 0.25,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsets?',
      description: 'リストの内側の余白。余白もスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 2,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      excludes: ['prototypeItem', 'itemExtentBuilder'],
      typeLabel: 'double?',
      description: '項目の並ぶ向きの大きさを、全部この値にそろえる',
      initiallyOn: false,
      control: SliderControl(
        min: 24,
        max: 48,
        divisions: 2,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'prototypeItem',
      group: PropertyGroup.size,
      excludes: ['itemExtent', 'itemExtentBuilder'],
      omitIf: _omitsPrototypeItem,
      typeLabel: 'Widget?',
      description: '見本の項目。項目の大きさを全部、この見本の大きさにそろえる',
      initiallyOn: false,
      control: FixedControl(
        value: SizedBox.square(dimension: 40),
        source: 'const SizedBox.square(dimension: 40)',
      ),
    ),
    const PropertySpec(
      name: 'itemExtentBuilder',
      group: PropertyGroup.size,
      excludes: ['itemExtent', 'prototypeItem'],
      omitIf: _omitsItemExtentBuilder,
      typeLabel: 'ItemExtentBuilder?',
      description: '項目ごとの、並ぶ向きの大きさを返す関数',
      initiallyOn: false,
      control: FixedControl(
        value: _itemExtent,
        source: '(index, dimensions) => 24.0 + index * 8',
      ),
    ),
    const PropertySpec(
      name: 'shrinkWrap',
      group: PropertyGroup.size,
      typeLabel: 'bool',
      description: 'リストの大きさを、使える広さいっぱいでなく項目の合計に合わせるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'proxyDecorator',
      group: PropertyGroup.paint,
      typeLabel: 'ReorderItemProxyDecorator?',
      description: 'ドラッグしている間の項目の見た目を作る関数。指定しないと影を付けて浮かせる',
      initiallyOn: false,
      control: FixedControl(
        value: _proxyDecorator,
        source:
            '(child, index, animation) => Material(\n'
            '    color: Colors.transparent,\n'
            '    child: Opacity(opacity: 0.5, child: child),\n'
            '  )',
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出した項目を切り抜くか。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(choices: clipChoices),
    ),
    const PropertySpec(
      name: 'physics',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollPhysics?',
      description: '端に来たときの動き。指定しないと端末に合わせる',
      initiallyOn: false,
      control: ChoiceControl(choices: physicsChoices),
    ),
    const PropertySpec(
      name: 'autoScrollerVelocityScalar',
      group: PropertyGroup.behavior,
      typeLabel: 'double?',
      description: '項目を端までドラッグしたときに、リストが自動で送られる速さ。既定は 50',
      initiallyOn: false,
      control: SliderControl(
        min: 10,
        max: 200,
        divisions: 19,
        initialValue: 150,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'onReorderItem',
      group: PropertyGroup.behavior,
      typeLabel: 'ReorderItemCallback',
      description:
          '落としたときに呼ばれる。ここで自分のリストを並べ替える'
          '（newIndex は、元の項目を抜いた後の位置）',
      required: true,
      control: FixedControl(
        value: _onReorderItem,
        source:
            '(oldIndex, newIndex) => setState(\n'
            '    () => items.insert(newIndex, items.removeAt(oldIndex)),\n'
            '  )',
      ),
    ),
    const PropertySpec(
      name: 'header',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '先頭に置く、並べ替えない項目',
      initiallyOn: false,
      control: FixedControl(value: Text('見出し'), source: "const Text('見出し')"),
    ),
    const PropertySpec(
      name: 'footer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '最後に置く、並べ替えない項目',
      initiallyOn: false,
      control: FixedControl(value: Text('おわり'), source: "const Text('おわり')"),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '並べ替える項目（5 つ）。どれにも key が要る',
      required: true,
      // 並べ替えはデモの部品が持つリストで行うので、値は最初の並び
      control: FixedControl(
        value: <int>[1, 2, 3, 4, 5],
        source: '[for (final n in items) Tile(n, key: ValueKey(n))]',
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
      name: 'onReorder',
      typeLabel: 'ReorderCallback?',
      description: '非推奨。代わりに onReorderItem を使う',
    ),
    ReferenceArg(
      name: 'onReorderStart',
      typeLabel: 'void Function(int index)?',
      description: '項目をドラッグし始めたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onReorderEnd',
      typeLabel: 'void Function(int index)?',
      description: '項目を落としたとき（やめたときも）に呼ばれる',
    ),
    ReferenceArg(
      name: 'scrollController',
      typeLabel: 'ScrollController?',
      description: 'スクロールの位置を読んだり動かしたりする',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool?',
      description: '画面のいちばん外のスクロールとして、PrimaryScrollController を使うか',
    ),
    ReferenceArg(
      name: 'cacheExtent',
      typeLabel: 'double?',
      description: '非推奨。代わりに scrollCacheExtent を使う',
    ),
    ReferenceArg(
      name: 'scrollCacheExtent',
      typeLabel: 'ScrollCacheExtent?',
      description: '見える範囲の外に、前もって作っておく項目の広さ',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグを、指が動き始めた位置と最初に触れた位置のどちらから始めるか',
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
      name: 'dragBoundaryProvider',
      typeLabel: 'ReorderDragBoundaryProvider?',
      description: 'ドラッグした項目を動かせる範囲を決める',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを項目のつまみに乗せたときのカーソル',
    ),
  ],
  build: _build,
  codeName: 'ReorderableListView',
);

/// 並べ替えの関数の印（並べ替えはデモの部品が持つリストで行う）。
void _onReorderItem(int oldIndex, int newIndex) {}

/// 項目ごとに 8 ずつ大きくする。
double? _itemExtent(int index, SliverLayoutDimensions dimensions) =>
    24.0 + index * 8;

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) =>
    Material(
      color: Colors.transparent,
      child: Opacity(opacity: 0.5, child: child),
    );

bool _isOn(Map<String, PropertySetting> settings, String name) =>
    settings[name]?.on ?? false;

/// itemExtent・prototypeItem・itemExtentBuilder は 1 つしか渡せない（assert）。
/// 一緒に ON なら、itemExtent・prototypeItem・itemExtentBuilder の順に先のものを渡す。
bool _omitsPrototypeItem(Map<String, PropertySetting> settings) =>
    _isOn(settings, 'itemExtent');

bool _omitsItemExtentBuilder(Map<String, PropertySetting> settings) =>
    _isOn(settings, 'itemExtent') || _isOn(settings, 'prototypeItem');

Widget _build(DemoArgs args) {
  final handles = args.valueOf<bool>('buildDefaultDragHandles') ?? true;
  final direction = args.valueOf<Axis>('scrollDirection') ?? Axis.vertical;
  final reverse = args.valueOf<bool>('reverse') ?? false;
  final anchor = args.valueOf<double>('anchor') ?? 0;
  final padding = args.valueOf<EdgeInsets>('padding');
  // omitIf と同じ順で、1 つだけ渡す
  final itemExtent = args.valueOf<double>('itemExtent');
  final prototypeItem = itemExtent == null
      ? args.valueOf<Widget>('prototypeItem')
      : null;
  final itemExtentBuilder = itemExtent == null && prototypeItem == null
      ? args.valueOf<ItemExtentBuilder>('itemExtentBuilder')
      : null;
  final shrinkWrap = args.valueOf<bool>('shrinkWrap') ?? false;
  final proxyDecorator = args.valueOf<ReorderItemProxyDecorator>(
    'proxyDecorator',
  );
  final clipBehavior = args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge;
  final physics = args.valueOf<ScrollPhysics>('physics');
  final velocity = args.valueOf<double>('autoScrollerVelocityScalar');
  final header = args.valueOf<Widget>('header');
  final footer = args.valueOf<Widget>('footer');
  // 必須のプロパティなので、常に値がある
  final initial = args.valueOf<List<int>>('children')!;
  return DemoValue<List<int>>(
    initial: initial,
    builder: (context, items, onChanged) => ReorderableListView(
      buildDefaultDragHandles: handles,
      scrollDirection: direction,
      reverse: reverse,
      anchor: anchor,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      itemExtentBuilder: itemExtentBuilder,
      shrinkWrap: shrinkWrap,
      proxyDecorator: proxyDecorator,
      clipBehavior: clipBehavior,
      physics: physics,
      autoScrollerVelocityScalar: velocity,
      header: header,
      footer: footer,
      onReorderItem: (oldIndex, newIndex) {
        final next = [...items];
        next.insert(newIndex, next.removeAt(oldIndex));
        onChanged(next);
      },
      children: [
        for (final n in items)
          DemoTile(n, key: ValueKey(n), width: 64, height: 32),
      ],
    ),
  );
}
