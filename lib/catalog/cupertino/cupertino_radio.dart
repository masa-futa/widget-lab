import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'T',
      description: 'このラジオボタンの値。RadioGroup の groupValue と同じなら選ばれた見た目になる',
      required: true,
      control: FixedControl(value: 1, source: '1'),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選ばれているときの色。指定しないと activeBlue',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'inactiveColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選ばれていないときの地の色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    PropertySpec(
      name: 'fillColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選ばれているときの、真ん中の小さな丸の色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 3),
    ),
    const PropertySpec(
      name: 'useCheckmarkStyle',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: 'true なら、丸の代わりにチェックの印で選んだことを見せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'toggleable',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら、選んでいるものをもう一度押すと選ばない状態（null）に戻せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'false なら押せない見た目になる。指定しないと RadioGroup に従う',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'groupValue',
      typeLabel: 'T?',
      description: '選んでいる値（非推奨）。上に置いた RadioGroup の groupValue を使う',
    ),
    ReferenceArg(
      name: 'onChanged',
      typeLabel: 'ValueChanged<T?>?',
      description: '押したときに呼ばれる（非推奨）。上に置いた RadioGroup の onChanged を使う',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードでフォーカスしたときの縁の色',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'キーボードのフォーカスを、外から移したり調べたりするための印',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面に出たときに、最初からフォーカスを持つか',
    ),
    ReferenceArg(
      name: 'groupRegistry',
      typeLabel: 'RadioGroupRegistry<T>?',
      description: '属するラジオボタンの組。指定しないと上に置いた RadioGroup を使う',
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
  final fillColor = args.valueOf<Color>('fillColor');
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
                  fillColor: fillColor,
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
