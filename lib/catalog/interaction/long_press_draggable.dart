import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_drop_zone.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final longPressDraggableEntry = WidgetEntry(
  id: 'longPressDraggable',
  name: 'LongPressDraggable',
  genreIds: const ['interaction'],
  summary: '長押ししてから、子をドラッグして DragTarget へ値を運ぶ',
  description:
      'Draggable と同じく値を運びますが、長押ししてからドラッグが始まります。'
      'スクロールする中の項目のように、ふつうのドラッグはスクロールに使いたいときに向きます。'
      'ここでは右に受け取る場所（DragTarget）を置いています。左の箱を長押ししてから動かしてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/LongPressDraggable-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'data',
      typeLabel: 'T?',
      description: '落とした先に渡す値',
      control: FixedControl(value: 1, source: '1'),
    ),
    PropertySpec(
      name: 'delay',
      typeLabel: 'Duration',
      description: 'ドラッグが始まるまで押し続ける時間。既定は 500 ミリ秒',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '200 ミリ秒',
            Duration(milliseconds: 200),
            'Duration(milliseconds: 200)',
          ),
          Choice('1 秒', Duration(seconds: 1), 'Duration(seconds: 1)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'hapticFeedbackOnStart',
      typeLabel: 'bool',
      description: 'ドラッグが始まるときに端末を震わせるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'feedback',
      typeLabel: 'Widget',
      description: 'ドラッグ中に指の下に出すもの',
      required: true,
      control: FixedControl(
        value: Opacity(opacity: 0.7, child: _tile),
        source: 'Opacity(opacity: 0.7, child: Tile(1))',
      ),
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
  codeName: 'LongPressDraggable<int>',
);

const _tile = DemoTile(1, width: 48, height: 48);

// feedback・child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => DemoDropZone(
  draggable: LongPressDraggable<int>(
    data: args.valueOf<int>('data'),
    delay: args.valueOf<Duration>('delay') ?? const Duration(milliseconds: 500),
    hapticFeedbackOnStart: args.valueOf<bool>('hapticFeedbackOnStart') ?? true,
    feedback: args.valueOf<Widget>('feedback')!,
    child: args.valueOf<Widget>('child')!,
  ),
);
