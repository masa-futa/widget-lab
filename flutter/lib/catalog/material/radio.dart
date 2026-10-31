import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// デモの RadioGroup が選んでいる値（コードには出さない）。
const _groupValue = 1;

final radioEntry = WidgetEntry(
  id: 'radio',
  name: 'Radio',
  genreIds: const ['material'],
  summary: 'いくつかの中から 1 つを選ぶ丸いボタン',
  description:
      'いくつかの中から 1 つだけを選ぶ丸いボタンです。選んでいる値と押されたときの処理は、'
      '上に置く RadioGroup（groupValue・onChanged）がまとめて持ち、'
      'Radio は自分の value が groupValue と同じなら選んだ見た目になります。'
      'ここでは RadioGroup の groupValue を 1 にしています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Radio-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'T',
      description: 'この Radio が表す値。RadioGroup の groupValue（ここでは 1）と同じなら選んだ見た目',
      required: true,
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 1,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '押せるか。指定しないと RadioGroup があれば押せる',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選んでいるときの色。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'toggleable',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '選んでいるときにもう一度押すと、選択を外せる（groupValue が null になる）か',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'fillColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description:
          '丸の線と中の点の色。状態ごとに変えられ、activeColor より優先する。指定しないと activeColor かテーマの色',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('瑠璃', Color(0xFF1E50A2)),
          ('若竹', Color(0xFF68BE8D)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '丸の内側の地の色。指定しないと透明',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('山吹', Color(0xFFF8B500)),
          ('白', Color(0xFFFFFFFF)),
        ]),
      ),
    ),
    const PropertySpec(
      name: 'side',
      group: PropertyGroup.paint,
      typeLabel: 'BorderSide?',
      description: '丸のふちの線。指定しないと fillColor の色の線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '紅の線',
            BorderSide(color: Color(0xFFD7003A), width: 2),
            'BorderSide(color: Color(0xFFD7003A), width: 2)',
          ),
          Choice('太い線', BorderSide(width: 3), 'BorderSide(width: 3)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'innerRadius',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<double?>?',
      description: '選んでいるときの中の点の半径。指定しないと 4.5',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 8,
        divisions: 6,
        initialValue: 7,
        resolve: (v) => WidgetStatePropertyAll<double?>(v),
        code: (v) => 'WidgetStatePropertyAll($v)',
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '押している間に丸のまわりに広がる色。指定しないと activeColor かテーマの色を薄くしたもの',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('紅（半透明）', Color(0x66D7003A)),
          ('若竹（半透明）', Color(0x6668BE8D)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'splashRadius',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押している間に広がる丸の半径。指定しないと 20',
      initiallyOn: false,
      control: SliderControl(
        min: 8,
        max: 24,
        divisions: 4,
        initialValue: 12,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'materialTapTargetSize',
      group: PropertyGroup.size,
      typeLabel: 'MaterialTapTargetSize?',
      description:
          '押せる範囲の最小の大きさ。padded は 48×48、shrinkWrap は丸の大きさだけ。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in MaterialTapTargetSize.values)
            Choice(value.name, value, 'MaterialTapTargetSize.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'visualDensity',
      group: PropertyGroup.size,
      typeLabel: 'VisualDensity?',
      description: 'まわりの詰め具合。compact にすると押せる範囲が小さくなる。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(choices: _densityChoices()),
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
      description: '非推奨。上に置く RadioGroup の groupValue を使う',
    ),
    ReferenceArg(
      name: 'onChanged',
      typeLabel: 'ValueChanged<T?>?',
      description: '非推奨。上に置く RadioGroup の onChanged を使う',
    ),
    ReferenceArg(
      name: 'groupRegistry',
      typeLabel: 'RadioGroupRegistry<T>?',
      description: '選択をまとめる相手を直接渡す。指定しないと上の RadioGroup を探す',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形。タッチの端末では違いが出ない',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードなどでフォーカスしているときに、まわりに出す色',
    ),
    ReferenceArg(
      name: 'hoverColor',
      typeLabel: 'Color?',
      description: 'マウスを重ねているときに、まわりに出す色。タッチの端末では出ない',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から操作・監視するための部品',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面に出たときに最初からフォーカスするか。指定しないと false',
    ),
  ],
  build: _build,
  codeName: 'Radio<int>',
);

void _onChanged(int? value) {}

List<Choice> _stateColors(List<(String, Color)> colors) => [
  for (final (name, color) in colors)
    Choice(
      name,
      WidgetStatePropertyAll<Color?>(color),
      'WidgetStatePropertyAll(${colorCode(color)})',
    ),
];

List<Choice> _densityChoices() => [
  for (final (name, density) in const [
    ('standard', VisualDensity.standard),
    ('comfortable', VisualDensity.comfortable),
    ('compact', VisualDensity.compact),
  ])
    Choice(name, density, 'VisualDensity.$name'),
];

/// Radio は RadioGroup の下に置く。RadioGroup はデモの部品（コードには出さない）。
Widget _build(DemoArgs args) => RadioGroup<int>(
  groupValue: _groupValue,
  onChanged: _onChanged,
  child: Radio<int>(
    value: args.valueOf<int>('value') ?? 0,
    enabled: args.valueOf<bool>('enabled'),
    activeColor: args.valueOf<Color>('activeColor'),
    toggleable: args.valueOf<bool>('toggleable') ?? false,
    fillColor: args.valueOf<WidgetStateProperty<Color?>>('fillColor'),
    backgroundColor: args.valueOf<WidgetStateProperty<Color?>>(
      'backgroundColor',
    ),
    side: args.valueOf<BorderSide>('side'),
    innerRadius: args.valueOf<WidgetStateProperty<double?>>('innerRadius'),
    overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
    splashRadius: args.valueOf<double>('splashRadius'),
    materialTapTargetSize: args.valueOf<MaterialTapTargetSize>(
      'materialTapTargetSize',
    ),
    visualDensity: args.valueOf<VisualDensity>('visualDensity'),
  ),
);
