import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final listBodyEntry = WidgetEntry(
  id: 'listBody',
  name: 'ListBody',
  genreIds: const ['layout'],
  summary: '子を一方向に順に並べ、直角の向きは親の広さに揃える',
  description:
      '子を mainAxis の向きに順に並べます。直角の向きは親の広さいっぱいにします。'
      '並べる向きには上限のない場所（スクロールの中）に置く必要があり、'
      'ここでは SingleChildScrollView の中に置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ListBody-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'mainAxis',
      typeLabel: 'Axis',
      description: '並べる向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    PropertySpec(
      name: 'reverse',
      typeLabel: 'bool',
      description: '逆の順（下から・右から）に並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '並べる子',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 48, height: 16),
          DemoTile(2, width: 48, height: 16),
          DemoTile(3, width: 48, height: 16),
        ],
        source: '[Tile(1), Tile(2), Tile(3)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'ListBody',
);

Widget _build(DemoArgs args) {
  final mainAxis = args.valueOf<Axis>('mainAxis') ?? Axis.vertical;
  return SingleChildScrollView(
    scrollDirection: mainAxis,
    child: ListBody(
      mainAxis: mainAxis,
      reverse: args.valueOf<bool>('reverse') ?? false,
      children: args.valueOf<List<Widget>>('children') ?? const [],
    ),
  );
}
