import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final stackEntry = WidgetEntry(
  id: 'stack',
  name: 'Stack',
  genreIds: const ['layout'],
  summary: '子を重ねて置く',
  description:
      '子を前のものから順に重ねて描きます（後の子が上）。'
      'Positioned で包んだ子は、端からの距離で位置を決められます。'
      '大きさは位置を決めていない子のうち一番大きいものに合わせます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Stack-class.html'),
  properties: const [
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '位置を決めていない子を置く位置。既定は topStart（左上）',
      control: ChoiceControl(
        choices: alignmentChoices,
        initialIndex: alignmentCenter,
      ),
    ),
    PropertySpec(
      name: 'fit',
      typeLabel: 'StackFit',
      description: '位置を決めていない子に渡す制約。expand は使える広さいっぱいにする',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('loose', StackFit.loose, 'StackFit.loose'),
          Choice('expand', StackFit.expand, 'StackFit.expand'),
          Choice('passthrough', StackFit.passthrough, 'StackFit.passthrough'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '重ねる子（大きいものから順）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 96, height: 56),
          DemoTile(2, width: 64, height: 40),
          DemoTile(3, width: 32, height: 24),
        ],
        source: '[Tile(1), Tile(2), Tile(3)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'Stack',
);

Widget _build(DemoArgs args) => Stack(
  alignment:
      args.valueOf<AlignmentGeometry>('alignment') ??
      AlignmentDirectional.topStart,
  fit: args.valueOf<StackFit>('fit') ?? StackFit.loose,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
