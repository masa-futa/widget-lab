import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final slideTransitionEntry = WidgetEntry(
  id: 'slideTransition',
  name: 'SlideTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子をずらす',
  description:
      'position に渡した Animation の Offset の分だけ、子をずらして描きます。'
      'Offset は子の大きさを 1 とした割合で、Offset(1, 0) なら子の幅 1 つ分右へずれます。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SlideTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'position',
      typeLabel: 'Animation<Offset>',
      description: 'ずらす量の Animation。ここでは Offset.zero から行き先へ動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end) in const [
            ('右へ', Offset(1, 0)),
            ('下へ', Offset(0, 1)),
            ('左上へ', Offset(-1, -1)),
          ])
            Choice(
              name,
              (Animation<double> controller) =>
                  controller.drive(Tween<Offset>(begin: Offset.zero, end: end)),
              'controller.drive(Tween(begin: Offset.zero, '
              'end: Offset(${end.dx}, ${end.dy})))',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'transformHitTests',
      typeLabel: 'bool',
      description: '押せる範囲もずらすか。false だと、見た目だけ動いて押せる範囲は元の場所に残る',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'ずらして描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 64),
        source: 'FlutterLogo(size: 64)',
      ),
    ),
  ],
  build: _build,
  codeName: 'SlideTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => SlideTransition(
    position: (args.valueOf<AnimationOf<Offset>>('position') ?? _still)(
      controller,
    ),
    transformHitTests: args.valueOf<bool>('transformHitTests') ?? true,
    child: args.valueOf<Widget>('child'),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<Offset> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(Offset.zero);
