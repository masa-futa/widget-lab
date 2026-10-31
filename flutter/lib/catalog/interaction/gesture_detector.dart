import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final gestureDetectorEntry = WidgetEntry(
  id: 'gestureDetector',
  name: 'GestureDetector',
  genreIds: const ['interaction'],
  summary: '子の上のタップ・長押し・ドラッグなどを受け取る',
  description:
      '子の上で起きた押す・長押し・ドラッグなどを見分けて、onTap などを呼びます。'
      '見た目は持ちません。onDoubleTap も付けると、2 回目を待つので onTap は少し遅れます。'
      '既定では子が描いた所だけで受け取り、何も描いていない所は behavior で決めます。'
      'ここでは左に文字だけがある横長の枠（何も描いていない所が右にある）を包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/GestureDetector-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'onTap',
      group: PropertyGroup.behavior,
      typeLabel: 'GestureTapCallback?',
      description: '押して離したときに呼ばれます。',
      control: FixedControl(value: true, source: "() => debugPrint('onTap')"),
    ),
    PropertySpec(
      name: 'onDoubleTap',
      group: PropertyGroup.behavior,
      typeLabel: 'GestureTapCallback?',
      description: '2 回続けて押したときに呼ばれます。付けると onTap は 2 回目を待つ分遅れます。',
      initiallyOn: false,
      control: FixedControl(
        value: true,
        source: "() => debugPrint('onDoubleTap')",
      ),
    ),
    PropertySpec(
      name: 'onLongPress',
      group: PropertyGroup.behavior,
      typeLabel: 'GestureLongPressCallback?',
      description: '長く押したときに呼ばれます（そのあと離しても onTap は呼ばれません）。',
      initiallyOn: false,
      control: FixedControl(
        value: true,
        source: "() => debugPrint('onLongPress')",
      ),
    ),
    PropertySpec(
      name: 'behavior',
      group: PropertyGroup.behavior,
      typeLabel: 'HitTestBehavior?',
      description:
          '何も描いていない所を押したときに受け取るか。deferToChild は子が描いた所だけ、'
          'opaque は自分の四角の全部で受け取ります。既定は deferToChild',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice(
            'deferToChild',
            HitTestBehavior.deferToChild,
            'HitTestBehavior.deferToChild',
          ),
          Choice('opaque', HitTestBehavior.opaque, 'HitTestBehavior.opaque'),
          Choice(
            'translucent',
            HitTestBehavior.translucent,
            'HitTestBehavior.translucent',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'supportedDevices',
      group: PropertyGroup.behavior,
      typeLabel: 'Set<PointerDeviceKind>?',
      description: '受け取る入力の種類を絞る。mouse だけにすると、指で押しても受け取らない。指定しないと全部受け取る',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('mouse だけ', {
            PointerDeviceKind.mouse,
          }, '{PointerDeviceKind.mouse}'),
          Choice('touch だけ', {
            PointerDeviceKind.touch,
          }, '{PointerDeviceKind.touch}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '包む Widget。ここでは左に文字だけがある横長の枠',
      // 子がないと、カードの中で高さが決まらず組み立てられない（見本は包む相手が要る）
      required: true,
      control: FixedControl(value: _Target(), source: 'const Target()'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onTapDown',
      typeLabel: 'GestureTapDownCallback?',
      description: '押した指が触れて、タップになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTapUp',
      typeLabel: 'GestureTapUpCallback?',
      description: 'タップとして指を離したときに、onTap の直前に呼ばれる',
    ),
    ReferenceArg(
      name: 'onTapMove',
      typeLabel: 'GestureTapMoveCallback?',
      description: '押したまま指を動かしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTapCancel',
      typeLabel: 'GestureTapCancelCallback?',
      description: '押したがタップにならなかったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryTap',
      typeLabel: 'GestureTapCallback?',
      description: 'マウスの右ボタンでクリックしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryTapDown',
      typeLabel: 'GestureTapDownCallback?',
      description: 'マウスの右ボタンを押したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryTapUp',
      typeLabel: 'GestureTapUpCallback?',
      description: 'マウスの右ボタンでクリックして離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryTapCancel',
      typeLabel: 'GestureTapCancelCallback?',
      description: 'マウスの右ボタンで押したがクリックにならなかったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryTapDown',
      typeLabel: 'GestureTapDownCallback?',
      description: 'マウスの中ボタンを押したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryTapUp',
      typeLabel: 'GestureTapUpCallback?',
      description: 'マウスの中ボタンでクリックして離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryTapCancel',
      typeLabel: 'GestureTapCancelCallback?',
      description: 'マウスの中ボタンで押したがクリックにならなかったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDoubleTapDown',
      typeLabel: 'GestureTapDownCallback?',
      description: 'ダブルタップの 2 回目に指が触れたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onDoubleTapCancel',
      typeLabel: 'GestureTapCancelCallback?',
      description: 'ダブルタップにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressDown',
      typeLabel: 'GestureLongPressDownCallback?',
      description: '押し始めて、長押しになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressCancel',
      typeLabel: 'GestureLongPressCancelCallback?',
      description: '長押しにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressStart',
      typeLabel: 'GestureLongPressStartCallback?',
      description: '長押しと決まったときに、押した位置つきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressMoveUpdate',
      typeLabel: 'GestureLongPressMoveUpdateCallback?',
      description: '長押ししたまま動かしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressUp',
      typeLabel: 'GestureLongPressUpCallback?',
      description: '長押しのあと離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onLongPressEnd',
      typeLabel: 'GestureLongPressEndCallback?',
      description: '長押しのあと離したときに、離した位置と速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressDown',
      typeLabel: 'GestureLongPressDownCallback?',
      description: 'マウスの右ボタンで押し始めて、長押しになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressCancel',
      typeLabel: 'GestureLongPressCancelCallback?',
      description: 'マウスの右ボタンで長押しにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPress',
      typeLabel: 'GestureLongPressCallback?',
      description: 'マウスの右ボタンで長押しと決まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressStart',
      typeLabel: 'GestureLongPressStartCallback?',
      description: 'マウスの右ボタンで長押しと決まったときに、押した位置つきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressMoveUpdate',
      typeLabel: 'GestureLongPressMoveUpdateCallback?',
      description: 'マウスの右ボタンで長押ししたまま動かしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressUp',
      typeLabel: 'GestureLongPressUpCallback?',
      description: 'マウスの右ボタンで長押しのあと離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onSecondaryLongPressEnd',
      typeLabel: 'GestureLongPressEndCallback?',
      description: 'マウスの右ボタンで長押しのあと離したときに、離した位置と速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressDown',
      typeLabel: 'GestureLongPressDownCallback?',
      description: 'マウスの中ボタンで押し始めて、長押しになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressCancel',
      typeLabel: 'GestureLongPressCancelCallback?',
      description: 'マウスの中ボタンで長押しにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPress',
      typeLabel: 'GestureLongPressCallback?',
      description: 'マウスの中ボタンで長押しと決まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressStart',
      typeLabel: 'GestureLongPressStartCallback?',
      description: 'マウスの中ボタンで長押しと決まったときに、押した位置つきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressMoveUpdate',
      typeLabel: 'GestureLongPressMoveUpdateCallback?',
      description: 'マウスの中ボタンで長押ししたまま動かしたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressUp',
      typeLabel: 'GestureLongPressUpCallback?',
      description: 'マウスの中ボタンで長押しのあと離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onTertiaryLongPressEnd',
      typeLabel: 'GestureLongPressEndCallback?',
      description: 'マウスの中ボタンで長押しのあと離したときに、離した位置と速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onVerticalDragDown',
      typeLabel: 'GestureDragDownCallback?',
      description: '押し始めて、縦のドラッグになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onVerticalDragStart',
      typeLabel: 'GestureDragStartCallback?',
      description: '縦のドラッグが始まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onVerticalDragUpdate',
      typeLabel: 'GestureDragUpdateCallback?',
      description: '縦のドラッグで指が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'onVerticalDragEnd',
      typeLabel: 'GestureDragEndCallback?',
      description: '縦のドラッグで指を離したときに、離した速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onVerticalDragCancel',
      typeLabel: 'GestureDragCancelCallback?',
      description: '縦のドラッグにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onHorizontalDragDown',
      typeLabel: 'GestureDragDownCallback?',
      description: '押し始めて、横のドラッグになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onHorizontalDragStart',
      typeLabel: 'GestureDragStartCallback?',
      description: '横のドラッグが始まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onHorizontalDragUpdate',
      typeLabel: 'GestureDragUpdateCallback?',
      description: '横のドラッグで指が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'onHorizontalDragEnd',
      typeLabel: 'GestureDragEndCallback?',
      description: '横のドラッグで指を離したときに、離した速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onHorizontalDragCancel',
      typeLabel: 'GestureDragCancelCallback?',
      description: '横のドラッグにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onForcePressStart',
      typeLabel: 'GestureForcePressStartCallback?',
      description: '強く押し込んだときに呼ばれる（感圧に対応した端末だけ）',
    ),
    ReferenceArg(
      name: 'onForcePressPeak',
      typeLabel: 'GestureForcePressPeakCallback?',
      description: 'いちばん強く押し込んだときに呼ばれる（感圧に対応した端末だけ）',
    ),
    ReferenceArg(
      name: 'onForcePressUpdate',
      typeLabel: 'GestureForcePressUpdateCallback?',
      description: '押し込む強さが変わるたびに呼ばれる（感圧に対応した端末だけ）',
    ),
    ReferenceArg(
      name: 'onForcePressEnd',
      typeLabel: 'GestureForcePressEndCallback?',
      description: '強く押し込んだあと、指を離したときに呼ばれる（感圧に対応した端末だけ）',
    ),
    ReferenceArg(
      name: 'onPanDown',
      typeLabel: 'GestureDragDownCallback?',
      description: '押し始めて、どの向きにも動くドラッグになりそうなときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onPanStart',
      typeLabel: 'GestureDragStartCallback?',
      description: 'どの向きにも動くドラッグが始まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onPanUpdate',
      typeLabel: 'GestureDragUpdateCallback?',
      description: 'どの向きにも動くドラッグで指が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'onPanEnd',
      typeLabel: 'GestureDragEndCallback?',
      description: 'どの向きにも動くドラッグで指を離したときに、離した速さつきで呼ばれる',
    ),
    ReferenceArg(
      name: 'onPanCancel',
      typeLabel: 'GestureDragCancelCallback?',
      description: 'どの向きにも動くドラッグにならずに終わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onScaleStart',
      typeLabel: 'GestureScaleStartCallback?',
      description: '2 本指でつまむ（拡大・縮小・回転）動きが始まったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onScaleUpdate',
      typeLabel: 'GestureScaleUpdateCallback?',
      description: 'つまむ動きの途中、指が動くたびに呼ばれる',
    ),
    ReferenceArg(
      name: 'onScaleEnd',
      typeLabel: 'GestureScaleEndCallback?',
      description: 'つまむ動きで指を離したときに呼ばれる',
    ),
    ReferenceArg(
      name: 'excludeFromSemantics',
      typeLabel: 'bool',
      description: '読み上げなどの支援技術に、押せることを知らせないようにするか。既定は false',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグの始まりを、指が触れた所にするか、動き出した所にするか',
    ),
    ReferenceArg(
      name: 'trackpadScrollCausesScale',
      typeLabel: 'bool',
      description: 'トラックパッドの 2 本指のスクロールを、拡大・縮小として扱うか。既定は false',
    ),
    ReferenceArg(
      name: 'trackpadScrollToScaleFactor',
      typeLabel: 'Offset',
      description: 'トラックパッドのスクロールの量を、拡大・縮小の倍率に換える係数',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'GestureDetector',
);

Widget _build(DemoArgs args) {
  final onTap = args.valueOf<bool>('onTap') != null;
  final onDoubleTap = args.valueOf<bool>('onDoubleTap') != null;
  final onLongPress = args.valueOf<bool>('onLongPress') != null;
  final behavior = args.valueOf<HitTestBehavior>('behavior');
  final supportedDevices = args.valueOf<Set<PointerDeviceKind>>(
    'supportedDevices',
  );
  final names = [
    if (onTap) 'onTap',
    if (onDoubleTap) 'onDoubleTap',
    if (onLongPress) 'onLongPress',
    if (behavior != null) behavior.name,
    if (supportedDevices != null)
      supportedDevices.map((kind) => kind.name).join('・'),
  ];
  return DemoScope(
    label: 'GestureDetector(${names.join(', ')})',
    child: Builder(
      builder: (context) {
        final recorder = DemoRecorder.of(context);
        return GestureDetector(
          behavior: behavior,
          supportedDevices: supportedDevices,
          onTap: onTap ? () => recorder.log('onTap') : null,
          onDoubleTap: onDoubleTap ? () => recorder.log('onDoubleTap') : null,
          onLongPress: onLongPress ? () => recorder.log('onLongPress') : null,
          child: args.valueOf<Widget>('child'),
        );
      },
    ),
  );
}

/// 包みを外す。押しても何も起きない。
Widget _buildWithout(DemoArgs args) => const DemoFit(child: _Target());

/// 左に文字だけがある横長の枠。右は何も描いていない。
class _Target extends StatelessWidget {
  const _Target();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 48,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text('文字のところ'),
    ),
  );
}
