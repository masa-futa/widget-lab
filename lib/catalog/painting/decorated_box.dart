import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final decoratedBoxEntry = WidgetEntry(
  id: 'decoratedBox',
  name: 'DecoratedBox',
  genreIds: const ['painting'],
  summary: '子の後ろ（または前）に、色・枠線・角丸・グラデーションを描く',
  description:
      'decoration（ふつうは BoxDecoration）を子の大きさで描きます。'
      '大きさや余白は変えないので、余白も欲しいときは Container を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DecoratedBox-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'decoration',
      typeLabel: 'Decoration',
      description: '描く飾り',
      control: ChoiceControl(
        choices: [
          Choice(
            '色と角丸',
            BoxDecoration(
              color: DemoTile.colors[2],
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            'BoxDecoration(color: Color(0xFF68BE8D), '
                'borderRadius: BorderRadius.circular(16))',
          ),
          Choice(
            '枠線',
            BoxDecoration(
              border: Border.all(color: DemoTile.colors[3], width: 4),
            ),
            'BoxDecoration(border: Border.all(color: Color(0xFFD7003A), '
                'width: 4))',
          ),
          Choice(
            'グラデーション',
            BoxDecoration(
              gradient: LinearGradient(
                colors: [DemoTile.colors[0], DemoTile.colors[1]],
              ),
            ),
            'BoxDecoration(gradient: LinearGradient('
                'colors: [Color(0xFF1E50A2), Color(0xFFF8B500)]))',
          ),
          Choice(
            '円',
            BoxDecoration(color: DemoTile.colors[1], shape: BoxShape.circle),
            'BoxDecoration(color: Color(0xFFF8B500), shape: BoxShape.circle)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'position',
      typeLabel: 'DecorationPosition',
      description: '子の後ろに描くか、前に描くか。既定は background（後ろ）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice(
            'background',
            DecorationPosition.background,
            'DecorationPosition.background',
          ),
          Choice(
            'foreground',
            DecorationPosition.foreground,
            'DecorationPosition.foreground',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '飾る Widget',
      control: FixedControl(
        value: Padding(
          padding: EdgeInsets.all(12),
          child: FlutterLogo(size: 32),
        ),
        source: 'Padding(padding: EdgeInsets.all(12), child: FlutterLogo(size: 32))',
      ),
    ),
  ],
  build: _build,
  codeName: 'DecoratedBox',
);

Widget _build(DemoArgs args) => DecoratedBox(
  // API では必須。Padding の padding と同じく、OFF は何も描かない飾りで組む
  decoration: args.valueOf<Decoration>('decoration') ?? const BoxDecoration(),
  position:
      args.valueOf<DecorationPosition>('position') ??
      DecorationPosition.background,
  child: args.valueOf<Widget>('child'),
);
