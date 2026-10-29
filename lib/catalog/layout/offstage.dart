import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final offstageEntry = WidgetEntry(
  id: 'offstage',
  name: 'Offstage',
  genreIds: const ['layout'],
  summary: '子を木に残したまま、見えなくして場所も取らなくする',
  description:
      'offstage が true のあいだ、子は組み立てられて状態も残りますが、描かれず、'
      '押せず、場所も取りません（大きさ 0）。ここでは右に Tile(2) を並べています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Offstage-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'offstage',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '見えなくするか。既定は true（見えない）',
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '隠す Widget',
      control: FixedControl(
        value: DemoTile(1, width: 48, height: 48),
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
  codeName: 'Offstage',
);

Widget _build(DemoArgs args) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Offstage(
      offstage: args.valueOf<bool>('offstage') ?? true,
      child: args.valueOf<Widget>('child'),
    ),
    const DemoTile(2, width: 48, height: 48),
  ],
);
