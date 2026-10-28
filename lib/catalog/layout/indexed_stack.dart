import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final indexedStackEntry = WidgetEntry(
  id: 'indexedStack',
  name: 'IndexedStack',
  genreIds: const ['layout'],
  summary: '重ねた子のうち、1 つだけを見せる',
  description:
      '子を Stack のように重ね、index 番目の子だけを描きます。'
      'ほかの子も木に残って状態を保つので、タブの切り替えによく使います。'
      '大きさは一番大きい子に合わせます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/IndexedStack-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'index',
      typeLabel: 'int?',
      description: '見せる子の番号（0 から）。既定は 0',
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 1,
        resolve: asInt,
        code: intCode,
      ),
    ),
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '子を置く位置。既定は topStart（左上）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: alignmentChoices,
        initialIndex: alignmentCenter,
      ),
    ),
    PropertySpec(
      name: 'sizing',
      typeLabel: 'StackFit',
      description: '子に渡す制約。expand は自分の大きさいっぱいにする',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('loose', StackFit.loose, 'StackFit.loose'),
          Choice('expand', StackFit.expand, 'StackFit.expand'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '重ねる子（大きさが違う 3 つ）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 48, height: 48),
          DemoTile(2, width: 96, height: 32),
          DemoTile(3, width: 32, height: 56),
        ],
        source: '[Tile(1), Tile(2), Tile(3)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'IndexedStack',
);

Widget _build(DemoArgs args) => IndexedStack(
  index: args.valueOf<int>('index') ?? 0,
  alignment:
      args.valueOf<AlignmentGeometry>('alignment') ??
      AlignmentDirectional.topStart,
  sizing: args.valueOf<StackFit>('sizing') ?? StackFit.loose,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
