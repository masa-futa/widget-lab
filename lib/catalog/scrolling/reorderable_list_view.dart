import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

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
  properties: const [
    PropertySpec(
      name: 'buildDefaultDragHandles',
      typeLabel: 'bool',
      description:
          '項目につまみを付けるか（スマートフォンでは長押しでドラッグ）。'
          'false にすると、自分で ReorderableDragStartListener を置く。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'scrollDirection',
      typeLabel: 'Axis',
      description: '並べる向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'onReorderItem',
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
  ],
  build: _build,
  codeName: 'ReorderableListView',
  codeArguments: const [
    'children: [for (final n in items) Tile(n, key: ValueKey(n))]',
  ],
);

/// 並べ替えの関数の印（並べ替えはデモの部品が持つリストで行う）。
void _onReorderItem(int oldIndex, int newIndex) {}

Widget _build(DemoArgs args) {
  final handles = args.valueOf<bool>('buildDefaultDragHandles') ?? true;
  final direction = args.valueOf<Axis>('scrollDirection') ?? Axis.vertical;
  return DemoValue<List<int>>(
    initial: const [1, 2, 3, 4, 5],
    builder: (context, items, onChanged) => ReorderableListView(
      buildDefaultDragHandles: handles,
      scrollDirection: direction,
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
