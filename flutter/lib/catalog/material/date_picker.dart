import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.behavior,
      typeLabel: 'DateTime',
      description: '選べる最初の日',
      required: true,
      control: FixedControl(value: DateTime(2026), source: 'DateTime(2026)'),
    ),
    PropertySpec(
      name: 'lastDate',
      group: PropertyGroup.behavior,
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
      group: PropertyGroup.content,
      typeLabel: 'DateTime?',
      description: '開いたときに選んでいる日。指定しないと何も選ばない',
      control: FixedControl(
        value: DateTime(2026, 10, 28),
        source: 'DateTime(2026, 10, 28)',
      ),
    ),
    PropertySpec(
      name: 'initialEntryMode',
      group: PropertyGroup.layout,
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
      group: PropertyGroup.layout,
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
    PropertySpec(
      name: 'currentDate',
      group: PropertyGroup.content,
      typeLabel: 'DateTime?',
      description: '「今日」として丸い枠の印を付ける日。指定しないと本当の今日',
      control: ChoiceControl(
        choices: [
          Choice('10月28日', DateTime(2026, 10, 28), 'DateTime(2026, 10, 28)'),
          Choice('10月5日', DateTime(2026, 10, 5), 'DateTime(2026, 10, 5)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'selectableDayPredicate',
      group: PropertyGroup.behavior,
      typeLabel: 'SelectableDayPredicate?',
      description: '日ごとに選べるかを決める関数。ここでは土日を選べなくする。initialDate は選べる日にする決まり',
      initiallyOn: false,
      control: FixedControl(
        value: _isWeekday,
        source: '(day) => day.weekday < DateTime.saturday',
      ),
    ),
    const PropertySpec(
      name: 'helpText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: 'ダイアログの上の小さな見出し。指定しないと「日付を選択」など',
      initiallyOn: false,
      control: TextControl(initialValue: '出発日'),
    ),
    const PropertySpec(
      name: 'cancelText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '取り消しのボタンの文字。指定しないと「キャンセル」',
      initiallyOn: false,
      control: TextControl(initialValue: 'やめる'),
    ),
    const PropertySpec(
      name: 'confirmText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '決めるボタンの文字。指定しないと「OK」',
      initiallyOn: false,
      control: TextControl(initialValue: '決める'),
    ),
    const PropertySpec(
      name: 'fieldLabelText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れるときの入力欄の名前。指定しないと日付の書式を表す言葉',
      initiallyOn: false,
      control: TextControl(initialValue: '出発日'),
    ),
    const PropertySpec(
      name: 'fieldHintText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れるとき、空の入力欄に薄く出す例。指定しないと日付の書式（yyyy/mm/dd など）',
      initiallyOn: false,
      control: TextControl(initialValue: '2026/10/28'),
    ),
    const PropertySpec(
      name: 'errorFormatText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れた日付の書き方が違うときに出す文。指定しないと「形式が無効です。」など',
      initiallyOn: false,
      control: TextControl(initialValue: '年/月/日 で入れてください'),
    ),
    const PropertySpec(
      name: 'errorInvalidText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れた日付が選べる範囲の外のときに出す文。指定しないと「範囲外です。」など',
      initiallyOn: false,
      control: TextControl(initialValue: '2026 年の日を入れてください'),
    ),
    const PropertySpec(
      name: 'switchToInputEntryModeIcon',
      group: PropertyGroup.content,
      typeLabel: 'Icon?',
      description: 'カレンダーのときに出す、文字で入れるほうへ切り替えるボタンのアイコン。指定しないと鉛筆',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.keyboard),
        source: 'Icon(Icons.keyboard)',
      ),
    ),
    const PropertySpec(
      name: 'switchToCalendarEntryModeIcon',
      group: PropertyGroup.content,
      typeLabel: 'Icon?',
      description: '文字で入れるときに出す、カレンダーへ切り替えるボタンのアイコン。指定しないとカレンダー',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.event),
        source: 'Icon(Icons.event)',
      ),
    ),
    PropertySpec(
      name: 'insetPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsets',
      description: '画面の端とダイアログの間に空ける余白。指定しないと左右 16・上下 24',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 0,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
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
      name: 'keyboardType',
      typeLabel: 'TextInputType?',
      description: '文字で入れるときに出すキーボードの種類。指定しないと TextInputType.datetime',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリが一度終わって戻ったときに、選んでいた日と入れ方を戻すための名前',
    ),
    ReferenceArg(
      name: 'onDatePickerModeChange',
      typeLabel: 'ValueChanged<DatePickerEntryMode>?',
      description:
          'カレンダーと文字で入れるほうを切り替えたときに呼ばれる。次に開くときの initialEntryMode を覚えるのに使う',
    ),
    ReferenceArg(
      name: 'calendarDelegate',
      typeLabel: 'CalendarDelegate<DateTime>',
      description:
          '暦の数え方（月の日数・週の始まりなど）を決める役。指定しないとグレゴリオ暦（GregorianCalendarDelegate）',
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
    currentDate: args.valueOf<DateTime>('currentDate'),
    selectableDayPredicate: args.valueOf<SelectableDayPredicate>(
      'selectableDayPredicate',
    ),
    helpText: args.valueOf<String>('helpText'),
    cancelText: args.valueOf<String>('cancelText'),
    confirmText: args.valueOf<String>('confirmText'),
    fieldLabelText: args.valueOf<String>('fieldLabelText'),
    fieldHintText: args.valueOf<String>('fieldHintText'),
    errorFormatText: args.valueOf<String>('errorFormatText'),
    errorInvalidText: args.valueOf<String>('errorInvalidText'),
    switchToInputEntryModeIcon: args.valueOf<Icon>(
      'switchToInputEntryModeIcon',
    ),
    switchToCalendarEntryModeIcon: args.valueOf<Icon>(
      'switchToCalendarEntryModeIcon',
    ),
    // Flutter の既定値。OFF のときも省いたコードと同じ余白にそろえる。
    insetPadding:
        args.valueOf<EdgeInsets>('insetPadding') ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    initialEntryMode:
        args.valueOf<DatePickerEntryMode>('initialEntryMode') ??
        DatePickerEntryMode.calendar,
    initialCalendarMode:
        args.valueOf<DatePickerMode>('initialCalendarMode') ??
        DatePickerMode.day,
  ),
);

/// 土日を選べなくする（initialDate の 2026-10-28 は水曜なので assert に当たらない）。
bool _isWeekday(DateTime day) => day.weekday < DateTime.saturday;
