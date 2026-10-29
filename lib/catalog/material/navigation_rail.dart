import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Navigation rail」のカード。クラスの NavigationRail で見せる。
final navigationRailEntry = WidgetEntry(
  id: 'navigationRail',
  name: 'Navigation rail',
  genreIds: const ['material'],
  summary: '画面の横に、行き先を縦に並べる細い帯',
  description:
      '画面の左（か右）に置き、主な行き先を 3〜7 個縦に並べます。タブレットなど幅の広い画面で、'
      'NavigationBar の代わりに使います。extended にすると幅が広がり、名前がアイコンの横に出ます'
      '（extended の間は labelType を none か指定なしにする決まりなので、ここでは labelType を渡しません）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/NavigationRail-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'destinations',
      group: PropertyGroup.content,
      typeLabel: 'List<NavigationRailDestination>',
      description: '行き先。2 個以上',
      required: true,
      control: FixedControl(
        value: <NavigationRailDestination>[
          NavigationRailDestination(icon: Icon(Icons.home), label: Text('ホーム')),
          NavigationRailDestination(
            icon: Icon(Icons.bookmark),
            label: Text('保存'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings),
            label: Text('設定'),
          ),
        ],
        source:
            "[NavigationRailDestination(icon: Icon(Icons.home), label: Text('ホーム')), "
            "NavigationRailDestination(icon: Icon(Icons.bookmark), label: Text('保存')), "
            "NavigationRailDestination(icon: Icon(Icons.settings), label: Text('設定'))]",
      ),
    ),
    PropertySpec(
      name: 'selectedIndex',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '選んでいる行き先の番号（0 から）。null（指定なし）だとどれも選ばない',
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 0,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'labelType',
      group: PropertyGroup.text,
      typeLabel: 'NavigationRailLabelType?',
      description: '行き先の名前を出すか。selected は選んでいるものだけ、all は全部',
      omitIf: _isExtended,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in NavigationRailLabelType.values)
            Choice(value.name, value, 'NavigationRailLabelType.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'extended',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '幅を広げ、名前をアイコンの横に出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'leading',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行き先の上に置く Widget。ふつうは FloatingActionButton やロゴ',
      initiallyOn: false,
      control: FixedControl(
        value: IconButton(onPressed: _noop, icon: Icon(Icons.menu)),
        source: 'IconButton(onPressed: () {}, icon: Icon(Icons.menu))',
      ),
    ),
    const PropertySpec(
      name: 'trailing',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '行き先の下に置く Widget。ふつうはほかの操作のボタン',
      initiallyOn: false,
      control: FixedControl(
        value: IconButton(onPressed: _noop, icon: Icon(Icons.logout)),
        source: 'IconButton(onPressed: () {}, icon: Icon(Icons.logout))',
      ),
    ),
    const PropertySpec(
      name: 'leadingAtTop',
      group: PropertyGroup.layout,
      requires: 'leading',
      typeLabel: 'bool',
      description: 'leading を帯のいちばん上に留めるか。false だと行き先の組に入り、groupAlignment で一緒に動く。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'trailingAtBottom',
      group: PropertyGroup.layout,
      requires: 'trailing',
      typeLabel: 'bool',
      description: 'trailing を帯のいちばん下に留めるか。指定しないと false で、行き先の組に入る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'groupAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'double?',
      description:
          '行き先の組の縦の位置。-1 で上、0 で真ん中、1 で下。mainAxisAlignment を指定すると効かない。指定しないと -1',
      initiallyOn: false,
      control: SliderControl(
        min: -1,
        max: 1,
        divisions: 4,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'mainAxisAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'MainAxisAlignment?',
      description: '縦に余りがあるときの、行き先の並べ方。指定すると groupAlignment は効かない。指定しないと start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 5,
        choices: [
          for (final value in MainAxisAlignment.values)
            Choice(value.name, value, 'MainAxisAlignment.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'scrollable',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '縦に収まらないとき、行き先の組を流して見られるようにするか。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'minWidth',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '広げていないときの帯の幅。指定しないと 72',
      initiallyOn: false,
      control: SliderControl(
        min: 56,
        max: 120,
        divisions: 4,
        initialValue: 104,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'minExtendedWidth',
      group: PropertyGroup.size,
      requires: 'extended',
      typeLabel: 'double?',
      description: 'extended で広げたときの帯の幅。minWidth より小さくできない。指定しないと 256',
      initiallyOn: false,
      control: SliderControl(
        min: 160,
        max: 256,
        divisions: 4,
        initialValue: 184,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。0 より大きくする。指定しないと 0',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 8,
        divisions: 3,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'useIndicator',
      group: PropertyGroup.paint,
      typeLabel: 'bool?',
      description:
          '選んでいる行き先のアイコンの後ろに、丸い地（indicator）を付けるか。指定しないと Material 3 では true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'indicatorColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選んでいる行き先のアイコンの後ろの地の色。指定しないとテーマの secondaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'indicatorShape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '選んでいる行き先のアイコンの後ろの地の形。指定しないと StadiumBorder（両端が丸い）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸 4',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            'RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))',
          ),
          Choice('四角', RoundedRectangleBorder(), 'RoundedRectangleBorder()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'selectedIconTheme',
      group: PropertyGroup.paint,
      pairsWith: const ['unselectedIconTheme'],
      typeLabel: 'IconThemeData?',
      description: '選んでいる行き先のアイコンの色と大きさ。中の値を組み合わせて IconThemeData を作る',
      initiallyOn: false,
      control: _iconThemeControl('紅', const Color(0xFFD7003A)),
    ),
    PropertySpec(
      name: 'unselectedIconTheme',
      group: PropertyGroup.paint,
      pairsWith: const ['selectedIconTheme'],
      typeLabel: 'IconThemeData?',
      description: '選んでいない行き先のアイコンの色と大きさ。中の値を組み合わせて IconThemeData を作る',
      initiallyOn: false,
      control: _iconThemeControl('若竹', const Color(0xFF68BE8D)),
    ),
    PropertySpec(
      name: 'selectedLabelTextStyle',
      group: PropertyGroup.text,
      pairsWith: const ['unselectedLabelTextStyle'],
      typeLabel: 'TextStyle?',
      description: '選んでいる行き先の名前の文字の見た目。中の値を組み合わせて TextStyle を作る',
      initiallyOn: false,
      control: _textStyleControl('紅', const Color(0xFFD7003A)),
    ),
    PropertySpec(
      name: 'unselectedLabelTextStyle',
      group: PropertyGroup.text,
      pairsWith: const ['selectedLabelTextStyle'],
      typeLabel: 'TextStyle?',
      description: '選んでいない行き先の名前の文字の見た目。中の値を組み合わせて TextStyle を作る',
      initiallyOn: false,
      control: _textStyleControl('若竹', const Color(0xFF68BE8D)),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'onDestinationSelected',
      typeLabel: 'ValueChanged<int>?',
      description: '行き先を押したときに、その番号で呼ばれる。ふつうはここで selectedIndex を変える',
    ),
  ],
  build: _build,
  codeName: 'NavigationRail',
);

/// extended の間は labelType を none 以外にできない（assert）ので渡さない。
bool _isExtended(Map<String, PropertySetting> settings) =>
    switch (settings['extended']) {
      PropertySetting(on: true, value: SwitchValue(value: true)) => true,
      _ => false,
    };

void _noop() {}

NestedControl _iconThemeControl(String label, Color color) => NestedControl(
  typeName: 'IconThemeData',
  children: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: 'アイコンの色',
      control: ColorControl(
        palette: [
          Choice.color(label, color),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'size',
      typeLabel: 'double?',
      description: 'アイコンの大きさ。指定しないと 24',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 32,
        divisions: 4,
        initialValue: 28,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
  ],
  build: (values) => IconThemeData(
    color: values['color'] as Color?,
    size: values['size'] as double?,
  ),
);

NestedControl _textStyleControl(String label, Color color) => NestedControl(
  typeName: 'TextStyle',
  children: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '文字の色',
      control: ColorControl(
        palette: [
          Choice.color(label, color),
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
        max: 18,
        divisions: 4,
        initialValue: 12,
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
        initialIndex: 1,
        choices: [
          for (final (name, weight) in const [
            ('w400', FontWeight.w400),
            ('w700', FontWeight.w700),
          ])
            Choice(name, weight, 'FontWeight.$name'),
        ],
      ),
    ),
  ],
  build: (values) => TextStyle(
    color: values['color'] as Color?,
    fontSize: values['fontSize'] as double?,
    fontWeight: values['fontWeight'] as FontWeight?,
  ),
);

Widget _build(DemoArgs args) {
  final extended = args.valueOf<bool>('extended') ?? false;
  return DemoStage(
    size: const Size(280, 320),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: NavigationRail(
        destinations:
            args.valueOf<List<NavigationRailDestination>>('destinations') ??
            const [],
        selectedIndex: args.valueOf<int>('selectedIndex'),
        // extended の間は labelType を none 以外にできない（assert）ので渡さない
        labelType: extended
            ? null
            : args.valueOf<NavigationRailLabelType>('labelType'),
        extended: extended,
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        leading: args.valueOf<Widget>('leading'),
        trailing: args.valueOf<Widget>('trailing'),
        // Flutter の既定値。OFF のときも省いたコードと同じ並びにそろえる。
        leadingAtTop: args.valueOf<bool>('leadingAtTop') ?? true,
        trailingAtBottom: args.valueOf<bool>('trailingAtBottom') ?? false,
        groupAlignment: args.valueOf<double>('groupAlignment'),
        mainAxisAlignment: args.valueOf<MainAxisAlignment>('mainAxisAlignment'),
        scrollable: args.valueOf<bool>('scrollable') ?? false,
        minWidth: args.valueOf<double>('minWidth'),
        minExtendedWidth: args.valueOf<double>('minExtendedWidth'),
        elevation: args.valueOf<double>('elevation'),
        useIndicator: args.valueOf<bool>('useIndicator'),
        indicatorColor: args.valueOf<Color>('indicatorColor'),
        indicatorShape: args.valueOf<ShapeBorder>('indicatorShape'),
        selectedIconTheme: args.valueOf<IconThemeData>('selectedIconTheme'),
        unselectedIconTheme: args.valueOf<IconThemeData>('unselectedIconTheme'),
        selectedLabelTextStyle: args.valueOf<TextStyle>(
          'selectedLabelTextStyle',
        ),
        unselectedLabelTextStyle: args.valueOf<TextStyle>(
          'unselectedLabelTextStyle',
        ),
      ),
    ),
  );
}
