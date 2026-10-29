import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.layout,
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
      group: PropertyGroup.layout,
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
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: 'ダイアログの上の小さな見出し。指定しないと「時刻を選択」など',
      initiallyOn: false,
      control: TextControl(initialValue: '起きる時刻'),
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
      name: 'hourLabelText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れるときの、時の入力欄の下の名前。指定しないと「時」',
      initiallyOn: false,
      control: TextControl(initialValue: 'じ'),
    ),
    const PropertySpec(
      name: 'minuteLabelText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れるときの、分の入力欄の下の名前。指定しないと「分」',
      initiallyOn: false,
      control: TextControl(initialValue: 'ふん'),
    ),
    const PropertySpec(
      name: 'errorInvalidText',
      group: PropertyGroup.text,
      typeLabel: 'String?',
      description: '文字で入れた時刻がおかしいときに出す文。指定しないと「有効な時刻を入力してください」など',
      initiallyOn: false,
      control: TextControl(initialValue: '0〜23 時で入れてください'),
    ),
    const PropertySpec(
      name: 'emptyInitialInput',
      group: PropertyGroup.behavior,
      requires: 'initialEntryMode',
      typeLabel: 'bool',
      description:
          '文字で入れるとき、入力欄を initialTime で埋めずに空で始めるか。文字盤のときは効かない。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'switchToInputEntryModeIcon',
      group: PropertyGroup.content,
      typeLabel: 'Icon?',
      description: '文字盤のときに出す、文字で入れるほうへ切り替えるボタンのアイコン。指定しないとキーボード',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.edit),
        source: 'Icon(Icons.edit)',
      ),
    ),
    const PropertySpec(
      name: 'switchToTimerEntryModeIcon',
      group: PropertyGroup.content,
      typeLabel: 'Icon?',
      description: '文字で入れるときに出す、文字盤へ切り替えるボタンのアイコン。指定しないと時計',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.timer),
        source: 'Icon(Icons.timer)',
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
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリが一度終わって戻ったときに、選んでいた時刻と入れ方を戻すための名前',
    ),
    ReferenceArg(
      name: 'onEntryModeChanged',
      typeLabel: 'EntryModeChangeCallback?',
      description:
          '文字盤と文字で入れるほうを切り替えたときに呼ばれる。次に開くときの initialEntryMode を覚えるのに使う',
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
      cancelText: args.valueOf<String>('cancelText'),
      confirmText: args.valueOf<String>('confirmText'),
      hourLabelText: args.valueOf<String>('hourLabelText'),
      minuteLabelText: args.valueOf<String>('minuteLabelText'),
      errorInvalidText: args.valueOf<String>('errorInvalidText'),
      emptyInitialInput: args.valueOf<bool>('emptyInitialInput') ?? false,
      switchToInputEntryModeIcon: args.valueOf<Icon>(
        'switchToInputEntryModeIcon',
      ),
      switchToTimerEntryModeIcon: args.valueOf<Icon>(
        'switchToTimerEntryModeIcon',
      ),
    ),
  );
}
