import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
