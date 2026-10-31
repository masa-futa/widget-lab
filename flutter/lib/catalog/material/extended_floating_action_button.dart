import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Extended FloatingActionButton」のカード。クラス名ではないので、
/// FloatingActionButton.extended のコンストラクタで見せる。
final extendedFloatingActionButtonEntry = WidgetEntry(
  id: 'extendedFloatingActionButton',
  name: 'Extended FloatingActionButton',
  genreIds: const ['material'],
  summary: '文字の入った、横に長い FloatingActionButton',
  description:
      'アイコンに加えて文字（label）を出す、横に長い FloatingActionButton です。'
      'FloatingActionButton.extended で作ります。isExtended を false にすると'
      'アイコンだけのボタンに縮むので、スクロールに合わせて縮める使い方もできます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/FloatingActionButton/FloatingActionButton.extended.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'label',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'ボタンの文字',
      required: true,
      control: FixedControl(value: Text('新規作成'), source: "Text('新規作成')"),
    ),
    const PropertySpec(
      name: 'icon',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '文字の左に置くアイコン',
      control: FixedControl(
        value: Icon(Icons.edit),
        source: 'Icon(Icons.edit)',
      ),
    ),
    const PropertySpec(
      name: 'isExtended',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '横に長い形で出すか。false にするとアイコンだけのボタンになる。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'extendedPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'ボタンの中身の左右の余白。指定しないと、アイコンがあれば左 16・右 20、なければ左右 20',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'extendedIconLabelSpacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: 'アイコンと文字の間の幅。指定しないと 8',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 20,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ボタンの地の色。指定しないとテーマの primaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'foregroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '中のアイコンと文字の色。指定しないとテーマの onPrimaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'splashColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '押したときに広がる波紋の色。指定しないと onPrimaryContainer を薄くしたもの',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅（半透明）', const Color(0x99D7003A)),
          Choice.color('瑠璃（半透明）', const Color(0x991E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: 'ボタンの浮き上がりの高さ。影の濃さが変わる。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'highlightElevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押している間の浮き上がりの高さ。指定しないと 12',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'disabledElevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押せないとき（onPressed が null）の浮き上がりの高さ。指定しないと elevation と同じ',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: 'ボタンの形。指定しないと角の丸い四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('StadiumBorder', StadiumBorder(), 'StadiumBorder()'),
          Choice(
            '角の小さい四角',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            'RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: 'shape の形で中身を切り抜くか。指定しないと none（切り抜かない）',
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
      name: 'extendedTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description:
          '文字（label）の書式。中の値を組み合わせて TextStyle を作る。指定しないとテーマの labelLarge',
      initiallyOn: false,
      control: NestedControl(
        typeName: 'TextStyle',
        children: [
          PropertySpec(
            name: 'fontSize',
            typeLabel: 'double?',
            description: '文字の大きさ',
            control: SliderControl(
              min: 10,
              max: 20,
              divisions: 5,
              initialValue: 18,
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
                  ('w700', FontWeight.w700),
                ])
                  Choice(name, weight, 'FontWeight.$name'),
              ],
            ),
          ),
          PropertySpec(
            name: 'letterSpacing',
            typeLabel: 'double?',
            description: '文字と文字の間の幅',
            initiallyOn: false,
            control: SliderControl(
              min: 0,
              max: 4,
              divisions: 4,
              initialValue: 2,
              resolve: (v) => v,
              code: (v) => '$v',
            ),
          ),
        ],
        build: _buildTextStyle,
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
      name: 'heroTag',
      typeLabel: 'Object?',
      description:
          '画面を移るときに、同じ印のボタンどうしを飛ぶように動かす Hero の印。'
          '指定しないと全部のボタンで同じ印になるので、1 つの画面に 2 つ置くときは別の値か null を渡す',
    ),
    ReferenceArg(
      name: 'tooltip',
      typeLabel: 'String?',
      description: '長押ししたときに出す説明の文字。読み上げにも使われる',
    ),
    ReferenceArg(
      name: 'materialTapTargetSize',
      typeLabel: 'MaterialTapTargetSize?',
      description: '押せる範囲の最小の大きさ。このボタンは高さ 56 で 48 より大きいので、見た目は変わらない',
    ),
    ReferenceArg(
      name: 'focusElevation',
      typeLabel: 'double?',
      description: 'キーボードなどで選ばれている（フォーカスがある）ときの浮き上がりの高さ。指定しないと 8',
    ),
    ReferenceArg(
      name: 'hoverElevation',
      typeLabel: 'double?',
      description: 'マウスのポインタが乗っているときの浮き上がりの高さ。指定しないと 8',
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
  ],
  build: _build,
  codeName: 'FloatingActionButton.extended',
);

void _noop() {}

TextStyle _buildTextStyle(Map<String, Object> values) => TextStyle(
  fontSize: values['fontSize'] as double?,
  fontWeight: values['fontWeight'] as FontWeight?,
  letterSpacing: values['letterSpacing'] as double?,
);

Widget _build(DemoArgs args) => FloatingActionButton.extended(
  // 一覧の見本と詳細の両方に出るので、画面の切り替えで Hero が重ならないようにする
  heroTag: null,
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  label: args.valueOf<Widget>('label') ?? const SizedBox.shrink(),
  icon: args.valueOf<Widget>('icon'),
  isExtended: args.valueOf<bool>('isExtended') ?? true,
  extendedPadding: args.valueOf<EdgeInsetsGeometry>('extendedPadding'),
  extendedIconLabelSpacing: args.valueOf<double>('extendedIconLabelSpacing'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  foregroundColor: args.valueOf<Color>('foregroundColor'),
  splashColor: args.valueOf<Color>('splashColor'),
  elevation: args.valueOf<double>('elevation'),
  highlightElevation: args.valueOf<double>('highlightElevation'),
  disabledElevation: args.valueOf<double>('disabledElevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  // Flutter の既定値（Clip.none）。OFF のときも省いたコードと同じ挙動にそろえる。
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
  extendedTextStyle: args.valueOf<TextStyle>('extendedTextStyle'),
);
