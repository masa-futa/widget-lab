import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoCheckBoxEntry = WidgetEntry(
  id: 'cupertinoCheckBox',
  name: 'CupertinoCheckBox',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のチェックボックス',
  description:
      'iOS の見た目のチェックボックスです（クラス名は CupertinoCheckbox）。'
      '自分では値を持たないので、onChanged で受けた値を State に持ち、value に渡し直します。'
      'tristate を true にすると、押すたびに オン → 未定（null）→ オフ と変わります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoCheckbox-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'bool?',
      description: 'チェックが入っているか。プレビューで押すと変わる',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'tristate',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら、未定（null）の状態も取る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'チェックが入っているときの地の色。指定しないと activeBlue',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'checkColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'チェックの印の色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    PropertySpec(
      name: 'fillColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '状態（チェックあり・なし・押せない）ごとの地の色。activeColor より優先される',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          const Choice(
            'systemIndigo 一色',
            WidgetStatePropertyAll<Color?>(CupertinoColors.systemIndigo),
            'const WidgetStatePropertyAll(CupertinoColors.systemIndigo)',
          ),
          Choice(
            'チェックでピンク・なしで灰色',
            WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? CupertinoColors.systemPink
                  : CupertinoColors.systemGrey5,
            ),
            'WidgetStateProperty.resolveWith((states) => '
                'states.contains(WidgetState.selected) '
                '? CupertinoColors.systemPink : CupertinoColors.systemGrey5)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'side',
      group: PropertyGroup.paint,
      typeLabel: 'BorderSide?',
      description: 'チェックが入っていないときの、ふちの線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太い青線',
            BorderSide(width: 2, color: CupertinoColors.activeBlue),
            'BorderSide(width: 2, color: CupertinoColors.activeBlue)',
          ),
          Choice(
            '細い墨線',
            BorderSide(color: Color(0xFF18181B)),
            'BorderSide(color: Color(0xFF18181B))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'OutlinedBorder?',
      description: '枠の形。指定しないと角の丸み 4 の四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('丸', CircleBorder(), 'CircleBorder()'),
          Choice(
            '角の丸み 0',
            RoundedRectangleBorder(),
            'RoundedRectangleBorder()',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'tapTargetSize',
      group: PropertyGroup.size,
      typeLabel: 'Size?',
      description: '押せる範囲と、場所を取る大きさ。見える枠の大きさは変わらない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('24×24', Size(24, 24), 'Size(24, 24)'),
          Choice('64×64', Size(64, 64), 'Size(64, 64)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<bool?>?',
      description: '押したときに新しい値で呼ばれる。null なら押せない見た目になる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            'setState',
            true,
            '(value) => setState(() => _checked = value)',
          ),
          Choice('null', false, 'null'),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形',
    ),
    ReferenceArg(
      name: 'inactiveColor',
      typeLabel: 'Color?',
      description: '非推奨。今は使われない。fillColor を使う',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードの操作の行き先になったときの、まわりの色（プレビューでは見えない）',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'キーボードの操作の行き先を、外から決める・読むときに渡す',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '開いたときに、キーボードの操作の行き先にするか',
    ),
    ReferenceArg(
      name: 'semanticLabel',
      typeLabel: 'String?',
      description: '読み上げで伝える名前。画面には出ない',
    ),
  ],
  build: _build,
  codeName: 'CupertinoCheckbox',
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
  final tristate = args.valueOf<bool>('tristate') ?? false;
  final activeColor = args.valueOf<Color>('activeColor');
  final checkColor = args.valueOf<Color>('checkColor');
  final fillColor = args.valueOf<WidgetStateProperty<Color?>>('fillColor');
  final side = args.valueOf<BorderSide>('side');
  final shape = args.valueOf<OutlinedBorder>('shape');
  final tapTargetSize = args.valueOf<Size>('tapTargetSize');
  // どちらも必須のプロパティなので、常に値がある
  final enabled = args.valueOf<bool>('onChanged')!;
  return DemoValue<bool?>(
    initial: args.valueOf<bool>('value')!,
    builder: (context, value, onChanged) => CupertinoCheckbox(
      // tristate を OFF に戻したとき、未定（null）のままだと assert で落ちるので、オフにする
      value: tristate ? value : (value ?? false),
      tristate: tristate,
      activeColor: activeColor,
      checkColor: checkColor,
      fillColor: fillColor,
      side: side,
      shape: shape,
      tapTargetSize: tapTargetSize,
      onChanged: enabled ? onChanged : null,
    ),
  );
}
