import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final elevatedButtonEntry = WidgetEntry(
  id: 'elevatedButton',
  name: 'ElevatedButton',
  genreIds: const ['basics'],
  summary: '影で少し浮いて見えるボタン',
  description:
      '地に影を付けて、少し浮いて見えるボタンです。押すと影が深くなります。'
      'Material 3 では、平らな地の上で目立たせたいときに使います'
      '（ほかの基本のボタンは Material design の Common buttons）。'
      'onPressed を渡さないと、押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/ElevatedButton-class.html',
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
      description: 'ボタンの見た目。ここでは浮き上がりの高さだけを変える',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final elevation in const [0.0, 6.0, 12.0])
            Choice(
              '$elevation',
              ElevatedButton.styleFrom(elevation: elevation),
              'ElevatedButton.styleFrom(elevation: $elevation)',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: 'ボタンの中に置く Widget。ふつうは Text',
      required: true,
      control: FixedControl(value: Text('保存'), source: "Text('保存')"),
    ),
  ],
  build: _build,
  codeName: 'ElevatedButton',
);

void _noop() {}

Widget _build(DemoArgs args) => ElevatedButton(
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  style: args.valueOf<ButtonStyle>('style'),
  child: args.valueOf<Widget>('child'),
);
