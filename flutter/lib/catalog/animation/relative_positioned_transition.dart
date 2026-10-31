import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 始まりの四角（左上の 80×80）。どの選択肢もここから動かす。
const _begin = Rect.fromLTWH(0, 0, 80, 80);

final relativePositionedTransitionEntry = WidgetEntry(
  id: 'relativePositionedTransition',
  name: 'RelativePositionedTransition',
  genreIds: const ['animation'],
  summary: 'Animation の四角（Rect）に合わせて、Stack の中で子の位置と大きさを動かす',
  description:
      'Animation の Rect（左上の点と大きさ）を、size の広さを基準にした位置にして、'
      'Stack の中の子を動かします。PositionedTransition が四辺からの距離で書くのに対し、'
      'こちらは四角そのものを書きます。ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RelativePositionedTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'rect',
      group: PropertyGroup.layout,
      typeLabel: 'Animation<Rect?>',
      description: '四角の Animation。ここでは Rect.fromLTWH(0, 0, 80, 80) から動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end, code) in const [
            (
              '右下へ',
              Rect.fromLTWH(160, 80, 80, 80),
              'Rect.fromLTWH(160, 80, 80, 80)',
            ),
            (
              '横に伸びる',
              Rect.fromLTWH(0, 0, 240, 80),
              'Rect.fromLTWH(0, 0, 240, 80)',
            ),
            (
              '中央で小さく',
              Rect.fromLTWH(100, 60, 40, 40),
              'Rect.fromLTWH(100, 60, 40, 40)',
            ),
          ])
            Choice(
              name,
              (Animation<double> controller) =>
                  controller.drive(RectTween(begin: _begin, end: end)),
              'controller.drive(RectTween('
              'begin: Rect.fromLTWH(0, 0, 80, 80), end: $code))',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'size',
      group: PropertyGroup.size,
      typeLabel: 'Size',
      description: 'rect の基準にする広さ。Stack の大きさと同じにすると、rect がそのまま位置になる',
      required: true,
      control: FixedControl(value: Size(240, 160), source: 'Size(240, 160)'),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '動かす Widget。rect の大きさに広げられる',
      required: true,
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  references: const [keyReference],
  build: _build,
  codeName: 'RelativePositionedTransition',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 160),
  child: DemoAnimation(
    builder: (context, controller) => Stack(
      children: [
        RelativePositionedTransition(
          rect: (args.valueOf<AnimationOf<Rect?>>('rect') ?? _still)(
            controller,
          ),
          size: args.valueOf<Size>('size') ?? const Size(240, 160),
          child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
        ),
      ],
    ),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<Rect?> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(_begin);
