import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final floatingActionButtonEntry = WidgetEntry(
  id: 'floatingActionButton',
  name: 'FloatingActionButton',
  genreIds: const ['material'],
  summary: '画面の主な操作を 1 つだけ置く、浮いた丸いボタン',
  description:
      '画面でいちばん大事な操作（新規作成など）を 1 つだけ置く、浮き上がったボタンです。'
      'ふつうは Scaffold の floatingActionButton に渡し、右下に置きます。'
      'onPressed が null でも見た目は変わらないので、押せないときはボタンごと出さないのが基本です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/FloatingActionButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'ボタンの中に置く Widget。ふつうは Icon',
      control: FixedControl(value: Icon(Icons.add), source: 'Icon(Icons.add)'),
    ),
    const PropertySpec(
      name: 'mini',
      typeLabel: 'bool',
      description: '小さい（40×40）ボタンにするか。指定しないと 56×56',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: 'ボタンの地の色。指定しないとテーマの primaryContainer',
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
      name: 'elevation',
      typeLabel: 'double?',
      description: 'ボタンの浮き上がりの高さ。影の濃さが変わる。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'shape',
      typeLabel: 'ShapeBorder?',
      description: 'ボタンの形。指定しないと角の丸い四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('CircleBorder', CircleBorder(), 'CircleBorder()'),
          Choice('StadiumBorder', StadiumBorder(), 'StadiumBorder()'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'FloatingActionButton',
);

void _noop() {}

Widget _build(DemoArgs args) => FloatingActionButton(
  // 一覧の見本と詳細の両方に出るので、画面の切り替えで Hero が重ならないようにする
  heroTag: null,
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  mini: args.valueOf<bool>('mini') ?? false,
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  elevation: args.valueOf<double>('elevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  child: args.valueOf<Widget>('child'),
);
