import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedScaleEntry = WidgetEntry(
  id: 'animatedScale',
  name: 'AnimatedScale',
  genreIds: const ['animation'],
  summary: '子の倍率が変わると、新しい大きさへ動かす',
  description:
      '子を scale の倍率で拡大・縮小して描きます。scale が変わると、'
      'duration の時間をかけて新しい倍率へ動かします。並びの中で取る場所は変わりません。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedScale-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'scale',
      group: PropertyGroup.transform,
      typeLabel: 'double',
      description: '倍率。1 でそのまま、2 で 2 倍',
      required: true,
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 8,
        initialValue: 1.5,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    durationSpec,
    curveSpec,
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.transform,
      typeLabel: 'Alignment',
      description: '拡大・縮小の中心。指定しないと真ん中（Alignment.center）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('topLeft', Alignment.topLeft),
            ('center', Alignment.center),
            ('bottomRight', Alignment.bottomRight),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
    filterQualitySpec(),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '大きさを変える Widget',
      control: FixedControl(
        value: FlutterLogo(size: 48),
        source: 'FlutterLogo(size: 48)',
      ),
    ),
  ],
  references: const [keyReference, onEndReference],
  build: _build,
  codeName: 'AnimatedScale',
);

Widget _build(DemoArgs args) => AnimatedScale(
  scale: args.valueOf<double>('scale') ?? 1,
  duration: durationOf(args),
  curve: curveOf(args),
  alignment: args.valueOf<Alignment>('alignment') ?? Alignment.center,
  filterQuality: args.valueOf<FilterQuality>('filterQuality'),
  child: args.valueOf<Widget>('child'),
);
