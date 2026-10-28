import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTabScaffoldEntry = WidgetEntry(
  id: 'cupertinoTabScaffold',
  name: 'CupertinoTabScaffold',
  genreIds: const ['cupertino'],
  summary: '下のタブバーで画面を切り替える、iOS の骨組み',
  description:
      '下に CupertinoTabBar を置き、押したタブの中身を tabBuilder で組み立てます。'
      '選んでいるタブは自分で持つので、タブバーに onTap や currentIndex を渡さなくても切り替わります。'
      '一度開いたタブは、切り替えても State を残します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTabScaffold-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'tabBar',
      typeLabel: 'CupertinoTabBar',
      description: '下に置くタブバー',
      required: true,
      control: FixedControl(value: _tabBar, source: _tabBarSource),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '地の色。指定しないとテーマの scaffoldBackgroundColor',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGroupedBackground',
            CupertinoColors.systemGroupedBackground,
            'CupertinoColors.systemGroupedBackground',
          ),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTabScaffold',
  codeArguments: const [
    "tabBuilder: (context, index) => Center(child: Text('タブ \${index + 1}'))",
  ],
);

// assert で items.length を読むので const にできない
final _tabBar = CupertinoTabBar(
  items: const [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'ホーム'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '探す'),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '設定'),
  ],
);
const _tabBarSource =
    'CupertinoTabBar(items: ['
    "BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'ホーム'), "
    "BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '探す'), "
    "BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '設定')])";

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final tabBar = args.valueOf<CupertinoTabBar>('tabBar')!;
  final backgroundColor = args.valueOf<Color>('backgroundColor');
  return SizedBox(
    width: 300,
    height: 200,
    // 詳細画面の上下の余白（ステータスバーなどの分）を、小さな画面に持ち込まない
    child: Builder(
      builder: (context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: CupertinoTabScaffold(
          tabBar: tabBar,
          backgroundColor: backgroundColor,
          tabBuilder: (context, index) =>
              Center(child: Text('タブ ${index + 1}')),
        ),
      ),
    ),
  );
}
