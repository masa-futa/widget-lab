import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final matrixTransitionEntry = WidgetEntry(
  id: 'matrixTransition',
  name: 'MatrixTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値から作った行列（Matrix4）で、子を変形する',
  description:
      'animation の値を onTransform で Matrix4 にして、子を変形して描きます。'
      'RotationTransition・ScaleTransition はこれの特別な形で、奥行きのある回転のように'
      '自由な変形を動かしたいときに使います。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/MatrixTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'animation',
      group: PropertyGroup.transform,
      typeLabel: 'Animation<double>',
      description: 'onTransform に渡す値の Animation。ここでは 0 → 1 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices()),
    ),
    const PropertySpec(
      name: 'onTransform',
      group: PropertyGroup.transform,
      typeLabel: 'Matrix4 Function(double)',
      description: 'animation の値から、子にかける行列を作る関数',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '奥へ回す（Y 軸）',
            _rotateY,
            '(value) => Matrix4.identity()..setEntry(3, 2, 0.002)'
                '..rotateY(value * math.pi)',
          ),
          Choice(
            '平らに回す（Z 軸）',
            _rotateZ,
            '(value) => Matrix4.rotationZ(value * math.pi)',
          ),
          Choice('傾ける', _skew, '(value) => Matrix4.skewX(value * 0.5)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.transform,
      typeLabel: 'Alignment',
      description: '変形の中心。topLeft なら左上を止めたまま変形する',
      initiallyOn: false,
      control: ChoiceControl(initialIndex: 1, choices: pivotChoices()),
    ),
    filterQualitySpec(),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '変形して描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  references: const [keyReference],
  build: _build,
  codeName: 'MatrixTransition',
);

/// 奥行き（遠近）を付けて、縦の軸で回す。
Matrix4 _rotateY(double value) => Matrix4.identity()
  ..setEntry(3, 2, 0.002)
  ..rotateY(value * math.pi);

Matrix4 _rotateZ(double value) => Matrix4.rotationZ(value * math.pi);

Matrix4 _skew(double value) => Matrix4.skewX(value * 0.5);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => MatrixTransition(
    animation: (args.valueOf<AnimationOf<double>>('animation') ?? linearOf)(
      controller,
    ),
    onTransform:
        args.valueOf<Matrix4 Function(double)>('onTransform') ?? _rotateY,
    alignment: args.valueOf<Alignment>('alignment') ?? Alignment.center,
    filterQuality: args.valueOf<FilterQuality>('filterQuality'),
    child: args.valueOf<Widget>('child'),
  ),
);
