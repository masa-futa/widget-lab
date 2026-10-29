import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final badgeEntry = WidgetEntry(
  id: 'badge',
  name: 'Badge',
  genreIds: const ['material'],
  summary: 'アイコンの右上に、件数や印を重ねる',
  description:
      '子（ふつうはアイコン）の右上に、未読の件数などを出す小さな印を重ねます。'
      'label を渡さないと、文字のない小さな点になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Badge-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'label',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '印の中の文字。指定しないと小さな点になる',
      control: FixedControl(value: Text('3'), source: "Text('3')"),
    ),
    const PropertySpec(
      name: 'isLabelVisible',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '印を出すか。false にすると子だけになる。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '印の地の色。指定しないとテーマの error',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      requires: 'label',
      pairsWith: const ['offset'],
      typeLabel: 'AlignmentGeometry?',
      description: '子の上での印の位置。label があるときだけ効く。指定しないと右上',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('topEnd', AlignmentDirectional.topEnd),
            ('topStart', AlignmentDirectional.topStart),
            ('bottomEnd', AlignmentDirectional.bottomEnd),
            ('bottomStart', AlignmentDirectional.bottomStart),
          ])
            Choice(name, value, 'AlignmentDirectional.$name'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textColor',
      group: PropertyGroup.paint,
      requires: 'label',
      typeLabel: 'Color?',
      description: '印の中の文字の色。textStyle の色より優先する。指定しないとテーマの onError',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'smallSize',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: 'label がないときの点の直径。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 4,
        max: 16,
        divisions: 6,
        initialValue: 12,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'largeSize',
      group: PropertyGroup.size,
      requires: 'label',
      pairsWith: const ['padding', 'alignment'],
      typeLabel: 'double?',
      description: 'label があるときの印の高さ。指定しないと 16',
      initiallyOn: false,
      control: SliderControl(
        min: 12,
        max: 28,
        divisions: 4,
        initialValue: 24,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'textStyle',
      group: PropertyGroup.text,
      requires: 'label',
      pairsWith: ['largeSize', 'padding', 'alignment'],
      typeLabel: 'TextStyle?',
      description: '印の中の文字の書式。色は textColor で上書きされる。指定しないとテーマの labelSmall',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '太字',
            TextStyle(fontWeight: FontWeight.bold),
            'TextStyle(fontWeight: FontWeight.bold)',
          ),
          Choice('大きめ 14', TextStyle(fontSize: 14), 'TextStyle(fontSize: 14)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      requires: 'label',
      pairsWith: const ['largeSize'],
      typeLabel: 'EdgeInsetsGeometry?',
      description: '印の中の、文字の左右の余白。指定しないと左右 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    const PropertySpec(
      name: 'offset',
      group: PropertyGroup.layout,
      requires: 'label',
      pairsWith: ['alignment'],
      typeLabel: 'Offset?',
      description: 'alignment で決めた位置からのずらし。指定しないと Offset(4, -4)',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('内側へ', Offset(-4, 4), 'Offset(-4, 4)'),
          Choice('外側へ', Offset(8, -8), 'Offset(8, -8)'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '印を重ねる Widget',
      control: FixedControl(
        value: Icon(Icons.notifications, size: 32),
        source: 'Icon(Icons.notifications, size: 32)',
      ),
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
  codeName: 'Badge',
);

Widget _build(DemoArgs args) => Badge(
  label: args.valueOf<Widget>('label'),
  isLabelVisible: args.valueOf<bool>('isLabelVisible') ?? true,
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  textColor: args.valueOf<Color>('textColor'),
  smallSize: args.valueOf<double>('smallSize'),
  largeSize: args.valueOf<double>('largeSize'),
  textStyle: args.valueOf<TextStyle>('textStyle'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  alignment: args.valueOf<AlignmentGeometry>('alignment'),
  offset: args.valueOf<Offset>('offset'),
  child: args.valueOf<Widget>('child'),
);
