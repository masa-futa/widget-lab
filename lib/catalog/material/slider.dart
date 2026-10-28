import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliderEntry = WidgetEntry(
  id: 'slider',
  name: 'Slider',
  genreIds: const ['material'],
  summary: 'つまみを動かして、範囲の中の値を選ぶ',
  description:
      '線の上のつまみを動かして、min から max の間の値を選びます。Slider 自身は値を持たないので、'
      '動かされると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。divisions を渡すと、決まった段にだけ止まります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Slider-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      typeLabel: 'double',
      description: '今の値。min（0）から max（1）の間',
      required: true,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'onChanged',
      typeLabel: 'ValueChanged<double>?',
      description: '動かされたときに新しい値で呼ばれる。null（指定なし）だと動かせない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'divisions',
      typeLabel: 'int?',
      description: '範囲を何段に分けるか。分けると線の上に段の点が出る',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 10,
        divisions: 8,
        initialValue: 5,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'activeColor',
      typeLabel: 'Color?',
      description: 'つまみより左（選んだ側）の線とつまみの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'inactiveColor',
      typeLabel: 'Color?',
      description: 'つまみより右の線の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'Slider',
);

void _onChanged(double value) {}

Widget _build(DemoArgs args) => Slider(
  value: args.valueOf<double>('value') ?? 0,
  onChanged: args.valueOf<ValueChanged<double>>('onChanged'),
  divisions: args.valueOf<int>('divisions'),
  activeColor: args.valueOf<Color>('activeColor'),
  inactiveColor: args.valueOf<Color>('inactiveColor'),
);
