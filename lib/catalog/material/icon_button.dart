import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

const _alignmentNames = [
  ('topLeft', Alignment.topLeft),
  ('center', Alignment.center),
  ('bottomRight', Alignment.bottomRight),
];

final iconButtonEntry = WidgetEntry(
  id: 'iconButton',
  name: 'IconButton',
  genreIds: const ['material'],
  summary: 'アイコンだけのボタン',
  description:
      'アイコンだけを出すボタンです。AppBar の actions などに置きます。'
      'isSelected を渡すと、選んでいる／いないで見た目を切り替えるトグルになります。'
      'IconButton.filled などのコンストラクタで地の付いた形も作れます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/IconButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'icon',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '出すアイコン',
      required: true,
      control: FixedControl(
        value: Icon(Icons.favorite_border),
        source: 'Icon(Icons.favorite_border)',
      ),
    ),
    PropertySpec(
      name: 'iconSize',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: 'アイコンの大きさ。指定しないと 24',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 12,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'visualDensity',
      group: PropertyGroup.size,
      typeLabel: 'VisualDensity?',
      description: 'ボタンの詰まり具合。compact にすると押せる範囲が小さくなる。指定しないと standard',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('standard', VisualDensity.standard, 'VisualDensity.standard'),
          Choice(
            'comfortable',
            VisualDensity.comfortable,
            'VisualDensity.comfortable',
          ),
          Choice('compact', VisualDensity.compact, 'VisualDensity.compact'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'constraints',
      group: PropertyGroup.size,
      typeLabel: 'BoxConstraints?',
      description: 'ボタンの大きさの上限と下限。指定しないと幅・高さとも 48 以上',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'min 56×56',
            BoxConstraints(minWidth: 56, minHeight: 56),
            'BoxConstraints(minWidth: 56, minHeight: 56)',
          ),
          Choice(
            'minWidth 96',
            BoxConstraints(minWidth: 96),
            'BoxConstraints(minWidth: 96)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'アイコンのまわりの余白。余白も押せる範囲に入る。指定しないと 8',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 12,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry?',
      description: 'ボタンの中でのアイコンの位置。ボタンがアイコンより大きいときに効く。指定しないと center',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in _alignmentNames)
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'アイコンの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'highlightColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '押している間、ボタンに重ねる色。指定しないとアイコンの色を薄くしたもの',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹（半透明）', const Color(0x66F8B500)),
          Choice.color('瑠璃（半透明）', const Color(0x661E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'disabledColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '押せないとき（onPressed が null）のアイコンの色。指定しないとテーマの薄い色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.paint,
      typeLabel: 'ButtonStyle?',
      description: 'ボタンの見た目をまとめて決める。ここで決めた値は IconButton のほかの引数より優先される',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '地の色',
            IconButton.styleFrom(backgroundColor: const Color(0xFFF8B500)),
            'IconButton.styleFrom(backgroundColor: Color(0xFFF8B500))',
          ),
          Choice(
            '枠線',
            IconButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1E50A2), width: 2),
            ),
            'IconButton.styleFrom(side: BorderSide(color: Color(0xFF1E50A2), width: 2))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'isSelected',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: '選んでいるか。true のときは selectedIcon を出す。指定しないとトグルにならない',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'selectedIcon',
      group: PropertyGroup.content,
      requires: 'isSelected',
      typeLabel: 'Widget?',
      description: '選んでいるとき（isSelected が true）に出すアイコン',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.favorite),
        source: 'Icon(Icons.favorite)',
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
      name: 'onLongPress',
      typeLabel: 'VoidCallback?',
      description: '長押しされたときに呼ばれる。見た目は変わらない（押せるかは onPressed で決まる）',
    ),
    ReferenceArg(
      name: 'onHover',
      typeLabel: 'ValueChanged<bool>?',
      description: 'マウスのポインタが乗った・離れたときに呼ばれる。タッチ端末では呼ばれない',
    ),
    ReferenceArg(
      name: 'tooltip',
      typeLabel: 'String?',
      description: '長押ししたときに出す説明の文字。読み上げにも使われる',
    ),
    ReferenceArg(
      name: 'splashRadius',
      typeLabel: 'double?',
      description: '押したときの波紋の半径。Material 3 では使われない',
    ),
    ReferenceArg(
      name: 'splashColor',
      typeLabel: 'Color?',
      description: '押したときの波紋の色。Material 3 では使われず、highlightColor を使う',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードなどで選ばれている（フォーカスがある）ときに重ねる色',
    ),
    ReferenceArg(
      name: 'hoverColor',
      typeLabel: 'Color?',
      description: 'マウスのポインタが乗っているときに重ねる色',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスのポインタが乗ったときのカーソルの形',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から操作したり、状態を調べたりするときに渡す',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '最初からフォーカスを持つか。指定しないと false',
    ),
    ReferenceArg(
      name: 'enableFeedback',
      typeLabel: 'bool?',
      description: '押したときに音や振動で知らせるか。指定しないと true',
    ),
    ReferenceArg(
      name: 'statesController',
      typeLabel: 'WidgetStatesController?',
      description: '押している・選んでいるなどの状態を外から見たり変えたりするときに渡す',
    ),
  ],
  build: _build,
  codeName: 'IconButton',
);

void _noop() {}

Widget _build(DemoArgs args) => IconButton(
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  icon: args.valueOf<Widget>('icon') ?? const SizedBox.shrink(),
  iconSize: args.valueOf<double>('iconSize'),
  visualDensity: args.valueOf<VisualDensity>('visualDensity'),
  constraints: args.valueOf<BoxConstraints>('constraints'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  alignment: args.valueOf<AlignmentGeometry>('alignment'),
  color: args.valueOf<Color>('color'),
  highlightColor: args.valueOf<Color>('highlightColor'),
  disabledColor: args.valueOf<Color>('disabledColor'),
  style: args.valueOf<ButtonStyle>('style'),
  isSelected: args.valueOf<bool>('isSelected'),
  selectedIcon: args.valueOf<Widget>('selectedIcon'),
);
