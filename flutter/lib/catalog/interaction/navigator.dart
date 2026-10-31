import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final navigatorEntry = WidgetEntry(
  id: 'navigator',
  name: 'Navigator',
  genreIds: const ['interaction'],
  summary: '画面（Route）を積み重ねて、進む・戻るを管理する',
  description:
      '画面を Route として積み重ね、push で上に積み、pop で一番上を外します。'
      '戻るボタンや戻るジェスチャー、画面の切り替えの動きも Navigator が受け持ちます。'
      'アプリの Navigator は MaterialApp が置きます。ここではカードの中に小さな Navigator を置き、'
      '積み外しをログに出しています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Navigator-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'initialRoute',
      group: PropertyGroup.behavior,
      typeLabel: 'String?',
      description:
          '最初に開く画面の名前。/detail にすると、/ の上に /detail を積んだ状態で始まり、'
          '戻ると / に戻ります。既定は /',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('/', '/', "'/'"),
          Choice('/detail', '/detail', "'/detail'"),
        ],
      ),
    ),
    PropertySpec(
      name: 'onGenerateRoute',
      group: PropertyGroup.behavior,
      typeLabel: 'RouteFactory?',
      description: '画面の名前から Route を作る関数。pushNamed で呼ばれます。',
      required: true,
      control: FixedControl(
        value: true,
        source:
            '(settings) => MaterialPageRoute(\n'
            '    settings: settings,\n'
            '    builder: (context) => pageFor(settings.name),\n'
            '  )',
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
      name: 'pages',
      typeLabel: 'List<Page<dynamic>>',
      description: '宣言的に積む画面の一覧。並びを変えて組み直すと、積み方が変わる。onDidRemovePage と組で使う',
    ),
    ReferenceArg(
      name: 'onPopPage',
      typeLabel: 'PopPageCallback?',
      description: '非推奨。代わりに onDidRemovePage を使う',
    ),
    ReferenceArg(
      name: 'onGenerateInitialRoutes',
      typeLabel: 'RouteListFactory',
      description: 'initialRoute から、最初に積む画面の一覧を作る',
    ),
    ReferenceArg(
      name: 'onUnknownRoute',
      typeLabel: 'RouteFactory?',
      description: 'onGenerateRoute が画面を作れなかった名前のときに呼ばれる',
    ),
    ReferenceArg(
      name: 'transitionDelegate',
      typeLabel: 'TransitionDelegate<dynamic>',
      description: 'pages が変わったときに、どの画面を動きつきで出し入れするかを決める',
    ),
    ReferenceArg(
      name: 'reportsRouteUpdateToEngine',
      typeLabel: 'bool',
      description: '今の画面の名前を OS（Web ならアドレスバー）に知らせるか。既定は false',
    ),
    ReferenceArg(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '画面の切り替えの動きで、はみ出した所を切り取るか。見本は外側で切り取っているので違いは出ない',
    ),
    ReferenceArg(
      name: 'observers',
      typeLabel: 'List<NavigatorObserver>',
      description: '画面の積み外しを知らせる相手の一覧。ここではログを出すのに使っている',
    ),
    ReferenceArg(
      name: 'requestFocus',
      typeLabel: 'bool',
      description: '画面を積んだときに、その画面へフォーカスを移すか。既定は true',
    ),
    ReferenceArg(
      name: 'restorationScopeId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、積んでいた画面を戻すための ID',
    ),
    ReferenceArg(
      name: 'routeTraversalEdgeBehavior',
      typeLabel: 'TraversalEdgeBehavior',
      description: 'Tab キーでフォーカスを送って画面の端に来たときにどうするか',
    ),
    ReferenceArg(
      name: 'routeDirectionalTraversalEdgeBehavior',
      typeLabel: 'TraversalEdgeBehavior',
      description: '矢印キーでフォーカスを送って画面の端に来たときにどうするか',
    ),
    ReferenceArg(
      name: 'onDidRemovePage',
      typeLabel: 'DidRemovePageCallback?',
      description: 'pages の画面が外されたときに呼ばれる。ここで自分の pages の一覧からも除く',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'Navigator',
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。どちらの画面を出すかを State に持ち、setState で入れ替える
/// （画面を重ねないので、戻るジェスチャーや切り替えの動きはない）。
const _codeWithout = '''
class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  var _detail = false;

  @override
  Widget build(BuildContext context) => _detail
      ? DetailPage(onBack: () => setState(() => _detail = false))
      : HomePage(onNext: () => setState(() => _detail = true));
}''';

const _size = Size(280, 140);

Widget _build(DemoArgs args) {
  final initialRoute = args.valueOf<String>('initialRoute');
  return DemoScope(
    label: 'Navigator(initialRoute: ${initialRoute ?? '/'})',
    // 最初の画面は Navigator を作るときにしか効かないので、変えたら作り直す
    child: _NavigatorDemo(
      key: ValueKey(initialRoute),
      initialRoute: initialRoute,
    ),
  );
}

/// 使わない側。State で画面を入れ替える。
Widget _buildWithout(DemoArgs args) => DemoFit(
  child: _SwitchDemo(detail: args.valueOf<String>('initialRoute') == '/detail'),
);

/// カードの中の Navigator。積み外しをログに出す。
class _NavigatorDemo extends StatefulWidget {
  const _NavigatorDemo({required this.initialRoute, super.key});

  final String? initialRoute;

  @override
  State<_NavigatorDemo> createState() => _NavigatorDemoState();
}

class _NavigatorDemoState extends State<_NavigatorDemo> {
  // NavigatorObserver は 1 つの Navigator にしか付けられないので、Navigator ごとに作る
  late final _observer = _LogObserver(
    (text) => DemoRecorder.of(context).log(text),
  );

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: _size,
    child: ClipRect(
      child: Navigator(
        initialRoute: widget.initialRoute ?? Navigator.defaultRouteName,
        observers: [_observer],
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => settings.name == '/detail'
              ? _Page(
                  title: '詳細',
                  action: '戻る',
                  onPressed: () => Navigator.of(context).pop(),
                )
              : _Page(
                  title: 'ホーム',
                  action: '詳細へ',
                  onPressed: () => Navigator.of(context).pushNamed('/detail'),
                ),
        ),
      ),
    ),
  );
}

/// push・pop をログに出す。
class _LogObserver extends NavigatorObserver {
  _LogObserver(this._log);

  final void Function(String text) _log;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push: ${route.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop: ${route.settings.name}');
}

/// 使わない側。どちらの画面を出すかを State に持ち、setState で入れ替える。
class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo({required this.detail});

  final bool detail;

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  late bool _detail = widget.detail;

  void _show({required bool detail}) {
    DemoRecorder.of(context).log('setState: ${detail ? '詳細' : 'ホーム'}を出す');
    setState(() => _detail = detail);
  }

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: _size,
    child: _detail
        ? _Page(
            title: '詳細',
            action: '戻る',
            onPressed: () => _show(detail: false),
          )
        : _Page(
            title: 'ホーム',
            action: '詳細へ',
            onPressed: () => _show(detail: true),
          ),
  );
}

/// デモの 1 画面。題とボタン。
class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(title),
          FilledButton(onPressed: onPressed, child: Text(action)),
        ],
      ),
    ),
  );
}
