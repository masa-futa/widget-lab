import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final checkboxEntry = WidgetEntry(
  id: 'checkbox',
  name: 'Checkbox',
  genreIds: const ['material'],
  summary: 'ON / OFF を切り替えるチェックの箱',
  description:
      'ON / OFF を切り替える四角い箱です。Checkbox 自身は値を持たないので、'
      '押されると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。onChanged を渡さないと押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Checkbox-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      typeLabel: 'bool?',
      description: 'チェックが入っているか',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onChanged',
      typeLabel: 'ValueChanged<bool?>?',
      description: '押されたときに新しい値で呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'activeColor',
      typeLabel: 'Color?',
      description: 'チェックが入っているときの箱の色。指定しないとテーマの primary',
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
      name: 'checkColor',
      typeLabel: 'Color?',
      description: 'チェックの印の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('白', const Color(0xFFFFFFFF)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'isError',
      typeLabel: 'bool',
      description: '入力の誤りを示す色（テーマの error）で描くか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'Checkbox',
);

void _onChanged(bool? value) {}

Widget _build(DemoArgs args) => Checkbox(
  value: args.valueOf<bool>('value'),
  onChanged: args.valueOf<ValueChanged<bool?>>('onChanged'),
  activeColor: args.valueOf<Color>('activeColor'),
  checkColor: args.valueOf<Color>('checkColor'),
  isError: args.valueOf<bool>('isError') ?? false,
);
