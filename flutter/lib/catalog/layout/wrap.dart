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
      group: PropertyGroup.spacing,
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
      group: PropertyGroup.spacing,
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
      group: PropertyGroup.layout,
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
      name: 'runAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'WrapAlignment',
      description: '行そのものを、行を重ねる向きにどう並べるか。既定は start',
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
      name: 'crossAxisAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'WrapCrossAlignment',
      description: '行の中で、高さの違う子をどこに揃えるか。既定は start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('start', WrapCrossAlignment.start, 'WrapCrossAlignment.start'),
          Choice(
            'center',
            WrapCrossAlignment.center,
            'WrapCrossAlignment.center',
          ),
          Choice('end', WrapCrossAlignment.end, 'WrapCrossAlignment.end'),
        ],
      ),
    ),
    PropertySpec(
      name: 'direction',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '並べる向き。既定は horizontal',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices),
    ),
    PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.layout,
      typeLabel: 'TextDirection?',
      description: '横に並べる向き。rtl にすると右から並べる。指定しないとまわりの向き',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('ltr', TextDirection.ltr, 'TextDirection.ltr'),
          Choice('rtl', TextDirection.rtl, 'TextDirection.rtl'),
        ],
      ),
    ),
    PropertySpec(
      name: 'verticalDirection',
      group: PropertyGroup.layout,
      typeLabel: 'VerticalDirection',
      description: '縦に並べる向き。up にすると下から積む。既定は down',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('down', VerticalDirection.down, 'VerticalDirection.down'),
          Choice('up', VerticalDirection.up, 'VerticalDirection.up'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '並べる子（幅も高さもまちまち）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 56, height: 16),
          DemoTile(2, width: 40, height: 24),
          DemoTile(3, width: 72, height: 16),
          DemoTile(4, width: 48, height: 24),
          DemoTile(5, width: 64, height: 16),
          DemoTile(6, width: 40, height: 16),
          DemoTile(7, width: 56, height: 24),
        ],
        source: '[Tile(1), Tile(2), …, Tile(7)]',
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
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: 'はみ出した子を切り抜くか。ここでは子がはみ出さないので違いは出ない。既定は none',
    ),
  ],
  build: _build,
  codeName: 'Wrap',
);

Widget _build(DemoArgs args) => Wrap(
  spacing: args.valueOf<double>('spacing') ?? 0,
  runSpacing: args.valueOf<double>('runSpacing') ?? 0,
  alignment: args.valueOf<WrapAlignment>('alignment') ?? WrapAlignment.start,
  runAlignment:
      args.valueOf<WrapAlignment>('runAlignment') ?? WrapAlignment.start,
  crossAxisAlignment:
      args.valueOf<WrapCrossAlignment>('crossAxisAlignment') ??
      WrapCrossAlignment.start,
  direction: args.valueOf<Axis>('direction') ?? Axis.horizontal,
  textDirection: args.valueOf<TextDirection>('textDirection'),
  verticalDirection:
      args.valueOf<VerticalDirection>('verticalDirection') ??
      VerticalDirection.down,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
