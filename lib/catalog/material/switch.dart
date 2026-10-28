import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final switchEntry = WidgetEntry(
  id: 'switch',
  name: 'Switch',
  genreIds: const ['material'],
  summary: '1 つの設定の ON / OFF を切り替える',
  description:
      '1 つの設定の ON / OFF を、つまみを左右に動かして切り替えます。Switch 自身は値を持たないので、'
      '押されると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Switch-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      typeLabel: 'bool',
      description: 'ON か',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onChanged',
      typeLabel: 'ValueChanged<bool>?',
      description: '押されたときに新しい値で呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'activeThumbColor',
      typeLabel: 'Color?',
      description: 'ON のときのつまみの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'activeTrackColor',
      typeLabel: 'Color?',
      description: 'ON のときの溝（つまみの通り道）の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'thumbIcon',
      typeLabel: 'WidgetStateProperty<Icon?>?',
      description: 'つまみの中のアイコン。状態（ON / OFF など）ごとに変えられる',
      initiallyOn: false,
      control: FixedControl(
        value: WidgetStateProperty<Icon?>.fromMap({
          WidgetState.selected: Icon(Icons.check),
          WidgetState.any: Icon(Icons.close),
        }),
        source:
            'WidgetStateProperty.fromMap({WidgetState.selected: Icon(Icons.check), '
            'WidgetState.any: Icon(Icons.close)})',
      ),
    ),
  ],
  build: _build,
  codeName: 'Switch',
);

void _onChanged(bool value) {}

Widget _build(DemoArgs args) => Switch(
  value: args.valueOf<bool>('value') ?? false,
  onChanged: args.valueOf<ValueChanged<bool>>('onChanged'),
  activeThumbColor: args.valueOf<Color>('activeThumbColor'),
  activeTrackColor: args.valueOf<Color>('activeTrackColor'),
  thumbIcon: args.valueOf<WidgetStateProperty<Icon?>>('thumbIcon'),
);
