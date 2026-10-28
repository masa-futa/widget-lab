import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'GestureTapCallback?',
      description: '押して離したときに呼ばれます。',
      control: FixedControl(value: true, source: "() => debugPrint('onTap')"),
    ),
    PropertySpec(
      name: 'onDoubleTap',
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
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'GestureDetector',
  codeArguments: const ['child: const Target()'],
);

Widget _build(DemoArgs args) {
  final onTap = args.valueOf<bool>('onTap') != null;
  final onDoubleTap = args.valueOf<bool>('onDoubleTap') != null;
  final onLongPress = args.valueOf<bool>('onLongPress') != null;
  final behavior = args.valueOf<HitTestBehavior>('behavior');
  final names = [
    if (onTap) 'onTap',
    if (onDoubleTap) 'onDoubleTap',
    if (onLongPress) 'onLongPress',
    if (behavior != null) behavior.name,
  ];
  return DemoScope(
    label: 'GestureDetector(${names.join(', ')})',
    child: Builder(
      builder: (context) {
        final recorder = DemoRecorder.of(context);
        return GestureDetector(
          behavior: behavior,
          onTap: onTap ? () => recorder.log('onTap') : null,
          onDoubleTap: onDoubleTap ? () => recorder.log('onDoubleTap') : null,
          onLongPress: onLongPress ? () => recorder.log('onLongPress') : null,
          child: const _Target(),
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
