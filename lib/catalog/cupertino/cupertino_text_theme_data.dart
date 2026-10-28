import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      name: 'textStyle',
      typeLabel: 'TextStyle?',
      description: '本文の文字。指定しないと 17 の label 色',
      control: ChoiceControl(choices: _styles),
    ),
    PropertySpec(
      name: 'actionTextStyle',
      typeLabel: 'TextStyle?',
      description: 'CupertinoButton など、押せる文字。指定しないと主な色',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles, initialIndex: 1),
    ),
    PropertySpec(
      name: 'navTitleTextStyle',
      typeLabel: 'TextStyle?',
      description: 'ナビゲーションバーの真ん中の題',
      initiallyOn: false,
      control: ChoiceControl(choices: _styles, initialIndex: 2),
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
      textStyle: args.valueOf<TextStyle>('textStyle'),
      actionTextStyle: args.valueOf<TextStyle>('actionTextStyle'),
      navTitleTextStyle: args.valueOf<TextStyle>('navTitleTextStyle'),
    ),
  ),
);

/// 文字のテーマを受ける小さな画面（デモの部品）。題・本文・ボタン。
class _Sample extends StatelessWidget {
  const _Sample({required this.textTheme});

  final CupertinoTextThemeData textTheme;

  @override
  Widget build(BuildContext context) => CupertinoTheme(
    // 明るさなどは親から受け、文字だけ差し替える
    data: CupertinoTheme.of(context).copyWith(textTheme: textTheme),
    child: SizedBox(
      width: 300,
      height: 160,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('題の文字'),
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
            ],
          ),
        ),
      ),
    ),
  );
}
