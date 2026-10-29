import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final aspectRatioEntry = WidgetEntry(
  id: 'aspectRatio',
  name: 'AspectRatio',
  genreIds: const ['layout'],
  summary: '幅と高さの比を決めた大きさにする',
  description:
      '幅 ÷ 高さが aspectRatio になる大きさで子を組みます。'
      'まず使える幅いっぱいを試し、高さが収まらなければ高さに合わせて幅を縮めます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AspectRatio-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'aspectRatio',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '幅 ÷ 高さ。2.0 なら横長、0.5 なら縦長',
      required: true,
      control: SliderControl(
        min: 0.5,
        max: 3,
        divisions: 10,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'その比の大きさに組む Widget',
      control: FixedControl(value: DemoTile(1), source: 'Tile(1)'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'AspectRatio',
);

Widget _build(DemoArgs args) => AspectRatio(
  // 必須のプロパティなので、常に値がある
  aspectRatio: args.valueOf<double>('aspectRatio')!,
  child: args.valueOf<Widget>('child'),
);
