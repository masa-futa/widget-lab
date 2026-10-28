import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final segmentedButtonEntry = WidgetEntry(
  id: 'segmentedButton',
  name: 'SegmentedButton',
  genreIds: const ['material'],
  summary: '2〜5 個の選択肢を 1 列に並べて選ぶボタン',
  description:
      '2〜5 個の選択肢（ButtonSegment）を 1 列につなげて並べ、1 つ（または複数）を選ばせます。'
      '選んでいるものは selected の Set で渡します。'
      'onSelectionChanged を渡さないと押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/SegmentedButton-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'segments',
      typeLabel: 'List<ButtonSegment<String>>',
      description: '選択肢。ButtonSegment に値・文字・アイコンを持たせる',
      required: true,
      control: FixedControl(
        value: <ButtonSegment<String>>[
          ButtonSegment(value: 'day', label: Text('日')),
          ButtonSegment(value: 'week', label: Text('週')),
          ButtonSegment(value: 'month', label: Text('月')),
        ],
        source:
            "[ButtonSegment(value: 'day', label: Text('日')), "
            "ButtonSegment(value: 'week', label: Text('週')), "
            "ButtonSegment(value: 'month', label: Text('月'))]",
      ),
    ),
    PropertySpec(
      name: 'selected',
      typeLabel: 'Set<String>',
      description: '選んでいる選択肢の値。2 つ以上なら multiSelectionEnabled を true にする',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('日', {'day'}, "{'day'}"),
          Choice('週', {'week'}, "{'week'}"),
          Choice('月', {'month'}, "{'month'}"),
        ],
      ),
    ),
    PropertySpec(
      name: 'onSelectionChanged',
      typeLabel: 'ValueChanged<Set<String>>?',
      description: '選び替えたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _ignore, source: '(selected) {}'),
    ),
    PropertySpec(
      name: 'multiSelectionEnabled',
      typeLabel: 'bool',
      description: '複数を選べるか。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'showSelectedIcon',
      typeLabel: 'bool',
      description: '選んでいる選択肢にチェックの印を出すか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'SegmentedButton<String>',
);

void _ignore(Set<String> selected) {}

Widget _build(DemoArgs args) {
  final selected = args.valueOf<Set<String>>('selected') ?? const {'day'};
  final multi = args.valueOf<bool>('multiSelectionEnabled') ?? false;
  return SegmentedButton<String>(
    segments: args.valueOf<List<ButtonSegment<String>>>('segments') ?? const [],
    selected: selected,
    onSelectionChanged: args.valueOf<ValueChanged<Set<String>>>(
      'onSelectionChanged',
    ),
    multiSelectionEnabled: multi,
    showSelectedIcon: args.valueOf<bool>('showSelectedIcon') ?? true,
  );
}
