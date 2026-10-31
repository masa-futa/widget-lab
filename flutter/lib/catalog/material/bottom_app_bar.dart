import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Bottom app bar」のカード。クラスの BottomAppBar で見せる。
final bottomAppBarEntry = WidgetEntry(
  id: 'bottomAppBar',
  name: 'Bottom app bar',
  genreIds: const ['material'],
  summary: '画面の下の帯。よく使う操作のアイコンを並べる',
  description:
      '画面の下に置き、その画面でよく使う操作のアイコンを並べる帯です。'
      'ふつうは Scaffold の bottomNavigationBar に渡し、FloatingActionButton と組み合わせます。'
      '行き先を切り替えるなら NavigationBar を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/BottomAppBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '帯の中に置く Widget。ふつうは IconButton を並べた Row',
      control: FixedControl(
        value: Row(
          children: [
            IconButton(onPressed: _noop, icon: Icon(Icons.menu)),
            IconButton(onPressed: _noop, icon: Icon(Icons.search)),
            IconButton(onPressed: _noop, icon: Icon(Icons.favorite)),
          ],
        ),
        source:
            'Row(children: [IconButton(onPressed: () {}, icon: Icon(Icons.menu)), '
            'IconButton(onPressed: () {}, icon: Icon(Icons.search)), '
            'IconButton(onPressed: () {}, icon: Icon(Icons.favorite))])',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surfaceContainer',
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
      name: 'height',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '帯の高さ。指定しないと 80',
      initiallyOn: false,
      control: SliderControl(
        min: 48,
        max: 96,
        divisions: 6,
        initialValue: 64,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      pairsWith: const ['shadowColor'],
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。指定しないと 3',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '帯の内側、child のまわりの余白。指定しないと上下 12・左右 16',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 4,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'NotchedShape?',
      description: '帯の形。FloatingActionButton の切り欠きもこの形で作る。指定しないと四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸',
            AutomaticNotchedShape(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            'AutomaticNotchedShape(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))',
          ),
          const Choice(
            '両端が丸い',
            AutomaticNotchedShape(StadiumBorder()),
            'AutomaticNotchedShape(StadiumBorder())',
          ),
          const Choice(
            '丸い切り欠き',
            CircularNotchedRectangle(),
            'CircularNotchedRectangle()',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '帯の形で中身を切り抜くか。指定しないと Clip.none（切り抜かない）',
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
    PropertySpec(
      name: 'surfaceTintColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'elevation に応じて地に重ねる色。おすすめされない引数。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: '帯の下に落とす影の色。影の大きさは elevation で決まる。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
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
      name: 'notchMargin',
      typeLabel: 'double',
      description:
          'FloatingActionButton と、shape で作る切り欠きとの間の空き。'
          'Scaffold に FloatingActionButton を置いたときだけ効くので、見本では違いが出ない。指定しないと 4',
    ),
  ],
  build: _build,
  codeName: 'BottomAppBar',
);

void _noop() {}

Widget _build(DemoArgs args) => BottomAppBar(
  color: args.valueOf<Color>('color'),
  height: args.valueOf<double>('height'),
  elevation: args.valueOf<double>('elevation'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  shape: args.valueOf<NotchedShape>('shape'),
  // Flutter の既定値（Clip.none）。OFF のときも省いたコードと同じ挙動にそろえる。
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
  surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
  shadowColor: args.valueOf<Color>('shadowColor'),
  child: args.valueOf<Widget>('child'),
);
