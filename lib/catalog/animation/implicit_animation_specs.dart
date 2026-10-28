import 'package:flutter/animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';

/// 暗黙のアニメーション（Animated*）で共通の、動き方の選択肢。
const curveChoices = [
  Choice('linear', Curves.linear, 'Curves.linear'),
  Choice('easeInOut', Curves.easeInOut, 'Curves.easeInOut'),
  Choice('easeOut', Curves.easeOut, 'Curves.easeOut'),
  Choice('bounceOut', Curves.bounceOut, 'Curves.bounceOut'),
  Choice('elasticOut', Curves.elasticOut, 'Curves.elasticOut'),
];

/// 暗黙のアニメーションの `duration`（必須）。100〜2000 ミリ秒。
final durationSpec = PropertySpec(
  name: 'duration',
  typeLabel: 'Duration',
  description: '新しい値へ動くのにかける時間。ほかの値を変えると、この時間をかけて動く',
  required: true,
  control: SliderControl(
    min: 100,
    max: 2000,
    divisions: 19,
    initialValue: 600,
    resolve: (v) => Duration(milliseconds: v.round()),
    code: (v) => 'Duration(milliseconds: ${v.round()})',
  ),
);

/// 暗黙のアニメーションの `curve`。指定しないと一定の速さ（Curves.linear）。
const curveSpec = PropertySpec(
  name: 'curve',
  typeLabel: 'Curve',
  description: '動き方（速さの変わり方）。指定しないと一定の速さ（Curves.linear）',
  control: ChoiceControl(choices: curveChoices, initialIndex: 1),
);

/// [durationSpec] の値。必須なので常にある。
Duration durationOf(DemoArgs args) =>
    args.valueOf<Duration>('duration') ?? Duration.zero;

/// [curveSpec] の値。OFF なら既定の Curves.linear。
Curve curveOf(DemoArgs args) => args.valueOf<Curve>('curve') ?? Curves.linear;
