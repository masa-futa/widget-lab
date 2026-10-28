import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Extended FloatingActionButton」のカード。クラス名ではないので、
/// FloatingActionButton.extended のコンストラクタで見せる。
final extendedFloatingActionButtonEntry = WidgetEntry(
  id: 'extendedFloatingActionButton',
  name: 'Extended FloatingActionButton',
  genreIds: const ['material'],
  summary: '文字の入った、横に長い FloatingActionButton',
  description:
      'アイコンに加えて文字（label）を出す、横に長い FloatingActionButton です。'
      'FloatingActionButton.extended で作ります。isExtended を false にすると'
      'アイコンだけのボタンに縮むので、スクロールに合わせて縮める使い方もできます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/FloatingActionButton/FloatingActionButton.extended.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'label',
      typeLabel: 'Widget',
      description: 'ボタンの文字',
      required: true,
      control: FixedControl(value: Text('新規作成'), source: "Text('新規作成')"),
    ),
    const PropertySpec(
      name: 'icon',
      typeLabel: 'Widget?',
      description: '文字の左に置くアイコン',
      control: FixedControl(
        value: Icon(Icons.edit),
        source: 'Icon(Icons.edit)',
      ),
    ),
    const PropertySpec(
      name: 'isExtended',
      typeLabel: 'bool',
      description: '横に長い形で出すか。false にするとアイコンだけのボタンになる。指定しないと true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
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
  ],
  build: _build,
  codeName: 'FloatingActionButton.extended',
);

void _noop() {}

Widget _build(DemoArgs args) => FloatingActionButton.extended(
  // 一覧の見本と詳細の両方に出るので、画面の切り替えで Hero が重ならないようにする
  heroTag: null,
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  label: args.valueOf<Widget>('label') ?? const SizedBox.shrink(),
  icon: args.valueOf<Widget>('icon'),
  isExtended: args.valueOf<bool>('isExtended') ?? true,
  backgroundColor: args.valueOf<Color>('backgroundColor'),
);
