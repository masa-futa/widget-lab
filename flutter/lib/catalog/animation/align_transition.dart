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

final alignTransitionEntry = WidgetEntry(
  id: 'alignTransition',
  name: 'AlignTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子の位置（Align の alignment）を動かす',
  description:
      'Align の alignment を Animation で動かします。親の広さの中で、子の位置が動いて見えます。'
      'ここでは 240×160 の枠の中に置き、左の中央から行き先へ動かします。'
      'controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AlignTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'Animation<AlignmentGeometry>',
      description: '位置の Animation。ここでは Alignment.centerLeft から行き先へ動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end) in const [
            ('centerRight', Alignment.centerRight),
            ('topRight', Alignment.topRight),
            ('bottomCenter', Alignment.bottomCenter),
          ])
            Choice(
              name,
              (Animation<double> controller) => controller.drive(
                AlignmentTween(begin: Alignment.centerLeft, end: end),
              ),
              'controller.drive(AlignmentTween('
              'begin: Alignment.centerLeft, end: Alignment.$name))',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'widthFactor',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '幅を子の幅の何倍にするか。指定しないと親の幅いっぱい',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 4,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'heightFactor',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '高さを子の高さの何倍にするか。指定しないと親の高さいっぱい',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 4,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '動かす Widget',
      required: true,
      control: FixedControl(
        value: FlutterLogo(size: 48),
        source: 'FlutterLogo(size: 48)',
      ),
    ),
  ],
  references: const [keyReference],
  build: _build,
  codeName: 'AlignTransition',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(240, 160),
  child: DemoAnimation(
    builder: (context, controller) => AlignTransition(
      alignment:
          (args.valueOf<AnimationOf<AlignmentGeometry>>('alignment') ?? _still)(
            controller,
          ),
      widthFactor: args.valueOf<double>('widthFactor'),
      heightFactor: args.valueOf<double>('heightFactor'),
      child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
    ),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<AlignmentGeometry> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(Alignment.centerLeft);
