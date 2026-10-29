import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_drop_zone.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.behavior,
      typeLabel: 'T?',
      description: '落とした先に渡す値',
      control: FixedControl(value: 1, source: '1'),
    ),
    PropertySpec(
      name: 'childWhenDragging',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ドラッグ中に元の場所に出すもの。指定しないと子のまま',
      initiallyOn: false,
      control: FixedControl(value: _hole, source: _holeCode),
    ),
    PropertySpec(
      name: 'axis',
      group: PropertyGroup.behavior,
      typeLabel: 'Axis?',
      description: '動かせる向きを 1 つに絞る。指定しないとどの向きにも動かせる',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'feedbackOffset',
      group: PropertyGroup.behavior,
      typeLabel: 'Offset',
      description:
          '落とす先を探す点を、指の位置からずらす量。feedback をずらして出すときに合わせる。既定は Offset.zero',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('上へ 48', Offset(0, -48), 'Offset(0, -48)')],
      ),
    ),
    PropertySpec(
      name: 'dragAnchorStrategy',
      group: PropertyGroup.layout,
      typeLabel: 'DragAnchorStrategy',
      description: 'feedback を指に対してどこに出すか。pointer は指の位置に feedback の左上を合わせる。既定は child（子と同じ位置から動かす）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'pointer',
            pointerDragAnchorStrategy,
            'pointerDragAnchorStrategy',
          ),
          Choice('child', childDragAnchorStrategy, 'childDragAnchorStrategy'),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxSimultaneousDrags',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '同時にできるドラッグの数。0 にするとドラッグできない。指定しないと何本の指でもドラッグできる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('0', 0, '0'), Choice('1', 1, '1')],
      ),
    ),
    PropertySpec(
      name: 'delay',
      group: PropertyGroup.behavior,
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
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'ドラッグが始まるときに端末を震わせるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'feedback',
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'ドラッグする前に見えているもの',
      required: true,
      control: FixedControl(value: _tile, source: 'Tile(1)'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onDragStarted',
      typeLabel: 'VoidCallback?',
      description: 'ドラッグが始まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDragUpdate',
      typeLabel: 'DragUpdateCallback?',
      description: 'ドラッグ中に指が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDraggableCanceled',
      typeLabel: 'DraggableCanceledCallback?',
      description: '受け取られずに離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDragEnd',
      typeLabel: 'DragEndCallback?',
      description: '受け取られたかどうかにかかわらず、離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDragCompleted',
      typeLabel: 'VoidCallback?',
      description: 'DragTarget に受け取られたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'ignoringFeedbackSemantics',
      typeLabel: 'bool',
      description: 'ドラッグ中の feedback を読み上げの対象から外すか。既定は true',
    ),
    ReferenceArg(
      name: 'ignoringFeedbackPointer',
      typeLabel: 'bool',
      description: 'ドラッグ中の feedback が押す操作を受けないようにするか。既定は true',
    ),
    ReferenceArg(
      name: 'allowedButtonsFilter',
      typeLabel: 'AllowedButtonsFilter?',
      description: 'ドラッグを始められるマウスのボタンを絞る',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: 'ドラッグを始める当たり判定のしかた。見本の箱は全面を塗っているので違いは出ない',
    ),
    ReferenceArg(
      name: 'rootOverlay',
      typeLabel: 'bool',
      description: 'feedback を一番外側の Overlay に出すか。見本では Overlay が 1 つなので違いは出ない',
    ),
  ],
  build: _build,
  codeName: 'LongPressDraggable<int>',
);

const _tile = DemoTile(1, width: 48, height: 48);
const _hole = DemoDropArea(highlighted: false, label: '');
const _holeCode = 'const Hole()';

// feedback・child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => DemoDropZone(
  draggable: LongPressDraggable<int>(
    data: args.valueOf<int>('data'),
    childWhenDragging: args.valueOf<Widget>('childWhenDragging'),
    axis: args.valueOf<Axis>('axis'),
    feedbackOffset: args.valueOf<Offset>('feedbackOffset') ?? Offset.zero,
    dragAnchorStrategy:
        args.valueOf<DragAnchorStrategy>('dragAnchorStrategy') ??
        childDragAnchorStrategy,
    maxSimultaneousDrags: args.valueOf<int>('maxSimultaneousDrags'),
    delay: args.valueOf<Duration>('delay') ?? const Duration(milliseconds: 500),
    hapticFeedbackOnStart: args.valueOf<bool>('hapticFeedbackOnStart') ?? true,
    feedback: args.valueOf<Widget>('feedback')!,
    child: args.valueOf<Widget>('child')!,
  ),
);
