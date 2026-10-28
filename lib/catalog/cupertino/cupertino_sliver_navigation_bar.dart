import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSliverNavigationBarEntry = WidgetEntry(
  id: 'cupertinoSliverNavigationBar',
  name: 'CupertinoSliverNavigationBar',
  genreIds: const ['cupertino', 'layout', 'scrolling'],
  summary: 'スクロールで縮む、大きな題の iOS のナビゲーションバー',
  description:
      'CustomScrollView の最初に置く、大きな題（largeTitle）のナビゲーションバーです。'
      '中身を上へスクロールすると大きな題が縮み、バーの真ん中の小さな題に替わります。'
      'プレビューの中のリストをスクロールして確かめます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSliverNavigationBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'largeTitle',
      typeLabel: 'Widget?',
      description: '広がっているときに出す大きな題',
      control: FixedControl(value: Text('メール'), source: "Text('メール')"),
    ),
    const PropertySpec(
      name: 'middle',
      typeLabel: 'Widget?',
      description: 'バーの真ん中の小さな題。指定しないと largeTitle を使う',
      initiallyOn: false,
      control: FixedControl(value: Text('受信'), source: "Text('受信')"),
    ),
    const PropertySpec(
      name: 'alwaysShowMiddle',
      typeLabel: 'bool',
      description: 'false なら、縮みきるまで真ん中の小さな題を出さない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'trailing',
      typeLabel: 'Widget?',
      description: 'バーの終わりに置く Widget',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(CupertinoIcons.add),
        source: 'Icon(CupertinoIcons.add)',
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: 'バーの地の色。指定しないとテーマの barBackgroundColor',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'stretch',
      typeLabel: 'bool',
      description: 'true なら、上の端を越えて引いたとき大きな題の部分が伸びる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: _build,
  codeName: 'CupertinoSliverNavigationBar',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 320,
  height: 220,
  child: CustomScrollView(
    // 端を越えて引けるようにする（stretch を試すため）
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    slivers: [
      CupertinoSliverNavigationBar(
        largeTitle: args.valueOf<Widget>('largeTitle'),
        middle: args.valueOf<Widget>('middle'),
        alwaysShowMiddle: args.valueOf<bool>('alwaysShowMiddle') ?? true,
        trailing: args.valueOf<Widget>('trailing'),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        stretch: args.valueOf<bool>('stretch') ?? false,
        // 一覧の見本や比較で同じ Route に並ぶと Hero の tag が重なるので、Hero で飛ばさない
        transitionBetweenRoutes: false,
      ),
      SliverList.builder(
        itemCount: 20,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('${index + 1} 通目のメール'),
        ),
      ),
    ],
  ),
);
