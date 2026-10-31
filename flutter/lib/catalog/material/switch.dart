import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// つまみの画像に使う、デモのアセット。
const _thumbImage = 'assets/demo/landscape.png';

final switchEntry = WidgetEntry(
  id: 'switch',
  name: 'Switch',
  genreIds: const ['material'],
  summary: '1 つの設定の ON / OFF を切り替える',
  description:
      '1 つの設定の ON / OFF を、つまみを左右に動かして切り替えます。Switch 自身は値を持たないので、'
      '押されると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Switch-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'value',
      group: PropertyGroup.content,
      typeLabel: 'bool',
      description: 'ON か',
      required: true,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<bool>?',
      description: '押されたときに新しい値で呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'activeThumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ON のときのつまみの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'activeTrackColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ON のときの溝（つまみの通り道）の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'inactiveThumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'OFF のときのつまみの色。value を OFF にすると見える',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'inactiveTrackColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'OFF のときの溝の色。value を OFF にすると見える',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'thumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description:
          'つまみの色を状態ごとに決める。activeThumbColor・inactiveThumbColor より優先する。'
          'ここではどの状態でも同じ色',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('紅', Color(0xFFD7003A)),
          ('瑠璃', Color(0xFF1E50A2)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'trackColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description:
          '溝の色を状態ごとに決める。activeTrackColor・inactiveTrackColor より優先する。'
          'ここではどの状態でも同じ色',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('山吹', Color(0xFFF8B500)),
          ('若竹', Color(0xFF68BE8D)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'trackOutlineColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '溝のふちの線の色。指定しないと、ON では透明、OFF ではテーマの outline',
      initiallyOn: false,
      control: ChoiceControl(
        choices: _stateColors(const [
          ('墨', Color(0xFF18181B)),
          ('紅', Color(0xFFD7003A)),
        ]),
      ),
    ),
    PropertySpec(
      name: 'trackOutlineWidth',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<double?>?',
      description: '溝のふちの線の太さ。指定しないと 2',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 4,
        divisions: 4,
        initialValue: 3,
        resolve: (v) => WidgetStatePropertyAll<double?>(v),
        code: (v) => 'WidgetStatePropertyAll($v)',
      ),
    ),
    const PropertySpec(
      name: 'thumbIcon',
      group: PropertyGroup.content,
      typeLabel: 'WidgetStateProperty<Icon?>?',
      description: 'つまみの中のアイコン。状態（ON / OFF など）ごとに変えられる',
      initiallyOn: false,
      control: FixedControl(
        value: WidgetStateProperty<Icon?>.fromMap({
          WidgetState.selected: Icon(Icons.check),
          WidgetState.any: Icon(Icons.close),
        }),
        source:
            'WidgetStateProperty.fromMap({WidgetState.selected: Icon(Icons.check), '
            'WidgetState.any: Icon(Icons.close)})',
      ),
    ),
    const PropertySpec(
      name: 'activeThumbImage',
      group: PropertyGroup.content,
      typeLabel: 'ImageProvider?',
      description: 'ON のときにつまみに描く画像',
      initiallyOn: false,
      control: FixedControl(
        value: AssetImage(_thumbImage),
        source: "AssetImage('$_thumbImage')",
      ),
    ),
    const PropertySpec(
      name: 'inactiveThumbImage',
      group: PropertyGroup.content,
      typeLabel: 'ImageProvider?',
      description: 'OFF のときにつまみに描く画像。value を OFF にすると見える',
      initiallyOn: false,
      control: FixedControl(
        value: AssetImage(_thumbImage),
        source: "AssetImage('$_thumbImage')",
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description:
          '押している間につまみのまわりに広がる丸の色。指定しないと activeThumbColor かテーマの色を薄くしたもの',
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
      description: '押せる範囲の最小の大きさ。shrinkWrap にすると上下の余白がなくなる。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in MaterialTapTargetSize.values)
            Choice(value.name, value, 'MaterialTapTargetSize.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'Switch の枠の内側の余白。指定しないと左右 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
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
      description: '非推奨。activeThumbColor か activeTrackColor を使う',
    ),
    ReferenceArg(
      name: 'onActiveThumbImageError',
      typeLabel: 'ImageErrorListener?',
      description:
          'activeThumbImage の読み込みに失敗したときに呼ばれる。activeThumbImage がないと渡せない',
    ),
    ReferenceArg(
      name: 'onInactiveThumbImageError',
      typeLabel: 'ImageErrorListener?',
      description:
          'inactiveThumbImage の読み込みに失敗したときに呼ばれる。inactiveThumbImage がないと渡せない',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'つまみのドラッグをいつ始めたとみなすか（触れた瞬間か、動き出してからか）。指定しないと start',
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
      name: 'onFocusChange',
      typeLabel: 'ValueChanged<bool>?',
      description: 'フォーカスを得たとき・失ったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '画面に出たときに最初からフォーカスするか。指定しないと false',
    ),
  ],
  build: _build,
  codeName: 'Switch',
);

void _onChanged(bool value) {}

List<Choice> _stateColors(List<(String, Color)> colors) => [
  for (final (name, color) in colors)
    Choice(
      name,
      WidgetStatePropertyAll<Color?>(color),
      'WidgetStatePropertyAll(${colorCode(color)})',
    ),
];

Widget _build(DemoArgs args) => Switch(
  value: args.valueOf<bool>('value') ?? false,
  onChanged: args.valueOf<ValueChanged<bool>>('onChanged'),
  activeThumbColor: args.valueOf<Color>('activeThumbColor'),
  activeTrackColor: args.valueOf<Color>('activeTrackColor'),
  inactiveThumbColor: args.valueOf<Color>('inactiveThumbColor'),
  inactiveTrackColor: args.valueOf<Color>('inactiveTrackColor'),
  thumbColor: args.valueOf<WidgetStateProperty<Color?>>('thumbColor'),
  trackColor: args.valueOf<WidgetStateProperty<Color?>>('trackColor'),
  trackOutlineColor: args.valueOf<WidgetStateProperty<Color?>>(
    'trackOutlineColor',
  ),
  trackOutlineWidth: args.valueOf<WidgetStateProperty<double?>>(
    'trackOutlineWidth',
  ),
  thumbIcon: args.valueOf<WidgetStateProperty<Icon?>>('thumbIcon'),
  activeThumbImage: args.valueOf<ImageProvider>('activeThumbImage'),
  inactiveThumbImage: args.valueOf<ImageProvider>('inactiveThumbImage'),
  overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
  splashRadius: args.valueOf<double>('splashRadius'),
  materialTapTargetSize: args.valueOf<MaterialTapTargetSize>(
    'materialTapTargetSize',
  ),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
);
