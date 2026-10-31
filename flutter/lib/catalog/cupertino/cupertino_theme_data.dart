import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoThemeDataEntry = WidgetEntry(
  id: 'cupertinoThemeData',
  name: 'CupertinoThemeData',
  genreIds: const ['cupertino'],
  summary: 'Cupertino の Widget の色・明るさ・文字をまとめた値',
  description:
      'Widget ではなく、CupertinoTheme や CupertinoApp の theme に渡す値です。主な色・明るさ・'
      'バーと画面の地の色・文字（textTheme）をまとめて持ちます。指定しない項目は、明るさに合わせた既定の値になります。'
      'プレビューは、組み立てた値を CupertinoTheme で配った小さな画面です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoThemeData-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'primaryColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '主な色。ボタンの文字やバーのボタンに使われる。指定しないと systemBlue',
      control: ColorControl(palette: _colors),
    ),
    PropertySpec(
      name: 'primaryContrastingColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '主な色の地の上に置く文字の色。塗りつぶしのボタン（CupertinoButton.filled）の文字に使われる',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 3),
    ),
    const PropertySpec(
      name: 'textTheme',
      group: PropertyGroup.text,
      typeLabel: 'CupertinoTextThemeData?',
      description: '文字のスタイルをまとめた値。指定しないと主な色と明るさから作る',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '本文 20・太字',
            CupertinoTextThemeData(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            'CupertinoTextThemeData(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))',
          ),
          Choice(
            'ボタン 13・斜体',
            CupertinoTextThemeData(
              actionTextStyle: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            'CupertinoTextThemeData(actionTextStyle: TextStyle(fontSize: 13, fontStyle: FontStyle.italic))',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'applyThemeToAll',
      group: PropertyGroup.behavior,
      typeLabel: 'bool?',
      description: 'true なら、主な色を CupertinoSwitch などにも使う。指定しないと false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'brightness',
      group: PropertyGroup.paint,
      typeLabel: 'Brightness?',
      description: '明るさ。指定しないと端末の設定に合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('light', Brightness.light, 'Brightness.light'),
          Choice('dark', Brightness.dark, 'Brightness.dark'),
        ],
      ),
    ),
    PropertySpec(
      name: 'barBackgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ナビゲーションバーとタブバーの地の色',
      initiallyOn: false,
      control: ColorControl(palette: _colors, initialIndex: 2),
    ),
    PropertySpec(
      name: 'scaffoldBackgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'CupertinoPageScaffold の地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGroupedBackground',
            CupertinoColors.systemGroupedBackground,
            'CupertinoColors.systemGroupedBackground',
          ),
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'selectionHandleColor',
      typeLabel: 'Color?',
      description: '入力欄で文字を選ぶときの、両端のつまみの色（プレビューには入力欄を置いていない）',
    ),
  ],
  build: _build,
  codeName: 'CupertinoThemeData',
);

final _colors = [
  const Choice(
    'systemPink',
    CupertinoColors.systemPink,
    'CupertinoColors.systemPink',
  ),
  const Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen',
  ),
  Choice.color('若竹（薄）', const Color(0x6668BE8D)),
  Choice.color('瑠璃', const Color(0xFF1E50A2)),
];

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: CupertinoTheme(
    data: CupertinoThemeData(
      primaryColor: args.valueOf<Color>('primaryColor'),
      brightness: args.valueOf<Brightness>('brightness'),
      barBackgroundColor: args.valueOf<Color>('barBackgroundColor'),
      scaffoldBackgroundColor: args.valueOf<Color>('scaffoldBackgroundColor'),
      primaryContrastingColor: args.valueOf<Color>('primaryContrastingColor'),
      textTheme: args.valueOf<CupertinoTextThemeData>('textTheme'),
      applyThemeToAll: args.valueOf<bool>('applyThemeToAll'),
    ),
    child: const _Sample(),
  ),
);

/// テーマを受ける小さな画面（デモの部品）。ナビゲーションバー・ボタン・塗りつぶしのボタン・スイッチ・文字。
class _Sample extends StatelessWidget {
  const _Sample();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    height: 220,
    child: CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('設定'),
        trailing: Icon(CupertinoIcons.add),
        // 一覧の見本や比較で同じ Route に並ぶと Hero の tag が重なるので、Hero で飛ばさない
        transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            const Text('本文の文字'),
            CupertinoButton(onPressed: () {}, child: const Text('ボタン')),
            CupertinoButton.filled(
              sizeStyle: CupertinoButtonSize.small,
              onPressed: () {},
              child: const Text('塗りつぶし'),
            ),
            CupertinoSwitch(value: true, onChanged: (value) {}),
          ],
        ),
      ),
    ),
  );
}
