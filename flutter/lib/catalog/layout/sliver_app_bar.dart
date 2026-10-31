import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverAppBarEntry = WidgetEntry(
  id: 'sliverAppBar',
  name: 'SliverAppBar',
  genreIds: const ['layout', 'scrolling'],
  summary: 'スクロールに合わせて縮む・隠れる・残る AppBar',
  description:
      'CustomScrollView の最初の sliver に置く AppBar。'
      'スクロールすると上へ隠れます。pinned で上に残し、floating で少し戻すだけで現れます。'
      'ここでは下に 12 行の SliverList をつないでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/SliverAppBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'title',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '題',
      control: FixedControl(
        value: Text('SliverAppBar'),
        source: "Text('SliverAppBar')",
      ),
    ),
    const PropertySpec(
      name: 'pinned',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'スクロールしても、縮めた高さで上に残すか。既定は false',
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'floating',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '上へ戻し始めたらすぐ現れるか（一番上まで戻らなくても）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'expandedHeight',
      group: PropertyGroup.size,
      pairsWith: ['flexibleSpace'],
      typeLabel: 'double?',
      description: '広げたときの高さ。スクロールでツールバーの高さまで縮む',
      initiallyOn: false,
      control: SliderControl(
        min: 64,
        max: 160,
        divisions: 4,
        initialValue: 112,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '地の色。既定はテーマの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', DemoTile.colors[1]),
          Choice.color('若竹', DemoTile.colors[2]),
        ],
      ),
    ),
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
      name: 'automaticallyImplyLeading',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'leading がないとき、戻るボタンなどを自動で付けるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'actions',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>?',
      description: '題の右に並べる Widget。ふつうは IconButton',
      initiallyOn: false,
      control: FixedControl(
        value: <Widget>[IconButton(onPressed: _noop, icon: Icon(Icons.search))],
        source: '[IconButton(onPressed: () {}, icon: Icon(Icons.search))]',
      ),
    ),
    const PropertySpec(
      name: 'flexibleSpace',
      group: PropertyGroup.content,
      pairsWith: ['expandedHeight'],
      typeLabel: 'Widget?',
      description: 'ツールバーの後ろに敷く Widget。広げた高さいっぱいに広がり、縮むと隠れる',
      initiallyOn: false,
      control: FixedControl(
        value: FlexibleSpaceBar(background: DemoTile(3)),
        source: 'FlexibleSpaceBar(background: Tile(3))',
      ),
    ),
    const PropertySpec(
      name: 'bottom',
      group: PropertyGroup.content,
      typeLabel: 'PreferredSizeWidget?',
      description: 'ツールバーの下に付ける帯。ふつうは TabBar',
      initiallyOn: false,
      control: FixedControl(
        value: PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: DemoTile(4, height: 24),
        ),
        source:
            'PreferredSize(preferredSize: Size.fromHeight(24), child: Tile(4))',
      ),
    ),
    const PropertySpec(
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
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'scrolledUnderElevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '下の中身が帯の下に潜り込んだときの浮き上がりの高さ',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '浮き上がったときの影の色',
      initiallyOn: false,
      control: ColorControl(palette: [Choice.color('紅', DemoTile.colors[3])]),
    ),
    PropertySpec(
      name: 'surfaceTintColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '浮き上がった高さに合わせて地に重ねる色',
      initiallyOn: false,
      control: ColorControl(palette: [Choice.color('紅', DemoTile.colors[3])]),
    ),
    const PropertySpec(
      name: 'forceElevated',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: '中身が潜り込んでいなくても、elevation の影を出すか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'foregroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '題とアイコンの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', DemoTile.colors[3]),
          Choice.color('瑠璃', DemoTile.colors[0]),
        ],
      ),
    ),
    const PropertySpec(
      name: 'iconTheme',
      group: PropertyGroup.paint,
      typeLabel: 'IconThemeData?',
      description: 'leading など、帯の中のアイコンの色と大きさ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '紅',
            IconThemeData(color: Color(0xFFD7003A)),
            'IconThemeData(color: Color(0xFFD7003A))',
          ),
          Choice('大きく 32', IconThemeData(size: 32), 'IconThemeData(size: 32)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'actionsIconTheme',
      group: PropertyGroup.paint,
      typeLabel: 'IconThemeData?',
      description: 'actions のアイコンの色と大きさ。指定しないと iconTheme と同じ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '若竹',
            IconThemeData(color: Color(0xFF68BE8D)),
            'IconThemeData(color: Color(0xFF68BE8D))',
          ),
          Choice('大きく 32', IconThemeData(size: 32), 'IconThemeData(size: 32)'),
        ],
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
    const PropertySpec(
      name: 'titleSpacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double?',
      description: '題の左右のあき。指定しないと 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 6,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'collapsedHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '縮めたときの高さ。toolbarHeight より小さくはできない。指定しないと toolbarHeight',
      initiallyOn: false,
      control: SliderControl(
        min: 64,
        max: 112,
        divisions: 3,
        initialValue: 80,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'snap',
      group: PropertyGroup.behavior,
      requires: 'floating',
      omitIf: (settings) => !_isFloating(settings),
      typeLabel: 'bool',
      description: 'floating で現れ始めたら、指を離しても最後まで出しきるか。floating が true のときだけ使える',
      initiallyOn: false,
      control: const SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'stretch',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '端を越えて引いたとき、帯を引き伸ばすか（iOS のように跳ね返るスクロールのとき）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '帯の形。影もこの形に落ちる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '下の角を丸く',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            'RoundedRectangleBorder(borderRadius: '
                'BorderRadius.vertical(bottom: Radius.circular(16)))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'toolbarHeight',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'ツールバー（題とアイコンの段）の高さ。既定は 56',
      initiallyOn: false,
      control: SliderControl(
        min: 40,
        max: 56,
        divisions: 2,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'leadingWidth',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: 'leading に取る幅。指定しないと 56',
      initiallyOn: false,
      control: SliderControl(
        min: 32,
        max: 96,
        divisions: 4,
        initialValue: 96,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'titleTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: '題の文字の書式',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太字 24',
            TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            'TextStyle(fontSize: 24, fontWeight: FontWeight.bold)',
          ),
          Choice(
            '斜体',
            TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            'TextStyle(fontSize: 18, fontStyle: FontStyle.italic)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'forceMaterialTransparency',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: '帯の地を透明にし、下の中身を押せるようにするか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: '帯の形（shape）からはみ出した中身を切り抜くか。指定しないと切り抜かない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
        ],
      ),
    ),
    PropertySpec(
      name: 'actionsPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'actions のまわりの余白。ここでは左右に同じ幅を入れる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 24,
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
      name: 'automaticallyImplyActions',
      typeLabel: 'bool',
      description: 'actions がないとき、Scaffold の endDrawer を開くボタンを自動で付けるか。既定は true',
    ),
    ReferenceArg(
      name: 'primary',
      typeLabel: 'bool',
      description: '画面の一番上に置くものとして、ステータスバーの高さだけ上をあけるか。既定は true',
    ),
    ReferenceArg(
      name: 'excludeHeaderSemantics',
      typeLabel: 'bool',
      description: '読み上げで、題を見出しとして扱わないようにするか。既定は false',
    ),
    ReferenceArg(
      name: 'stretchTriggerOffset',
      typeLabel: 'double',
      description: 'onStretchTrigger を呼ぶまでに引き伸ばす量。既定は 100',
    ),
    ReferenceArg(
      name: 'onStretchTrigger',
      typeLabel: 'AsyncCallback?',
      description:
          'stretch で stretchTriggerOffset まで引き伸ばしたときに呼ばれる。引っぱって更新などに使う',
    ),
    ReferenceArg(
      name: 'toolbarTextStyle',
      typeLabel: 'TextStyle?',
      description: 'leading・actions の中の文字の書式。題には titleTextStyle を使う',
    ),
    ReferenceArg(
      name: 'systemOverlayStyle',
      typeLabel: 'SystemUiOverlayStyle?',
      description: '帯の後ろにあるステータスバーの文字・アイコンの色',
    ),
    ReferenceArg(
      name: 'useDefaultSemanticsOrder',
      typeLabel: 'bool',
      description: '読み上げの順を、leading・題・actions の決まった順にするか。既定は true',
    ),
  ],
  build: _build,
  codeName: 'SliverAppBar',
);

void _noop() {}

/// floating が ON で true か（snap は floating が true のときだけ渡せる。assert）。
bool _isFloating(Map<String, PropertySetting> settings) {
  final floating = settings['floating'];
  return floating != null &&
      floating.on &&
      floating.value is SwitchValue &&
      (floating.value as SwitchValue).value;
}

Widget _build(DemoArgs args) {
  final floating = args.valueOf<bool>('floating') ?? false;
  return CustomScrollView(
    slivers: [
      SliverAppBar(
        leading: args.valueOf<Widget>('leading'),
        // Flutter の既定値（true）。OFF のときも省いたコードと同じ挙動にそろえる。
        automaticallyImplyLeading:
            args.valueOf<bool>('automaticallyImplyLeading') ?? true,
        title: args.valueOf<Widget>('title'),
        actions: args.valueOf<List<Widget>>('actions'),
        flexibleSpace: args.valueOf<Widget>('flexibleSpace'),
        bottom: args.valueOf<PreferredSizeWidget>('bottom'),
        elevation: args.valueOf<double>('elevation'),
        scrolledUnderElevation: args.valueOf<double>('scrolledUnderElevation'),
        shadowColor: args.valueOf<Color>('shadowColor'),
        surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
        forceElevated: args.valueOf<bool>('forceElevated') ?? false,
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        foregroundColor: args.valueOf<Color>('foregroundColor'),
        iconTheme: args.valueOf<IconThemeData>('iconTheme'),
        actionsIconTheme: args.valueOf<IconThemeData>('actionsIconTheme'),
        centerTitle: args.valueOf<bool>('centerTitle'),
        titleSpacing: args.valueOf<double>('titleSpacing'),
        collapsedHeight: args.valueOf<double>('collapsedHeight'),
        expandedHeight: args.valueOf<double>('expandedHeight'),
        floating: floating,
        pinned: args.valueOf<bool>('pinned') ?? false,
        // omitIf と同じ条件。floating が true でないと snap は渡せない（assert）
        snap: floating && (args.valueOf<bool>('snap') ?? false),
        stretch: args.valueOf<bool>('stretch') ?? false,
        shape: args.valueOf<ShapeBorder>('shape'),
        toolbarHeight: args.valueOf<double>('toolbarHeight') ?? kToolbarHeight,
        leadingWidth: args.valueOf<double>('leadingWidth'),
        titleTextStyle: args.valueOf<TextStyle>('titleTextStyle'),
        forceMaterialTransparency:
            args.valueOf<bool>('forceMaterialTransparency') ?? false,
        clipBehavior: args.valueOf<Clip>('clipBehavior'),
        actionsPadding: args.valueOf<EdgeInsetsGeometry>('actionsPadding'),
      ),
      SliverList.list(
        children: [for (var i = 1; i <= 12; i++) DemoTile(i, height: 32)],
      ),
    ],
  );
}
