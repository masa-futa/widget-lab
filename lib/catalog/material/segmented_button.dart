import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'segments',
      group: PropertyGroup.content,
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
    const PropertySpec(
      name: 'selected',
      group: PropertyGroup.behavior,
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
    const PropertySpec(
      name: 'onSelectionChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<Set<String>>?',
      description: '選び替えたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _ignore, source: '(selected) {}'),
    ),
    const PropertySpec(
      name: 'multiSelectionEnabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '複数を選べるか。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'showSelectedIcon',
      group: PropertyGroup.content,
      typeLabel: 'bool',
      description: '選んでいる選択肢にチェックの印を出すか。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'emptySelectionAllowed',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '1 つも選んでいない状態を許すか。true なら、ただ 1 つ選んでいるものを押すと選択が外れる。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'expandedInsets',
      group: PropertyGroup.size,
      typeLabel: 'EdgeInsets?',
      description: '指定すると、ボタンを親の幅いっぱいに広げ、この値を外側の余白にする。指定しないと中身の大きさ',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.paint,
      typeLabel: 'ButtonStyle?',
      description: '色・文字・余白などの見た目。SegmentedButton.styleFrom で作る。指定しないとテーマの見た目',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '選んだものを瑠璃に',
            SegmentedButton.styleFrom(
              selectedBackgroundColor: const Color(0xFF1E50A2),
              selectedForegroundColor: const Color(0xFFFFFFFF),
            ),
            'SegmentedButton.styleFrom(selectedBackgroundColor: Color(0xFF1E50A2), '
                'selectedForegroundColor: Color(0xFFFFFFFF))',
          ),
          Choice(
            '紅の線',
            SegmentedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD7003A), width: 2),
            ),
            'SegmentedButton.styleFrom(side: BorderSide(color: Color(0xFFD7003A), width: 2))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'selectedIcon',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description:
          '選んでいる選択肢の前に出す印。showSelectedIcon が false の間は出ない。指定しないとチェックの印',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.star),
        source: 'Icon(Icons.star)',
      ),
    ),
    PropertySpec(
      name: 'direction',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '選択肢を並べる向き。vertical にすると縦に積む。指定しないと横',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final axis in Axis.values)
            Choice(axis.name, axis, 'Axis.${axis.name}'),
        ],
        initialIndex: 1,
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
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
    emptySelectionAllowed: args.valueOf<bool>('emptySelectionAllowed') ?? false,
    expandedInsets: args.valueOf<EdgeInsets>('expandedInsets'),
    style: args.valueOf<ButtonStyle>('style'),
    showSelectedIcon: args.valueOf<bool>('showSelectedIcon') ?? true,
    selectedIcon: args.valueOf<Widget>('selectedIcon'),
    direction: args.valueOf<Axis>('direction') ?? Axis.horizontal,
  );
}
