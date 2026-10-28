import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 始まりの飾り。どの選択肢もここから動かす。
const _begin = BoxDecoration(color: Color(0xFF1E50A2));

final decoratedBoxTransitionEntry = WidgetEntry(
  id: 'decoratedBoxTransition',
  name: 'DecoratedBoxTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子の後ろ（か前）の飾りを変える',
  description:
      'decoration に渡した Animation の Decoration（色・角丸・影など）で、子の後ろか前を飾ります。'
      'ふつうは DecorationTween で 2 つの BoxDecoration のあいだを動かします。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DecoratedBoxTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'decoration',
      typeLabel: 'Animation<Decoration>',
      description: '飾りの Animation。ここでは瑠璃色の四角（BoxDecoration(color: Color(0xFF1E50A2))）から動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end, code) in const [
            (
              '色が変わる',
              BoxDecoration(color: Color(0xFFF8B500)),
              'BoxDecoration(color: Color(0xFFF8B500))',
            ),
            (
              '角が丸くなる',
              BoxDecoration(
                color: Color(0xFF1E50A2),
                borderRadius: BorderRadius.all(Radius.circular(48)),
              ),
              'BoxDecoration(color: Color(0xFF1E50A2), '
                  'borderRadius: BorderRadius.all(Radius.circular(48)))',
            ),
            (
              '影が付く',
              BoxDecoration(
                color: Color(0xFF1E50A2),
                boxShadow: [BoxShadow(blurRadius: 24, offset: Offset(0, 12))],
              ),
              'BoxDecoration(color: Color(0xFF1E50A2), '
                  'boxShadow: [BoxShadow(blurRadius: 24, offset: Offset(0, 12))])',
            ),
          ])
            Choice(
              name,
              (Animation<double> controller) =>
                  controller.drive(DecorationTween(begin: _begin, end: end)),
              'controller.drive(DecorationTween('
              'begin: BoxDecoration(color: Color(0xFF1E50A2)), end: $code))',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'position',
      typeLabel: 'DecorationPosition',
      description: '飾りを子の後ろ（background）に描くか、前（foreground）に描くか',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in DecorationPosition.values)
            Choice(value.name, value, 'DecorationPosition.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '飾る Widget。飾りはこの大きさに描かれる',
      required: true,
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  build: _build,
  codeName: 'DecoratedBoxTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => DecoratedBoxTransition(
    decoration: (args.valueOf<AnimationOf<Decoration>>('decoration') ?? _still)(
      controller,
    ),
    position:
        args.valueOf<DecorationPosition>('position') ??
        DecorationPosition.background,
    child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<Decoration> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(_begin);
