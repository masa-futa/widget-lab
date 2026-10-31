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

final carouselViewEntry = WidgetEntry(
  id: 'carouselView',
  name: 'CarouselView',
  genreIds: const ['layout', 'scrolling'],
  summary: '角の丸い項目を横に並べ、送って見るカルーセル',
  description:
      'Material 3 のカルーセル。項目を itemExtent の幅で並べ、横にスクロールします。'
      '端に出ていく項目は shrinkExtent まで縮みます。項目は押せます（onTap）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/CarouselView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'itemExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '1 つの項目の幅',
      required: true,
      control: SliderControl(
        min: 80,
        max: 240,
        divisions: 8,
        initialValue: 160,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'shrinkExtent',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '端に出ていく項目が縮む下限の幅。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'itemSnapping',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '指を離したら、項目の端にぴったり止めるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsets?',
      description: '項目ごとのまわりの余白。既定は四辺 4',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 12,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '項目の地の色。子が覆っていない所に見える。既定は ColorScheme.surface',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice('紅', Color(0xFFD7003A), 'Color(0xFFD7003A)'),
          Choice('墨', Color(0xFF18181B), 'Color(0xFF18181B)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '項目の浮き上がりの高さ。大きいほど影が濃くなる。既定は 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 6,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: '項目の形。既定は角の丸み 28 の RoundedRectangleBorder',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 8,
        resolve: _roundedShape,
        code: _roundedShapeCode,
      ),
    ),
    PropertySpec(
      name: 'itemClipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip?',
      description: '項目の形で子を切り抜くか。none にすると子の角が丸くならない。既定は antiAlias',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('none', Clip.none, 'Clip.none'),
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
        ],
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: '押した・触れたときに項目に重ねる色',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '紅（半透明）',
            WidgetStatePropertyAll<Color?>(Color(0x66D7003A)),
            'WidgetStatePropertyAll(Color(0x66D7003A))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: 'スクロールの向き。既定は horizontal',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices),
    ),
    PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '逆の端（右・下）から並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'enableSplash',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '項目を InkWell で覆い、押したときに波紋を出すか。false にすると子が自分で押されたことを受け取れる。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'infinite',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '最後の項目の次に最初の項目をつなぎ、どちらへもずっと送れるようにするか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '並べる項目',
      required: true,
      control: FixedControl(
        value: <Widget>[
          DemoTile(1),
          DemoTile(2),
          DemoTile(3),
          DemoTile(4),
          DemoTile(5),
          DemoTile(6),
        ],
        source: 'List.generate(6, (i) => Tile(i + 1))',
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
      name: 'controller',
      typeLabel: 'CarouselController?',
      description: 'スクロールの位置を読んだり、決めた項目まで動かしたりする',
    ),
    ReferenceArg(
      name: 'onTap',
      typeLabel: 'ValueChanged<int>?',
      description: '項目が押されたときに、その番号を受け取る',
    ),
    ReferenceArg(
      name: 'onIndexChanged',
      typeLabel: 'ValueChanged<int>?',
      description: '先頭に見えている項目が替わったときに、その番号を受け取る',
    ),
  ],
  build: _build,
  codeName: 'CarouselView',
);

// itemExtent・children は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => CarouselView(
  itemExtent: args.valueOf<double>('itemExtent')!,
  shrinkExtent: args.valueOf<double>('shrinkExtent') ?? 0,
  itemSnapping: args.valueOf<bool>('itemSnapping') ?? false,
  padding: args.valueOf<EdgeInsets>('padding'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  itemClipBehavior: args.valueOf<Clip>('itemClipBehavior'),
  overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.horizontal,
  reverse: args.valueOf<bool>('reverse') ?? false,
  enableSplash: args.valueOf<bool>('enableSplash') ?? true,
  infinite: args.valueOf<bool>('infinite') ?? false,
  children: args.valueOf<List<Widget>>('children')!,
);

ShapeBorder _roundedShape(double radius) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

String _roundedShapeCode(double radius) =>
    'RoundedRectangleBorder(borderRadius: BorderRadius.circular($radius))';
