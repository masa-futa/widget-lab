import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final centerEntry = WidgetEntry(
  id: 'center',
  name: 'Center',
  genreIds: const ['layout'],
  summary: '子を自分の中央に置く',
  description:
      '使える広さいっぱいに広がり、その中央に子を置きます（alignment が center の Align）。'
      'widthFactor・heightFactor を指定すると広がらず、子の大きさの倍数になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Center-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'widthFactor',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '幅を子の幅の何倍にするか。指定しないと使える幅いっぱいに広がる',
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 8,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'heightFactor',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '高さを子の高さの何倍にするか。指定しないと使える高さいっぱいに広がる',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 8,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '中央に置く Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
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
  codeName: 'Center',
);

Widget _build(DemoArgs args) => Center(
  widthFactor: args.valueOf<double>('widthFactor'),
  heightFactor: args.valueOf<double>('heightFactor'),
  child: args.valueOf<Widget>('child'),
);
