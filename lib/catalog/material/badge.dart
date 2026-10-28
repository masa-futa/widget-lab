import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
      typeLabel: 'Widget?',
      description: '印の中の文字。指定しないと小さな点になる',
      control: FixedControl(value: Text('3'), source: "Text('3')"),
    ),
    const PropertySpec(
      name: 'isLabelVisible',
      typeLabel: 'bool',
      description: '印を出すか。false にすると子だけになる。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'backgroundColor',
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
      typeLabel: 'AlignmentGeometry?',
      description: '子の上での印の位置。指定しないと右上',
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
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '印を重ねる Widget',
      control: FixedControl(
        value: Icon(Icons.notifications, size: 32),
        source: 'Icon(Icons.notifications, size: 32)',
      ),
    ),
  ],
  build: _build,
  codeName: 'Badge',
);

Widget _build(DemoArgs args) => Badge(
  label: args.valueOf<Widget>('label'),
  isLabelVisible: args.valueOf<bool>('isLabelVisible') ?? true,
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  alignment: args.valueOf<AlignmentGeometry>('alignment'),
  child: args.valueOf<Widget>('child'),
);
