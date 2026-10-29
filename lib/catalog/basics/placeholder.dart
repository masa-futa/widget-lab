import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final placeholderEntry = WidgetEntry(
  id: 'placeholder',
  name: 'Placeholder',
  genreIds: const ['basics'],
  summary: 'まだ作っていない部分の場所を、×印の箱で示す',
  description:
      '枠と対角線の × を描き、あとで Widget を置く場所を示します。使える広さいっぱいに広がり、'
      '広さに上限がないときだけ fallbackWidth・fallbackHeight（既定は 400）の大きさになります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Placeholder-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '枠と × の線の色。既定は青みの灰色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'strokeWidth',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '線の太さ。既定は 2',
      control: SliderControl(
        min: 1,
        max: 8,
        divisions: 7,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '箱の中に重ねる Widget。何の場所かを書いておける',
      initiallyOn: false,
      control: FixedControl(value: Text('写真'), source: "Text('写真')"),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'fallbackWidth',
      typeLabel: 'double',
      description: '幅に上限がないときの幅（既定は 400）。この見本では幅に上限があるので違いが出ない',
    ),
    ReferenceArg(
      name: 'fallbackHeight',
      typeLabel: 'double',
      description: '高さに上限がないときの高さ（既定は 400）。この見本では高さに上限があるので違いが出ない',
    ),
  ],
  build: _build,
  codeName: 'Placeholder',
);

Widget _build(DemoArgs args) => Placeholder(
  color: args.valueOf<Color>('color') ?? const Color(0xFF455A64),
  strokeWidth: args.valueOf<double>('strokeWidth') ?? 2,
  child: args.valueOf<Widget>('child'),
);
