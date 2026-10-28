import 'package:flutter/cupertino.dart';

/// 画面の遷移（Route・Page）のデモで使う、カードの中だけの Navigator。
///
/// アプリの Navigator に積むと詳細画面ごと覆ってしまうので、カードの大きさの Navigator を置き、
/// 最初の画面のボタンで [onOpen] を呼ぶ（渡すのはこの Navigator）。
/// 押したときの [onOpen] を使うので、プロパティを変えたあとに押すと、その値で開く。
class DemoNavigator extends StatefulWidget {
  const DemoNavigator({required this.onOpen, this.label = '開く', super.key});

  static const size = Size(300, 200);

  final void Function(NavigatorState navigator) onOpen;
  final String label;

  @override
  State<DemoNavigator> createState() => _DemoNavigatorState();
}

class _DemoNavigatorState extends State<DemoNavigator> {
  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: DemoNavigator.size,
    child: ClipRect(
      child: Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => DemoPage(
            child: CupertinoButton.filled(
              onPressed: () => widget.onOpen(Navigator.of(context)),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    ),
  );
}

/// デモの Navigator の中の 1 画面。地を塗り、[child] を中央に置く。
class DemoPage extends StatelessWidget {
  const DemoPage({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: CupertinoColors.systemBackground.resolveFrom(context),
    child: Center(child: child),
  );
}

/// 開いた先の画面（デモの部品。コードでは `const NextPage()`）。
///
/// ナビゲーションバーの題と戻るボタンは、開いた Route から自動で決まる
/// （`CupertinoPageRoute` の `title`、`fullscreenDialog` なら閉じるボタン）。
class DemoNextPage extends StatelessWidget {
  const DemoNextPage({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
    // デモは一覧の見本や比較で同じ Route に何枚も並ぶので、Hero で飛ばさない
    navigationBar: CupertinoNavigationBar(transitionBetweenRoutes: false),
    child: Center(child: Text('次の画面')),
  );
}
