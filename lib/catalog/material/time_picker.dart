import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「TimePicker」のカード。ふつうは showTimePicker で出すダイアログを、
/// その中身の TimePickerDialog でカードの中に置いて見せる。
final timePickerEntry = WidgetEntry(
  id: 'timePicker',
  name: 'TimePicker',
  genreIds: const ['material'],
  summary: '時計の文字盤か入力欄で時刻を選ぶダイアログ',
  description:
      'showTimePicker で出す、時刻を選ぶダイアログです。時計の文字盤で選ぶか、文字で入れるかを'
      '切り替えられます。ここでは中身の TimePickerDialog をカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/showTimePicker.html',
  ),
  properties: [
    const PropertySpec(
      name: 'initialTime',
      typeLabel: 'TimeOfDay',
      description: '開いたときに選んでいる時刻',
      required: true,
      control: FixedControl(
        value: TimeOfDay(hour: 10, minute: 30),
        source: 'TimeOfDay(hour: 10, minute: 30)',
      ),
    ),
    PropertySpec(
      name: 'initialEntryMode',
      typeLabel: 'TimePickerEntryMode',
      description: '文字盤で選ぶか（dial）、文字で入れるか（input）。Only は切り替えのボタンを出さない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in TimePickerEntryMode.values)
            Choice(value.name, value, 'TimePickerEntryMode.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'orientation',
      typeLabel: 'Orientation?',
      description: '縦長（portrait）か横長（landscape）の並べ方。指定しないと画面の向きに合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in Orientation.values)
            Choice(value.name, value, 'Orientation.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'helpText',
      typeLabel: 'String?',
      description: 'ダイアログの上の小さな見出し。指定しないと「時刻を選択」など',
      initiallyOn: false,
      control: TextControl(initialValue: '起きる時刻'),
    ),
  ],
  build: _build,
  codeName: 'TimePickerDialog',
);

Widget _build(DemoArgs args) {
  final orientation = args.valueOf<Orientation>('orientation');
  return DemoStage(
    // 横長の並べ方は幅が要るので、組み立てる大きさを向きで変える
    size: orientation == Orientation.landscape
        ? const Size(640, 400)
        : const Size(360, 560),
    child: TimePickerDialog(
      initialTime:
          args.valueOf<TimeOfDay>('initialTime') ??
          const TimeOfDay(hour: 0, minute: 0),
      initialEntryMode:
          args.valueOf<TimePickerEntryMode>('initialEntryMode') ??
          TimePickerEntryMode.dial,
      orientation: orientation,
      helpText: args.valueOf<String>('helpText'),
    ),
  );
}
