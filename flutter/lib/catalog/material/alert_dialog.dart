import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// ふつうは showDialog で出すものを、AlertDialog そのものをカードの中に置いて見せる。
final alertDialogEntry = WidgetEntry(
  id: 'alertDialog',
  name: 'AlertDialog',
  genreIds: const ['material'],
  summary: '確認や知らせを出し、選んでもらうダイアログ',
  description:
      '大事な知らせや確認を出し、下のボタンで選んでもらうダイアログです。'
      'showDialog(context: context, builder: (context) => AlertDialog(…)) で出します。'
      'ここでは AlertDialog そのものをカードの中に置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/AlertDialog-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'icon',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の上に置くアイコン',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.delete_outline),
        source: 'Icon(Icons.delete_outline)',
      ),
    ),
    const PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ダイアログの題',
      control: FixedControl(value: Text('削除しますか？'), source: "Text('削除しますか？')"),
    ),
    const PropertySpec(
      name: 'content',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の下の本文',
      control: FixedControl(
        value: Text('削除したメモは元に戻せません。'),
        source: "Text('削除したメモは元に戻せません。')",
      ),
    ),
    const PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '下に並べるボタン。ふつうは TextButton',
      control: FixedControl(
        value: <Widget>[
          TextButton(onPressed: _noop, child: Text('キャンセル')),
          TextButton(onPressed: _noop, child: Text('削除')),
        ],
        source:
            "[TextButton(onPressed: () {}, child: Text('キャンセル')), "
            "TextButton(onPressed: () {}, child: Text('削除'))]",
      ),
    ),
    PropertySpec(
      name: 'actionsAlignment',
      group: PropertyGroup.layout,
      requires: 'actions',
      typeLabel: 'MainAxisAlignment?',
      description: 'ボタンの横の並べ方。指定しないと右寄せ（end）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in const [
            MainAxisAlignment.start,
            MainAxisAlignment.center,
            MainAxisAlignment.end,
            MainAxisAlignment.spaceBetween,
          ])
            Choice(value.name, value, 'MainAxisAlignment.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry?',
      description: '画面の中でのダイアログの位置。指定しないと真ん中',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('topCenter', Alignment.topCenter),
            ('center', Alignment.center),
            ('bottomCenter', Alignment.bottomCenter),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'constraints',
      group: PropertyGroup.size,
      typeLabel: 'BoxConstraints?',
      description: 'ダイアログの大きさの上限と下限。指定しないと幅 280 以上',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'maxWidth 240',
            BoxConstraints(maxWidth: 240),
            'BoxConstraints(maxWidth: 240)',
          ),
          Choice(
            'minWidth 300',
            BoxConstraints(minWidth: 300),
            'BoxConstraints(minWidth: 300)',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'insetPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsets?',
      description: '画面の端とダイアログのあいだに少なくとも空ける余白。指定しないと左右 40・上下 24',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'iconPadding',
      group: PropertyGroup.spacing,
      requires: 'icon',
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'アイコンのまわりの余白。指定しないと上と左右 24、題との間 16',
      initiallyOn: false,
      control: _paddingControl(),
    ),
    PropertySpec(
      name: 'titlePadding',
      group: PropertyGroup.spacing,
      requires: 'title',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '題のまわりの余白。指定しないと上と左右 24',
      initiallyOn: false,
      control: _paddingControl(),
    ),
    PropertySpec(
      name: 'contentPadding',
      group: PropertyGroup.spacing,
      requires: 'content',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '本文のまわりの余白。指定しないと上 16、左右と下 24',
      initiallyOn: false,
      control: _paddingControl(),
    ),
    PropertySpec(
      name: 'actionsPadding',
      group: PropertyGroup.spacing,
      requires: 'actions',
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'ボタンの並び全体とダイアログの端のあいだの余白',
      initiallyOn: false,
      control: _paddingControl(),
    ),
    PropertySpec(
      name: 'buttonPadding',
      group: PropertyGroup.spacing,
      requires: 'actions',
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'ボタン 1 つずつのまわりの余白。指定しないと左右 8',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 16,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ダイアログの地の色。指定しないとテーマの surfaceContainerHigh',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('生成', const Color(0xFFFBFAF5)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'iconColor',
      group: PropertyGroup.paint,
      requires: 'icon',
      typeLabel: 'Color?',
      description: 'アイコンの色。指定しないとテーマの secondary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: 'ダイアログの浮き上がりの高さ。影の濃さが変わる。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 12,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ダイアログの下の影の色。指定しないと Material 3 では透明（影が出ない）',
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
      typeLabel: 'Color?',
      description: '浮き上がりの高さに応じて地に重ねる色。指定しないと重ねない',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: 'ダイアログの形。指定しないと角の丸み 28 の角丸',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '小さい角丸',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            'RoundedRectangleBorder(borderRadius: '
                'BorderRadius.all(Radius.circular(8)))',
          ),
          Choice(
            '面取り',
            BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            'BeveledRectangleBorder(borderRadius: '
                'BorderRadius.all(Radius.circular(16)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: 'ダイアログの中身を shape の形で切り抜くか。指定しないと切り抜かない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in Clip.values)
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'titleTextStyle',
      group: PropertyGroup.text,
      requires: 'title',
      typeLabel: 'TextStyle?',
      description: '題の文字の書式。指定しないとテーマの headlineSmall',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
    PropertySpec(
      name: 'contentTextStyle',
      group: PropertyGroup.text,
      requires: 'content',
      typeLabel: 'TextStyle?',
      description: '本文の文字の書式。指定しないとテーマの bodyMedium',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
    const PropertySpec(
      name: 'scrollable',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '題と本文が収まらないとき、スクロールして読めるようにするか。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'actionsOverflowAlignment',
      typeLabel: 'OverflowBarAlignment?',
      description: 'ボタンが 1 行に収まらず縦に並ぶときの横の位置。この見本のボタンは収まるので違いが出ない',
    ),
    ReferenceArg(
      name: 'actionsOverflowDirection',
      typeLabel: 'VerticalDirection?',
      description: 'ボタンが 1 行に収まらず縦に並ぶときの順の向き。この見本のボタンは収まるので違いが出ない',
    ),
    ReferenceArg(
      name: 'actionsOverflowButtonSpacing',
      typeLabel: 'double?',
      description: 'ボタンが 1 行に収まらず縦に並ぶときのボタンの間隔。この見本のボタンは収まるので違いが出ない',
    ),
    ReferenceArg(
      name: 'semanticLabel',
      typeLabel: 'String?',
      description: 'ダイアログを開いたり閉じたりしたときに読み上げる名前',
    ),
  ],
  build: _build,
  codeName: 'AlertDialog',
);

void _noop() {}

SliderControl _paddingControl() => SliderControl(
  min: 0,
  max: 24,
  divisions: 6,
  initialValue: 8,
  resolve: EdgeInsets.all,
  code: (v) => 'EdgeInsets.all($v)',
);

NestedControl _textStyleControl() => NestedControl(
  typeName: 'TextStyle',
  children: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '文字の色',
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'fontSize',
      typeLabel: 'double?',
      description: '文字の大きさ',
      initiallyOn: false,
      control: SliderControl(
        min: 12,
        max: 24,
        divisions: 6,
        initialValue: 16,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'fontWeight',
      typeLabel: 'FontWeight?',
      description: '文字の太さ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('bold', FontWeight.bold, 'FontWeight.bold'),
          Choice('w300', FontWeight.w300, 'FontWeight.w300'),
        ],
      ),
    ),
  ],
  build: _buildTextStyle,
);

TextStyle _buildTextStyle(Map<String, Object> values) => TextStyle(
  color: values['color'] as Color?,
  fontSize: values['fontSize'] as double?,
  fontWeight: values['fontWeight'] as FontWeight?,
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(360, 320),
  child: AlertDialog(
    icon: args.valueOf<Widget>('icon'),
    iconPadding: args.valueOf<EdgeInsetsGeometry>('iconPadding'),
    iconColor: args.valueOf<Color>('iconColor'),
    title: args.valueOf<Widget>('title'),
    titlePadding: args.valueOf<EdgeInsetsGeometry>('titlePadding'),
    titleTextStyle: args.valueOf<TextStyle>('titleTextStyle'),
    content: args.valueOf<Widget>('content'),
    contentPadding: args.valueOf<EdgeInsetsGeometry>('contentPadding'),
    contentTextStyle: args.valueOf<TextStyle>('contentTextStyle'),
    actions: args.valueOf<List<Widget>>('actions'),
    actionsPadding: args.valueOf<EdgeInsetsGeometry>('actionsPadding'),
    actionsAlignment: args.valueOf<MainAxisAlignment>('actionsAlignment'),
    buttonPadding: args.valueOf<EdgeInsetsGeometry>('buttonPadding'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    elevation: args.valueOf<double>('elevation'),
    shadowColor: args.valueOf<Color>('shadowColor'),
    surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
    insetPadding: args.valueOf<EdgeInsets>('insetPadding'),
    clipBehavior: args.valueOf<Clip>('clipBehavior'),
    shape: args.valueOf<ShapeBorder>('shape'),
    alignment: args.valueOf<AlignmentGeometry>('alignment'),
    constraints: args.valueOf<BoxConstraints>('constraints'),
    // Flutter の既定値（false）。OFF のときも省いたコードと同じ挙動にそろえる。
    scrollable: args.valueOf<bool>('scrollable') ?? false,
  ),
);
