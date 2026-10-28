import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final fittedBoxEntry = WidgetEntry(
  id: 'fittedBox',
  name: 'FittedBox',
  genreIds: const ['layout'],
  summary: '子を、自分の大きさに合わせて拡大・縮小する',
  description:
      '子を好きな大きさで組んでから、自分の大きさに収まるように拡大・縮小して描きます。'
      'ここでは 160×56 の枠（SizedBox）の中に、80×24 の子を置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FittedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'fit',
      typeLabel: 'BoxFit',
      description: '合わせ方。contain は比を保って収める、fill は比を崩して埋める',
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('contain', BoxFit.contain, 'BoxFit.contain'),
          Choice('fill', BoxFit.fill, 'BoxFit.fill'),
          Choice('cover', BoxFit.cover, 'BoxFit.cover'),
          Choice('fitWidth', BoxFit.fitWidth, 'BoxFit.fitWidth'),
          Choice('fitHeight', BoxFit.fitHeight, 'BoxFit.fitHeight'),
          Choice('none', BoxFit.none, 'BoxFit.none'),
          Choice('scaleDown', BoxFit.scaleDown, 'BoxFit.scaleDown'),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '余った所・はみ出した所をどちらに寄せるか。既定は center',
      initiallyOn: false,
      control: ChoiceControl(choices: alignmentChoices),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '枠からはみ出した所を切るか。既定は none（切らない）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('none', Clip.none, 'Clip.none'),
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '拡大・縮小する Widget（80×24）',
      control: FixedControl(
        value: DemoTile(1, width: 80, height: 24),
        source: 'Tile(1)',
      ),
    ),
  ],
  build: _build,
  codeName: 'FittedBox',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 160,
  height: 56,
  child: FittedBox(
    fit: args.valueOf<BoxFit>('fit') ?? BoxFit.contain,
    alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
    child: args.valueOf<Widget>('child'),
  ),
);
