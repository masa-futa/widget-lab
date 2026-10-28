import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoRadioEntry = WidgetEntry(
  id: 'cupertinoRadio',
  name: 'CupertinoRadio',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目の、1 つだけ選ぶ丸い印',
  description:
      'iOS の見た目のラジオボタンです。選んでいる値と押したときの処理は、'
      '上に置いた RadioGroup の groupValue と onChanged で決めます（CupertinoRadio の groupValue・'
      'onChanged は非推奨）。プレビューでは value が 0・1・2 の 3 つを並べ、どれにも同じプロパティを渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoRadio-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      typeLabel: 'T',
      description: 'このラジオボタンの値。RadioGroup の groupValue と同じなら選ばれた見た目になる',
      required: true,
      control: FixedControl(value: 1, source: '1'),
    ),
    PropertySpec(
      name: 'activeColor',
      typeLabel: 'Color?',
      description: '選ばれているときの色。指定しないと activeBlue',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'inactiveColor',
      typeLabel: 'Color?',
      description: '選ばれていないときの地の色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    const PropertySpec(
      name: 'useCheckmarkStyle',
      typeLabel: 'bool',
      description: 'true なら、丸の代わりにチェックの印で選んだことを見せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'toggleable',
      typeLabel: 'bool',
      description: 'true なら、選んでいるものをもう一度押すと選ばない状態（null）に戻せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'enabled',
      typeLabel: 'bool?',
      description: 'false なら押せない見た目になる。指定しないと RadioGroup に従う',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  build: _build,
  codeName: 'CupertinoRadio<int>',
);

final _colors = [
  const Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen',
  ),
  const Choice(
    'systemOrange',
    CupertinoColors.systemOrange,
    'CupertinoColors.systemOrange',
  ),
  const Choice(
    'systemYellow',
    CupertinoColors.systemYellow,
    'CupertinoColors.systemYellow',
  ),
  Choice.color('墨', const Color(0xFF18181B)),
];

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final selected = args.valueOf<int>('value')!;
  final activeColor = args.valueOf<Color>('activeColor');
  final inactiveColor = args.valueOf<Color>('inactiveColor');
  final useCheckmarkStyle = args.valueOf<bool>('useCheckmarkStyle') ?? false;
  final toggleable = args.valueOf<bool>('toggleable') ?? false;
  final enabled = args.valueOf<bool>('enabled');
  return DemoValue<int?>(
    initial: selected,
    builder: (context, value, onChanged) => RadioGroup<int>(
      groupValue: value,
      onChanged: onChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          for (var i = 0; i < 3; i++)
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                CupertinoRadio<int>(
                  value: i,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  useCheckmarkStyle: useCheckmarkStyle,
                  toggleable: toggleable,
                  enabled: enabled,
                ),
                Text('$i'),
              ],
            ),
        ],
      ),
    ),
  );
}
