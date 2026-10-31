import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedPhysicalModelEntry = WidgetEntry(
  id: 'animatedPhysicalModel',
  name: 'AnimatedPhysicalModel',
  genreIds: const ['animation'],
  summary: '浮き上がりの高さ・角丸・色が変わると、影ごと新しい値へ動かす',
  description:
      'PhysicalModel と同じく、子を色の付いた板に載せて影を落とします。'
      'elevation・borderRadius・color が変わると、duration の時間をかけて新しい値へ動かします。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedPhysicalModel-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '板の浮き上がりの高さ。高いほど影が大きく薄くなる',
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 12,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      group: PropertyGroup.paint,
      typeLabel: 'BorderRadius?',
      description: '板の角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 40,
        divisions: 8,
        initialValue: 16,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '板の色',
      required: true,
      control: ColorControl(
        palette: [
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '影の色',
      required: true,
      control: FixedControl(
        value: Color(0xFF000000),
        source: 'Color(0xFF000000)',
      ),
    ),
    PropertySpec(
      name: 'shape',
      typeLabel: 'BoxShape',
      description: '板の形。circle にすると丸い板になり、borderRadius は効かない',
      initiallyOn: false,
      group: PropertyGroup.paint,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final shape in BoxShape.values)
            Choice(shape.name, shape, 'BoxShape.${shape.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '板の形で子を切り抜くか。指定しないと切り抜かない（Clip.none）',
      initiallyOn: false,
      group: PropertyGroup.transform,
      control: ChoiceControl(initialIndex: 1, choices: clipChoices()),
    ),
    const PropertySpec(
      name: 'animateColor',
      typeLabel: 'bool',
      description: 'color を変えたときに色を移り変わらせるか。false ならすぐ新しい色になる',
      initiallyOn: false,
      group: PropertyGroup.behavior,
      control: SwitchControl(initialValue: false),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '板に載せる Widget',
      required: true,
      control: FixedControl(
        value: SizedBox(
          width: 120,
          height: 80,
          child: Center(child: FlutterLogo()),
        ),
        source: 'SizedBox(width: 120, height: 80, child: Center(child: FlutterLogo()))',
      ),
    ),
  ],
  references: const [
    keyReference,
    ReferenceArg(
      name: 'animateShadowColor',
      typeLabel: 'bool',
      description: 'shadowColor を変えたときに影の色を移り変わらせるか。見本では影の色を変えないので違いが見えない',
    ),
    onEndReference,
  ],
  build: _build,
  codeName: 'AnimatedPhysicalModel',
);

Widget _build(DemoArgs args) => AnimatedPhysicalModel(
  elevation: args.valueOf<double>('elevation') ?? 0,
  shape: args.valueOf<BoxShape>('shape') ?? BoxShape.rectangle,
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
  animateColor: args.valueOf<bool>('animateColor') ?? true,
  borderRadius: args.valueOf<BorderRadius>('borderRadius'),
  color: args.valueOf<Color>('color') ?? const Color(0xFFFFFFFF),
  shadowColor: args.valueOf<Color>('shadowColor') ?? const Color(0xFF000000),
  duration: durationOf(args),
  curve: curveOf(args),
  child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
);
