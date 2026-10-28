import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final clipOvalEntry = WidgetEntry(
  id: 'clipOval',
  name: 'ClipOval',
  genreIds: const ['painting'],
  summary: '子を楕円（正方形なら円）に切り抜く',
  description:
      '自分の大きさに内接する楕円の外を切り落として描きます。'
      '正方形の子なら円になり、丸いアイコンや写真に使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ClipOval-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '切り方。antiAlias は縁をなめらかに、hardEdge は速いが縁がぎざぎざ。既定は antiAlias',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('none', Clip.none, 'Clip.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '切り抜く Widget（120×56）',
      control: FixedControl(
        value: DemoTile(1, width: 120, height: 56),
        source: 'Tile(1)',
      ),
    ),
  ],
  build: _build,
  codeName: 'ClipOval',
);

Widget _build(DemoArgs args) => ClipOval(
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.antiAlias,
  child: args.valueOf<Widget>('child'),
);
