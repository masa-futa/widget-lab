import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSwitchEntry = WidgetEntry(
  id: 'cupertinoSwitch',
  name: 'CupertinoSwitch',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のオン・オフのスイッチ',
  description:
      'iOS の見た目のスイッチです。自分では値を持たないので、onChanged で受けた値を'
      'State に持ち、value に渡し直します。onChanged が null なら押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSwitch-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'bool',
      description: 'オンか。プレビューで押すと変わる',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'activeTrackColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'オンのときの溝の色。指定しないと systemGreen',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'inactiveTrackColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'オフのときの溝の色',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 3),
    ),
    PropertySpec(
      name: 'thumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'つまみの色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    PropertySpec(
      name: 'inactiveThumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'オフのときのつまみの色。指定しないと thumbColor と同じ',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'applyTheme',
      group: PropertyGroup.paint,
      typeLabel: 'bool?',
      description: 'true なら、オンのときの溝にテーマの主な色を使う。指定しないとテーマの applyThemeToAll',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'thumbIcon',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Icon?>?',
      description: 'つまみの上に描くアイコン',
      initiallyOn: false,
      control: FixedControl(
        value: WidgetStatePropertyAll<Icon?>(
          Icon(CupertinoIcons.check_mark, size: 16),
        ),
        source:
            'WidgetStatePropertyAll(Icon(CupertinoIcons.check_mark, size: 16))',
      ),
    ),
    const PropertySpec(
      name: 'activeThumbImage',
      group: PropertyGroup.paint,
      pairsWith: ['inactiveThumbImage'],
      typeLabel: 'ImageProvider?',
      description: 'オンのときにつまみに描く画像',
      initiallyOn: false,
      control: FixedControl(value: _image, source: _imageSource),
    ),
    const PropertySpec(
      name: 'inactiveThumbImage',
      group: PropertyGroup.paint,
      pairsWith: ['activeThumbImage'],
      typeLabel: 'ImageProvider?',
      description: 'オフのときにつまみに描く画像',
      initiallyOn: false,
      control: FixedControl(value: _image, source: _imageSource),
    ),
    PropertySpec(
      name: 'trackOutlineColor',
      group: PropertyGroup.paint,
      pairsWith: const ['trackOutlineWidth'],
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '溝のふちの線の色。指定しないと線を引かない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final choice in _colors)
            Choice(
              choice.label,
              WidgetStatePropertyAll<Color?>(choice.value as Color),
              'WidgetStatePropertyAll(${choice.code})',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'trackOutlineWidth',
      group: PropertyGroup.paint,
      pairsWith: const ['trackOutlineColor'],
      requires: 'trackOutlineColor',
      typeLabel: 'WidgetStateProperty<double?>?',
      description: '溝のふちの線の太さ。指定しないと 2',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 6,
        divisions: 5,
        initialValue: 4,
        resolve: (v) => WidgetStatePropertyAll<double?>(v),
        code: (v) => 'WidgetStatePropertyAll($v)',
      ),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<bool>?',
      description: '押したときに新しい値で呼ばれる。null なら押せない見た目になる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('setState', true, '(value) => setState(() => _on = value)'),
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
      name: 'activeColor',
      typeLabel: 'Color?',
      description: '非推奨。activeTrackColor を使う',
    ),
    ReferenceArg(
      name: 'trackColor',
      typeLabel: 'Color?',
      description: '非推奨。inactiveTrackColor を使う',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードで選んだ（フォーカスがある）ときのふちの色',
    ),
    ReferenceArg(
      name: 'onLabelColor',
      typeLabel: 'Color?',
      description: '端末の設定で「オン／オフのラベル」を出すときの、オンの印の色',
    ),
    ReferenceArg(
      name: 'offLabelColor',
      typeLabel: 'Color?',
      description: '端末の設定で「オン／オフのラベル」を出すときの、オフの印の色',
    ),
    ReferenceArg(
      name: 'onActiveThumbImageError',
      typeLabel: 'ImageErrorListener?',
      description:
          'activeThumbImage を読み込めなかったときに呼ばれる。activeThumbImage がないと渡せない',
    ),
    ReferenceArg(
      name: 'onInactiveThumbImageError',
      typeLabel: 'ImageErrorListener?',
      description:
          'inactiveThumbImage を読み込めなかったときに呼ばれる。inactiveThumbImage がないと渡せない',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'WidgetStateProperty<MouseCursor>?',
      description: 'マウスを重ねたときのカーソルの形',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'キーボードのフォーカスを外から操作するときに使う',
    ),
    ReferenceArg(
      name: 'onFocusChange',
      typeLabel: 'ValueChanged<bool>?',
      description: 'フォーカスを得たとき・失ったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '最初に出たときにフォーカスを持つか',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'つまみを引くとき、動かし始めを指が触れた位置にするか、動き出した位置にするか',
    ),
  ],
  build: _build,
  codeName: 'CupertinoSwitch',
);

final _colors = [
  const Choice(
    'activeBlue',
    CupertinoColors.activeBlue,
    'CupertinoColors.activeBlue',
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

const _image = AssetImage('assets/demo/landscape.png');
const _imageSource = "AssetImage('assets/demo/landscape.png')";

Widget _build(DemoArgs args) {
  final activeTrackColor = args.valueOf<Color>('activeTrackColor');
  final inactiveTrackColor = args.valueOf<Color>('inactiveTrackColor');
  final thumbColor = args.valueOf<Color>('thumbColor');
  final inactiveThumbColor = args.valueOf<Color>('inactiveThumbColor');
  final applyTheme = args.valueOf<bool>('applyTheme');
  final thumbIcon = args.valueOf<WidgetStateProperty<Icon?>>('thumbIcon');
  final activeThumbImage = args.valueOf<ImageProvider>('activeThumbImage');
  final inactiveThumbImage = args.valueOf<ImageProvider>('inactiveThumbImage');
  final trackOutlineColor = args.valueOf<WidgetStateProperty<Color?>>(
    'trackOutlineColor',
  );
  final trackOutlineWidth = args.valueOf<WidgetStateProperty<double?>>(
    'trackOutlineWidth',
  );
  // どちらも必須のプロパティなので、常に値がある
  final enabled = args.valueOf<bool>('onChanged')!;
  return DemoValue<bool>(
    initial: args.valueOf<bool>('value')!,
    builder: (context, value, onChanged) => CupertinoSwitch(
      value: value,
      activeTrackColor: activeTrackColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      inactiveThumbColor: inactiveThumbColor,
      applyTheme: applyTheme,
      thumbIcon: thumbIcon,
      activeThumbImage: activeThumbImage,
      inactiveThumbImage: inactiveThumbImage,
      trackOutlineColor: trackOutlineColor,
      trackOutlineWidth: trackOutlineWidth,
      onChanged: enabled ? onChanged : null,
    ),
  );
}
