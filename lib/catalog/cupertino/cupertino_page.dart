import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/demo/demo_navigator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPageEntry = WidgetEntry(
  id: 'cupertinoPage',
  name: 'CupertinoPage',
  genreIds: const ['cupertino'],
  summary: 'Navigator の pages に並べる、iOS の遷移の画面',
  description:
      'Navigator の pages に並べる画面です。リストに足すと右から滑り込み、外すと戻ります'
      '（push で積む CupertinoPageRoute の、状態から画面を決める書き方）。'
      'プレビューの中の Navigator で、ボタンを押すと 2 枚目を足します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPage-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'title',
      typeLabel: 'String?',
      description: '画面の題。CupertinoNavigationBar の真ん中と、戻るボタンの文字に使われる',
      control: TextControl(initialValue: '設定'),
    ),
    PropertySpec(
      name: 'fullscreenDialog',
      typeLabel: 'bool',
      description: 'true なら下からせり上がり、戻るボタンの代わりに閉じるボタンが出る',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '画面の中身',
      required: true,
      control: FixedControl(value: DemoNextPage(), source: 'const NextPage()'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoPage<void>',
);

Widget _build(DemoArgs args) => _PagesDemo(
  title: args.valueOf<String>('title'),
  fullscreenDialog: args.valueOf<bool>('fullscreenDialog') ?? false,
  // 必須のプロパティなので、常に値がある
  child: args.valueOf<Widget>('child')!,
);

/// pages で画面を決める Navigator（デモの部品）。2 枚目を出すかを State に持つ。
class _PagesDemo extends StatefulWidget {
  const _PagesDemo({
    required this.title,
    required this.fullscreenDialog,
    required this.child,
  });

  final String? title;
  final bool fullscreenDialog;
  final Widget child;

  @override
  State<_PagesDemo> createState() => _PagesDemoState();
}

class _PagesDemoState extends State<_PagesDemo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: DemoNavigator.size,
    child: ClipRect(
      child: Navigator(
        pages: [
          CupertinoPage<void>(
            key: const ValueKey('home'),
            child: DemoPage(
              child: CupertinoButton.filled(
                onPressed: () => setState(() => _open = true),
                child: const Text('開く'),
              ),
            ),
          ),
          if (_open)
            CupertinoPage<void>(
              key: const ValueKey('next'),
              title: widget.title,
              fullscreenDialog: widget.fullscreenDialog,
              child: widget.child,
            ),
        ],
        // 戻るボタン・引いて戻る操作で外れたら、State も閉じる
        // （pages から外したときにも呼ばれるので、そのときは何もしない）
        onDidRemovePage: (page) {
          if (_open) setState(() => _open = false);
        },
      ),
    ),
  );
}
