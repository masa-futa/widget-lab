import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoAppEntry = WidgetEntry(
  id: 'cupertinoApp',
  name: 'CupertinoApp',
  genreIds: const ['cupertino'],
  summary: 'iOS の見た目のアプリの土台',
  description:
      'アプリの一番外に置き、Navigator・CupertinoTheme・文言の言語などをまとめて用意します。'
      'theme で、中の Cupertino の Widget の色と明るさが決まります。'
      'プレビューでは小さな箱の中に置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'title',
      typeLabel: 'String?',
      description: 'アプリの名前。OS のアプリの切り替えの画面に出る（プレビューには出ない）',
      initiallyOn: false,
      control: TextControl(initialValue: 'Widget Lab'),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: 'OS がアプリの切り替えの画面で使う色。指定しないと theme の主な色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemIndigo',
            CupertinoColors.systemIndigo,
            'CupertinoColors.systemIndigo',
          ),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'theme',
      typeLabel: 'CupertinoThemeData?',
      description: '中の Cupertino の Widget に配るテーマ。ここでは明るさを変える',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice(
            'light',
            CupertinoThemeData(brightness: Brightness.light),
            'CupertinoThemeData(brightness: Brightness.light)',
          ),
          Choice(
            'dark',
            CupertinoThemeData(brightness: Brightness.dark),
            'CupertinoThemeData(brightness: Brightness.dark)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'debugShowCheckedModeBanner',
      typeLabel: 'bool',
      description: 'debug のビルドで、右上に「DEBUG」の帯を出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'home',
      typeLabel: 'Widget?',
      description: '最初に出す画面',
      required: true,
      control: FixedControl(value: _Home(), source: 'const HomePage()'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoApp',
);

Widget _build(DemoArgs args) {
  final title = args.valueOf<String>('title');
  final color = args.valueOf<Color>('color');
  final theme = args.valueOf<CupertinoThemeData>('theme');
  final banner = args.valueOf<bool>('debugShowCheckedModeBanner') ?? true;
  final home = args.valueOf<Widget>('home');
  return SizedBox(
    width: 300,
    height: 200,
    // 詳細画面の上の余白（ステータスバーの分）を、小さなアプリに持ち込まない
    child: Builder(
      builder: (context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: CupertinoApp(
          title: title,
          color: color,
          theme: theme,
          debugShowCheckedModeBanner: banner,
          home: home,
        ),
      ),
    ),
  );
}

/// 小さなアプリの最初の画面（デモの部品。コードでは `const HomePage()`）。
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
    // デモは一覧の見本や比較で同じ Route に何枚も並ぶので、Hero で飛ばさない
    navigationBar: CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      middle: Text('ホーム'),
    ),
    child: Center(child: Text('CupertinoApp の中')),
  );
}
