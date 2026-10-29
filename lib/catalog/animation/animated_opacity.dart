import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedOpacityEntry = WidgetEntry(
  id: 'animatedOpacity',
  name: 'AnimatedOpacity',
  genreIds: const ['animation'],
  summary: '子の不透明度が変わると、新しい濃さへ動かす',
  description:
      'Opacity と同じく子を半透明にします。opacity が変わると、'
      'duration の時間をかけて新しい濃さへ移り変わらせます。0 にしても場所は取ったままです。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'opacity',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '不透明度。0 で見えず、1 でそのまま',
      required: true,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.3,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '濃さを変える Widget',
      control: FixedControl(
        value: FlutterLogo(size: 80),
        source: 'FlutterLogo(size: 80)',
      ),
    ),
  ],
  references: const [
    keyReference,
    onEndReference,
    ReferenceArg(
      name: 'alwaysIncludeSemantics',
      typeLabel: 'bool',
      description: '透明（0）のときも読み上げの対象に残すか。見た目は変わらない',
    ),
  ],
  build: _build,
  codeName: 'AnimatedOpacity',
);

Widget _build(DemoArgs args) => AnimatedOpacity(
  opacity: args.valueOf<double>('opacity') ?? 1,
  duration: durationOf(args),
  curve: curveOf(args),
  child: args.valueOf<Widget>('child'),
);
