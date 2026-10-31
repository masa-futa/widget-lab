import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextThemeDataEntry = WidgetEntry(
  id: 'cupertinoTextThemeData',
  name: 'CupertinoTextThemeData',
  genreIds: const ['cupertino'],
  summary: 'Cupertino の Widget が使う文字のスタイルをまとめた値',
  description:
      'Widget ではなく、CupertinoThemeData の textTheme に渡す値です。本文（textStyle）・'
      'ボタン（actionTextStyle）・ナビゲーションバーの題（navTitleTextStyle）などの文字のスタイルを持ちます。'
      'プレビューは、組み立てた値を CupertinoTheme で配った小さな画面です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextThemeData-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'primaryColor',
      group: PropertyGroup.text,
      typeLabel: 'Color',
      description: '押せる文字の既定の色。ここでは戻るボタンの文字に出る。指定しないと systemBlue',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice(
            'systemPink',
            CupertinoColors.systemPink,
            'CupertinoColors.systemPink',
          ),
          Choice(
            'systemGreen',
            CupertinoColors.systemGreen,
            'CupertinoColors.systemGreen',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'textStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: '本文の文字。指定しないと 17 の label 色',
      control: ChoiceControl(choices: _styles),
    ),
    PropertySpec(
      name: 'actionTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: 'CupertinoButton など、押せる文字。指定しないと主な色',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles, initialIndex: 1),
    ),
    PropertySpec(
      name: 'navTitleTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: 'ナビゲーションバーの真ん中の題',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles, initialIndex: 2),
    ),
    PropertySpec(
      name: 'actionSmallTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: '小さい CupertinoButton（sizeStyle が small）の文字',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles, initialIndex: 2),
    ),
    PropertySpec(
      name: 'navActionTextStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: 'ナビゲーションバーの戻るボタンの文字',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'tabLabelTextStyle',
      typeLabel: 'TextStyle?',
      description: 'CupertinoTabBar のタブの名前の文字（プレビューにはタブバーを置いていない）',
    ),
    ReferenceArg(
      name: 'navLargeTitleTextStyle',
      typeLabel: 'TextStyle?',
      description: 'CupertinoSliverNavigationBar の大きな題の文字（プレビューには置いていない）',
    ),
    ReferenceArg(
      name: 'pickerTextStyle',
      typeLabel: 'TextStyle?',
      description: 'CupertinoPicker の行の文字（プレビューには置いていない）',
    ),
    ReferenceArg(
      name: 'dateTimePickerTextStyle',
      typeLabel: 'TextStyle?',
      description:
          'CupertinoDatePicker・CupertinoTimerPicker の行の文字（プレビューには置いていない）',
    ),
  ],
  build: _build,
  codeName: 'CupertinoTextThemeData',
);

const _styles = [
  Choice(
    '20・太字',
    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    'TextStyle(fontSize: 20, fontWeight: FontWeight.bold)',
  ),
  Choice(
    '紅',
    TextStyle(color: Color(0xFFD7003A)),
    'TextStyle(color: Color(0xFFD7003A))',
  ),
  Choice(
    '13・斜体',
    TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
    'TextStyle(fontSize: 13, fontStyle: FontStyle.italic)',
  ),
];

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: _Sample(
    textTheme: CupertinoTextThemeData(
      primaryColor:
          args.valueOf<Color>('primaryColor') ?? CupertinoColors.systemBlue,
      textStyle: args.valueOf<TextStyle>('textStyle'),
      actionTextStyle: args.valueOf<TextStyle>('actionTextStyle'),
      navTitleTextStyle: args.valueOf<TextStyle>('navTitleTextStyle'),
      actionSmallTextStyle: args.valueOf<TextStyle>('actionSmallTextStyle'),
      navActionTextStyle: args.valueOf<TextStyle>('navActionTextStyle'),
    ),
  ),
);

/// 文字のテーマを受ける小さな画面（デモの部品）。戻るボタン・題・本文・ボタン・小さいボタン。
class _Sample extends StatelessWidget {
  const _Sample({required this.textTheme});

  final CupertinoTextThemeData textTheme;

  @override
  Widget build(BuildContext context) => CupertinoTheme(
    // 明るさなどは親から受け、文字だけ差し替える
    data: CupertinoTheme.of(context).copyWith(textTheme: textTheme),
    child: SizedBox(
      width: 300,
      height: 200,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // 前の画面はないので、押しても何もしない戻るボタンを置く
          leading: CupertinoNavigationBarBackButton(
            previousPageTitle: '戻る',
            onPressed: () {},
          ),
          middle: const Text('題の文字'),
          // 一覧の見本や比較で同じ Route に並ぶと Hero の tag が重なるので、Hero で飛ばさない
          transitionBetweenRoutes: false,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const Text('本文の文字'),
              CupertinoButton(onPressed: () {}, child: const Text('ボタンの文字')),
              CupertinoButton(
                sizeStyle: CupertinoButtonSize.small,
                onPressed: () {},
                child: const Text('小さいボタン'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
