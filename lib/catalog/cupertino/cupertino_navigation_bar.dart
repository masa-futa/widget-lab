import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoNavigationBarEntry = WidgetEntry(
  id: 'cupertinoNavigationBar',
  name: 'CupertinoNavigationBar',
  genreIds: const ['cupertino'],
  summary: '画面の上に置く iOS のナビゲーションバー',
  description:
      '画面の上に、真ん中の題と左右のボタンを並べるバーです。'
      '地は半透明で、後ろをぼかして透かします。'
      '戻れる画面では、左に戻るボタンを自動で出します（automaticallyImplyLeading）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoNavigationBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'leading',
      typeLabel: 'Widget?',
      description: '左に置く Widget。指定しないと、戻れる画面では戻るボタンが出る',
      initiallyOn: false,
      control: FixedControl(value: _leading, source: _leadingSource),
    ),
    const PropertySpec(
      name: 'middle',
      typeLabel: 'Widget?',
      description: '真ん中の題。指定しないと Route の題（CupertinoPageRoute の title）が出る',
      control: FixedControl(value: Text('設定'), source: "Text('設定')"),
    ),
    const PropertySpec(
      name: 'trailing',
      typeLabel: 'Widget?',
      description: '右に置く Widget',
      control: FixedControl(value: _trailing, source: _trailingSource),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: 'バーの地の色。指定しないとテーマの barBackgroundColor（半透明）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoNavigationBar',
);

const _leading = CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: _pressed,
  child: Text('編集'),
);
const _leadingSource =
    "CupertinoButton(padding: EdgeInsets.zero, onPressed: () {}, child: Text('編集'))";

const _trailing = CupertinoButton(
  padding: EdgeInsets.zero,
  onPressed: _pressed,
  child: Icon(CupertinoIcons.add),
);
const _trailingSource =
    'CupertinoButton(padding: EdgeInsets.zero, onPressed: () {}, '
    'child: Icon(CupertinoIcons.add))';

void _pressed() {}

Widget _build(DemoArgs args) => SizedBox(
  width: 320,
  // 詳細画面の上の余白（ステータスバーの分）を、バーの高さに持ち込まない
  child: Builder(
    builder: (context) => MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: CupertinoNavigationBar(
        // デモは一覧の見本や比較で同じ Route に何枚も並ぶので、Hero で飛ばさない
        transitionBetweenRoutes: false,
        leading: args.valueOf<Widget>('leading'),
        middle: args.valueOf<Widget>('middle'),
        trailing: args.valueOf<Widget>('trailing'),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
      ),
    ),
  ),
);
