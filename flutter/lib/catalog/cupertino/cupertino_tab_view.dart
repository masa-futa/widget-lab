import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTabViewEntry = WidgetEntry(
  id: 'cupertinoTabView',
  name: 'CupertinoTabView',
  genreIds: const ['cupertino'],
  summary: 'タブごとに自分の Navigator を持つ、iOS のタブの中身',
  description:
      'CupertinoTabScaffold の tabBuilder で返し、タブごとに別の Navigator を持たせます。'
      'タブの中で push した画面はそのタブの中だけで重なり、ほかのタブに切り替えても残ります。'
      'プレビューでは「次へ」を押すと、箱の中だけで遷移します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTabView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'defaultTitle',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '最初の画面の題。ナビゲーションバーの真ん中と、次の画面の戻るボタンの文字に使われる',
      control: TextControl(initialValue: 'ホーム'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'builder',
      typeLabel: 'WidgetBuilder?',
      description: 'タブの最初の画面を組み立てる。routes の / の代わりに使う',
    ),
    ReferenceArg(
      name: 'navigatorKey',
      typeLabel: 'GlobalKey<NavigatorState>?',
      description: 'このタブの Navigator を外から操作するための鍵',
    ),
    ReferenceArg(
      name: 'routes',
      typeLabel: 'Map<String, WidgetBuilder>?',
      description: '名前で push する画面の一覧',
    ),
    ReferenceArg(
      name: 'onGenerateRoute',
      typeLabel: 'RouteFactory?',
      description: 'routes にない名前で push したときに Route を作る',
    ),
    ReferenceArg(
      name: 'onUnknownRoute',
      typeLabel: 'RouteFactory?',
      description: 'onGenerateRoute でも作れなかったときに Route を作る',
    ),
    ReferenceArg(
      name: 'navigatorObservers',
      typeLabel: 'List<NavigatorObserver>',
      description: 'このタブの Navigator の push・pop を見張る',
    ),
    ReferenceArg(
      name: 'restorationScopeId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、このタブの画面の重なりを戻すための ID',
    ),
  ],
  build: _build,
  codeName: 'CupertinoTabView',
  codeArguments: const ['builder: (context) => const HomePage()'],
);

Widget _build(DemoArgs args) {
  final defaultTitle = args.valueOf<String>('defaultTitle');
  return SizedBox.fromSize(
    size: DemoNavigator.size,
    // 詳細画面の上の余白（ステータスバーの分）を、小さな画面に持ち込まない
    child: Builder(
      builder: (context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ClipRect(
          child: CupertinoTabView(
            defaultTitle: defaultTitle,
            builder: (context) => const _Home(),
          ),
        ),
      ),
    ),
  );
}

/// タブの最初の画面（デモの部品。コードでは `const HomePage()`）。
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    // デモは一覧の見本や比較で同じ Route に何枚も並ぶので、Hero で飛ばさない
    navigationBar: const CupertinoNavigationBar(transitionBetweenRoutes: false),
    child: Center(
      child: CupertinoButton.filled(
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute<void>(
            title: '次の画面',
            builder: (context) => const DemoNextPage(),
          ),
        ),
        child: const Text('次へ'),
      ),
    ),
  );
}
