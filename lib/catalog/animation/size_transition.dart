import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Animation<double>',
      description: '見せる割合の Animation。ここでは 0.3 → 1.0 を曲線を選んで動かす',
      required: true,
      control: ChoiceControl(choices: curveChoices(begin: 0.3)),
    ),
    PropertySpec(
      name: 'axis',
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
      typeLabel: 'AlignmentGeometry?',
      description: '切り抜くときに残す側。指定しないと縮める向きの中央',
      initiallyOn: false,
      control: ChoiceControl(choices: pivotChoices()),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '切り抜いて見せる Widget',
      control: FixedControl(
        value: FlutterLogo(size: 96),
        source: 'FlutterLogo(size: 96)',
      ),
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
    child: args.valueOf<Widget>('child'),
  ),
);
