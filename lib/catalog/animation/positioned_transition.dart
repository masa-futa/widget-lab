import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 始まりの位置（240×160 の Stack の左上の 80×80）。どの選択肢もここから動かす。
const _begin = RelativeRect.fromLTRB(0, 0, 160, 80);

final positionedTransitionEntry = WidgetEntry(
  id: 'positionedTransition',
  name: 'PositionedTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、Stack の中で子の位置と大きさを動かす',
  description:
      'Positioned の位置（Stack の四辺からの距離。RelativeRect）を Animation で動かします。'
      'Stack の子として置きます。ここでは 240×160 の Stack の左上の 80×80 から動かします。'
      'controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/PositionedTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'rect',
      typeLabel: 'Animation<RelativeRect>',
      description:
          '位置の Animation。ここでは RelativeRect.fromLTRB(0, 0, 160, 80) から動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end, code) in const [
            (
              '右下へ',
              RelativeRect.fromLTRB(160, 80, 0, 0),
              'RelativeRect.fromLTRB(160, 80, 0, 0)',
            ),
            (
              '右へ',
              RelativeRect.fromLTRB(160, 0, 0, 80),
              'RelativeRect.fromLTRB(160, 0, 0, 80)',
            ),
            ('全体に広がる', RelativeRect.fill, 'RelativeRect.fill'),
          ])
            Choice(
              name,
              (Animation<double> controller) =>
                  controller.drive(RelativeRectTween(begin: _begin, end: end)),
              'controller.drive(RelativeRectTween('
              'begin: RelativeRect.fromLTRB(0, 0, 160, 80), end: $code))',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '動かす Widget。rect の大きさに広げられる',
      required: true,
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  build: _build,
  codeName: 'PositionedTransition',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 160),
  child: DemoAnimation(
    builder: (context, controller) => Stack(
      children: [
        PositionedTransition(
          rect: (args.valueOf<AnimationOf<RelativeRect>>('rect') ?? _still)(
            controller,
          ),
          child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
        ),
      ],
    ),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<RelativeRect> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(_begin);
