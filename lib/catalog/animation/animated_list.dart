import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedListEntry = WidgetEntry(
  id: 'animatedList',
  name: 'AnimatedList',
  genreIds: const ['animation'],
  summary: '項目を足す・消すときに動きを付けるリスト',
  description:
      '項目を足す・消すときに、その項目だけを動かして入れる／出すスクロールのリストです。'
      '足す・消すは AnimatedListState の insertItem・removeItem で知らせます'
      '（ここでは「足す」「消す」のボタン）。itemBuilder は animation を受け取り、'
      'SizeTransition などで項目を包みます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedList-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'initialItemCount',
      group: PropertyGroup.content,
      typeLabel: 'int',
      description: '最初にある項目の数。最初の項目は動かずに出る',
      control: SliderControl(
        min: 0,
        max: 5,
        divisions: 5,
        initialValue: 2,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '並べる向き',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in Axis.values)
            Choice(value.name, value, 'Axis.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '並びを逆にする（縦なら下から、横なら右から）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'physics',
      typeLabel: 'ScrollPhysics?',
      description: 'スクロールの手ざわり。端で跳ね返るか、止まるか、動かさないか',
      initiallyOn: false,
      group: PropertyGroup.behavior,
      control: ChoiceControl(
        choices: [
          Choice(
            'Bouncing',
            BouncingScrollPhysics(),
            'const BouncingScrollPhysics()',
          ),
          Choice(
            'Clamping',
            ClampingScrollPhysics(),
            'const ClampingScrollPhysics()',
          ),
          Choice(
            'NeverScrollable',
            NeverScrollableScrollPhysics(),
            'const NeverScrollableScrollPhysics()',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'リストの中身のまわりの余白。スクロールすると余白ごと動く',
      initiallyOn: false,
      group: PropertyGroup.spacing,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: 'リストの枠からはみ出す項目を切るか。指定しないと Clip.hardEdge',
      initiallyOn: false,
      group: PropertyGroup.transform,
      control: ChoiceControl(choices: clipChoices()),
    ),
  ],
  references: const [
    keyReference,
    ReferenceArg(
      name: 'itemBuilder',
      typeLabel: 'AnimatedItemBuilder',
      description: '項目を 1 つずつ組み立てる関数。入ってくる動きの animation を受け取る',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: 'スクロールの位置を読む・動かすためのもの。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool?',
      description: '画面の主なスクロール（PrimaryScrollController）につなぐか。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'shrinkWrap',
      typeLabel: 'bool',
      description: 'リストの長さを中身に合わせるか。見本では高さが決まっているので違いが見えない',
    ),
    ReferenceArg(
      name: 'scrollCacheExtent',
      typeLabel: 'ScrollCacheExtent?',
      description: '画面の外で先に組み立てておく範囲。見た目は変わらない',
    ),
  ],
  build: _build,
  codeName: 'AnimatedList',
  codeArguments: const [
    'key: listKey',
    'itemBuilder: (context, index, animation) => SizeTransition(\n'
        '    sizeFactor: animation,\n'
        '    child: Item(items[index]),\n'
        '  )',
  ],
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(280, 240),
  child: _ListDemo(
    initialItemCount: args.valueOf<int>('initialItemCount') ?? 0,
    scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
    reverse: args.valueOf<bool>('reverse') ?? false,
    physics: args.valueOf<ScrollPhysics>('physics'),
    padding: args.valueOf<EdgeInsetsGeometry>('padding'),
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  ),
);

/// 「足す」「消す」のボタン（デモの部品）と AnimatedList。
class _ListDemo extends StatefulWidget {
  const _ListDemo({
    required this.initialItemCount,
    required this.scrollDirection,
    required this.reverse,
    required this.physics,
    required this.padding,
    required this.clipBehavior,
  });

  final int initialItemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  State<_ListDemo> createState() => _ListDemoState();
}

class _ListDemoState extends State<_ListDemo> {
  /// State ごとに作るので、見本と詳細の両方にあっても重ならない。
  GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<int> _items = _initialItems();

  /// 次に足す項目の番号。
  late int _next = widget.initialItemCount + 1;

  List<int> _initialItems() => [
    for (var i = 1; i <= widget.initialItemCount; i++) i,
  ];

  @override
  void didUpdateWidget(_ListDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItemCount != widget.initialItemCount) {
      // initialItemCount は最初の 1 回しか読まれないので、リストごと作り直す
      _listKey = GlobalKey();
      _items = _initialItems();
      _next = widget.initialItemCount + 1;
    }
  }

  void _add() {
    _items.insert(0, _next++);
    _listKey.currentState?.insertItem(0);
  }

  void _remove() {
    if (_items.isEmpty) return;
    final removed = _items.removeAt(0);
    _listKey.currentState?.removeItem(
      0,
      (context, animation) => _Item(
        number: removed,
        animation: animation,
        axis: widget.scrollDirection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Row(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('足す'),
          ),
          OutlinedButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.remove),
            label: const Text('消す'),
          ),
        ],
      ),
      Expanded(
        child: AnimatedList(
          key: _listKey,
          initialItemCount: widget.initialItemCount,
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          physics: widget.physics,
          padding: widget.padding,
          clipBehavior: widget.clipBehavior,
          itemBuilder: (context, index, animation) => _Item(
            number: _items[index],
            animation: animation,
            axis: widget.scrollDirection,
          ),
        ),
      ),
    ],
  );
}

/// 1 つの項目。animation に合わせて、並べる向きに伸び縮みする。
class _Item extends StatelessWidget {
  const _Item({
    required this.number,
    required this.animation,
    required this.axis,
  });

  final int number;
  final Animation<double> animation;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizeTransition(
      sizeFactor: animation,
      axis: axis,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: axis == Axis.horizontal ? 72 : null,
          height: axis == Axis.vertical ? 40 : null,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '項目 $number',
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
        ),
      ),
    );
  }
}
