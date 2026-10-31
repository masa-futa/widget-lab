import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
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
      group: PropertyGroup.size,
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
      group: PropertyGroup.paint,
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
      group: PropertyGroup.behavior,
      typeLabel: 'String?',
      description: '読み上げる名前。見た目は変わらない。飾りのアイコンなら指定しない',
      initiallyOn: false,
      control: TextControl(initialValue: 'お気に入り'),
    ),
    const PropertySpec(
      name: 'shadows',
      group: PropertyGroup.paint,
      typeLabel: 'List<Shadow>?',
      description: 'アイコンの下に落とす影',
      initiallyOn: false,
      control: FixedControl(
        value: [
          Shadow(color: Color(0x80000000), offset: Offset(2, 2), blurRadius: 4),
        ],
        source: '[Shadow(color: Color(0x80000000), offset: Offset(2, 2), blurRadius: 4)]',
      ),
    ),
    const PropertySpec(
      name: 'blendMode',
      group: PropertyGroup.paint,
      typeLabel: 'BlendMode?',
      description: 'アイコンを下の色と混ぜる方法。指定しないと srcOver（上に重ねるだけ）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('difference', BlendMode.difference, 'BlendMode.difference'),
          Choice('xor', BlendMode.xor, 'BlendMode.xor'),
          Choice('softLight', BlendMode.softLight, 'BlendMode.softLight'),
        ],
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'fill',
      typeLabel: 'double?',
      description: '塗りつぶしの度合い（0〜1）。可変フォント（Material Symbols など）で効き、見本の Material Icons では変わらない',
    ),
    ReferenceArg(
      name: 'weight',
      typeLabel: 'double?',
      description:
          '線の太さ。可変フォント（Material Symbols など）で効き、見本の Material Icons では変わらない',
    ),
    ReferenceArg(
      name: 'grade',
      typeLabel: 'double?',
      description: '線の太さの細かい調整。可変フォント（Material Symbols など）で効き、見本の Material Icons では変わらない',
    ),
    ReferenceArg(
      name: 'opticalSize',
      typeLabel: 'double?',
      description: '大きさに合わせた線の太さの補正。可変フォント（Material Symbols など）で効き、見本の Material Icons では変わらない',
    ),
    ReferenceArg(
      name: 'fontWeight',
      typeLabel: 'FontWeight?',
      description: 'アイコンのフォントの太さ。可変フォント（Material Symbols など）で効き、見本の Material Icons では変わらない',
    ),
    ReferenceArg(
      name: 'textDirection',
      typeLabel: 'TextDirection?',
      description: '左右の向き。向きのあるアイコン（矢印など）を右から左の言語で反転させるときに使う',
    ),
    ReferenceArg(
      name: 'applyTextScaling',
      typeLabel: 'bool?',
      description: '端末の文字の大きさの設定に合わせて、アイコンも大きくするか',
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
  shadows: args.valueOf<List<Shadow>>('shadows'),
  blendMode: args.valueOf<BlendMode>('blendMode'),
);
