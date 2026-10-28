import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTimerPickerEntry = WidgetEntry(
  id: 'cupertinoTimerPicker',
  name: 'CupertinoTimerPicker',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の、回して選ぶ時間の長さのピッカー',
  description:
      '時・分・秒の列を回して、時間の長さ（Duration）を選ぶ iOS の見た目のピッカーです。'
      '選んだ長さは onTimerDurationChanged で受け取ります。高さは親が決めます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTimerPicker-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'mode',
      typeLabel: 'CupertinoTimerPickerMode',
      description: '出す列。hm（時・分）・ms（分・秒）・hms（時・分・秒）',
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final mode in CupertinoTimerPickerMode.values)
            Choice(mode.name, mode, 'CupertinoTimerPickerMode.${mode.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'initialTimerDuration',
      typeLabel: 'Duration',
      description: '最初に選んでいる長さ。指定しないと 0',
      control: FixedControl(
        value: Duration(minutes: 30),
        source: 'const Duration(minutes: 30)',
      ),
    ),
    const PropertySpec(
      name: 'minuteInterval',
      typeLabel: 'int',
      description: '分の刻み。60 を割り切れる数にする',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('1', 1, '1'),
          Choice('5', 5, '5'),
          Choice('15', 15, '15'),
          Choice('30', 30, '30'),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: 'ピッカーの地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGroupedBackground',
            CupertinoColors.systemGroupedBackground,
            'CupertinoColors.systemGroupedBackground',
          ),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'onTimerDurationChanged',
      typeLabel: 'ValueChanged<Duration>',
      description: '回して選んだ長さで呼ばれる',
      required: true,
      control: FixedControl(value: _changed, source: '(duration) {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTimerPicker',
);

void _changed(Duration duration) {}

Widget _build(DemoArgs args) {
  final mode =
      args.valueOf<CupertinoTimerPickerMode>('mode') ??
      CupertinoTimerPickerMode.hms;
  final minuteInterval = args.valueOf<int>('minuteInterval') ?? 1;
  return FittedBox(
    // 見本（幅 240）や比較の低いカードで幅が足りないと組めないので、決めた大きさで組んでから縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 320,
      height: 200,
      child: CupertinoTimerPicker(
        // 列の組み立てが mode と刻みで変わるので、変わったら State ごと作り直す
        key: ValueKey((mode, minuteInterval)),
        mode: mode,
        initialTimerDuration:
            args.valueOf<Duration>('initialTimerDuration') ?? Duration.zero,
        minuteInterval: minuteInterval,
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        // 必須のプロパティなので、常に値がある
        onTimerDurationChanged: args.valueOf<ValueChanged<Duration>>(
          'onTimerDurationChanged',
        )!,
      ),
    ),
  );
}
