import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedAlignEntry = WidgetEntry(
  id: 'animatedAlign',
  name: 'AnimatedAlign',
  genreIds: const ['animation'],
  summary: '子の位置（alignment）が変わると、新しい位置へ動かす Align',
  description:
      'Align と同じく、子を広さの中の決めた位置に置きます。alignment が変わると、'
      'duration の時間をかけて新しい位置へ子を動かします。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedAlign-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: '子の位置。変えると、新しい位置へ動く',
      required: true,
      control: ChoiceControl(
        initialIndex: 4,
        choices: [
          for (final (name, value) in const [
            ('topLeft', Alignment.topLeft),
            ('topCenter', Alignment.topCenter),
            ('topRight', Alignment.topRight),
            ('centerLeft', Alignment.centerLeft),
            ('center', Alignment.center),
            ('centerRight', Alignment.centerRight),
            ('bottomLeft', Alignment.bottomLeft),
            ('bottomCenter', Alignment.bottomCenter),
            ('bottomRight', Alignment.bottomRight),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'widthFactor',
      typeLabel: 'double?',
      description: '幅を子の幅の何倍にするか。指定しないと親の幅いっぱい。変えると新しい幅へ動く',
      initiallyOn: false,
      group: PropertyGroup.size,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 4,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'heightFactor',
      typeLabel: 'double?',
      description: '高さを子の高さの何倍にするか。指定しないと親の高さいっぱい。変えると新しい高さへ動く',
      initiallyOn: false,
      group: PropertyGroup.size,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 4,
        initialValue: 2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '動かす Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  references: const [keyReference, onEndReference],
  build: _build,
  codeName: 'AnimatedAlign',
);

Widget _build(DemoArgs args) => AnimatedAlign(
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  duration: durationOf(args),
  curve: curveOf(args),
  widthFactor: args.valueOf<double>('widthFactor'),
  heightFactor: args.valueOf<double>('heightFactor'),
  child: args.valueOf<Widget>('child'),
);
