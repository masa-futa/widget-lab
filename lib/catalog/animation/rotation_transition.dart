import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final rotationTransitionEntry = WidgetEntry(
  id: 'rotationTransition',
  name: 'RotationTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子を回す',
  description:
      'turns に渡した Animation の値を回転の数（1 で 1 回転）にして、子を回して描きます。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RotationTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'turns',
      group: PropertyGroup.transform,
      typeLabel: 'Animation<double>',
      description: '回転の数の Animation。ここでは 0 → 1（1 回転）を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices()),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.transform,
      typeLabel: 'Alignment',
      description: '回転の中心。topLeft なら左上を軸に回る',
      initiallyOn: false,
      control: ChoiceControl(initialIndex: 1, choices: pivotChoices()),
    ),
    filterQualitySpec(),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '回して描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  references: const [keyReference],
  build: _build,
  codeName: 'RotationTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => RotationTransition(
    turns: (args.valueOf<AnimationOf<double>>('turns') ?? linearOf)(controller),
    alignment: args.valueOf<Alignment>('alignment') ?? Alignment.center,
    filterQuality: args.valueOf<FilterQuality>('filterQuality'),
    child: args.valueOf<Widget>('child'),
  ),
);
