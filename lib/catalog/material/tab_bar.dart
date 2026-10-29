import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

const _isScrollableInitial = true;

const _tabAlignments = [
  TabAlignment.fill,
  TabAlignment.center,
  TabAlignment.start,
  TabAlignment.startOffset,
];

final tabBarEntry = WidgetEntry(
  id: 'tabBar',
  name: 'TabBar',
  genreIds: const ['material'],
  summary: 'タブを横に並べ、選んでいるものに下線を引く',
  description:
      'タブを横に並べ、選んでいるタブに下線（indicator）を引きます。'
      'TabController で TabBarView と選択をそろえます。ふつうは DefaultTabController で包み、'
      'AppBar の bottom に置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/TabBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'tabs',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: 'タブ。ふつうは Tab。数は TabController の length と同じにする',
      required: true,
      control: FixedControl(
        value: <Widget>[
          Tab(text: 'おすすめ'),
          Tab(text: '新着'),
          Tab(text: 'フォロー中'),
        ],
        source: "[Tab(text: 'おすすめ'), Tab(text: '新着'), Tab(text: 'フォロー中')]",
      ),
    ),
    const PropertySpec(
      name: 'isScrollable',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '横にスクロールできるようにするか。true だと各タブは中身の幅になり、左に寄る',
      initiallyOn: false,
      control: SwitchControl(initialValue: _isScrollableInitial),
    ),
    PropertySpec(
      name: 'tabAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'TabAlignment?',
      description:
          'タブの横の並べ方。fill は isScrollable が false のときだけ、start・startOffset は true のときだけ使える'
          '（合わない値は渡さない）。指定しないと、スクロールしないなら fill、するなら startOffset',
      initiallyOn: false,
      omitIf: _tabAlignmentMismatch,
      control: ChoiceControl(
        choices: [
          for (final value in _tabAlignments)
            Choice(value.name, value, 'TabAlignment.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'タブの列のまわりの余白。isScrollable が true だと余白ごとスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 16,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'labelPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '各タブの文字のまわりの余白。指定しないと左右 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'indicatorSize',
      group: PropertyGroup.paint,
      typeLabel: 'TabBarIndicatorSize?',
      description: '下線の幅。tab はタブの幅いっぱい、label は文字の幅',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in TabBarIndicatorSize.values)
            Choice(value.name, value, 'TabBarIndicatorSize.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'indicatorColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '下線の色。indicator を指定すると効かない。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'indicatorWeight',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '下線の太さ。0 より大きくする。indicator を指定すると効かない。指定しないと 3（Material 3 では 3 より細くできない）',
      initiallyOn: false,
      control: SliderControl(
        min: 3,
        max: 8,
        divisions: 5,
        initialValue: 6,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'indicatorPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '下線の左右を縮める余白。指定しないと EdgeInsets.zero',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 16,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    PropertySpec(
      name: 'indicator',
      group: PropertyGroup.paint,
      pairsWith: const ['splashBorderRadius'],
      typeLabel: 'Decoration?',
      description: '選んでいるタブに描く飾り。指定すると indicatorColor・indicatorWeight は効かない',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸の地',
            BoxDecoration(
              color: const Color(0x401E50A2),
              borderRadius: BorderRadius.circular(16),
            ),
            'BoxDecoration(color: Color(0x401E50A2), '
                'borderRadius: BorderRadius.circular(16))',
          ),
          const Choice(
            '太い紅の下線',
            UnderlineTabIndicator(
              borderSide: BorderSide(width: 4, color: Color(0xFFD7003A)),
            ),
            'UnderlineTabIndicator(borderSide: '
                'BorderSide(width: 4, color: Color(0xFFD7003A)))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'dividerColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description:
          'タブの列の下の区切り線の色。Colors.transparent で消える。指定しないとテーマの outlineVariant',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('透明', const Color(0x00000000)),
        ],
      ),
    ),
    PropertySpec(
      name: 'dividerHeight',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '区切り線の太さ。0 以下で消える。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 4,
        divisions: 4,
        initialValue: 3,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'labelColor',
      group: PropertyGroup.text,
      pairsWith: const ['unselectedLabelColor'],
      typeLabel: 'Color?',
      description: '選んでいるタブの文字の色。labelStyle の色より優先する',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'unselectedLabelColor',
      group: PropertyGroup.text,
      pairsWith: const ['labelColor'],
      typeLabel: 'Color?',
      description: '選んでいないタブの文字の色。unselectedLabelStyle の色より優先する。指定しないとテーマの onSurfaceVariant',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'labelStyle',
      group: PropertyGroup.text,
      pairsWith: const ['unselectedLabelStyle'],
      typeLabel: 'TextStyle?',
      description:
          '選んでいるタブの文字の書式。unselectedLabelStyle がなければ全部のタブに効く。'
          '中の値を組み合わせて TextStyle を作る。指定しないとテーマの titleSmall',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
    PropertySpec(
      name: 'unselectedLabelStyle',
      group: PropertyGroup.text,
      pairsWith: const ['labelStyle'],
      typeLabel: 'TextStyle?',
      description:
          '選んでいないタブの文字の書式。中の値を組み合わせて TextStyle を作る。指定しないとテーマの titleSmall',
      initiallyOn: false,
      control: _textStyleControl(),
    ),
    PropertySpec(
      name: 'textScaler',
      group: PropertyGroup.text,
      typeLabel: 'TextScaler?',
      description: 'タブの文字の拡大率。指定しないと端末の文字の大きさの設定に従う',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final scale in const [0.8, 1.3])
            Choice(
              '×$scale',
              TextScaler.linear(scale),
              'TextScaler.linear($scale)',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: 'タブを押している間に広がる波紋の色。指定しないとテーマの primary を薄くしたもの',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('紅（半透明）', Color(0x66D7003A)),
            ('若竹（半透明）', Color(0x6668BE8D)),
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
      name: 'splashFactory',
      group: PropertyGroup.paint,
      typeLabel: 'InteractiveInkFeatureFactory?',
      description: 'タブを押したときの波紋の描き方。NoSplash で波紋を出さない。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'InkRipple',
            InkRipple.splashFactory,
            'InkRipple.splashFactory',
          ),
          Choice('NoSplash', NoSplash.splashFactory, 'NoSplash.splashFactory'),
        ],
      ),
    ),
    PropertySpec(
      name: 'splashBorderRadius',
      group: PropertyGroup.paint,
      pairsWith: const ['indicator'],
      typeLabel: 'BorderRadius?',
      description:
          '波紋を切り抜く角の丸み。indicator の角の丸みと合わせて使う。指定しないと BorderRadius.zero',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 16,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'indicatorAnimation',
      group: PropertyGroup.behavior,
      typeLabel: 'TabIndicatorAnimation?',
      description:
          'タブを替えたときの下線の動き方。elastic は伸び縮みしながら動く。'
          '指定しないと、indicatorSize が tab なら linear、label なら elastic',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in TabIndicatorAnimation.values)
            Choice(value.name, value, 'TabIndicatorAnimation.${value.name}'),
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
      name: 'controller',
      typeLabel: 'TabController?',
      description:
          '選んでいるタブを決め、TabBarView とそろえる部品。指定しないと上の DefaultTabController を使う',
    ),
    ReferenceArg(
      name: 'scrollController',
      typeLabel: 'ScrollController?',
      description: 'isScrollable が true のときの、タブの列のスクロールの位置を外から操作・監視する部品',
    ),
    ReferenceArg(
      name: 'automaticIndicatorColorAdjustment',
      typeLabel: 'bool',
      description: 'indicatorColor が親の Material の色と同じときに、下線を白に変えるか。指定しないと true',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'タブの列のドラッグをいつ始めたとみなすか（触れた瞬間か、動き出してからか）。指定しないと start',
    ),
    ReferenceArg(
      name: 'physics',
      typeLabel: 'ScrollPhysics?',
      description:
          'isScrollable が true のときの、スクロールの止まり方や端での跳ね返り。見本のタブは画面に収まるので違いが出ない',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを重ねたときのカーソルの形。タッチの端末では違いが出ない',
    ),
    ReferenceArg(
      name: 'enableFeedback',
      typeLabel: 'bool?',
      description: '押したときに音や振動で知らせるか。指定しないと true',
    ),
    ReferenceArg(
      name: 'onTap',
      typeLabel: 'ValueChanged<int>?',
      description: 'タブを押したときに、そのタブの番号で呼ばれる。選択の切り替えはこれがなくても行う',
    ),
    ReferenceArg(
      name: 'onHover',
      typeLabel: 'TabValueChanged<bool>?',
      description: 'マウスがタブに重なったとき・離れたときに呼ばれる',
    ),
    ReferenceArg(
      name: 'onFocusChange',
      typeLabel: 'TabValueChanged<bool>?',
      description: 'タブがフォーカスを得たとき・失ったときに呼ばれる',
    ),
  ],
  build: _build,
  codeName: 'TabBar',
);

NestedControl _textStyleControl() => NestedControl(
  typeName: 'TextStyle',
  children: [
    PropertySpec(
      name: 'fontSize',
      typeLabel: 'double?',
      description: '文字の大きさ',
      control: SliderControl(
        min: 10,
        max: 18,
        divisions: 4,
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
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '文字の色。labelColor・unselectedLabelColor があればそちらが優先する',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
  ],
  build: (values) => TextStyle(
    fontSize: values['fontSize'] as double?,
    fontWeight: values['fontWeight'] as FontWeight?,
    color: values['color'] as Color?,
  ),
);

/// tabAlignment の値が isScrollable と合わないか（合わないと TabBar が例外を投げる）。
/// fill はスクロールしないとき、start・startOffset はスクロールするときだけ使える。
bool _tabAlignmentMismatch(Map<String, PropertySetting> settings) {
  final alignment = settings['tabAlignment']?.value;
  if (alignment is! ChoiceValue) return false;
  return !_fits(
    _tabAlignments[alignment.index],
    isScrollable: _isScrollableIn(settings),
  );
}

bool _isScrollableIn(Map<String, PropertySetting> settings) {
  final setting = settings['isScrollable'];
  if (setting == null || !setting.on) return false;
  final value = setting.value;
  return value is SwitchValue ? value.value : _isScrollableInitial;
}

bool _fits(TabAlignment alignment, {required bool isScrollable}) =>
    switch (alignment) {
      TabAlignment.fill => !isScrollable,
      TabAlignment.start || TabAlignment.startOffset => isScrollable,
      TabAlignment.center => true,
    };

/// TabBar は TabController が要るので、デモの部品の DefaultTabController で包む
/// （コードには出さない）。
Widget _build(DemoArgs args) {
  final isScrollable = args.valueOf<bool>('isScrollable') ?? false;
  final tabAlignment = args.valueOf<TabAlignment>('tabAlignment');
  return DefaultTabController(
    length: 3,
    child: TabBar(
      tabs: args.valueOf<List<Widget>>('tabs') ?? const [],
      isScrollable: isScrollable,
      // omitIf と同じ条件を手で守る（合わない値を渡すと例外になる）。
      tabAlignment:
          tabAlignment != null &&
              _fits(tabAlignment, isScrollable: isScrollable)
          ? tabAlignment
          : null,
      padding: args.valueOf<EdgeInsetsGeometry>('padding'),
      labelPadding: args.valueOf<EdgeInsetsGeometry>('labelPadding'),
      indicatorSize: args.valueOf<TabBarIndicatorSize>('indicatorSize'),
      indicatorColor: args.valueOf<Color>('indicatorColor'),
      // Flutter の既定値（2.0。Material 3 では 3 に引き上げられる）。
      indicatorWeight: args.valueOf<double>('indicatorWeight') ?? 2.0,
      // Flutter の既定値（EdgeInsets.zero）。
      indicatorPadding:
          args.valueOf<EdgeInsetsGeometry>('indicatorPadding') ??
          EdgeInsets.zero,
      indicator: args.valueOf<Decoration>('indicator'),
      dividerColor: args.valueOf<Color>('dividerColor'),
      dividerHeight: args.valueOf<double>('dividerHeight'),
      labelColor: args.valueOf<Color>('labelColor'),
      unselectedLabelColor: args.valueOf<Color>('unselectedLabelColor'),
      labelStyle: args.valueOf<TextStyle>('labelStyle'),
      unselectedLabelStyle: args.valueOf<TextStyle>('unselectedLabelStyle'),
      textScaler: args.valueOf<TextScaler>('textScaler'),
      overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
      splashFactory: args.valueOf<InteractiveInkFeatureFactory>(
        'splashFactory',
      ),
      splashBorderRadius: args.valueOf<BorderRadius>('splashBorderRadius'),
      indicatorAnimation: args.valueOf<TabIndicatorAnimation>(
        'indicatorAnimation',
      ),
    ),
  );
}
