import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sizedOverflowBoxEntry = WidgetEntry(
  id: 'sizedOverflowBox',
  name: 'SizedOverflowBox',
  genreIds: const ['layout'],
  summary: '自分は決めた大きさのまま、子には親の制約を渡してはみ出させる',
  description:
      '自分の大きさは size に決め、子には親からの制約をそのまま渡します。'
      '子が size より大きいと、はみ出して描かれます（外枠の線が自分の大きさ）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SizedOverflowBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'size',
      group: PropertyGroup.size,
      typeLabel: 'Size',
      description: '自分の大きさ',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('32×32', Size(32, 32), 'Size(32, 32)'),
          Choice('96×24', Size(96, 24), 'Size(96, 24)'),
          Choice('160×48', Size(160, 48), 'Size(160, 48)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: '子を置く位置。既定は center',
      initiallyOn: false,
      control: ChoiceControl(choices: alignmentChoices),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '置く Widget（64×40）',
      control: FixedControl(
        value: DemoTile(1, width: 64, height: 40),
        source: 'Tile(1)',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'SizedOverflowBox',
);

Widget _build(DemoArgs args) => SizedOverflowBox(
  // 必須のプロパティなので、常に値がある
  size: args.valueOf<Size>('size')!,
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  child: args.valueOf<Widget>('child'),
);
