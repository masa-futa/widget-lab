import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.behavior,
      typeLabel: 'Curve',
      description: '外枠の大きさが変わるときの動き方。指定しないと一定の速さ（Curves.linear）',
      initiallyOn: false,
      control: ChoiceControl(choices: curveChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'firstCurve',
      typeLabel: 'Curve',
      description: 'firstChild が薄れる・浮かぶときの動き方。指定しないと一定の速さ（Curves.linear）',
      initiallyOn: false,
      group: PropertyGroup.behavior,
      control: ChoiceControl(choices: boundedCurveChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'secondCurve',
      typeLabel: 'Curve',
      description: 'secondChild が薄れる・浮かぶときの動き方。指定しないと一定の速さ（Curves.linear）',
      initiallyOn: false,
      group: PropertyGroup.behavior,
      control: ChoiceControl(choices: boundedCurveChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'reverseDuration',
      typeLabel: 'Duration?',
      description: 'showSecond から showFirst へ戻るときにかける時間。指定しないと duration と同じ',
      initiallyOn: false,
      group: PropertyGroup.behavior,
      control: SliderControl(
        min: 100,
        max: 2000,
        divisions: 19,
        initialValue: 1500,
        resolve: (v) => Duration(milliseconds: v.round()),
        code: (v) => 'Duration(milliseconds: ${v.round()})',
      ),
    ),
    const PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '大きさの違う 2 つの子を、外枠のどこに寄せるか。指定しないと上の中央（Alignment.topCenter）',
      initiallyOn: false,
      group: PropertyGroup.layout,
      control: ChoiceControl(
        initialIndex: alignmentCenter,
        choices: alignmentChoices,
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '外枠の大きさが動く間、はみ出す子を切り抜くか。指定しないと Clip.hardEdge',
      initiallyOn: false,
      group: PropertyGroup.transform,
      control: ChoiceControl(choices: clipChoices()),
    ),
    const PropertySpec(
      name: 'firstChild',
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
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
  references: const [
    keyReference,
    ReferenceArg(
      name: 'layoutBuilder',
      typeLabel: 'AnimatedCrossFadeBuilder',
      description: '2 つの子の重ね方を決める関数。指定しないと、見せる子の大きさに合わせて重ねる',
    ),
    ReferenceArg(
      name: 'excludeBottomFocus',
      typeLabel: 'bool',
      description: '隠れている側の子にフォーカスが移らないようにするか。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'onEnd',
      typeLabel: 'VoidCallback?',
      description: '入れ替わり終わったときに呼ばれる。見た目は変わらない',
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
  reverseDuration: args.valueOf<Duration>('reverseDuration'),
  firstCurve: args.valueOf<Curve>('firstCurve') ?? Curves.linear,
  secondCurve: args.valueOf<Curve>('secondCurve') ?? Curves.linear,
  alignment:
      args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.topCenter,
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  sizeCurve: args.valueOf<Curve>('sizeCurve') ?? Curves.linear,
  firstChild: args.valueOf<Widget>('firstChild') ?? const SizedBox.shrink(),
  secondChild: args.valueOf<Widget>('secondChild') ?? const SizedBox.shrink(),
);
