import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final wrapEntry = WidgetEntry(
  id: 'wrap',
  name: 'Wrap',
  genreIds: const ['layout'],
  summary: '子を並べ、入りきらなければ次の行に折り返す',
  description:
      '子を横（direction の向き）に並べ、端まで来たら次の行（run）に折り返します。'
      'タグやチップの並びによく使います。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Wrap-class.html'),
  properties: const [
    PropertySpec(
      name: 'spacing',
      typeLabel: 'double',
      description: '同じ行の、子と子のあいだ。既定は 0',
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'runSpacing',
      typeLabel: 'double',
      description: '行と行のあいだ。既定は 0',
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 4,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'WrapAlignment',
      description: '行の中での並べ方。既定は start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('start', WrapAlignment.start, 'WrapAlignment.start'),
          Choice('center', WrapAlignment.center, 'WrapAlignment.center'),
          Choice('end', WrapAlignment.end, 'WrapAlignment.end'),
          Choice(
            'spaceBetween',
            WrapAlignment.spaceBetween,
            'WrapAlignment.spaceBetween',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'direction',
      typeLabel: 'Axis',
      description: '並べる向き。既定は horizontal',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる子（幅がまちまち）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 56, height: 16),
          DemoTile(2, width: 40, height: 16),
          DemoTile(3, width: 72, height: 16),
          DemoTile(4, width: 48, height: 16),
          DemoTile(5, width: 64, height: 16),
          DemoTile(6, width: 40, height: 16),
          DemoTile(7, width: 56, height: 16),
        ],
        source: '[Tile(1), Tile(2), …, Tile(7)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'Wrap',
);

Widget _build(DemoArgs args) => Wrap(
  spacing: args.valueOf<double>('spacing') ?? 0,
  runSpacing: args.valueOf<double>('runSpacing') ?? 0,
  alignment: args.valueOf<WrapAlignment>('alignment') ?? WrapAlignment.start,
  direction: args.valueOf<Axis>('direction') ?? Axis.horizontal,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
