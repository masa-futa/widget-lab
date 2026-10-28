import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedPositionedEntry = WidgetEntry(
  id: 'animatedPositioned',
  name: 'AnimatedPositioned',
  genreIds: const ['animation'],
  summary: 'Stack の中の子の位置が変わると、新しい位置へ動かす',
  description:
      'Positioned と同じく、Stack の中で子の位置（左・上からの距離など）を決めます。'
      '位置が変わると、duration の時間をかけて新しい位置へ動かします。Stack の直下に置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'left',
      typeLabel: 'double?',
      description: 'Stack の左端からの距離',
      control: SliderControl(
        min: 0,
        max: 160,
        divisions: 8,
        initialValue: 80,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'top',
      typeLabel: 'double?',
      description: 'Stack の上端からの距離',
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '動かす Widget',
      required: true,
      control: FixedControl(
        value: FlutterLogo(size: 64),
        source: 'FlutterLogo(size: 64)',
      ),
    ),
  ],
  build: _build,
  codeName: 'AnimatedPositioned',
);

/// AnimatedPositioned は Stack の直下にしか置けないので、デモの Stack で包む（コードには出さない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  height: 160,
  child: Stack(
    children: [
      AnimatedPositioned(
        left: args.valueOf<double>('left'),
        top: args.valueOf<double>('top'),
        duration: durationOf(args),
        curve: curveOf(args),
        child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
      ),
    ],
  ),
);
