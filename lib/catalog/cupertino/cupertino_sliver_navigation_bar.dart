import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '広がっているときに出す大きな題',
      control: FixedControl(value: Text('メール'), source: "Text('メール')"),
    ),
    const PropertySpec(
      name: 'middle',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'バーの真ん中の小さな題。指定しないと largeTitle を使う',
      initiallyOn: false,
      control: FixedControl(value: Text('受信'), source: "Text('受信')"),
    ),
    const PropertySpec(
      name: 'alwaysShowMiddle',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'false なら、縮みきるまで真ん中の小さな題を出さない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'leading',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'バーの始めに置く Widget。指定しないと、戻れるときに戻るボタンが入る',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(CupertinoIcons.person),
        source: 'Icon(CupertinoIcons.person)',
      ),
    ),
    const PropertySpec(
      name: 'trailing',
      group: PropertyGroup.content,
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
      group: PropertyGroup.paint,
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
      name: 'border',
      group: PropertyGroup.paint,
      typeLabel: 'Border?',
      description: 'バーの下のふちの線。指定しないと灰色の細い線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太い赤線',
            Border(bottom: BorderSide(color: Color(0xFFD7003A), width: 2)),
            'Border(bottom: BorderSide(color: Color(0xFFD7003A), width: 2))',
          ),
          Choice('なし（null）', false, 'null'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enableBackgroundFilterBlur',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: 'false なら、中身がバーの下に入ったときに半透明の地の向こうをぼかさない',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsDirectional?',
      description: 'バーの中身の左右の余白。指定しないと 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 6,
        initialValue: 40,
        resolve: (v) => EdgeInsetsDirectional.only(start: v, end: v),
        code: (v) => 'EdgeInsetsDirectional.only(start: $v, end: $v)',
      ),
    ),
    const PropertySpec(
      name: 'bottom',
      group: PropertyGroup.content,
      pairsWith: ['bottomMode'],
      typeLabel: 'PreferredSizeWidget?',
      description: '大きな題の下に置く Widget（検索欄など）。PreferredSize で高さを決める',
      initiallyOn: false,
      control: FixedControl(value: _bottom, source: _bottomSource),
    ),
    PropertySpec(
      name: 'bottomMode',
      group: PropertyGroup.behavior,
      requires: 'bottom',
      omitIf: (settings) => !(settings['bottom']?.on ?? false),
      typeLabel: 'NavigationBarBottomMode?',
      description: 'スクロールしたときの bottom。automatic は縮めて隠し、always は残す',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final mode in NavigationBarBottomMode.values)
            Choice(mode.name, mode, 'NavigationBarBottomMode.${mode.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'stretch',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'true なら、上の端を越えて引いたとき大きな題の部分が伸びる',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'automaticallyImplyLeading',
      typeLabel: 'bool',
      description: 'leading がないとき、前の画面へ戻れるなら戻るボタンを自動で入れるか（プレビューには前の画面がない）',
    ),
    ReferenceArg(
      name: 'automaticallyImplyTitle',
      typeLabel: 'bool',
      description:
          'largeTitle がないとき、Route の title を大きな題に使うか（プレビューの Route には title がない）',
    ),
    ReferenceArg(
      name: 'previousPageTitle',
      typeLabel: 'String?',
      description: '自動で入れる戻るボタンに出す、前の画面の題（プレビューには前の画面がない）',
    ),
    ReferenceArg(
      name: 'automaticBackgroundVisibility',
      typeLabel: 'bool',
      description: '中身が下に入るまで地を透明にするか。CupertinoPageScaffold の中でだけ効く',
    ),
    ReferenceArg(
      name: 'brightness',
      typeLabel: 'Brightness?',
      description: 'バーの上のステータスバーの文字を明るくするか暗くするか。プレビューには出ない',
    ),
    ReferenceArg(
      name: 'transitionBetweenRoutes',
      typeLabel: 'bool',
      description: '画面を移るときに、バーを Hero で前後の画面のバーへ移すか。プレビューでは false にしている',
    ),
    ReferenceArg(
      name: 'heroTag',
      typeLabel: 'Object',
      description: 'transitionBetweenRoutes の Hero の tag。同じ画面に何本もバーを置くときに分ける',
    ),
  ],
  build: _build,
  codeName: 'CupertinoSliverNavigationBar',
);

const _bottom = PreferredSize(
  preferredSize: Size.fromHeight(36),
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Align(alignment: Alignment.centerLeft, child: Text('すべて・未読・旗つき')),
  ),
);
const _bottomSource =
    'PreferredSize(preferredSize: Size.fromHeight(36), '
    "child: Text('すべて・未読・旗つき'))";

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
        leading: args.valueOf<Widget>('leading'),
        middle: args.valueOf<Widget>('middle'),
        alwaysShowMiddle: args.valueOf<bool>('alwaysShowMiddle') ?? true,
        trailing: args.valueOf<Widget>('trailing'),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        stretch: args.valueOf<bool>('stretch') ?? false,
        border: _border(args),
        enableBackgroundFilterBlur:
            args.valueOf<bool>('enableBackgroundFilterBlur') ?? true,
        padding: args.valueOf<EdgeInsetsDirectional>('padding'),
        bottom: args.valueOf<PreferredSizeWidget>('bottom'),
        // bottom がないと bottomMode は渡せない（assert）
        bottomMode: args.valueOf<PreferredSizeWidget>('bottom') == null
            ? null
            : args.valueOf<NavigationBarBottomMode>('bottomMode'),
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

/// OFF なら既定の灰色の細い線。「なし」は null。
Border? _border(DemoArgs args) {
  final value = args.valueOf<Object>('border');
  if (value == null) {
    return const Border(bottom: BorderSide(color: Color(0x4D000000), width: 0));
  }
  return value is Border ? value : null;
}
