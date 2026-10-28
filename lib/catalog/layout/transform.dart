import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final transformEntry = WidgetEntry(
  id: 'transform',
  name: 'Transform',
  genreIds: const ['layout', 'painting'],
  summary: '子を回す・拡大する・ずらす・傾けて描く',
  description:
      '子を組んだ大きさのまま、描くときに行列（Matrix4）で変形します。'
      '場所の取り方は変わらないので、まわりの並びは動きません。'
      'Transform.rotate・Transform.scale・Transform.translate の書き方もあります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Transform-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'transform',
      typeLabel: 'Matrix4',
      description: '変形の行列',
      control: ChoiceControl(
        choices: [
          Choice(
            '回す 15°',
            Matrix4.rotationZ(math.pi / 12),
            'Matrix4.rotationZ(pi / 12)',
          ),
          Choice(
            '1.5 倍',
            Matrix4.diagonal3Values(1.5, 1.5, 1),
            'Matrix4.diagonal3Values(1.5, 1.5, 1)',
          ),
          Choice(
            '右へ 24',
            Matrix4.translationValues(24, 0, 0),
            'Matrix4.translationValues(24, 0, 0)',
          ),
          Choice('傾ける', Matrix4.skewX(0.4), 'Matrix4.skewX(0.4)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry?',
      description: '回す・拡大するときの中心。指定しないと左上を中心にする',
      control: ChoiceControl(
        choices: alignmentChoices,
        initialIndex: alignmentCenter,
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '変形して描く Widget',
      control: FixedControl(
        value: FlutterLogo(size: 40),
        source: 'FlutterLogo(size: 40)',
      ),
    ),
  ],
  build: _build,
  codeName: 'Transform',
);

Widget _build(DemoArgs args) => Transform(
  // API では必須。Padding の padding と同じく、OFF は効かない値（単位行列）で組む
  transform: args.valueOf<Matrix4>('transform') ?? Matrix4.identity(),
  alignment: args.valueOf<AlignmentGeometry>('alignment'),
  child: args.valueOf<Widget>('child'),
);
