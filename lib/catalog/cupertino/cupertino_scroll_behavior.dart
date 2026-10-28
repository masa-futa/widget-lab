import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoScrollBehaviorEntry = WidgetEntry(
  id: 'cupertinoScrollBehavior',
  name: 'CupertinoScrollBehavior',
  genreIds: const ['cupertino'],
  summary: 'スクロールを iOS の動き（端で跳ね返る）にする設定',
  description:
      'Widget ではなく、ScrollConfiguration の behavior に渡す設定です。子孫のスクロールが、'
      'Android でも端で跳ね返る iOS の動きになり、端の光る効果（グロー・伸び）が出なくなります。'
      'CupertinoApp は最初からこれを使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoScrollBehavior-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'behavior',
      typeLabel: 'ScrollBehavior',
      description: '子孫のスクロールの動き。OFF なら親（アプリ）の ScrollBehavior のまま',
      control: FixedControl(
        value: CupertinoScrollBehavior(),
        source: 'const CupertinoScrollBehavior()',
      ),
    ),
  ],
  build: _build,
  codeName: 'ScrollConfiguration',
  codeArguments: const ['child: ListView(children: rows)'],
);

Widget _build(DemoArgs args) {
  final behavior = args.valueOf<ScrollBehavior>('behavior');
  return Builder(
    // OFF なら親の behavior をそのまま渡す（ScrollConfiguration を置かないのと同じ）
    builder: (context) => ScrollConfiguration(
      behavior: behavior ?? ScrollConfiguration.of(context),
      child: SizedBox(
        width: 240,
        height: 160,
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text('${index + 1} 行目'),
          ),
        ),
      ),
    ),
  );
}
