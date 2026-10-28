import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final fadeTransitionEntry = WidgetEntry(
  id: 'fadeTransition',
  name: 'FadeTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子の不透明度を変える',
  description:
      'opacity に渡した Animation の値（0 で透明、1 で不透明）で子を描きます。'
      '値が変わっても子は組み直さず、描き方だけを変えるので、Opacity を毎フレーム組み直すより軽く済みます。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FadeTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'opacity',
      typeLabel: 'Animation<double>',
      description: '不透明度の Animation。ここでは 0.2 → 1.0 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices(begin: 0.2)),
    ),
    const PropertySpec(
      name: 'alwaysIncludeSemantics',
      typeLabel: 'bool',
      description: '透明（0）のときも読み上げの対象に残すか。見た目は変わらない',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '不透明度を変えて描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
    ),
  ],
  build: _build,
  codeName: 'FadeTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => FadeTransition(
    opacity: (args.valueOf<AnimationOf<double>>('opacity') ?? linearOf)(
      controller,
    ),
    alwaysIncludeSemantics:
        args.valueOf<bool>('alwaysIncludeSemantics') ?? false,
    child: args.valueOf<Widget>('child'),
  ),
);
