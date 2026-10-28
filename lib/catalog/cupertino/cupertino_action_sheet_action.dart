import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoActionSheetActionEntry = WidgetEntry(
  id: 'cupertinoActionSheetAction',
  name: 'CupertinoActionSheetAction',
  genreIds: const ['cupertino'],
  summary: 'アクションシートの選択肢のボタン',
  description:
      'CupertinoActionSheet の actions と cancelButton に並べるボタンです。'
      'isDefaultAction で太字に、isDestructiveAction で赤い文字になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoActionSheetAction-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('削除'), source: "Text('削除')"),
    ),
    PropertySpec(
      name: 'isDefaultAction',
      typeLabel: 'bool',
      description: 'true なら、すすめる選択肢として太字にする',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'isDestructiveAction',
      typeLabel: 'bool',
      description: 'true なら、取り消せない操作として赤い文字にする',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback',
      description: '押したときに呼ばれる',
      required: true,
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoActionSheetAction',
);

void _pressed() {}

/// シートの幅に近い幅で、シートの地の色の上に置く（ボタン自身は地を塗らない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 280,
  child: Builder(
    builder: (context) => ColoredBox(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      child: CupertinoActionSheetAction(
        isDefaultAction: args.valueOf<bool>('isDefaultAction') ?? false,
        isDestructiveAction: args.valueOf<bool>('isDestructiveAction') ?? false,
        // 必須のプロパティなので、常に値がある
        onPressed: args.valueOf<VoidCallback>('onPressed')!,
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);
