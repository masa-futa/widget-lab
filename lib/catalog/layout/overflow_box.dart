import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final overflowBoxEntry = WidgetEntry(
  id: 'overflowBox',
  name: 'OverflowBox',
  genreIds: const ['layout'],
  summary: '親の制約を無視した大きさを子に許し、はみ出させる',
  description:
      '親からの制約の代わりに、minWidth・maxWidth などで決めた制約を子に渡します。'
      '自分は親の制約どおりの大きさのままなので、子ははみ出して描かれます。'
      'ここでは 64×32 の枠（SizedBox）の中に、120×56 にしたい子を置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/OverflowBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'maxWidth',
      typeLabel: 'double?',
      // 下限（minWidth）を指定しないと親の下限（64）のままなので、上限はそれより小さくできない
      description: '子に許す幅の上限。指定しないと親の上限（64）のまま',
      control: SliderControl(
        min: 64,
        max: 160,
        divisions: 6,
        initialValue: 128,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxHeight',
      typeLabel: 'double?',
      description: '子に許す高さの上限。指定しないと親の上限（32）のまま',
      control: SliderControl(
        min: 32,
        max: 56,
        divisions: 3,
        initialValue: 56,
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
      description: 'はみ出させる Widget（120×56 にしたい）',
      control: FixedControl(
        value: DemoTile(1, width: 120, height: 56),
        source: 'Tile(1)',
      ),
    ),
  ],
  build: _build,
  codeName: 'OverflowBox',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 64,
  height: 32,
  child: OverflowBox(
    maxWidth: args.valueOf<double>('maxWidth'),
    maxHeight: args.valueOf<double>('maxHeight'),
    alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
    child: args.valueOf<Widget>('child'),
  ),
);
