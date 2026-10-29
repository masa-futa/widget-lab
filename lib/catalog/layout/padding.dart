import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final paddingEntry = WidgetEntry(
  id: 'padding',
  name: 'Padding',
  genreIds: const ['layout', 'styling'],
  summary: '子のまわりに余白を入れる',
  description: '子の上下左右に、指定した幅の余白を入れます。余白の中は何も描きません。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Padding-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '子のまわりに入れる余白。ここでは四辺に同じ幅を入れる',
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '余白の内側に置く Widget',
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
  codeName: 'Padding',
);

Widget _build(DemoArgs args) => Padding(
  padding: args.valueOf<EdgeInsetsGeometry>('padding') ?? EdgeInsets.zero,
  child: args.valueOf<Widget>('child'),
);
