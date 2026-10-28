import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final scaleTransitionEntry = WidgetEntry(
  id: 'scaleTransition',
  name: 'ScaleTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子を拡大・縮小する',
  description:
      'scale に渡した Animation の値を倍率にして、子を拡大・縮小して描きます。'
      '大きさが変わって見えるだけで、まわりのレイアウトは動きません。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ScaleTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'scale',
      typeLabel: 'Animation<double>',
      description: '倍率の Animation。ここでは 0.5 → 1.0 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices(begin: 0.5)),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'Alignment',
      description: '拡大・縮小の中心。topLeft なら左上を止めたまま大きさが変わる',
      initiallyOn: false,
      control: ChoiceControl(initialIndex: 1, choices: pivotChoices()),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '拡大・縮小して描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  build: _build,
  codeName: 'ScaleTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => ScaleTransition(
    scale: (args.valueOf<AnimationOf<double>>('scale') ?? linearOf)(controller),
    alignment: args.valueOf<Alignment>('alignment') ?? Alignment.center,
    child: args.valueOf<Widget>('child'),
  ),
);
