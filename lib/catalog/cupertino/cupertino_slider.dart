import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSliderEntry = WidgetEntry(
  id: 'cupertinoSlider',
  name: 'CupertinoSlider',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の、つまみを動かして値を選ぶ部品',
  description:
      'min から max の間の値を、つまみを動かして選ぶ iOS の見た目のスライダーです。'
      '自分では値を持たないので、onChanged で受けた値を State に持ち、value に渡し直します。'
      'onChanged が null なら動かせない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSlider-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'double',
      description: '今の値（0.0〜1.0）。プレビューで動かすと変わる',
      required: true,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.5,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'divisions',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '段の数。指定するとつまみが段ごとに止まる',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 10,
        divisions: 9,
        initialValue: 4,
        resolve: (v) => v.toInt(),
        code: (v) => '${v.toInt()}',
      ),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'つまみより左の溝の色。指定しないとテーマの主な色',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'thumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: 'つまみの色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    const PropertySpec(
      name: 'min',
      group: PropertyGroup.behavior,
      pairsWith: ['max'],
      typeLabel: 'double',
      description: '左端の値。小さくすると、同じ value でもつまみが右へ寄る',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [Choice('0.0', 0.0, '0.0'), Choice('-1.0', -1.0, '-1.0')],
      ),
    ),
    const PropertySpec(
      name: 'max',
      group: PropertyGroup.behavior,
      pairsWith: ['min'],
      typeLabel: 'double',
      description: '右端の値。大きくすると、同じ value でもつまみが左へ寄る',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [Choice('1.0', 1.0, '1.0'), Choice('2.0', 2.0, '2.0')],
      ),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<double>?',
      description: '動かしたときに新しい値で呼ばれる。null なら動かせない見た目になる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('setState', true, '(value) => setState(() => _value = value)'),
          Choice('null', false, 'null'),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onChangeStart',
      typeLabel: 'ValueChanged<double>?',
      description: 'つまみを動かし始めたときに、その時の値で呼ばれる',
    ),
    ReferenceArg(
      name: 'onChangeEnd',
      typeLabel: 'ValueChanged<double>?',
      description: 'つまみから指を離したときに、最後の値で呼ばれる',
    ),
  ],
  build: _build,
  codeName: 'CupertinoSlider',
);

final _colors = [
  const Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen',
  ),
  const Choice(
    'systemOrange',
    CupertinoColors.systemOrange,
    'CupertinoColors.systemOrange',
  ),
  const Choice(
    'systemYellow',
    CupertinoColors.systemYellow,
    'CupertinoColors.systemYellow',
  ),
  Choice.color('墨', const Color(0xFF18181B)),
];

Widget _build(DemoArgs args) {
  final divisions = args.valueOf<int>('divisions');
  final activeColor = args.valueOf<Color>('activeColor');
  final thumbColor = args.valueOf<Color>('thumbColor') ?? CupertinoColors.white;
  // どちらも必須のプロパティなので、常に値がある
  final enabled = args.valueOf<bool>('onChanged')!;
  final min = args.valueOf<double>('min') ?? 0;
  final max = args.valueOf<double>('max') ?? 1;
  return SizedBox(
    width: 260,
    child: DemoValue<double>(
      initial: args.valueOf<double>('value')!,
      builder: (context, value, onChanged) => CupertinoSlider(
        // value は min〜max の中に収める（assert）
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
        thumbColor: thumbColor,
        onChanged: enabled ? onChanged : null,
      ),
    ),
  );
}
