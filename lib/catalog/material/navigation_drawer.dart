import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
    children: args.valueOf<List<Widget>>('children') ?? const [],
  ),
);
