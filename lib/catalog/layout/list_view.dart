import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final listViewEntry = WidgetEntry(
  id: 'listView',
  name: 'ListView',
  genreIds: const ['layout', 'scrolling'],
  summary: '子を一列に並べてスクロールする',
  description:
      '子を一列に並べ、はみ出す分はスクロールします。'
      '子がたくさんあるときは、見える分だけを作る ListView.builder を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ListView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'scrollDirection',
      typeLabel: 'Axis',
      description: 'スクロールの向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'reverse',
      typeLabel: 'bool',
      description: '逆の端（下・右）から並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry?',
      description: '並びのまわりの余白。余白もスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'itemExtent',
      typeLabel: 'double?',
      description: '子 1 つのスクロールの向きの長さ。決めると子の大きさを調べずに済み、速くなる',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 6,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる子',
      control: FixedControl(
        value: <Widget>[
          for (var i = 1; i <= 12; i++) DemoTile(i, width: 64, height: 32),
        ],
        source: 'List.generate(12, (i) => Tile(i + 1))',
      ),
    ),
  ],
  build: _build,
  codeName: 'ListView',
);

Widget _build(DemoArgs args) => ListView(
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  reverse: args.valueOf<bool>('reverse') ?? false,
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  itemExtent: args.valueOf<double>('itemExtent'),
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
