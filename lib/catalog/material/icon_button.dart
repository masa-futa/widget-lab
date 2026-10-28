import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final iconButtonEntry = WidgetEntry(
  id: 'iconButton',
  name: 'IconButton',
  genreIds: const ['material'],
  summary: 'アイコンだけのボタン',
  description:
      'アイコンだけを出すボタンです。AppBar の actions などに置きます。'
      'isSelected を渡すと、選んでいる／いないで見た目を切り替えるトグルになります。'
      'IconButton.filled などのコンストラクタで地の付いた形も作れます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/IconButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'icon',
      typeLabel: 'Widget',
      description: '出すアイコン',
      required: true,
      control: FixedControl(
        value: Icon(Icons.favorite_border),
        source: 'Icon(Icons.favorite_border)',
      ),
    ),
    PropertySpec(
      name: 'iconSize',
      typeLabel: 'double?',
      description: 'アイコンの大きさ。指定しないと 24',
      initiallyOn: false,
      control: SliderControl(
        min: 16,
        max: 64,
        divisions: 12,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: 'アイコンの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'isSelected',
      typeLabel: 'bool?',
      description: '選んでいるか。true のときは selectedIcon を出す。指定しないとトグルにならない',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'selectedIcon',
      typeLabel: 'Widget?',
      description: '選んでいるとき（isSelected が true）に出すアイコン',
      initiallyOn: false,
      control: FixedControl(
        value: Icon(Icons.favorite),
        source: 'Icon(Icons.favorite)',
      ),
    ),
  ],
  build: _build,
  codeName: 'IconButton',
);

void _noop() {}

Widget _build(DemoArgs args) => IconButton(
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  icon: args.valueOf<Widget>('icon') ?? const SizedBox.shrink(),
  iconSize: args.valueOf<double>('iconSize'),
  color: args.valueOf<Color>('color'),
  isSelected: args.valueOf<bool>('isSelected'),
  selectedIcon: args.valueOf<Widget>('selectedIcon'),
);
