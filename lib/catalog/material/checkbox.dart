import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final checkboxEntry = WidgetEntry(
  id: 'checkbox',
  name: 'Checkbox',
  genreIds: const ['material'],
  summary: 'ON / OFF を切り替えるチェックの箱',
  description:
      'ON / OFF を切り替える四角い箱です。Checkbox 自身は値を持たないので、'
      '押されると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。onChanged を渡さないと押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Checkbox-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'bool?',
      description: 'チェックが入っているか',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<bool?>?',
      description: '押されたときに新しい値で呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'チェックが入っているときの箱の色。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'fillColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description:
          '箱を塗る色。状態ごとに変えられ、activeColor より優先する。指定しないと activeColor かテーマの色',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('瑠璃', Color(0xFF1E50A2)),
          ('若竹', Color(0xFF68BE8D)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'checkColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'チェックの印の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('白', const Color(0xFFFFFFFF)),
        ],
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '押している間に箱のまわりに広がる丸の色。指定しないと activeColor かテーマの色を薄くしたもの',
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
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'OutlinedBorder?',
      description: '箱の形。指定しないと角の丸みが 2 の四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸 6',
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            'RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))',
          ),
          const Choice('丸', CircleBorder(), 'CircleBorder()'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'side',
      group: PropertyGroup.paint,
      typeLabel: 'BorderSide?',
      description: '箱のふちの線。チェックが入っていないときだけ描かれる。指定しないと太さ 2 の線',
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
    const PropertySpec(
      name: 'isError',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: '入力の誤りを示す色（テーマの error）で描くか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'materialTapTargetSize',
      group: PropertyGroup.size,
      typeLabel: 'MaterialTapTargetSize?',
      description:
          '押せる範囲の最小の大きさ。padded は 48×48、shrinkWrap は箱の大きさだけ。指定しないとテーマの値',
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
      name: 'tristate',
      typeLabel: 'bool',
      description:
          'true にすると value に null（横線の印）を渡せ、押すたびに false → true → null と巡る。'
          'ここでは value をパネルで変えるので補足に置く。指定しないと false',
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
    ReferenceArg(
      name: 'semanticLabel',
      typeLabel: 'String?',
      description: '読み上げ（TalkBack・VoiceOver）で使う名前',
    ),
  ],
  build: _build,
  codeName: 'Checkbox',
);

void _onChanged(bool? value) {}

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

Widget _build(DemoArgs args) => Checkbox(
  value: args.valueOf<bool>('value'),
  onChanged: args.valueOf<ValueChanged<bool?>>('onChanged'),
  activeColor: args.valueOf<Color>('activeColor'),
  fillColor: args.valueOf<WidgetStateProperty<Color?>>('fillColor'),
  checkColor: args.valueOf<Color>('checkColor'),
  overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
  splashRadius: args.valueOf<double>('splashRadius'),
  shape: args.valueOf<OutlinedBorder>('shape'),
  side: args.valueOf<BorderSide>('side'),
  isError: args.valueOf<bool>('isError') ?? false,
  materialTapTargetSize: args.valueOf<MaterialTapTargetSize>(
    'materialTapTargetSize',
  ),
  visualDensity: args.valueOf<VisualDensity>('visualDensity'),
);
