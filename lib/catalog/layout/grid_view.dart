import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final gridViewEntry = WidgetEntry(
  id: 'gridView',
  name: 'GridView',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を格子に並べてスクロールする',
  description:
      '子を縦横の格子に並べ、はみ出す分はスクロールします。'
      'GridView.count は 1 行の数を決める書き方です。'
      '1 つの幅を決める GridView.extent、たくさんの子を必要な分だけ作る GridView.builder もあります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/GridView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'crossAxisCount',
      typeLabel: 'int',
      description: '1 行（スクロールと直角の向き）に並べる数',
      required: true,
      control: SliderControl(
        min: 1,
        max: 6,
        divisions: 5,
        initialValue: 4,
        resolve: asInt,
        code: intCode,
      ),
    ),
    const PropertySpec(
      name: 'mainAxisSpacing',
      typeLabel: 'double',
      description: 'スクロールの向きの、子と子のあいだ。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'crossAxisSpacing',
      typeLabel: 'double',
      description: 'スクロールと直角の向きの、子と子のあいだ。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'scrollDirection',
      typeLabel: 'Axis',
      description: 'スクロールの向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる子',
      control: FixedControl(
        value: <Widget>[for (var i = 1; i <= 16; i++) DemoTile(i)],
        source: 'List.generate(16, (i) => Tile(i + 1))',
      ),
    ),
  ],
  build: _build,
  codeName: 'GridView.count',
);

Widget _build(DemoArgs args) => GridView.count(
  // 必須のプロパティなので、常に値がある
  crossAxisCount: args.valueOf<int>('crossAxisCount')!,
  mainAxisSpacing: args.valueOf<double>('mainAxisSpacing') ?? 0,
  crossAxisSpacing: args.valueOf<double>('crossAxisSpacing') ?? 0,
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
