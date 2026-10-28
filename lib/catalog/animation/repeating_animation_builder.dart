import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final repeatingAnimationBuilderEntry = WidgetEntry(
  id: 'repeatingAnimationBuilder',
  name: 'RepeatingAnimationBuilder',
  genreIds: const ['animation'],
  summary: 'AnimationController を書かずに、動きをずっと繰り返す',
  description:
      'animatable の値を duration かけて進め、それをずっと繰り返します。'
      'AnimationController を自分で作らずに済みます。builder は値が進むたびに呼ばれ、'
      'child は一度だけ作って渡されます。paused で止められます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RepeatingAnimationBuilder-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'animatable',
      typeLabel: 'Animatable<T>',
      description: '進める値。ここでは回転の量（1 で 1 回転）',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '1 回転',
            Tween<double>(begin: 0, end: 1),
            'Tween<double>(begin: 0, end: 1)',
          ),
          Choice(
            '4 分の 1 回転',
            Tween<double>(begin: 0, end: 0.25),
            'Tween<double>(begin: 0, end: 0.25)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'duration',
      typeLabel: 'Duration',
      description: '1 回分にかける時間',
      required: true,
      control: SliderControl(
        min: 500,
        max: 4000,
        divisions: 7,
        initialValue: 2000,
        resolve: (v) => Duration(milliseconds: v.round()),
        code: (v) => 'Duration(milliseconds: ${v.round()})',
      ),
    ),
    PropertySpec(
      name: 'repeatMode',
      typeLabel: 'RepeatMode',
      description: 'restart は終わると最初に戻り、reverse は行って戻るを繰り返す',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in RepeatMode.values)
            Choice(value.name, value, 'RepeatMode.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'paused',
      typeLabel: 'bool',
      description: 'true にすると、その位置で止まる。false に戻すと続きから動く',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'RepeatingAnimationBuilder<double>',
  codeArguments: const [
    'builder: (context, value, child) => Transform.rotate(\n'
        '    angle: value * 2 * pi,\n'
        '    child: child,\n'
        '  )',
    'child: const FlutterLogo(size: 48)',
  ],
);

Widget _build(DemoArgs args) => RepeatingAnimationBuilder<double>(
  animatable:
      args.valueOf<Animatable<double>>('animatable') ??
      Tween<double>(begin: 0, end: 1),
  duration:
      args.valueOf<Duration>('duration') ?? const Duration(milliseconds: 2000),
  repeatMode: args.valueOf<RepeatMode>('repeatMode') ?? RepeatMode.restart,
  paused: args.valueOf<bool>('paused') ?? false,
  builder: (context, value, child) =>
      Transform.rotate(angle: value * 2 * math.pi, child: child),
  child: const FlutterLogo(size: 48),
);
