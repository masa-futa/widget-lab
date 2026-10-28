import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final singleChildScrollViewEntry = WidgetEntry(
  id: 'singleChildScrollView',
  name: 'SingleChildScrollView',
  genreIds: const ['scrolling'],
  summary: '1 つの子を、入りきらなければスクロールして見せる',
  description:
      '子を上限なしの高さで組み、入りきらない分をスクロールで見せます。'
      'ふだんは収まるが、小さい画面やキーボードで足りなくなる画面（フォームなど）に使います。'
      '子は全部一度に作るので、長いリストには ListView を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '子のまわりの余白。余白もスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    PropertySpec(
      name: 'reverse',
      typeLabel: 'bool',
      description: '下の端から見せるか（チャットのように）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'physics',
      typeLabel: 'ScrollPhysics?',
      description: '端に来たときの動き。指定しないと端末に合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('はね返る', BouncingScrollPhysics(), 'BouncingScrollPhysics()'),
          Choice('端で止まる', ClampingScrollPhysics(), 'ClampingScrollPhysics()'),
          Choice(
            'スクロールしない',
            NeverScrollableScrollPhysics(),
            'NeverScrollableScrollPhysics()',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'スクロールする子（8 つの箱を縦に並べた Column）',
      control: FixedControl(
        value: Column(
          children: [
            DemoTile(1, height: 32),
            DemoTile(2, height: 32),
            DemoTile(3, height: 32),
            DemoTile(4, height: 32),
            DemoTile(5, height: 32),
            DemoTile(6, height: 32),
            DemoTile(7, height: 32),
            DemoTile(8, height: 32),
          ],
        ),
        source: 'Column(children: tiles)',
      ),
    ),
  ],
  build: _build,
  codeName: 'SingleChildScrollView',
);

Widget _build(DemoArgs args) => SingleChildScrollView(
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  reverse: args.valueOf<bool>('reverse') ?? false,
  physics: args.valueOf<ScrollPhysics>('physics'),
  child: args.valueOf<Widget>('child'),
);
