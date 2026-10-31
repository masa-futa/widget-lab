import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final chipEntry = WidgetEntry(
  id: 'chip',
  name: 'Chip',
  genreIds: const ['material'],
  summary: '属性やタグを小さな角丸の札で見せる',
  description:
      '人・タグ・属性などを、小さな角丸の札で見せます。左に avatar、右に消すボタンを付けられます。'
      '選んだり押したりする札には ChoiceChip・FilterChip・ActionChip を使います。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/material/Chip-class.html'),
  properties: [
    const PropertySpec(
      name: 'label',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '札の文字',
      required: true,
      control: FixedControl(value: Text('Flutter'), source: "Text('Flutter')"),
    ),
    const PropertySpec(
      name: 'avatar',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '文字の左に置く Widget。ふつうはアイコンか CircleAvatar',
      control: FixedControl(
        value: Icon(Icons.local_offer),
        source: 'Icon(Icons.local_offer)',
      ),
    ),
    const PropertySpec(
      name: 'onDeleted',
      group: PropertyGroup.content,
      typeLabel: 'VoidCallback?',
      description: '渡すと右に消すボタン（×）が出て、押すと呼ばれる',
      initiallyOn: false,
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '札の地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('白', const Color(0xFFFFFFFF)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '札の浮き上がりの高さ。影が付く',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'labelStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: '札の文字の書式。中の値を組み合わせて TextStyle を作る。指定しないとテーマの labelLarge',
      initiallyOn: false,
      control: NestedControl(
        typeName: 'TextStyle',
        children: [
          PropertySpec(
            name: 'color',
            typeLabel: 'Color?',
            description: '文字の色',
            control: ColorControl(
              palette: [
                Choice.color('紅', const Color(0xFFD7003A)),
                Choice.color('瑠璃', const Color(0xFF1E50A2)),
              ],
            ),
          ),
          PropertySpec(
            name: 'fontSize',
            typeLabel: 'double?',
            description: '文字の大きさ',
            initiallyOn: false,
            control: SliderControl(
              min: 10,
              max: 20,
              divisions: 5,
              initialValue: 16,
              resolve: (v) => v,
              code: (v) => '$v',
            ),
          ),
          PropertySpec(
            name: 'fontWeight',
            typeLabel: 'FontWeight?',
            description: '文字の太さ',
            initiallyOn: false,
            control: ChoiceControl(
              choices: [
                for (final (name, weight) in const [
                  ('w300', FontWeight.w300),
                  ('bold', FontWeight.bold),
                ])
                  Choice(name, weight, 'FontWeight.$name'),
              ],
            ),
          ),
        ],
        build: _buildTextStyle,
      ),
    ),
    PropertySpec(
      name: 'labelPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '文字のまわりの余白。指定しないと左右 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 12,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '札の中身と外の形のあいだの余白。指定しないと 8',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 3,
        initialValue: 4,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'deleteIcon',
      group: PropertyGroup.content,
      requires: 'onDeleted',
      typeLabel: 'Widget?',
      description: '消すボタンのアイコン。onDeleted があるときだけ出る。指定しないと Icons.clear',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.highlight_off),
        source: 'Icon(Icons.highlight_off)',
      ),
    ),
    PropertySpec(
      name: 'deleteIconColor',
      group: PropertyGroup.paint,
      requires: 'onDeleted',
      typeLabel: 'Color?',
      description: '消すボタンのアイコンの色。onDeleted があるときだけ出る。指定しないと iconTheme の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'deleteIconBoxConstraints',
      group: PropertyGroup.size,
      requires: 'onDeleted',
      typeLabel: 'BoxConstraints?',
      description: '消すボタンの大きさの上限と下限。指定しないと札の高さに合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'tight 16×16',
            BoxConstraints.tightFor(width: 16, height: 16),
            'BoxConstraints.tightFor(width: 16, height: 16)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'avatarBoxConstraints',
      group: PropertyGroup.size,
      requires: 'avatar',
      typeLabel: 'BoxConstraints?',
      description: 'avatar の大きさの上限と下限。指定しないと札の高さに合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'tight 16×16',
            BoxConstraints.tightFor(width: 16, height: 16),
            'BoxConstraints.tightFor(width: 16, height: 16)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '札を塗る色。状態ごとに変えられ、backgroundColor より優先する',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('瑠璃', Color(0xFF1E50A2)),
            ('若竹', Color(0xFF68BE8D)),
          ])
            Choice(
              name,
              WidgetStatePropertyAll<Color?>(color),
              'WidgetStatePropertyAll(${colorCode(color)})',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'side',
      group: PropertyGroup.paint,
      typeLabel: 'BorderSide?',
      description:
          '札のふちの線。shape と組み合わせて描く。BorderSide.none で線を消す。指定しないとテーマの outline の線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '紅の線',
            BorderSide(color: Color(0xFFD7003A), width: 2),
            'BorderSide(color: Color(0xFFD7003A), width: 2)',
          ),
          Choice('線なし', BorderSide.none, 'BorderSide.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'OutlinedBorder?',
      description: '札の形。ふちの線は side が優先する。指定しないと角の丸みが 8 の四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          const Choice('StadiumBorder', StadiumBorder(), 'StadiumBorder()'),
          Choice(
            '角丸 0',
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            'RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '中身を札の形で切り抜くか。指定しないと Clip.none',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in const [
            Clip.hardEdge,
            Clip.antiAlias,
            Clip.antiAliasWithSaveLayer,
          ])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      requires: 'elevation',
      typeLabel: 'Color?',
      description: '影の色。elevation が 0 より大きいときだけ効く。指定しないと透明（影が見えない）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'surfaceTintColor',
      group: PropertyGroup.paint,
      requires: 'elevation',
      typeLabel: 'Color?',
      description: '浮き上がりの高さに応じて地に重ねる色。elevation が 0 より大きいときだけ効く。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'iconTheme',
      group: PropertyGroup.paint,
      typeLabel: 'IconThemeData?',
      description: '札の中のアイコン（avatar・消すボタン）の色と大きさ。指定しないとテーマの primary・大きさ 18',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '紅',
            IconThemeData(color: Color(0xFFD7003A)),
            'IconThemeData(color: Color(0xFFD7003A))',
          ),
          Choice('小さめ 12', IconThemeData(size: 12), 'IconThemeData(size: 12)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'visualDensity',
      group: PropertyGroup.size,
      typeLabel: 'VisualDensity?',
      description: '札の高さの詰め具合（横には効かない）。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, density) in const [
            ('standard', VisualDensity.standard),
            ('comfortable', VisualDensity.comfortable),
            ('compact', VisualDensity.compact),
          ])
            Choice(name, density, 'VisualDensity.$name'),
        ],
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
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'deleteButtonTooltipMessage',
      typeLabel: 'String?',
      description: '消すボタンを長押ししたときに出る説明。指定しないと「削除」の訳語',
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
      name: 'chipAnimationStyle',
      typeLabel: 'ChipAnimationStyle?',
      description: '押せる・押せないの切り替えや、消すボタンの出入りのアニメーションの長さ。Chip は選べないので見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形。タッチの端末では違いが出ない',
    ),
  ],
  build: _build,
  codeName: 'Chip',
);

void _noop() {}

TextStyle _buildTextStyle(Map<String, Object> values) => TextStyle(
  color: values['color'] as Color?,
  fontSize: values['fontSize'] as double?,
  fontWeight: values['fontWeight'] as FontWeight?,
);

Widget _build(DemoArgs args) => Chip(
  label: args.valueOf<Widget>('label') ?? const SizedBox.shrink(),
  avatar: args.valueOf<Widget>('avatar'),
  onDeleted: args.valueOf<VoidCallback>('onDeleted'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
  labelStyle: args.valueOf<TextStyle>('labelStyle'),
  labelPadding: args.valueOf<EdgeInsetsGeometry>('labelPadding'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  deleteIcon: args.valueOf<Widget>('deleteIcon'),
  deleteIconColor: args.valueOf<Color>('deleteIconColor'),
  deleteIconBoxConstraints: args.valueOf<BoxConstraints>(
    'deleteIconBoxConstraints',
  ),
  avatarBoxConstraints: args.valueOf<BoxConstraints>('avatarBoxConstraints'),
  color: args.valueOf<WidgetStateProperty<Color?>>('color'),
  side: args.valueOf<BorderSide>('side'),
  shape: args.valueOf<OutlinedBorder>('shape'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
  shadowColor: args.valueOf<Color>('shadowColor'),
  surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
  iconTheme: args.valueOf<IconThemeData>('iconTheme'),
  visualDensity: args.valueOf<VisualDensity>('visualDensity'),
  materialTapTargetSize: args.valueOf<MaterialTapTargetSize>(
    'materialTapTargetSize',
  ),
);
