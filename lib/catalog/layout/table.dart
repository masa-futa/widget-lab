import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final tableEntry = WidgetEntry(
  id: 'table',
  name: 'Table',
  genreIds: const ['layout'],
  summary: '子を行と列の表に並べる',
  description:
      'TableRow ごとに子を並べ、列の幅をそろえた表にします。'
      '行の高さはその行で一番高い子に合わせます。スクロールはしません。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Table-class.html'),
  properties: [
    PropertySpec(
      name: 'border',
      group: PropertyGroup.paint,
      typeLabel: 'TableBorder?',
      description: '表の線。既定は線なし',
      control: ChoiceControl(
        choices: [
          Choice('all', TableBorder.all(), 'TableBorder.all()'),
          const Choice(
            'symmetric',
            TableBorder.symmetric(inside: BorderSide()),
            'TableBorder.symmetric(inside: BorderSide())',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'defaultColumnWidth',
      group: PropertyGroup.size,
      typeLabel: 'TableColumnWidth',
      description: '列の幅の決め方。既定は FlexColumnWidth（残りを等分）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('Flex', FlexColumnWidth(), 'FlexColumnWidth()'),
          Choice('Intrinsic', IntrinsicColumnWidth(), 'IntrinsicColumnWidth()'),
          Choice('Fixed 48', FixedColumnWidth(48), 'FixedColumnWidth(48)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'columnWidths',
      group: PropertyGroup.size,
      typeLabel: 'Map<int, TableColumnWidth>?',
      description: '列ごとの幅の決め方。ここにない列は defaultColumnWidth で決める',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('1 列目を 24', {
            0: FixedColumnWidth(24),
          }, '{0: FixedColumnWidth(24)}'),
          Choice('2 列目を 2 倍', {
            1: FlexColumnWidth(2),
          }, '{1: FlexColumnWidth(2)}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'defaultVerticalAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'TableCellVerticalAlignment',
      description: '行の中での縦の位置。既定は top',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice(
            'top',
            TableCellVerticalAlignment.top,
            'TableCellVerticalAlignment.top',
          ),
          Choice(
            'middle',
            TableCellVerticalAlignment.middle,
            'TableCellVerticalAlignment.middle',
          ),
          Choice(
            'bottom',
            TableCellVerticalAlignment.bottom,
            'TableCellVerticalAlignment.bottom',
          ),
          Choice(
            'fill',
            TableCellVerticalAlignment.fill,
            'TableCellVerticalAlignment.fill',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.layout,
      typeLabel: 'TextDirection?',
      description: '列を並べる向き。rtl にすると 1 列目が右端になる。指定しないとまわりの向き',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('ltr', TextDirection.ltr, 'TextDirection.ltr'),
          Choice('rtl', TextDirection.rtl, 'TextDirection.rtl'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<TableRow>',
      description: '行。どの行も子の数（列の数）をそろえる',
      control: FixedControl(
        value: <TableRow>[
          TableRow(
            children: [
              DemoTile(1, width: 32, height: 20),
              DemoTile(2, width: 64, height: 32),
              DemoTile(3, width: 48, height: 20),
            ],
          ),
          TableRow(
            children: [
              DemoTile(4, width: 48, height: 16),
              DemoTile(5, width: 32, height: 16),
              DemoTile(1, width: 64, height: 16),
            ],
          ),
        ],
        source:
            '[TableRow(children: [Tile(1), Tile(2), Tile(3)]), '
            'TableRow(children: [Tile(4), Tile(5), Tile(1)])]',
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
      name: 'textBaseline',
      typeLabel: 'TextBaseline?',
      description: 'defaultVerticalAlignment が baseline のときに、子を揃える文字の基準線',
    ),
  ],
  build: _build,
  codeName: 'Table',
);

Widget _build(DemoArgs args) => Table(
  border: args.valueOf<TableBorder>('border'),
  defaultColumnWidth:
      args.valueOf<TableColumnWidth>('defaultColumnWidth') ??
      const FlexColumnWidth(),
  columnWidths: args.valueOf<Map<int, TableColumnWidth>>('columnWidths'),
  textDirection: args.valueOf<TextDirection>('textDirection'),
  defaultVerticalAlignment:
      args.valueOf<TableCellVerticalAlignment>('defaultVerticalAlignment') ??
      TableCellVerticalAlignment.top,
  children: args.valueOf<List<TableRow>>('children') ?? const [],
);
