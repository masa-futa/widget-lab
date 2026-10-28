import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Color',
      description: '影の色',
      required: true,
      control: FixedControl(
        value: Color(0xFF000000),
        source: 'Color(0xFF000000)',
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
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
  build: _build,
  codeName: 'AnimatedPhysicalModel',
);

Widget _build(DemoArgs args) => AnimatedPhysicalModel(
  elevation: args.valueOf<double>('elevation') ?? 0,
  borderRadius: args.valueOf<BorderRadius>('borderRadius'),
  color: args.valueOf<Color>('color') ?? const Color(0xFFFFFFFF),
  shadowColor: args.valueOf<Color>('shadowColor') ?? const Color(0xFF000000),
  duration: durationOf(args),
  curve: curveOf(args),
  child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
);
