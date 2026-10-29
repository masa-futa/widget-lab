import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSlidingSegmentedControlEntry = WidgetEntry(
  id: 'cupertinoSlidingSegmentedControl',
  name: 'CupertinoSlidingSegmentedControl',
  genreIds: const ['cupertino'],
  summary: '選んだ区切りへつまみが滑る、iOS の切り替え',
  description:
      '横に並べた区切りから 1 つを選ぶ、iOS の見た目の切り替えです。選ぶと白いつまみが滑って移ります。'
      '自分では値を持たないので、onValueChanged で受けた値を State に持ち、groupValue に渡し直します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSlidingSegmentedControl-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'Map<T, Widget>',
      description: '値と、その区切りに出す Widget。2 つ以上',
      required: true,
      control: FixedControl(
        value: _children,
        source: "{0: Text('日'), 1: Text('週'), 2: Text('月')}",
      ),
    ),
    const PropertySpec(
      name: 'groupValue',
      group: PropertyGroup.behavior,
      typeLabel: 'T?',
      description: '選んでいる値。null ならどれも選ばない。プレビューで押すと変わる',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('0（日）', 0, '0'),
          Choice('1（週）', 1, '1'),
          Choice('2（月）', 2, '2'),
        ],
      ),
    ),
    PropertySpec(
      name: 'thumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: 'つまみの色。指定しないと白（暗いときは灰色）',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '地の色。指定しないと tertiarySystemFill',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'proportionalWidth',
      group: PropertyGroup.size,
      typeLabel: 'bool',
      description: 'true なら、区切りの幅を中身の幅に合わせる（false なら等分）',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'disabledChildren',
      group: PropertyGroup.behavior,
      typeLabel: 'Set<T>',
      description: '押せなくする区切りの値。その区切りの文字が薄くなる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('{2}（月）', {2}, '{2}'),
          Choice('{0, 2}（日・月）', {0, 2}, '{0, 2}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '地の内側、区切りのまわりの余白。指定しないと上下 2・左右 3',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'isMomentary',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら、押した区切りを選んだままにせず、ボタンのように押した間だけ反応する',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onValueChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<T?>',
      description: '選んだときに新しい値で呼ばれる',
      required: true,
      control: FixedControl(
        value: true,
        source: '(value) => setState(() => _selected = value)',
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
  codeName: 'CupertinoSlidingSegmentedControl<int>',
);

const _children = <int, Widget>{0: Text('日'), 1: Text('週'), 2: Text('月')};

final _colors = [
  const Choice(
    'systemYellow',
    CupertinoColors.systemYellow,
    'CupertinoColors.systemYellow',
  ),
  const Choice(
    'systemTeal',
    CupertinoColors.systemTeal,
    'CupertinoColors.systemTeal',
  ),
  Choice.color('瑠璃', const Color(0xFF1E50A2)),
];

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final children = args.valueOf<Map<int, Widget>>('children')!;
  final thumbColor = args.valueOf<Color>('thumbColor');
  final backgroundColor = args.valueOf<Color>('backgroundColor');
  final proportionalWidth = args.valueOf<bool>('proportionalWidth') ?? false;
  final disabledChildren =
      args.valueOf<Set<int>>('disabledChildren') ?? const <int>{};
  final padding =
      args.valueOf<EdgeInsetsGeometry>('padding') ??
      const EdgeInsets.symmetric(vertical: 2, horizontal: 3);
  final isMomentary = args.valueOf<bool>('isMomentary') ?? false;
  return DemoValue<int?>(
    initial: args.valueOf<int>('groupValue'),
    builder: (context, value, onChanged) =>
        CupertinoSlidingSegmentedControl<int>(
          groupValue: value,
          thumbColor:
              thumbColor ??
              const CupertinoDynamicColor.withBrightness(
                color: Color(0xFFFFFFFF),
                darkColor: Color(0xFF636366),
              ),
          backgroundColor:
              backgroundColor ?? CupertinoColors.tertiarySystemFill,
          proportionalWidth: proportionalWidth,
          disabledChildren: disabledChildren,
          padding: padding,
          isMomentary: isMomentary,
          onValueChanged: onChanged,
          children: children,
        ),
  );
}
