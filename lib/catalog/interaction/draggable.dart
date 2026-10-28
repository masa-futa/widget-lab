import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_drop_zone.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final draggableEntry = WidgetEntry(
  id: 'draggable',
  name: 'Draggable',
  genreIds: const ['interaction'],
  summary: '子をドラッグして、DragTarget へ値を運ぶ',
  description:
      '子に触れて動かすと、指の下に feedback を出してドラッグします。'
      'DragTarget の上で離すと data が渡ります。'
      'ここでは右に受け取る場所（DragTarget）を置いています。左の箱をドラッグしてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Draggable-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'data',
      typeLabel: 'T?',
      description: '落とした先に渡す値',
      control: FixedControl(value: 1, source: '1'),
    ),
    PropertySpec(
      name: 'feedback',
      typeLabel: 'Widget',
      description: 'ドラッグ中に指の下に出すもの',
      required: true,
      control: FixedControl(value: _feedback, source: _feedbackCode),
    ),
    PropertySpec(
      name: 'childWhenDragging',
      typeLabel: 'Widget?',
      description: 'ドラッグ中に元の場所に出すもの。指定しないと子のまま',
      initiallyOn: false,
      control: FixedControl(value: _hole, source: _holeCode),
    ),
    PropertySpec(
      name: 'axis',
      typeLabel: 'Axis?',
      description: '動かせる向きを 1 つに絞る。指定しないとどの向きにも動かせる',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'ドラッグする前に見えているもの',
      required: true,
      control: FixedControl(value: _tile, source: 'Tile(1)'),
    ),
  ],
  build: _build,
  codeName: 'Draggable<int>',
);

const _tile = DemoTile(1, width: 48, height: 48);
const _feedback = Opacity(opacity: 0.7, child: _tile);
const _feedbackCode = 'Opacity(opacity: 0.7, child: Tile(1))';
const _hole = DemoDropArea(highlighted: false, label: '');
const _holeCode = 'const Hole()';

// feedback・child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => DemoDropZone(
  draggable: Draggable<int>(
    data: args.valueOf<int>('data'),
    feedback: args.valueOf<Widget>('feedback')!,
    childWhenDragging: args.valueOf<Widget>('childWhenDragging'),
    axis: args.valueOf<Axis>('axis'),
    child: args.valueOf<Widget>('child')!,
  ),
);
