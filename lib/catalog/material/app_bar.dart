import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final appBarEntry = WidgetEntry(
  id: 'appBar',
  name: 'AppBar',
  genreIds: const ['material', 'basics'],
  summary: '画面の上の帯。題・戻るボタン・操作のアイコンを並べる',
  description:
      '画面の上に置く帯です。左に leading（戻るボタンなど）、中に題、右に actions を並べます。'
      'ふつうは Scaffold の appBar に渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/AppBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'leading',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題の左に置く Widget。指定しないと、戻れる画面では戻るボタンが自動で付く',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.menu),
        source: 'Icon(Icons.menu)',
      ),
    ),
    const PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '帯の題',
      control: FixedControl(value: Text('受信箱'), source: "Text('受信箱')"),
    ),
    const PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '題の右に並べる Widget。ふつうは IconButton',
      control: FixedControl(
        value: <Widget>[
          IconButton(onPressed: _noop, icon: Icon(Icons.search)),
          IconButton(onPressed: _noop, icon: Icon(Icons.more_vert)),
        ],
        source:
            '[IconButton(onPressed: () {}, icon: Icon(Icons.search)), '
            'IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))]',
      ),
    ),
    const PropertySpec(
      name: 'flexibleSpace',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '帯の後ろに重ねて敷く Widget。帯と同じ大きさに広がる',
      initiallyOn: false,
      control: FixedControl(
        value: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E50A2), Color(0xFF68BE8D)],
            ),
          ),
        ),
        source:
            'DecoratedBox(decoration: BoxDecoration(gradient: '
            'LinearGradient(colors: [Color(0xFF1E50A2), Color(0xFF68BE8D)])))',
      ),
    ),
    const PropertySpec(
      name: 'bottom',
      group: PropertyGroup.content,
      typeLabel: 'PreferredSizeWidget?',
      description: '帯の下の段に置く Widget。ふつうは TabBar',
      initiallyOn: false,
      control: FixedControl(
        value: PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Text('未読 3 件'),
        ),
        source: "PreferredSize(preferredSize: Size.fromHeight(24), child: Text('未読 3 件'))",
      ),
    ),
    const PropertySpec(
      name: 'centerTitle',
      group: PropertyGroup.layout,
      typeLabel: 'bool?',
      description: '題を中央に置くか。指定しないと Android は左寄せ、iOS は中央',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'toolbarHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '帯（bottom を除く）の高さ。指定しないと 56',
      initiallyOn: false,
      control: SliderControl(
        min: 40,
        max: 72,
        divisions: 8,
        initialValue: 44,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'leadingWidth',
      group: PropertyGroup.size,
      requires: 'leading',
      typeLabel: 'double?',
      description: 'leading に取る幅。指定しないと 56',
      initiallyOn: false,
      control: SliderControl(
        min: 32,
        max: 80,
        divisions: 6,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'titleSpacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '題の左右の間隔。0 にすると題が横いっぱいに広がる。指定しないと 16',
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
      name: 'actionsPadding',
      group: PropertyGroup.spacing,
      requires: 'actions',
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'actions と帯の右端のあいだの余白。指定しないと 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 16,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'foregroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '題とアイコンの色。指定しないとテーマの onSurface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('生成', const Color(0xFFFBFAF5)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。影の濃さが変わる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の下の影の色。指定しないと Material 3 では透明（影が出ない）',
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
      description: '帯と影の形。指定しないと四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '下の角丸',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            'RoundedRectangleBorder(borderRadius: '
                'BorderRadius.vertical(bottom: Radius.circular(16)))',
          ),
          Choice(
            '面取り',
            BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            'BeveledRectangleBorder(borderRadius: '
                'BorderRadius.all(Radius.circular(12)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'iconTheme',
      group: PropertyGroup.paint,
      typeLabel: 'IconThemeData?',
      description: '帯のアイコンの色と大きさ。指定しないと foregroundColor の色',
      initiallyOn: false,
      control: _iconThemeControl(),
    ),
    PropertySpec(
      name: 'actionsIconTheme',
      group: PropertyGroup.paint,
      requires: 'actions',
      typeLabel: 'IconThemeData?',
      description: 'actions のアイコンだけの色と大きさ。指定しないと iconTheme',
      initiallyOn: false,
      control: _iconThemeControl(),
    ),
    PropertySpec(
      name: 'toolbarOpacity',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '帯（bottom を除く）の中身の不透明さ。0 で見えなくなる。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 4,
        initialValue: 0.5,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'bottomOpacity',
      group: PropertyGroup.paint,
      requires: 'bottom',
      typeLabel: 'double',
      description: 'bottom の不透明さ。0 で見えなくなる。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 4,
        initialValue: 0.5,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'forceMaterialTransparency',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description:
          '帯の地を透明にするか。true だと backgroundColor と elevation が描かれない。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: '帯の中身を shape の形で切り抜くか。指定しないと切り抜かない',
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
      description: '題の文字の書式。指定しないとテーマの titleLarge',
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
      name: 'automaticallyImplyLeading',
      typeLabel: 'bool',
      description:
          'leading がないとき、戻るボタンやドロワーのボタンを自動で付けるか。指定しないと true。'
          '見本では詳細画面から戻ってしまわないよう false に決めている',
    ),
    ReferenceArg(
      name: 'automaticallyImplyActions',
      typeLabel: 'bool',
      description:
          'actions がないとき、Scaffold の endDrawer を開くボタンを自動で付けるか。指定しないと true',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool',
      description:
          '画面のいちばん上に置く帯として、ステータスバーの高さの余白を上に取るか。指定しないと true。'
          '見本ではカードの中に置くので false に決めている',
    ),
    ReferenceArg(
      name: 'scrolledUnderElevation',
      typeLabel: 'double?',
      description: '下の中身が帯の下にスクロールしたときの浮き上がりの高さ。この見本には流れる中身がないので違いが出ない',
    ),
    ReferenceArg(
      name: 'notificationPredicate',
      typeLabel: 'ScrollNotificationPredicate',
      description: 'どのスクロールを見て、中身が帯の下に流れたと判断するかを決める関数',
    ),
    ReferenceArg(
      name: 'animateColor',
      typeLabel: 'bool',
      description: '中身が帯の下に流れたときの地の色の変化をアニメーションするか。指定しないと false',
    ),
    ReferenceArg(
      name: 'toolbarTextStyle',
      typeLabel: 'TextStyle?',
      description: 'leading・actions に置いた文字の書式（題は除く）。この見本はアイコンなので違いが出ない',
    ),
    ReferenceArg(
      name: 'systemOverlayStyle',
      typeLabel: 'SystemUiOverlayStyle?',
      description: '帯の後ろのステータスバーの文字やアイコンの色。カードの中では違いが出ない',
    ),
    ReferenceArg(
      name: 'excludeHeaderSemantics',
      typeLabel: 'bool',
      description: '題を読み上げで見出しとして扱わないか。指定しないと false',
    ),
    ReferenceArg(
      name: 'useDefaultSemanticsOrder',
      typeLabel: 'bool',
      description: '読み上げの順を既定（flexibleSpace を後ろ）にするか。指定しないと true',
    ),
  ],
  build: _build,
  codeName: 'AppBar',
);

void _noop() {}

ChoiceControl _iconThemeControl() => const ChoiceControl(
  choices: [
    Choice(
      '紅・大きめ',
      IconThemeData(color: Color(0xFFD7003A), size: 28),
      'IconThemeData(color: Color(0xFFD7003A), size: 28)',
    ),
    Choice(
      '瑠璃・小さめ',
      IconThemeData(color: Color(0xFF1E50A2), size: 18),
      'IconThemeData(color: Color(0xFF1E50A2), size: 18)',
    ),
  ],
);

TextStyle _buildTextStyle(Map<String, Object> values) => TextStyle(
  color: values['color'] as Color?,
  fontSize: values['fontSize'] as double?,
  fontWeight: values['fontWeight'] as FontWeight?,
);

Widget _build(DemoArgs args) => AppBar(
  // 詳細画面の中なので、戻るボタンが勝手に付かないようにする
  automaticallyImplyLeading: false,
  // プレビューのカードの中なので、上のステータスバーの余白を取らない
  primary: false,
  leading: args.valueOf<Widget>('leading'),
  title: args.valueOf<Widget>('title'),
  actions: args.valueOf<List<Widget>>('actions'),
  flexibleSpace: args.valueOf<Widget>('flexibleSpace'),
  bottom: args.valueOf<PreferredSizeWidget>('bottom'),
  centerTitle: args.valueOf<bool>('centerTitle'),
  toolbarHeight: args.valueOf<double>('toolbarHeight'),
  leadingWidth: args.valueOf<double>('leadingWidth'),
  titleSpacing: args.valueOf<double>('titleSpacing'),
  actionsPadding: args.valueOf<EdgeInsetsGeometry>('actionsPadding'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  foregroundColor: args.valueOf<Color>('foregroundColor'),
  elevation: args.valueOf<double>('elevation'),
  shadowColor: args.valueOf<Color>('shadowColor'),
  surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
  shape: args.valueOf<ShapeBorder>('shape'),
  iconTheme: args.valueOf<IconThemeData>('iconTheme'),
  actionsIconTheme: args.valueOf<IconThemeData>('actionsIconTheme'),
  // Flutter の既定値（1.0・false）。OFF のときも省いたコードと同じ挙動にそろえる。
  toolbarOpacity: args.valueOf<double>('toolbarOpacity') ?? 1.0,
  bottomOpacity: args.valueOf<double>('bottomOpacity') ?? 1.0,
  forceMaterialTransparency:
      args.valueOf<bool>('forceMaterialTransparency') ?? false,
  clipBehavior: args.valueOf<Clip>('clipBehavior'),
  titleTextStyle: args.valueOf<TextStyle>('titleTextStyle'),
);
