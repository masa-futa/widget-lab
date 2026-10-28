import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final clipRectEntry = WidgetEntry(
  id: 'clipRect',
  name: 'ClipRect',
  genreIds: const ['painting'],
  summary: '自分の四角の外にはみ出した子を切り落とす',
  description:
      '子が自分の大きさからはみ出して描かれるとき、はみ出した所を切り落とします。'
      'ここでは 64×32 の枠（SizedBox）の中で、OverflowBox で 120×56 にはみ出させた子を包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ClipRect-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '切り方。none にすると切らない。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
          Choice('none', Clip.none, 'Clip.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'はみ出す Widget',
      control: FixedControl(
        value: OverflowBox(
          maxWidth: 120,
          maxHeight: 56,
          child: DemoTile(1, width: 120, height: 56),
        ),
        source: 'OverflowBox(maxWidth: 120, maxHeight: 56, child: Tile(1))',
      ),
    ),
  ],
  build: _build,
  codeName: 'ClipRect',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 64,
  height: 32,
  child: ClipRect(
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
    child: args.valueOf<Widget>('child'),
  ),
);
