import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: 'アプリの名前。OS のアプリの切り替えの画面に出る（プレビューには出ない）',
      initiallyOn: false,
      control: TextControl(initialValue: 'Widget Lab'),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
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
      group: PropertyGroup.paint,
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
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'debug のビルドで、右上に「DEBUG」の帯を出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'showPerformanceOverlay',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '描く速さのグラフを上に重ねるか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'showSemanticsDebugger',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '画面の代わりに、読み上げに渡る情報の枠を出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'home',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '最初に出す画面',
      required: true,
      control: FixedControl(value: _Home(), source: 'const HomePage()'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'navigatorKey',
      typeLabel: 'GlobalKey<NavigatorState>?',
      description: '中の Navigator を、context を使わずに外から操作するときに渡す',
    ),
    ReferenceArg(
      name: 'routes',
      typeLabel: 'Map<String, WidgetBuilder>?',
      description: '名前で開く画面の一覧。pushNamed で使う',
    ),
    ReferenceArg(
      name: 'initialRoute',
      typeLabel: 'String?',
      description: '最初に開く画面の名前',
    ),
    ReferenceArg(
      name: 'onGenerateRoute',
      typeLabel: 'RouteFactory?',
      description: 'routes にない名前の画面を、名前から作る',
    ),
    ReferenceArg(
      name: 'onGenerateInitialRoutes',
      typeLabel: 'InitialRouteListFactory?',
      description: 'initialRoute から、最初に積む画面の並びを作る',
    ),
    ReferenceArg(
      name: 'onUnknownRoute',
      typeLabel: 'RouteFactory?',
      description: 'どこでも作れなかった名前のときに出す画面を作る',
    ),
    ReferenceArg(
      name: 'onNavigationNotification',
      typeLabel: 'NotificationListenerCallback<NavigationNotification>?',
      description: '画面を戻れるかが変わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'navigatorObservers',
      typeLabel: 'List<NavigatorObserver>',
      description: '画面の出し入れを見張る仕組みの一覧',
    ),
    ReferenceArg(
      name: 'builder',
      typeLabel: 'TransitionBuilder?',
      description: 'Navigator の外側を包む Widget を差し込む。全画面に共通の包みに使う',
    ),
    ReferenceArg(
      name: 'onGenerateTitle',
      typeLabel: 'GenerateAppTitle?',
      description: 'アプリの名前を、言語に合わせて作る。title より優先される',
    ),
    ReferenceArg(
      name: 'locale',
      typeLabel: 'Locale?',
      description: '使う言語。指定しないと端末の言語から選ぶ',
    ),
    ReferenceArg(
      name: 'localizationsDelegates',
      typeLabel: 'Iterable<LocalizationsDelegate<dynamic>>?',
      description: '文言の訳を読み込む仕組みの一覧',
    ),
    ReferenceArg(
      name: 'localeListResolutionCallback',
      typeLabel: 'LocaleListResolutionCallback?',
      description: '端末の言語の一覧から、使う言語を選ぶ',
    ),
    ReferenceArg(
      name: 'localeResolutionCallback',
      typeLabel: 'LocaleResolutionCallback?',
      description: '端末の言語から、使う言語を選ぶ',
    ),
    ReferenceArg(
      name: 'supportedLocales',
      typeLabel: 'Iterable<Locale>',
      description: 'アプリが対応する言語の一覧',
    ),
    ReferenceArg(
      name: 'checkerboardRasterCacheImages',
      typeLabel: 'bool',
      description: 'debug のときに、描き置きした画像を市松模様で示す（プレビューでは見えない）',
    ),
    ReferenceArg(
      name: 'checkerboardOffscreenLayers',
      typeLabel: 'bool',
      description: 'debug のときに、画面の外で描いた層を市松模様で示す（プレビューでは見えない）',
    ),
    ReferenceArg(
      name: 'shortcuts',
      typeLabel: 'Map<ShortcutActivator, Intent>?',
      description: 'キーの組み合わせと、それで起こす意図の対応',
    ),
    ReferenceArg(
      name: 'actions',
      typeLabel: 'Map<Type, Action<Intent>>?',
      description: '意図と、それで動く処理の対応',
    ),
    ReferenceArg(
      name: 'restorationScopeId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに状態を戻すための ID',
    ),
    ReferenceArg(
      name: 'scrollBehavior',
      typeLabel: 'ScrollBehavior?',
      description: '中のスクロールの既定のふるまい',
    ),
    ReferenceArg(
      name: 'useInheritedMediaQuery',
      typeLabel: 'bool',
      description: '非推奨。今は使われない',
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
  final performance = args.valueOf<bool>('showPerformanceOverlay') ?? false;
  final semantics = args.valueOf<bool>('showSemanticsDebugger') ?? false;
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
          showPerformanceOverlay: performance,
          showSemanticsDebugger: semantics,
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
