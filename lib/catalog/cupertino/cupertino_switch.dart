import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSwitchEntry = WidgetEntry(
  id: 'cupertinoSwitch',
  name: 'CupertinoSwitch',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のオン・オフのスイッチ',
  description:
      'iOS の見た目のスイッチです。自分では値を持たないので、onChanged で受けた値を'
      'State に持ち、value に渡し直します。onChanged が null なら押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSwitch-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      typeLabel: 'bool',
      description: 'オンか。プレビューで押すと変わる',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'activeTrackColor',
      typeLabel: 'Color?',
      description: 'オンのときの溝の色。指定しないと systemGreen',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'inactiveTrackColor',
      typeLabel: 'Color?',
      description: 'オフのときの溝の色',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 3),
    ),
    PropertySpec(
      name: 'thumbColor',
      typeLabel: 'Color?',
      description: 'つまみの色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    const PropertySpec(
      name: 'onChanged',
      typeLabel: 'ValueChanged<bool>?',
      description: '押したときに新しい値で呼ばれる。null なら押せない見た目になる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('setState', true, '(value) => setState(() => _on = value)'),
          Choice('null', false, 'null'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoSwitch',
);

final _colors = [
  const Choice(
    'activeBlue',
    CupertinoColors.activeBlue,
    'CupertinoColors.activeBlue',
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
  final activeTrackColor = args.valueOf<Color>('activeTrackColor');
  final inactiveTrackColor = args.valueOf<Color>('inactiveTrackColor');
  final thumbColor = args.valueOf<Color>('thumbColor');
  // どちらも必須のプロパティなので、常に値がある
  final enabled = args.valueOf<bool>('onChanged')!;
  return DemoValue<bool>(
    initial: args.valueOf<bool>('value')!,
    builder: (context, value, onChanged) => CupertinoSwitch(
      value: value,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      onChanged: enabled ? onChanged : null,
    ),
  );
}
