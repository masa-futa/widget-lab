import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTabControllerEntry = WidgetEntry(
  id: 'cupertinoTabController',
  name: 'CupertinoTabController',
  genreIds: const ['cupertino'],
  summary: 'CupertinoTabScaffold の選んでいるタブを、外から読み書きする',
  description:
      'CupertinoTabScaffold の controller に渡すと、選んでいるタブの番号（index）を外から'
      '読み書きできます。index を変えるとタブが切り替わります。'
      'State に持ち、使い終わったら dispose します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTabController-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'initialIndex',
      group: PropertyGroup.behavior,
      typeLabel: 'int',
      description: '最初に選んでいるタブの番号。変えると controller を作り直す',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('0', 0, '0'),
          Choice('1', 1, '1'),
          Choice('2', 2, '2'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTabController',
);

Widget _build(DemoArgs args) {
  final initialIndex = args.valueOf<int>('initialIndex') ?? 0;
  // key を変えて State ごと作り直し、前の controller を dispose する
  return _ControllerDemo(
    key: ValueKey(initialIndex),
    initialIndex: initialIndex,
  );
}

/// controller を State に持ち、タブの骨組みと「次のタブへ」のボタン（デモの部品）に渡す。
class _ControllerDemo extends StatefulWidget {
  const _ControllerDemo({required this.initialIndex, super.key});

  final int initialIndex;

  @override
  State<_ControllerDemo> createState() => _ControllerDemoState();
}

class _ControllerDemoState extends State<_ControllerDemo> {
  late final _controller = CupertinoTabController(
    initialIndex: widget.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() => _controller.index = (_controller.index + 1) % _tabCount;

  // ボタンとタブを縦に並べるので、低いカード（比較中）では全体を縮めて収める
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        CupertinoButton.filled(
          sizeStyle: CupertinoButtonSize.small,
          onPressed: _next,
          child: const Text('次のタブへ'),
        ),
        SizedBox(
          width: 300,
          height: 160,
          // 詳細画面の上下の余白（ステータスバーなどの分）を、小さな画面に持ち込まない
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: CupertinoTabScaffold(
              controller: _controller,
              tabBar: CupertinoTabBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: 'ホーム',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.search),
                    label: '探す',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings),
                    label: '設定',
                  ),
                ],
              ),
              tabBuilder: (context, index) =>
                  Center(child: Text('タブ ${index + 1}')),
            ),
          ),
        ),
      ],
    ),
  );
}

const _tabCount = 3;
