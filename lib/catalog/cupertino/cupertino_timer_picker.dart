import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.content,
      typeLabel: 'Duration',
      description: '最初に選んでいる長さ。指定しないと 0',
      control: FixedControl(
        value: Duration(minutes: 30),
        source: 'const Duration(minutes: 30)',
      ),
    ),
    const PropertySpec(
      name: 'minuteInterval',
      group: PropertyGroup.behavior,
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
    const PropertySpec(
      name: 'secondInterval',
      group: PropertyGroup.behavior,
      typeLabel: 'int',
      description: '秒の刻み。60 を割り切れる数にする',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('1', 1, '1'),
          Choice('5', 5, '5'),
          Choice('15', 15, '15'),
          Choice('30', 30, '30'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: '使える広さの中での列の位置。指定しないと真ん中',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: alignmentCenter,
        choices: alignmentChoices,
      ),
    ),
    const PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '1 行の高さ。指定しないと 32',
      initiallyOn: false,
      control: SliderControl(
        min: 24,
        max: 56,
        divisions: 4,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'selectionOverlayBuilder',
      group: PropertyGroup.paint,
      typeLabel: 'SelectionOverlayBuilder?',
      description: '選んでいる行に重ねる帯を組み立てる。指定しないと灰色の角丸の帯',
      initiallyOn: false,
      control: FixedControl(
        value: _overlay,
        source:
            '(context, {required selectedIndex, required columnCount}) => '
            'Container(color: Color(0x33F8B500))',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
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
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<Duration>',
      description: '回して選んだ長さで呼ばれる',
      required: true,
      control: FixedControl(value: _changed, source: '(duration) {}'),
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
      description: '回している間ずっと onTimerDurationChanged を呼ぶか、止まってから 1 回だけ呼ぶか',
    ),
  ],
  build: _build,
  codeName: 'CupertinoTimerPicker',
);

void _changed(Duration duration) {}

Widget? _overlay(
  BuildContext context, {
  required int selectedIndex,
  required int columnCount,
}) => const ColoredBox(color: Color(0x33F8B500));

Widget _build(DemoArgs args) {
  final mode =
      args.valueOf<CupertinoTimerPickerMode>('mode') ??
      CupertinoTimerPickerMode.hms;
  final minuteInterval = args.valueOf<int>('minuteInterval') ?? 1;
  final secondInterval = args.valueOf<int>('secondInterval') ?? 1;
  return FittedBox(
    // 見本（幅 240）や比較の低いカードで幅が足りないと組めないので、決めた大きさで組んでから縮める
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: 320,
      height: 200,
      child: CupertinoTimerPicker(
        // 列の組み立てが mode と刻みで変わるので、変わったら State ごと作り直す
        key: ValueKey((mode, minuteInterval, secondInterval)),
        mode: mode,
        initialTimerDuration:
            args.valueOf<Duration>('initialTimerDuration') ?? Duration.zero,
        minuteInterval: minuteInterval,
        secondInterval: secondInterval,
        alignment:
            args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
        itemExtent: args.valueOf<double>('itemExtent') ?? 32,
        selectionOverlayBuilder: args.valueOf<SelectionOverlayBuilder>(
          'selectionOverlayBuilder',
        ),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        // 必須のプロパティなので、常に値がある
        onTimerDurationChanged: args.valueOf<ValueChanged<Duration>>(
          'onTimerDurationChanged',
        )!,
      ),
    ),
  );
}
