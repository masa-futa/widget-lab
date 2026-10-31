import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final fractionalTranslationEntry = WidgetEntry(
  id: 'fractionalTranslation',
  name: 'FractionalTranslation',
  genreIds: const ['painting'],
  summary: '子を、子の大きさの割合だけずらして描く',
  description:
      '子を描くときに、子の幅・高さに translation を掛けた分だけずらします'
      '（0.5 なら半分）。場所の取り方は変わらないので、まわりの並びは動きません。'
      'ここでは左右に Tile(2)・Tile(3) を並べています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FractionalTranslation-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'translation',
      group: PropertyGroup.transform,
      typeLabel: 'Offset',
      description: 'ずらす量（子の幅・高さに対する割合）',
      control: ChoiceControl(
        choices: [
          Choice('右へ半分', Offset(0.5, 0), 'Offset(0.5, 0)'),
          Choice('下へ半分', Offset(0, 0.5), 'Offset(0, 0.5)'),
          Choice('左上へ 1 つ分', Offset(-1, -1), 'Offset(-1, -1)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ずらして描く Widget（40×40）',
      control: FixedControl(
        value: DemoTile(1, width: 40, height: 40),
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
    ReferenceArg(
      name: 'transformHitTests',
      typeLabel: 'bool',
      description: 'ずらした先で押されたことを受けるか。false だと元の場所で受ける。既定は true',
    ),
  ],
  build: _build,
  codeName: 'FractionalTranslation',
);

Widget _build(DemoArgs args) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const DemoTile(2, width: 40, height: 40),
    FractionalTranslation(
      // API では必須。Padding の padding と同じく、OFF はずらさない値で組む
      translation: args.valueOf<Offset>('translation') ?? Offset.zero,
      child: args.valueOf<Widget>('child'),
    ),
    const DemoTile(3, width: 40, height: 40),
  ],
);
