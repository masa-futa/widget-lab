import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// デモの RadioGroup が選んでいる値（コードには出さない）。
const _groupValue = 1;

final radioEntry = WidgetEntry(
  id: 'radio',
  name: 'Radio',
  genreIds: const ['material'],
  summary: 'いくつかの中から 1 つを選ぶ丸いボタン',
  description:
      'いくつかの中から 1 つだけを選ぶ丸いボタンです。選んでいる値と押されたときの処理は、'
      '上に置く RadioGroup（groupValue・onChanged）がまとめて持ち、'
      'Radio は自分の value が groupValue と同じなら選んだ見た目になります。'
      'ここでは RadioGroup の groupValue を 1 にしています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Radio-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      typeLabel: 'T',
      description: 'この Radio が表す値。RadioGroup の groupValue（ここでは 1）と同じなら選んだ見た目',
      required: true,
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 1,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      typeLabel: 'bool?',
      description: '押せるか。指定しないと RadioGroup があれば押せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'activeColor',
      typeLabel: 'Color?',
      description: '選んでいるときの色。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'toggleable',
      typeLabel: 'bool',
      description: '選んでいるときにもう一度押すと、選択を外せる（groupValue が null になる）か',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'Radio<int>',
);

void _onChanged(int? value) {}

/// Radio は RadioGroup の下に置く。RadioGroup はデモの部品（コードには出さない）。
Widget _build(DemoArgs args) => RadioGroup<int>(
  groupValue: _groupValue,
  onChanged: _onChanged,
  child: Radio<int>(
    value: args.valueOf<int>('value') ?? 0,
    enabled: args.valueOf<bool>('enabled'),
    activeColor: args.valueOf<Color>('activeColor'),
    toggleable: args.valueOf<bool>('toggleable') ?? false,
  ),
);
