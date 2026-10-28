import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
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
      name: 'child',
      typeLabel: 'Widget?',
      description: '動かす Widget',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
    ),
  ],
  build: _build,
  codeName: 'AnimatedAlign',
);

Widget _build(DemoArgs args) => AnimatedAlign(
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  duration: durationOf(args),
  curve: curveOf(args),
  child: args.valueOf<Widget>('child'),
);
