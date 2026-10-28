import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDatePickerEntry = WidgetEntry(
  id: 'cupertinoDatePicker',
  name: 'CupertinoDatePicker',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の、回して選ぶ日付・時刻のピッカー',
  description:
      '列を回して日付や時刻を選ぶ、iOS の見た目のピッカーです。mode で日付だけ・時刻だけ・両方などを選べます。'
      '選んだ値は onDateTimeChanged で受け取ります。高さは親が決めるので、SizedBox などで高さを与えます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDatePicker-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'mode',
      typeLabel: 'CupertinoDatePickerMode',
      description: '選ぶもの。time・date・dateAndTime・monthYear',
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final mode in CupertinoDatePickerMode.values)
            Choice(mode.name, mode, 'CupertinoDatePickerMode.${mode.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'initialDateTime',
      typeLabel: 'DateTime?',
      description:
          '最初に選んでいる日時。指定しないと今の日時（分が minuteInterval で割り切れないと落ちるので、ここでは必ず渡す）',
      required: true,
      control: FixedControl(
        value: DateTime(2026, 10, 28, 9, 30),
        source: 'DateTime(2026, 10, 28, 9, 30)',
      ),
    ),
    const PropertySpec(
      name: 'use24hFormat',
      typeLabel: 'bool',
      description: 'true なら時刻を 24 時間制で出す（午前・午後の列がなくなる）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'minuteInterval',
      typeLabel: 'int',
      description: '分の刻み。60 を割り切れる数にする（最初の日時の分も割り切れること）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('1', 1, '1'),
          Choice('5', 5, '5'),
          Choice('15', 15, '15'),
          Choice('30', 30, '30'),
        ],
        initialIndex: 1,
      ),
    ),
    const PropertySpec(
      name: 'onDateTimeChanged',
      typeLabel: 'ValueChanged<DateTime>',
      description: '回して選んだ日時で呼ばれる',
      required: true,
      control: FixedControl(value: _changed, source: '(dateTime) {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoDatePicker',
);

void _changed(DateTime dateTime) {}

Widget _build(DemoArgs args) {
  final mode =
      args.valueOf<CupertinoDatePickerMode>('mode') ??
      CupertinoDatePickerMode.dateAndTime;
  final minuteInterval = args.valueOf<int>('minuteInterval') ?? 1;
  final use24hFormat = args.valueOf<bool>('use24hFormat') ?? false;
  return FittedBox(
    // 見本（幅 240）や比較の低いカードで幅が足りないと組めないので、決めた大きさで組んでから縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 320,
      height: 200,
      child: CupertinoDatePicker(
        // 列の組み立てが mode などで変わるので、値が変わったら State ごと作り直す
        key: ValueKey((mode, minuteInterval, use24hFormat)),
        mode: mode,
        initialDateTime: args.valueOf<DateTime>('initialDateTime'),
        use24hFormat: use24hFormat,
        minuteInterval: minuteInterval,
        // 必須のプロパティなので、常に値がある
        onDateTimeChanged: args.valueOf<ValueChanged<DateTime>>(
          'onDateTimeChanged',
        )!,
      ),
    ),
  );
}
