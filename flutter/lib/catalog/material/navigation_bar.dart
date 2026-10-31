import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final navigationBarEntry = WidgetEntry(
  id: 'navigationBar',
  name: 'NavigationBar',
  genreIds: const ['material'],
  summary: '画面の下に、行き先を 3〜5 個並べる帯',
  description:
      '画面の下に置き、アプリの主な行き先を 3〜5 個並べます。選んでいる行き先には、'
      'アイコンの後ろに indicator（丸い地）が付きます。ふつうは Scaffold の bottomNavigationBar に渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/NavigationBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'destinations',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '行き先。ふつうは NavigationDestination を 3〜5 個',
      required: true,
      control: FixedControl(
        value: <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(icon: Icon(Icons.search), label: '検索'),
          NavigationDestination(icon: Icon(Icons.person), label: '自分'),
        ],
        source:
            "[NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'), "
            "NavigationDestination(icon: Icon(Icons.search), label: '検索'), "
            "NavigationDestination(icon: Icon(Icons.person), label: '自分')]",
      ),
    ),
    PropertySpec(
      name: 'selectedIndex',
      group: PropertyGroup.behavior,
      typeLabel: 'int',
      description: '選んでいる行き先の番号（0 から）',
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
      name: 'labelBehavior',
      group: PropertyGroup.text,
      typeLabel: 'NavigationDestinationLabelBehavior?',
      description: '行き先の名前を出すか。onlyShowSelected は選んでいるものだけ',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in NavigationDestinationLabelBehavior.values)
            Choice(
              value.name,
              value,
              'NavigationDestinationLabelBehavior.${value.name}',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'indicatorColor',
      group: PropertyGroup.paint,
      pairsWith: const ['indicatorShape'],
      typeLabel: 'Color?',
      description: '選んでいる行き先のアイコンの後ろの地の色',
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
      name: 'height',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '帯の高さ。指定しないと 80',
      initiallyOn: false,
      control: SliderControl(
        min: 56,
        max: 96,
        divisions: 4,
        initialValue: 64,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'indicatorShape',
      group: PropertyGroup.paint,
      pairsWith: ['indicatorColor'],
      typeLabel: 'ShapeBorder?',
      description: '選んでいる行き先のアイコンの後ろの地の形。指定しないと StadiumBorder（両端が丸い）',
      initiallyOn: false,
      control: ChoiceControl(choices: _shapeChoices),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surfaceContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      pairsWith: const ['shadowColor', 'surfaceTintColor'],
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。影と面の色合いに効く。指定しないと 3',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 4,
        initialValue: 6,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: '浮き上がりを表す影の色。指定しないと透明で、影は出ない',
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
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: '浮き上がりの高さに応じて地に重ねる色。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '行き先を押している間などに重ねる色。指定しないとテーマから決まる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('紅（半透明）', Color(0x66D7003A)),
            ('瑠璃（半透明）', Color(0x661E50A2)),
          ])
            Choice(
              name,
              WidgetStatePropertyAll<Color?>(color),
              'WidgetStatePropertyAll(${colorCode(color)})',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'labelTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'WidgetStateProperty<TextStyle?>?',
      description: '行き先の名前の文字の見た目。指定しないとテーマの labelMedium',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, style, code) in const [
            (
              '太字',
              TextStyle(fontWeight: FontWeight.w700),
              'TextStyle(fontWeight: FontWeight.w700)',
            ),
            (
              '紅',
              TextStyle(color: Color(0xFFD7003A)),
              'TextStyle(color: Color(0xFFD7003A))',
            ),
            ('小さめ', TextStyle(fontSize: 10), 'TextStyle(fontSize: 10)'),
          ])
            Choice(
              name,
              WidgetStatePropertyAll<TextStyle?>(style),
              'WidgetStatePropertyAll($code)',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'labelPadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '行き先の名前のまわりの余白。指定しないと上に 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: (v) => EdgeInsets.only(top: v),
        code: (v) => 'EdgeInsets.only(top: $v)',
      ),
    ),
    PropertySpec(
      name: 'animationDuration',
      group: PropertyGroup.behavior,
      typeLabel: 'Duration?',
      description: '選ぶ行き先が替わるときの動きの長さ。指定しないと 500 ミリ秒',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 2000,
        divisions: 4,
        initialValue: 1000,
        resolve: (v) => Duration(milliseconds: v.round()),
        code: (v) => 'Duration(milliseconds: ${v.round()})',
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
      name: 'onDestinationSelected',
      typeLabel: 'ValueChanged<int>?',
      description: '行き先を押したときに、その番号で呼ばれる。ふつうはここで selectedIndex を変える',
    ),
    ReferenceArg(
      name: 'maintainBottomViewPadding',
      typeLabel: 'bool',
      description: 'キーボードが出ても下の余白を保ち、帯が動かないようにするか。指定しないと false',
    ),
  ],
  build: _build,
  codeName: 'NavigationBar',
);

Widget _build(DemoArgs args) => NavigationBar(
  destinations: args.valueOf<List<Widget>>('destinations') ?? const [],
  selectedIndex: args.valueOf<int>('selectedIndex') ?? 0,
  labelBehavior: args.valueOf<NavigationDestinationLabelBehavior>(
    'labelBehavior',
  ),
  indicatorColor: args.valueOf<Color>('indicatorColor'),
  height: args.valueOf<double>('height'),
  indicatorShape: args.valueOf<ShapeBorder>('indicatorShape'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
  shadowColor: args.valueOf<Color>('shadowColor'),
  surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
  overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
  labelTextStyle: args.valueOf<WidgetStateProperty<TextStyle?>>(
    'labelTextStyle',
  ),
  labelPadding: args.valueOf<EdgeInsetsGeometry>('labelPadding'),
  animationDuration: args.valueOf<Duration>('animationDuration'),
);

const _shapeChoices = [
  Choice(
    '角丸 4',
    _roundedShape,
    'RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))',
  ),
  Choice('四角', RoundedRectangleBorder(), 'RoundedRectangleBorder()'),
  Choice('丸', CircleBorder(), 'CircleBorder()'),
];

const _roundedShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(4)),
);
