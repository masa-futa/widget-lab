import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      name: 'defaultVerticalAlignment',
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
      name: 'children',
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
  build: _build,
  codeName: 'Table',
);

Widget _build(DemoArgs args) => Table(
  border: args.valueOf<TableBorder>('border'),
  defaultColumnWidth:
      args.valueOf<TableColumnWidth>('defaultColumnWidth') ??
      const FlexColumnWidth(),
  defaultVerticalAlignment:
      args.valueOf<TableCellVerticalAlignment>('defaultVerticalAlignment') ??
      TableCellVerticalAlignment.top,
  children: args.valueOf<List<TableRow>>('children') ?? const [],
);
