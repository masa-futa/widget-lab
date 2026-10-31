import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '左に置く Widget。指定しないと、戻れる画面では戻るボタンが出る',
      initiallyOn: false,
      control: FixedControl(value: _leading, source: _leadingSource),
    ),
    const PropertySpec(
      name: 'automaticallyImplyLeading',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'leading がないとき、戻れる画面なら左に戻るボタンを自動で出すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'previousPageTitle',
      group: PropertyGroup.content,
      typeLabel: 'String?',
      description: '自動で出す戻るボタンの文字。指定しないと前の Route の題',
      initiallyOn: false,
      control: TextControl(initialValue: '一覧'),
    ),
    const PropertySpec(
      name: 'middle',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '真ん中の題。指定しないと Route の題（CupertinoPageRoute の title）が出る',
      control: FixedControl(value: Text('設定'), source: "Text('設定')"),
    ),
    const PropertySpec(
      name: 'trailing',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '右に置く Widget',
      control: FixedControl(value: _trailing, source: _trailingSource),
    ),
    const PropertySpec(
      name: 'bottom',
      group: PropertyGroup.content,
      typeLabel: 'PreferredSizeWidget?',
      description: 'バーの下の段に置く Widget。その分だけバーが高くなる',
      initiallyOn: false,
      control: FixedControl(value: _bottom, source: _bottomSource),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
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
    const PropertySpec(
      name: 'border',
      group: PropertyGroup.paint,
      typeLabel: 'Border?',
      description: 'バーのふちの線。指定しないと下に 1 物理ピクセルの薄い線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太い赤線',
            Border(
              bottom: BorderSide(color: CupertinoColors.systemRed, width: 2),
            ),
            'Border(bottom: BorderSide(color: CupertinoColors.systemRed, width: 2))',
          ),
          Choice('線なし', Border(), 'Border()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsDirectional?',
      description: 'バーの中の左右の余白。指定しないと 16（自動の戻るボタンがあれば 0）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 6,
        initialValue: 32,
        resolve: (v) => EdgeInsetsDirectional.symmetric(horizontal: v),
        code: (v) => 'EdgeInsetsDirectional.symmetric(horizontal: $v)',
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
      name: 'automaticallyImplyMiddle',
      typeLabel: 'bool',
      description: 'middle がないとき、Route の題（CupertinoPageRoute の title）を真ん中に出すか',
    ),
    ReferenceArg(
      name: 'automaticBackgroundVisibility',
      typeLabel: 'bool',
      description: 'CupertinoPageScaffold の中で、下の中身が重なるまで地を透明にしておくか',
    ),
    ReferenceArg(
      name: 'enableBackgroundFilterBlur',
      typeLabel: 'bool',
      description: '地が半透明のとき、後ろの中身をぼかすか。見本ではバーの後ろに中身がない',
    ),
    ReferenceArg(
      name: 'brightness',
      typeLabel: 'Brightness?',
      description: '上のステータスバーの文字やアイコンを明るくするか暗くするか',
    ),
    ReferenceArg(
      name: 'transitionBetweenRoutes',
      typeLabel: 'bool',
      description: '画面の遷移のとき、前後の画面のバーをつないで動かすか（見本では同じ画面に何枚も並ぶので false）',
    ),
    ReferenceArg(
      name: 'heroTag',
      typeLabel: 'Object',
      description: '遷移でバーをつなぐときの目印。transitionBetweenRoutes が true のときだけ指定できる',
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

// 小さいカード（高さ 64）にもバー（44）と合わせて収まる高さにする
const _bottom = PreferredSize(
  preferredSize: Size.fromHeight(20),
  child: Text('下の段', style: TextStyle(fontSize: 12)),
);
const _bottomSource =
    "PreferredSize(preferredSize: Size.fromHeight(20), child: Text('下の段'))";

/// CupertinoNavigationBar の border の既定値（SDK の _kDefaultNavBarBorder と同じ）。
const _defaultBorder = Border(
  bottom: BorderSide(color: Color(0x4D000000), width: 0),
);

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
        automaticallyImplyLeading:
            args.valueOf<bool>('automaticallyImplyLeading') ?? true,
        previousPageTitle: args.valueOf<String>('previousPageTitle'),
        middle: args.valueOf<Widget>('middle'),
        trailing: args.valueOf<Widget>('trailing'),
        bottom: args.valueOf<PreferredSizeWidget>('bottom'),
        backgroundColor: args.valueOf<Color>('backgroundColor'),
        border: args.valueOf<Border>('border') ?? _defaultBorder,
        padding: args.valueOf<EdgeInsetsDirectional>('padding'),
      ),
    ),
  ),
);
