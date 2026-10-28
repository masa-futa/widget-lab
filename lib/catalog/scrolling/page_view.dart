import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final pageViewEntry = WidgetEntry(
  id: 'pageView',
  name: 'PageView',
  genreIds: const ['scrolling'],
  summary: '子を 1 ページずつ、めくるように送る',
  description:
      '子を自分と同じ大きさのページにして並べ、指を離すとページの境目に止まります。'
      'オンボーディングや写真の一覧に使います。'
      '1 ページの幅を変えるときは PageController の viewportFraction を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/PageView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'scrollDirection',
      typeLabel: 'Axis',
      description: 'めくる向き。既定は horizontal',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices),
    ),
    PropertySpec(
      name: 'pageSnapping',
      typeLabel: 'bool',
      description: '指を離したら、ページの境目に止めるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'reverse',
      typeLabel: 'bool',
      description: '逆の向き（右から・下から）に並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: 'ページ（5 枚）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1),
          DemoTile(2),
          DemoTile(3),
          DemoTile(4),
          DemoTile(5),
        ],
        source: '[Tile(1), Tile(2), Tile(3), Tile(4), Tile(5)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'PageView',
);

Widget _build(DemoArgs args) => PageView(
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.horizontal,
  pageSnapping: args.valueOf<bool>('pageSnapping') ?? true,
  reverse: args.valueOf<bool>('reverse') ?? false,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
