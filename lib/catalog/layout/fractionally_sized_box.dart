import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final fractionallySizedBoxEntry = WidgetEntry(
  id: 'fractionallySizedBox',
  name: 'FractionallySizedBox',
  genreIds: const ['layout'],
  summary: '子の大きさを、使える広さの割合で決める',
  description:
      '使える幅・高さに widthFactor・heightFactor を掛けた大きさを子に渡します。'
      '自分は使える広さいっぱいに広がり、その中の alignment の位置に子を置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FractionallySizedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'widthFactor',
      typeLabel: 'double?',
      description: '使える幅の何割にするか。指定しないと子の幅のまま',
      control: SliderControl(
        min: 0.1,
        max: 1,
        divisions: 9,
        initialValue: 0.5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'heightFactor',
      typeLabel: 'double?',
      description: '使える高さの何割にするか。指定しないと子の高さのまま',
      initiallyOn: false,
      control: SliderControl(
        min: 0.1,
        max: 1,
        divisions: 9,
        initialValue: 0.5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '子を置く位置。既定は center',
      initiallyOn: false,
      control: ChoiceControl(choices: alignmentChoices),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '割合の大きさにする Widget（高さ 40）',
      control: FixedControl(value: DemoTile(1, height: 40), source: 'Tile(1)'),
    ),
  ],
  build: _build,
  codeName: 'FractionallySizedBox',
);

Widget _build(DemoArgs args) => FractionallySizedBox(
  widthFactor: args.valueOf<double>('widthFactor'),
  heightFactor: args.valueOf<double>('heightFactor'),
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  child: args.valueOf<Widget>('child'),
);
