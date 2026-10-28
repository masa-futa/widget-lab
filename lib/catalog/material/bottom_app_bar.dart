import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
  ],
  build: _build,
  codeName: 'BottomAppBar',
);

void _noop() {}

Widget _build(DemoArgs args) => BottomAppBar(
  color: args.valueOf<Color>('color'),
  height: args.valueOf<double>('height'),
  elevation: args.valueOf<double>('elevation'),
  child: args.valueOf<Widget>('child'),
);
