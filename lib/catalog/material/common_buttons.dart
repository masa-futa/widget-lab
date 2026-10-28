import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 公式カタログの「Common buttons」のカード。クラス名ではないので、
/// 一番目立つ基本のボタンの FilledButton で見せる。
final commonButtonsEntry = WidgetEntry(
  id: 'commonButtons',
  name: 'Common buttons',
  genreIds: const ['material'],
  summary: '押すと操作を始める、Material 3 の基本のボタン',
  description:
      'Material 3 の基本のボタンは、目立つ順に FilledButton・FilledButton.tonal・'
      'ElevatedButton・OutlinedButton・TextButton の 5 種類です。'
      'ここでは一番目立つ FilledButton で見ます（ElevatedButton は Basics に収録）。'
      'onPressed を渡さないと、押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/FilledButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない見た目になる',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    PropertySpec(
      name: 'style',
      typeLabel: 'ButtonStyle?',
      description: 'ボタンの見た目。ここでは地の色だけを変える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, color) in const [
            ('瑠璃', Color(0xFF1E50A2)),
            ('若竹', Color(0xFF68BE8D)),
            ('紅', Color(0xFFD7003A)),
          ])
            Choice(
              name,
              FilledButton.styleFrom(backgroundColor: color),
              'FilledButton.styleFrom(backgroundColor: ${colorCode(color)})',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'ボタンの中に置く Widget。ふつうは Text',
      required: true,
      control: FixedControl(value: Text('送信'), source: "Text('送信')"),
    ),
  ],
  build: _build,
  codeName: 'FilledButton',
);

void _noop() {}

Widget _build(DemoArgs args) => FilledButton(
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  style: args.valueOf<ButtonStyle>('style'),
  child: args.valueOf<Widget>('child'),
);
