import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「DatePicker」のカード。ふつうは showDatePicker で出すダイアログを、
/// その中身の DatePickerDialog でカードの中に置いて見せる。
final datePickerEntry = WidgetEntry(
  id: 'datePicker',
  name: 'DatePicker',
  genreIds: const ['material'],
  summary: 'カレンダーか入力欄で日付を選ぶダイアログ',
  description:
      'showDatePicker で出す、日付を選ぶダイアログです。カレンダーで選ぶか、文字で入れるかを'
      '切り替えられます。ここでは中身の DatePickerDialog をカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/showDatePicker.html',
  ),
  properties: [
    PropertySpec(
      name: 'firstDate',
      typeLabel: 'DateTime',
      description: '選べる最初の日',
      required: true,
      control: FixedControl(value: DateTime(2026), source: 'DateTime(2026)'),
    ),
    PropertySpec(
      name: 'lastDate',
      typeLabel: 'DateTime',
      description: '選べる最後の日',
      required: true,
      control: FixedControl(
        value: DateTime(2026, 12, 31),
        source: 'DateTime(2026, 12, 31)',
      ),
    ),
    PropertySpec(
      name: 'initialDate',
      typeLabel: 'DateTime?',
      description: '開いたときに選んでいる日。指定しないと何も選ばない',
      control: FixedControl(
        value: DateTime(2026, 10, 28),
        source: 'DateTime(2026, 10, 28)',
      ),
    ),
    PropertySpec(
      name: 'initialEntryMode',
      typeLabel: 'DatePickerEntryMode',
      description: 'カレンダーで選ぶか（calendar）、文字で入れるか（input）。Only は切り替えのボタンを出さない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in DatePickerEntryMode.values)
            Choice(value.name, value, 'DatePickerEntryMode.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'initialCalendarMode',
      typeLabel: 'DatePickerMode',
      description: 'カレンダーで最初に出すもの。日（day）か年（year）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in DatePickerMode.values)
            Choice(value.name, value, 'DatePickerMode.${value.name}'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'DatePickerDialog',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(360, 568),
  child: DatePickerDialog(
    firstDate: args.valueOf<DateTime>('firstDate') ?? DateTime(2026),
    lastDate: args.valueOf<DateTime>('lastDate') ?? DateTime(2026, 12, 31),
    initialDate: args.valueOf<DateTime>('initialDate'),
    // 「今日」の印が日によって動かないように固定する
    currentDate: DateTime(2026, 10, 28),
    initialEntryMode:
        args.valueOf<DatePickerEntryMode>('initialEntryMode') ??
        DatePickerEntryMode.calendar,
    initialCalendarMode:
        args.valueOf<DatePickerMode>('initialCalendarMode') ??
        DatePickerMode.day,
  ),
);
