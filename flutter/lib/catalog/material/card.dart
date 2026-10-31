import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cardEntry = WidgetEntry(
  id: 'card',
  name: 'Card',
  genreIds: const ['material'],
  summary: '関係する内容を 1 つにまとめる、角の丸い面',
  description:
      '1 つの話題の内容と操作をまとめる、角の丸い面です。少し浮き上がって影が付きます。'
      'Card.filled・Card.outlined のコンストラクタで、影のない形も作れます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/material/Card-class.html'),
  properties: [
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '面の地の色。指定しないとテーマの surfaceContainerLow',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('生成', const Color(0xFFFBFAF5)),
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      pairsWith: const ['shadowColor', 'surfaceTintColor'],
      typeLabel: 'double?',
      description: '面の浮き上がりの高さ。影の濃さが変わる。指定しないと 1',
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '面の形。ここでは角の丸みを変える。指定しないと 12',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 24,
        resolve: (v) =>
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(v)),
        code: (v) =>
            'RoundedRectangleBorder(borderRadius: BorderRadius.circular($v))',
      ),
    ),
    PropertySpec(
      name: 'margin',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '面の外側の余白。指定しないと 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '面の中に置く Widget。ここでは左端に色の帯を置き、clipBehavior で角が切り抜かれるのを見せる',
      control: FixedControl(
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 52,
              child: ColoredBox(color: Color(0xFF1E50A2)),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('今日の予定は 3 件です'),
              ),
            ),
          ],
        ),
        source:
            'Row(mainAxisSize: MainAxisSize.min, children: ['
            'SizedBox(width: 12, height: 52, child: ColoredBox(color: Color(0xFF1E50A2))), '
            "Flexible(child: Padding(padding: EdgeInsets.all(16), child: Text('今日の予定は 3 件です')))])",
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: '面の下に落とす影の色。影の大きさは elevation で決まる。指定しないとテーマの shadowColor（黒）',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'surfaceTintColor',
      group: PropertyGroup.paint,
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: 'elevation に応じた濃さで地に重ねる色。おすすめされない引数。指定しないと重ねない',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: '面の形で中身を切り抜くか。指定しないと Clip.none（切り抜かない）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final clip in const [
            Clip.hardEdge,
            Clip.antiAlias,
            Clip.antiAliasWithSaveLayer,
          ])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
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
      name: 'borderOnForeground',
      typeLabel: 'bool',
      description: 'shape のふちの線を child より手前に描くか。線のある shape で child が線に重なるときだけ違いが出る。指定しないと true',
    ),
    ReferenceArg(
      name: 'semanticContainer',
      typeLabel: 'bool',
      description:
          '読み上げで、中身をまとめて 1 つとして扱うか。違う種類の中身を並べるなら false にする。指定しないと true',
    ),
  ],
  build: _build,
  codeName: 'Card',
);

Widget _build(DemoArgs args) => Card(
  color: args.valueOf<Color>('color'),
  elevation: args.valueOf<double>('elevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  margin: args.valueOf<EdgeInsetsGeometry>('margin'),
  shadowColor: args.valueOf<Color>('shadowColor'),
  surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
  clipBehavior: args.valueOf<Clip>('clipBehavior'),
  child: args.valueOf<Widget>('child'),
);
