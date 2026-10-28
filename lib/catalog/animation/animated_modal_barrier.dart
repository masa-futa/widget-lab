import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 幕の色を、透明から選んだ色へ動かす Animation を作る関数。
typedef _ColorAnimation = Animation<Color?> Function(
  AnimationController controller,
);

final animatedModalBarrierEntry = WidgetEntry(
  id: 'animatedModalBarrier',
  name: 'AnimatedModalBarrier',
  genreIds: const ['animation'],
  summary: '後ろの操作をふさぐ幕。色を Animation で動かす',
  description:
      'ダイアログの後ろに敷く幕（ModalBarrier）の、色を Animation で受け取る版です。'
      '幕は下の Widget への操作をふさぎ、押すと onDismiss を呼びます。'
      'ここでは幕の色を、透明と選んだ色の間で 2 秒おきに行き来させます（controller は '
      '0 → 1 → 0 を繰り返す AnimationController）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedModalBarrier-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Animation<Color?>',
      description: '幕の色の Animation。ここでは透明と選んだ色の間を行き来する',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('墨（半透明）', Color(0x8A000000)),
            ('瑠璃（半透明）', Color(0x8A1E50A2)),
            ('紅（半透明）', Color(0x8AD7003A)),
          ])
            Choice(
              name,
              _tweenTo(color),
              'controller.drive(ColorTween(begin: Color(0x00000000), '
              'end: ${colorCode(color)}))',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'dismissible',
      typeLabel: 'bool',
      description: '幕を押したときに onDismiss を呼ぶか。false なら押しても何も起きない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'onDismiss',
      typeLabel: 'VoidCallback?',
      description:
          '幕を押したときに呼ばれる。指定しないと Navigator.maybePop で画面を閉じるので、'
          'ここでは詳細画面が閉じないように必ず渡す',
      required: true,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'AnimatedModalBarrier',
);

/// 透明から [end] へ動かす Animation を作る関数。Animation は controller を持つ
/// デモの部品の中でしか作れないので、選択肢の値は関数にする。
_ColorAnimation _tweenTo(Color end) =>
    (controller) =>
        controller.drive(ColorTween(begin: const Color(0x00000000), end: end));

void _noop() {}

Widget _build(DemoArgs args) {
  final color = args.valueOf<_ColorAnimation>('color');
  return SizedBox(
    width: 240,
    height: 160,
    child: Stack(
      fit: StackFit.expand,
      children: [
        // 幕の下の Widget（デモの部品）。幕があるので押せない
        const Center(child: FlutterLogo(size: 64)),
        DemoAnimation(
          builder: (context, controller) => AnimatedModalBarrier(
            color:
                color?.call(controller) ??
                const AlwaysStoppedAnimation<Color?>(null),
            dismissible: args.valueOf<bool>('dismissible') ?? true,
            onDismiss: args.valueOf<VoidCallback>('onDismiss'),
          ),
        ),
      ],
    ),
  );
}
