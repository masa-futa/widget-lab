/// animation の収録で繰り返し使う、補足と選択肢。
library;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';

/// `key` の補足。
const keyReference = ReferenceArg(
  name: 'key',
  typeLabel: 'Key?',
  description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
);

/// 暗黙のアニメーションの `onEnd` の補足。
const onEndReference = ReferenceArg(
  name: 'onEnd',
  typeLabel: 'VoidCallback?',
  description: '新しい値へ動き終わったときに呼ばれる。見た目は変わらない',
);

/// `Clip` の選択肢（none・hardEdge・antiAlias）。
List<Choice> clipChoices() => [
  for (final clip in const [Clip.none, Clip.hardEdge, Clip.antiAlias])
    Choice(clip.name, clip, 'Clip.${clip.name}'),
];

/// 変形して描くときの `filterQuality`（Transition 系と AnimatedScale）。
PropertySpec filterQualitySpec() => PropertySpec(
  name: 'filterQuality',
  typeLabel: 'FilterQuality?',
  description: '変形して描くときの画質。指定すると子を絵にしてから変形し、none は縁がぎざぎざになる',
  initiallyOn: false,
  group: PropertyGroup.paint,
  control: ChoiceControl(
    choices: [
      for (final quality in FilterQuality.values)
        Choice(quality.name, quality, 'FilterQuality.${quality.name}'),
    ],
  ),
);
