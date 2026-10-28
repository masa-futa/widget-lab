import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Color?',
      description: 'つまみより左の溝の色。指定しないとテーマの主な色',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'thumbColor',
      typeLabel: 'Color',
      description: 'つまみの色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    const PropertySpec(
      name: 'onChanged',
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
  return SizedBox(
    width: 260,
    child: DemoValue<double>(
      initial: args.valueOf<double>('value')!,
      builder: (context, value, onChanged) => CupertinoSlider(
        value: value,
        divisions: divisions,
        activeColor: activeColor,
        thumbColor: thumbColor,
        onChanged: enabled ? onChanged : null,
      ),
    ),
  );
}
