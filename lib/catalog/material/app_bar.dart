import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final appBarEntry = WidgetEntry(
  id: 'appBar',
  name: 'AppBar',
  genreIds: const ['material', 'basics'],
  summary: '画面の上の帯。題・戻るボタン・操作のアイコンを並べる',
  description:
      '画面の上に置く帯です。左に leading（戻るボタンなど）、中に題、右に actions を並べます。'
      'ふつうは Scaffold の appBar に渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/AppBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'leading',
      typeLabel: 'Widget?',
      description: '題の左に置く Widget。指定しないと、戻れる画面では戻るボタンが自動で付く',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.menu),
        source: 'Icon(Icons.menu)',
      ),
    ),
    const PropertySpec(
      name: 'title',
      typeLabel: 'Widget?',
      description: '帯の題',
      control: FixedControl(value: Text('受信箱'), source: "Text('受信箱')"),
    ),
    const PropertySpec(
      name: 'actions',
      typeLabel: 'List<Widget>?',
      description: '題の右に並べる Widget。ふつうは IconButton',
      control: FixedControl(
        value: <Widget>[
          IconButton(onPressed: _noop, icon: Icon(Icons.search)),
          IconButton(onPressed: _noop, icon: Icon(Icons.more_vert)),
        ],
        source:
            '[IconButton(onPressed: () {}, icon: Icon(Icons.search)), '
            'IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))]',
      ),
    ),
    const PropertySpec(
      name: 'centerTitle',
      typeLabel: 'bool?',
      description: '題を中央に置くか。指定しないと Android は左寄せ、iOS は中央',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '帯の地の色。指定しないとテーマの surface',
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
      name: 'elevation',
      typeLabel: 'double?',
      description: '帯の浮き上がりの高さ。影の濃さが変わる',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
  ],
  build: _build,
  codeName: 'AppBar',
);

void _noop() {}

Widget _build(DemoArgs args) => AppBar(
  // 詳細画面の中なので、戻るボタンが勝手に付かないようにする
  automaticallyImplyLeading: false,
  // プレビューのカードの中なので、上のステータスバーの余白を取らない
  primary: false,
  leading: args.valueOf<Widget>('leading'),
  title: args.valueOf<Widget>('title'),
  actions: args.valueOf<List<Widget>>('actions'),
  centerTitle: args.valueOf<bool>('centerTitle'),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
);
