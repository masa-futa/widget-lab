import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTabBarEntry = WidgetEntry(
  id: 'cupertinoTabBar',
  name: 'CupertinoTabBar',
  genreIds: const ['cupertino'],
  summary: '画面の下に置く iOS のタブバー',
  description:
      '画面の下に、アイコンと名前のタブを並べるバーです。2 つ以上のタブが要ります。'
      '自分では選んだタブを持たないので、onTap で受けた番号を State に持ち、currentIndex に渡し直します'
      '（CupertinoTabScaffold に渡すと、そちらが持ちます）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTabBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'items',
      group: PropertyGroup.content,
      typeLabel: 'List<BottomNavigationBarItem>',
      description: 'タブの一覧。2 つ以上',
      required: true,
      control: FixedControl(value: _items, source: _itemsSource),
    ),
    const PropertySpec(
      name: 'currentIndex',
      group: PropertyGroup.behavior,
      typeLabel: 'int',
      description: '選んでいるタブの番号。プレビューで押すと変わる',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('0', 0, '0'),
          Choice('1', 1, '1'),
          Choice('2', 2, '2'),
        ],
      ),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '選んでいるタブの色。指定しないとテーマの主な色',
      initiallyOn: false,
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'inactiveColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '選んでいないタブの色。指定しないと inactiveGray',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 1),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'バーの地の色。指定しないとテーマの barBackgroundColor（半透明）',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    PropertySpec(
      name: 'iconSize',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'アイコンの大きさ',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 40,
        divisions: 6,
        initialValue: 24,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'height',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: 'バーの高さ。指定しないと 50',
      initiallyOn: false,
      control: SliderControl(
        min: 40,
        max: 80,
        divisions: 4,
        initialValue: 70,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'border',
      group: PropertyGroup.paint,
      typeLabel: 'Border?',
      description: 'バーの上のふちの線。指定しないと灰色の細い線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太い赤線',
            Border(top: BorderSide(color: Color(0xFFD7003A), width: 2)),
            'Border(top: BorderSide(color: Color(0xFFD7003A), width: 2))',
          ),
          Choice('なし（null）', false, 'null'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'onTap',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<int>?',
      description: 'タブを押したときに番号で呼ばれる。指定しないと押しても選び直さない',
      control: FixedControl(
        value: true,
        source: '(index) => setState(() => _index = index)',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoTabBar',
);

const _items = [
  BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'ホーム'),
  BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '探す'),
  BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '設定'),
];
const _itemsSource =
    "[BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'ホーム'), "
    "BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '探す'), "
    "BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '設定')]";

final _colors = [
  const Choice(
    'systemPink',
    CupertinoColors.systemPink,
    'CupertinoColors.systemPink',
  ),
  const Choice(
    'systemBrown',
    CupertinoColors.systemBrown,
    'CupertinoColors.systemBrown',
  ),
  const Choice(
    'systemYellow',
    CupertinoColors.systemYellow,
    'CupertinoColors.systemYellow',
  ),
  Choice.color('墨', const Color(0xFF18181B)),
];

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final items = args.valueOf<List<BottomNavigationBarItem>>('items')!;
  final activeColor = args.valueOf<Color>('activeColor');
  final inactiveColor =
      args.valueOf<Color>('inactiveColor') ?? CupertinoColors.inactiveGray;
  final backgroundColor = args.valueOf<Color>('backgroundColor');
  final iconSize = args.valueOf<double>('iconSize') ?? 30;
  final tappable = args.valueOf<bool>('onTap') ?? false;
  final height = args.valueOf<double>('height') ?? 50;
  final border = _border(args);
  return SizedBox(
    width: 320,
    child: DemoValue<int>(
      initial: args.valueOf<int>('currentIndex') ?? 0,
      // 詳細画面の下の余白（ホームインジケータの分）を、バーの高さに持ち込まない
      builder: (context, index, onChanged) => MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: CupertinoTabBar(
          items: items,
          currentIndex: index,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          backgroundColor: backgroundColor,
          iconSize: iconSize,
          height: height,
          border: border,
          onTap: tappable ? onChanged : null,
        ),
      ),
    ),
  );
}

/// OFF なら既定の灰色の細い線。「なし」は null。
Border? _border(DemoArgs args) {
  final value = args.valueOf<Object>('border');
  if (value == null) {
    return const Border(
      top: BorderSide(
        color: CupertinoDynamicColor.withBrightness(
          color: Color(0x4D000000),
          darkColor: Color(0x29000000),
        ),
        width: 0,
      ),
    );
  }
  return value is Border ? value : null;
}
