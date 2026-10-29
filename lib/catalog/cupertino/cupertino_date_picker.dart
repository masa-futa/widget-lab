import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
      typeLabel: 'DateTime?',
      description:
          '最初に選んでいる日時。指定しないと今の日時（分が minuteInterval で割り切れないと落ちるので、ここでは必ず渡す）',
      required: true,
      control: FixedControl(
        value: DateTime(2026, 10, 28, 9, 30),
        source: 'DateTime(2026, 10, 28, 9, 30)',
      ),
    ),
    PropertySpec(
      name: 'minimumDate',
      group: PropertyGroup.behavior,
      pairsWith: const ['maximumDate'],
      typeLabel: 'DateTime?',
      description: '選べる最も早い日時。これより前へ回しても、離すと戻る',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '同じ日の 9:00',
            DateTime(2026, 10, 28, 9),
            'DateTime(2026, 10, 28, 9)',
          ),
          Choice('10 月 1 日', DateTime(2026, 10), 'DateTime(2026, 10)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'maximumDate',
      group: PropertyGroup.behavior,
      pairsWith: const ['minimumDate'],
      typeLabel: 'DateTime?',
      description: '選べる最も遅い日時。これより後へ回しても、離すと戻る',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '同じ日の 18:00',
            DateTime(2026, 10, 28, 18),
            'DateTime(2026, 10, 28, 18)',
          ),
          Choice('12 月 31 日', DateTime(2026, 12, 31), 'DateTime(2026, 12, 31)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'minimumYear',
      group: PropertyGroup.behavior,
      pairsWith: ['maximumYear'],
      typeLabel: 'int',
      description: 'date モードで回せる最も前の年。指定しないと 1 年',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('2000', 2000, '2000'), Choice('2026', 2026, '2026')],
      ),
    ),
    const PropertySpec(
      name: 'maximumYear',
      group: PropertyGroup.behavior,
      pairsWith: ['minimumYear'],
      typeLabel: 'int?',
      description: 'date モードで回せる最も後の年。指定しないと限りがない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('2026', 2026, '2026'), Choice('2030', 2030, '2030')],
      ),
    ),
    const PropertySpec(
      name: 'minuteInterval',
      group: PropertyGroup.behavior,
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
      name: 'use24hFormat',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら時刻を 24 時間制で出す（午前・午後の列がなくなる）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'dateOrder',
      group: PropertyGroup.layout,
      typeLabel: 'DatePickerDateOrder?',
      description: 'date・monthYear モードでの日・月・年の列の並び。指定しないと言語の決まりに従う',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final order in DatePickerDateOrder.values)
            Choice(order.name, order, 'DatePickerDateOrder.${order.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'showDayOfWeek',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら日の横に曜日を出す。date モードのときだけ渡せる',
      initiallyOn: false,
      omitIf: _isNotDateMode,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'showTimeSeparator',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら時と分の間に「:」を出す。time・dateAndTime モードのときだけ渡せる',
      initiallyOn: false,
      omitIf: _hasNoTime,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ピッカーの地の色。指定しないと地を塗らない',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGrey6',
            CupertinoColors.systemGrey6,
            'CupertinoColors.systemGrey6',
          ),
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'selectionOverlayBuilder',
      group: PropertyGroup.paint,
      typeLabel: 'SelectionOverlayBuilder?',
      description: '選んでいる行に重ねる帯を作る関数。ここでは null を返して帯を消す',
      initiallyOn: false,
      control: FixedControl(
        value: _noOverlay,
        source:
            '(context, {required columnCount, required selectedIndex}) => null',
      ),
    ),
    PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '1 行の高さ。指定しないと iOS と同じ 32',
      initiallyOn: false,
      control: SliderControl(
        min: 24,
        max: 48,
        divisions: 6,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'selectableDayPredicate',
      group: PropertyGroup.behavior,
      typeLabel: 'SelectableDayPredicate?',
      description: '選べる日を決める関数。ここでは平日だけにし、土日を薄く出す',
      initiallyOn: false,
      control: FixedControl(
        value: _isWeekday,
        source: '(day) => day.weekday <= DateTime.friday',
      ),
    ),
    const PropertySpec(
      name: 'onDateTimeChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<DateTime>',
      description: '回して選んだ日時で呼ばれる',
      required: true,
      control: FixedControl(value: _changed, source: '(dateTime) {}'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'changeReportingBehavior',
      typeLabel: 'ChangeReportingBehavior',
      description: 'onDateTimeChanged を、回している間に呼ぶか、止まってから呼ぶか',
    ),
  ],
  build: _build,
  codeName: 'CupertinoDatePicker',
);

void _changed(DateTime dateTime) {}

bool _isWeekday(DateTime day) => day.weekday <= DateTime.friday;

Widget? _noOverlay(
  BuildContext context, {
  required int columnCount,
  required int selectedIndex,
}) => null;

/// [settings] での mode。OFF なら Flutter の既定値（dateAndTime）。
CupertinoDatePickerMode _modeIn(Map<String, PropertySetting> settings) {
  final mode = settings['mode'];
  if (mode == null || !mode.on) return CupertinoDatePickerMode.dateAndTime;
  final value = mode.value;
  return value is ChoiceValue
      ? CupertinoDatePickerMode.values[value.index]
      : CupertinoDatePickerMode.dateAndTime;
}

/// showDayOfWeek は date モードでしか渡せない（assert）。
bool _isNotDateMode(Map<String, PropertySetting> settings) =>
    _modeIn(settings) != CupertinoDatePickerMode.date;

/// showTimeSeparator は time・dateAndTime モードでしか渡せない（assert）。
bool _hasNoTime(Map<String, PropertySetting> settings) =>
    !_hasTime(_modeIn(settings));

bool _hasTime(CupertinoDatePickerMode mode) =>
    mode == CupertinoDatePickerMode.time ||
    mode == CupertinoDatePickerMode.dateAndTime;

Widget _build(DemoArgs args) {
  final mode =
      args.valueOf<CupertinoDatePickerMode>('mode') ??
      CupertinoDatePickerMode.dateAndTime;
  final minuteInterval = args.valueOf<int>('minuteInterval') ?? 1;
  final use24hFormat = args.valueOf<bool>('use24hFormat') ?? false;
  final minimumDate = args.valueOf<DateTime>('minimumDate');
  final maximumDate = args.valueOf<DateTime>('maximumDate');
  final minimumYear = args.valueOf<int>('minimumYear') ?? 1;
  final maximumYear = args.valueOf<int>('maximumYear');
  final dateOrder = args.valueOf<DatePickerDateOrder>('dateOrder');
  // omitIf と同じ条件で、渡せないモードでは既定値（false）にする
  final showDayOfWeek =
      mode == CupertinoDatePickerMode.date &&
      (args.valueOf<bool>('showDayOfWeek') ?? false);
  final showTimeSeparator =
      _hasTime(mode) && (args.valueOf<bool>('showTimeSeparator') ?? false);
  final itemExtent = args.valueOf<double>('itemExtent') ?? 32;
  final selectionOverlayBuilder = args.valueOf<SelectionOverlayBuilder>(
    'selectionOverlayBuilder',
  );
  final selectableDayPredicate = args.valueOf<SelectableDayPredicate>(
    'selectableDayPredicate',
  );
  return FittedBox(
    // 見本（幅 240）や比較の低いカードで幅が足りないと組めないので、決めた大きさで組んでから縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      // 時と分の区切りの列を足すと、dateAndTime では 320 では幅が足りない
      width: showTimeSeparator ? 500 : 320,
      height: 200,
      child: CupertinoDatePicker(
        // 列の組み立てが mode などで変わるので、値が変わったら State ごと作り直す
        key: ValueKey((
          mode,
          minuteInterval,
          use24hFormat,
          minimumDate,
          maximumDate,
          minimumYear,
          maximumYear,
          dateOrder,
          showDayOfWeek,
          showTimeSeparator,
          itemExtent,
          selectionOverlayBuilder,
          selectableDayPredicate,
        )),
        mode: mode,
        initialDateTime: args.valueOf<DateTime>('initialDateTime'),
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        minimumYear: minimumYear,
        maximumYear: maximumYear,
        use24hFormat: use24hFormat,
        minuteInterval: minuteInterval,
        dateOrder: dateOrder,
        showDayOfWeek: showDayOfWeek,
        showTimeSeparator: showTimeSeparator,
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        selectionOverlayBuilder: selectionOverlayBuilder,
        itemExtent: itemExtent,
        selectableDayPredicate: selectableDayPredicate,
        // 必須のプロパティなので、常に値がある
        onDateTimeChanged: args.valueOf<ValueChanged<DateTime>>(
          'onDateTimeChanged',
        )!,
      ),
    ),
  );
}
