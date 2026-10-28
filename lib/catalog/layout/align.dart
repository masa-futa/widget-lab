import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final alignEntry = WidgetEntry(
  id: 'align',
  name: 'Align',
  genreIds: const ['layout'],
  summary: '子を自分の中の指定した位置に置く',
  description:
      '使える広さいっぱいに広がり、その中の alignment の位置に子を置きます。'
      'widthFactor・heightFactor を指定すると広がらず、子の大きさの倍数になります。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Align-class.html'),
  properties: const [
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '子を置く位置。既定は center',
      control: ChoiceControl(choices: alignmentChoices, initialIndex: 8),
    ),
    PropertySpec(
      name: 'widthFactor',
      typeLabel: 'double?',
      description: '幅を子の幅の何倍にするか。指定しないと使える幅いっぱいに広がる',
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
      name: 'heightFactor',
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
      typeLabel: 'Widget?',
      description: '置く Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  build: _build,
  codeName: 'Align',
);

Widget _build(DemoArgs args) => Align(
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  widthFactor: args.valueOf<double>('widthFactor'),
  heightFactor: args.valueOf<double>('heightFactor'),
  child: args.valueOf<Widget>('child'),
);
