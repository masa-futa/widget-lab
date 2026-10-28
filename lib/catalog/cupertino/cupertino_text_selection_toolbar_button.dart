import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextSelectionToolbarButtonEntry = WidgetEntry(
  id: 'cupertinoTextSelectionToolbarButton',
  name: 'CupertinoTextSelectionToolbarButton',
  genreIds: const ['cupertino'],
  summary: '文字を選んだときのメニューの、iOS の見た目のボタン',
  description:
      'CupertinoTextSelectionToolbar に並べるボタンです。押している間は地が少し明るくなります。'
      'onPressed が null なら文字が薄くなり、押せません。'
      'プレビューでは、ボタン 1 つだけのメニューに入れて描きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextSelectionToolbarButton-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'text',
      typeLabel: 'String',
      description: 'ボタンの文字',
      required: true,
      control: TextControl(initialValue: 'コピー'),
    ),
    PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら押せない見た目になる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTextSelectionToolbarButton.text',
);

void _pressed() {}

Widget _build(DemoArgs args) => SizedBox(
  width: 300,
  height: 120,
  child: CupertinoTextSelectionToolbar(
    anchorAbove: const Offset(150, 60),
    anchorBelow: const Offset(150, 80),
    children: [
      CupertinoTextSelectionToolbarButton.text(
        onPressed: args.valueOf<VoidCallback>('onPressed'),
        // 必須のプロパティなので、常に値がある
        text: args.valueOf<String>('text')!,
      ),
    ],
  ),
);
