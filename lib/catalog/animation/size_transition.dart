import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sizeTransitionEntry = WidgetEntry(
  id: 'sizeTransition',
  name: 'SizeTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子の見える高さか幅を変える',
  description:
      'sizeFactor に渡した Animation の値（0〜1）の割合だけ、子を切り抜いて見せます。'
      'ScaleTransition と違って自分の大きさも変わるので、まわりのレイアウトも動きます。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SizeTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'sizeFactor',
      group: PropertyGroup.size,
      typeLabel: 'Animation<double>',
      description: '見せる割合の Animation。ここでは 0.3 → 1.0 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices(begin: 0.3)),
    ),
    PropertySpec(
      name: 'axis',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '縮める向き。vertical は高さ、horizontal は幅',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in Axis.values)
            Choice(value.name, value, 'Axis.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry?',
      description: '切り抜くときに残す側。指定しないと縮める向きの中央',
      initiallyOn: false,
      control: ChoiceControl(choices: pivotChoices()),
    ),
    const PropertySpec(
      name: 'fixedCrossAxisSizeFactor',
      typeLabel: 'double?',
      description: '縮めない向きの大きさを、子の何倍に決めるか。指定しないと子の大きさのまま',
      initiallyOn: false,
      group: PropertyGroup.size,
      control: SliderControl(
        min: 0.5,
        max: 1.5,
        divisions: 2,
        initialValue: 0.5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '切り抜いて見せる Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  references: const [
    keyReference,
    ReferenceArg(
      name: 'axisAlignment',
      typeLabel: 'double?',
      description: '非推奨。代わりに alignment を使う',
    ),
  ],
  build: _build,
  codeName: 'SizeTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => SizeTransition(
    sizeFactor: (args.valueOf<AnimationOf<double>>('sizeFactor') ?? linearOf)(
      controller,
    ),
    axis: args.valueOf<Axis>('axis') ?? Axis.vertical,
    alignment: args.valueOf<AlignmentGeometry>('alignment'),
    fixedCrossAxisSizeFactor: args.valueOf<double>('fixedCrossAxisSizeFactor'),
    child: args.valueOf<Widget>('child'),
  ),
);
