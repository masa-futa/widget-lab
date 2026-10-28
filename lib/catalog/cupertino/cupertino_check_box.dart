import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'bool?',
      description: 'チェックが入っているか。プレビューで押すと変わる',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'tristate',
      typeLabel: 'bool',
      description: 'true なら、未定（null）の状態も取る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'activeColor',
      typeLabel: 'Color?',
      description: 'チェックが入っているときの地の色。指定しないと activeBlue',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'checkColor',
      typeLabel: 'Color?',
      description: 'チェックの印の色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    const PropertySpec(
      name: 'onChanged',
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
      onChanged: enabled ? onChanged : null,
    ),
  );
}
