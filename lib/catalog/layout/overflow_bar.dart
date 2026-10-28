import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final overflowBarEntry = WidgetEntry(
  id: 'overflowBar',
  name: 'OverflowBar',
  genreIds: const ['layout'],
  summary: '子を横に並べ、入りきらなければ縦に積み直す',
  description:
      '子を横一列に並べます。幅が足りないときは、はみ出させずに縦に積み直します。'
      'ダイアログのボタンの並びに使われます。比べると、狭いカードで縦に積まれます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/OverflowBar-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'spacing',
      typeLabel: 'double',
      description: '横に並べたときの、子と子のあいだ。既定は 0',
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'MainAxisAlignment?',
      description: '横に並べたときの並べ方。既定は start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('start', MainAxisAlignment.start, 'MainAxisAlignment.start'),
          Choice(
            'center',
            MainAxisAlignment.center,
            'MainAxisAlignment.center',
          ),
          Choice('end', MainAxisAlignment.end, 'MainAxisAlignment.end'),
          Choice(
            'spaceBetween',
            MainAxisAlignment.spaceBetween,
            'MainAxisAlignment.spaceBetween',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'overflowSpacing',
      typeLabel: 'double',
      description: '縦に積んだときの、子と子のあいだ。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 2,
        initialValue: 4,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'overflowAlignment',
      typeLabel: 'OverflowBarAlignment',
      description: '縦に積んだときの揃え方。既定は start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice(
            'start',
            OverflowBarAlignment.start,
            'OverflowBarAlignment.start',
          ),
          Choice(
            'center',
            OverflowBarAlignment.center,
            'OverflowBarAlignment.center',
          ),
          Choice('end', OverflowBarAlignment.end, 'OverflowBarAlignment.end'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる子（幅 64・88・112）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 64, height: 20),
          DemoTile(2, width: 88, height: 20),
          DemoTile(3, width: 112, height: 20),
        ],
        source: '[Tile(1), Tile(2), Tile(3)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'OverflowBar',
);

Widget _build(DemoArgs args) => OverflowBar(
  spacing: args.valueOf<double>('spacing') ?? 0,
  alignment: args.valueOf<MainAxisAlignment>('alignment'),
  overflowSpacing: args.valueOf<double>('overflowSpacing') ?? 0,
  overflowAlignment:
      args.valueOf<OverflowBarAlignment>('overflowAlignment') ??
      OverflowBarAlignment.start,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
