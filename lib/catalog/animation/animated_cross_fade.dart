import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedCrossFadeEntry = WidgetEntry(
  id: 'animatedCrossFade',
  name: 'AnimatedCrossFade',
  genreIds: const ['animation'],
  summary: '2 つの子を、重ねて薄れさせながら入れ替える',
  description:
      'firstChild と secondChild のどちらを見せるかを crossFadeState で決めます。'
      '切り替えると、片方を薄れさせながらもう片方を浮かび上がらせ、'
      '大きさが違えば外枠の大きさも合わせて動かします。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedCrossFade-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'crossFadeState',
      typeLabel: 'CrossFadeState',
      description: 'どちらの子を見せるか。変えると入れ替わる',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final value in CrossFadeState.values)
            Choice(value.name, value, 'CrossFadeState.${value.name}'),
        ],
      ),
    ),
    durationSpec,
    const PropertySpec(
      name: 'sizeCurve',
      typeLabel: 'Curve',
      description: '外枠の大きさが変わるときの動き方。指定しないと一定の速さ（Curves.linear）',
      initiallyOn: false,
      control: ChoiceControl(choices: curveChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'firstChild',
      typeLabel: 'Widget',
      description: 'CrossFadeState.showFirst のときに見せる子',
      required: true,
      control: FixedControl(
        value: FlutterLogo(size: 48),
        source: 'FlutterLogo(size: 48)',
      ),
    ),
    const PropertySpec(
      name: 'secondChild',
      typeLabel: 'Widget',
      description: 'CrossFadeState.showSecond のときに見せる子。大きさが違うと外枠も動く',
      required: true,
      control: FixedControl(
        value: SizedBox(
          width: 160,
          height: 96,
          child: ColoredBox(color: Color(0xFF68BE8D)),
        ),
        source:
            'SizedBox(width: 160, height: 96, '
            'child: ColoredBox(color: Color(0xFF68BE8D)))',
      ),
    ),
  ],
  build: _build,
  codeName: 'AnimatedCrossFade',
);

Widget _build(DemoArgs args) => AnimatedCrossFade(
  crossFadeState:
      args.valueOf<CrossFadeState>('crossFadeState') ??
      CrossFadeState.showFirst,
  duration: durationOf(args),
  sizeCurve: args.valueOf<Curve>('sizeCurve') ?? Curves.linear,
  firstChild: args.valueOf<Widget>('firstChild') ?? const SizedBox.shrink(),
  secondChild: args.valueOf<Widget>('secondChild') ?? const SizedBox.shrink(),
);
