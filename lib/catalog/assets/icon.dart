import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final iconEntry = WidgetEntry(
  id: 'icon',
  name: 'Icon',
  genreIds: const ['assets', 'basics'],
  summary: 'アイコンのフォントの 1 文字を、アイコンとして描く',
  description:
      'IconData（アイコンのフォントの 1 文字）を描きます。Material のアイコンは Icons.〜 で選びます。'
      '大きさと色を指定しないと、まわりの IconTheme（既定は 24）に合わせます。'
      '押せないので、押すなら IconButton を使います。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Icon-class.html'),
  properties: [
    const PropertySpec(
      name: 'icon',
      typeLabel: 'IconData?',
      description: '描くアイコン',
      required: true,
      arg: PropertyArg.positional,
      control: ChoiceControl(
        choices: [
          Choice('favorite', Icons.favorite, 'Icons.favorite'),
          Choice('home', Icons.home, 'Icons.home'),
          Choice('star', Icons.star, 'Icons.star'),
          Choice('settings', Icons.settings, 'Icons.settings'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'size',
      typeLabel: 'double?',
      description: '大きさ。指定しないと IconTheme の大きさ（既定は 24）',
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 6,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '色。指定しないと IconTheme の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', DemoTile.colors[3]),
          Choice.color('瑠璃', DemoTile.colors[0]),
          Choice.color('山吹', DemoTile.colors[1]),
        ],
      ),
    ),
    const PropertySpec(
      name: 'semanticLabel',
      typeLabel: 'String?',
      description: '読み上げる名前。見た目は変わらない。飾りのアイコンなら指定しない',
      initiallyOn: false,
      control: TextControl(initialValue: 'お気に入り'),
    ),
  ],
  build: _build,
  codeName: 'Icon',
);

Widget _build(DemoArgs args) => Icon(
  args.valueOf<IconData>('icon'),
  size: args.valueOf<double>('size'),
  color: args.valueOf<Color>('color'),
  semanticLabel: args.valueOf<String>('semanticLabel'),
);
