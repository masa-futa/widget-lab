import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final navigationDrawerEntry = WidgetEntry(
  id: 'navigationDrawer',
  name: 'NavigationDrawer',
  genreIds: const ['material'],
  summary: '横から出る引き出しに、行き先を縦に並べる',
  description:
      '画面の横から引き出す面に、行き先を縦に並べます。行き先が多いときや、'
      '画面の幅が広いときに使います。ふつうは Scaffold の drawer に渡します。'
      'ここではカードの中に開いた形で置いて見ます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/NavigationDrawer-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description:
          '引き出しの中身。NavigationDrawerDestination が行き先になり、'
          'ほかの Widget（見出しなど）も混ぜられる',
      required: true,
      control: FixedControl(
        value: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text('メール'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.inbox),
            label: Text('受信箱'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.send),
            label: Text('送信済み'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.delete),
            label: Text('ごみ箱'),
          ),
        ],
        source:
            '[Padding(padding: EdgeInsets.fromLTRB(28, 16, 16, 10), '
            "child: Text('メール')), "
            "NavigationDrawerDestination(icon: Icon(Icons.inbox), label: Text('受信箱')), "
            "NavigationDrawerDestination(icon: Icon(Icons.send), label: Text('送信済み')), "
            "NavigationDrawerDestination(icon: Icon(Icons.delete), label: Text('ごみ箱'))]",
      ),
    ),
    PropertySpec(
      name: 'selectedIndex',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '選んでいる行き先の番号（0 から。見出しなどは数えない）',
      control: SliderControl(
        min: 0,
        max: 2,
        divisions: 2,
        initialValue: 0,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'indicatorColor',
      group: PropertyGroup.paint,
      pairsWith: const ['indicatorShape'],
      typeLabel: 'Color?',
      description: '選んでいる行き先の後ろの地の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '引き出しの地の色。指定しないとテーマの surfaceContainerLow',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('白', const Color(0xFFFFFFFF)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'indicatorShape',
      group: PropertyGroup.paint,
      pairsWith: ['indicatorColor'],
      typeLabel: 'ShapeBorder?',
      description: '選んでいる行き先の後ろの地の形。指定しないと StadiumBorder（両端が丸い）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '角丸 4',
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            'RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))',
          ),
          Choice('四角', RoundedRectangleBorder(), 'RoundedRectangleBorder()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      pairsWith: const ['shadowColor'],
      typeLabel: 'double?',
      description: '引き出しの浮き上がりの高さ。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 16,
        divisions: 4,
        initialValue: 8,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'shadowColor',
      group: PropertyGroup.paint,
      pairsWith: const ['elevation'],
      typeLabel: 'Color?',
      description: '浮き上がりを表す影の色。指定しないと透明で、影は出ない',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'surfaceTintColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '浮き上がりの高さに応じて地に重ねる色。指定しないと透明',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'tilePadding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '行き先の左右の余白。指定しないと左右に 12',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 4,
        initialValue: 24,
        resolve: (v) => EdgeInsets.symmetric(horizontal: v),
        code: (v) => 'EdgeInsets.symmetric(horizontal: $v)',
      ),
    ),
    const PropertySpec(
      name: 'header',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '引き出しのいちばん上に置く Widget。中身と違って流れずに留まる',
      initiallyOn: false,
      control: FixedControl(
        value: ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('山田 花子'),
        ),
        source: "ListTile(leading: Icon(Icons.account_circle), title: Text('山田 花子'))",
      ),
    ),
    const PropertySpec(
      name: 'footer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '引き出しのいちばん下に置く Widget。中身と違って流れずに留まる',
      initiallyOn: false,
      control: FixedControl(
        value: ListTile(leading: Icon(Icons.settings), title: Text('設定')),
        source: "ListTile(leading: Icon(Icons.settings), title: Text('設定'))",
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
      name: 'onDestinationSelected',
      typeLabel: 'ValueChanged<int>?',
      description: '行き先を押したときに、その番号で呼ばれる。ふつうはここで selectedIndex を変える',
    ),
  ],
  build: _build,
  codeName: 'NavigationDrawer',
);

Widget _build(DemoArgs args) => DemoStage(
  size: const Size(320, 320),
  child: NavigationDrawer(
    selectedIndex: args.valueOf<int>('selectedIndex') ?? 0,
    indicatorColor: args.valueOf<Color>('indicatorColor'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    indicatorShape: args.valueOf<ShapeBorder>('indicatorShape'),
    elevation: args.valueOf<double>('elevation'),
    shadowColor: args.valueOf<Color>('shadowColor'),
    surfaceTintColor: args.valueOf<Color>('surfaceTintColor'),
    // Flutter の既定値。OFF のときも省いたコードと同じ見た目にそろえる。
    tilePadding:
        args.valueOf<EdgeInsetsGeometry>('tilePadding') ??
        const EdgeInsets.symmetric(horizontal: 12),
    header: args.valueOf<Widget>('header'),
    footer: args.valueOf<Widget>('footer'),
    children: args.valueOf<List<Widget>>('children') ?? const [],
  ),
);
