import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoButtonEntry = WidgetEntry(
  id: 'cupertinoButton',
  name: 'CupertinoButton',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のボタン',
  description:
      '押すと薄くなる、iOS の見た目のボタンです。color を指定すると地が塗られます。'
      'onPressed が null なら押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('保存'), source: "Text('保存')"),
    ),
    PropertySpec(
      name: 'sizeStyle',
      group: PropertyGroup.size,
      typeLabel: 'CupertinoButtonSize',
      description: 'ボタンの大きさ。文字の大きさと内側の余白が変わる',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final size in CupertinoButtonSize.values)
            Choice(size.name, size, 'CupertinoButtonSize.${size.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ボタンの地の色。指定しないと地を塗らない',
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'foregroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '文字とアイコンの色。指定しないとテーマの主な色',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 3),
    ),
    PropertySpec(
      name: 'disabledColor',
      group: PropertyGroup.paint,
      requires: 'color',
      typeLabel: 'Color',
      description: '押せないとき（onPressed と onLongPress が null）の地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGrey4',
            CupertinoColors.systemGrey4,
            'CupertinoColors.systemGrey4',
          ),
          Choice.color('紅（薄く）', const Color(0x66D7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'pressedOpacity',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押している間の不透明度',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      group: PropertyGroup.paint,
      typeLabel: 'BorderRadius?',
      description: '地の角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => BorderRadius.circular(v),
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'ボタンの内側の余白。指定しないと sizeStyle で決まる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 24,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'minimumSize',
      group: PropertyGroup.size,
      typeLabel: 'Size?',
      description: 'ボタンのいちばん小さい大きさ。指定しないと 44×44',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('160×44', Size(160, 44), 'Size(160, 44)'),
          Choice('88×56', Size(88, 56), 'Size(88, 56)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: 'ボタンの中での中身の位置。ボタンが中身より大きいときに効く',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('centerLeft', Alignment.centerLeft),
            ('center', Alignment.center),
            ('centerRight', Alignment.centerRight),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'onLongPress',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '長押ししたときに呼ばれる。onPressed が null でも、これがあれば押せる',
      initiallyOn: false,
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
    const PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら押せない見た目になる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'minSize',
      typeLabel: 'double?',
      description: '非推奨。minimumSize を使う',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードの操作の行き先になったときの、まわりの線の色（プレビューでは見えない）',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'キーボードの操作の行き先を、外から決める・読むときに渡す',
    ),
    ReferenceArg(
      name: 'onFocusChange',
      typeLabel: 'ValueChanged<bool>?',
      description: 'キーボードの操作の行き先になった・外れたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '開いたときに、キーボードの操作の行き先にするか',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形。指定しないと Web では指の形',
    ),
  ],
  build: _build,
  codeName: 'CupertinoButton',
);

void _pressed() {}

final _colors = [
  const Choice(
    'activeBlue',
    CupertinoColors.activeBlue,
    'CupertinoColors.activeBlue',
  ),
  const Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen',
  ),
  const Choice(
    'systemRed',
    CupertinoColors.systemRed,
    'CupertinoColors.systemRed',
  ),
  Choice.color('墨', const Color(0xFF18181B)),
];

Widget _build(DemoArgs args) => CupertinoButton(
  sizeStyle:
      args.valueOf<CupertinoButtonSize>('sizeStyle') ??
      CupertinoButtonSize.large,
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  color: args.valueOf<Color>('color'),
  foregroundColor: args.valueOf<Color>('foregroundColor'),
  disabledColor:
      args.valueOf<Color>('disabledColor') ??
      CupertinoColors.quaternarySystemFill,
  minimumSize: args.valueOf<Size>('minimumSize'),
  pressedOpacity: args.valueOf<double>('pressedOpacity') ?? 0.4,
  borderRadius: args.valueOf<BorderRadius>('borderRadius'),
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  onLongPress: args.valueOf<VoidCallback>('onLongPress'),
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  // 必須のプロパティなので、常に値がある
  child: args.valueOf<Widget>('child')!,
);
