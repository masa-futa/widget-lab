import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDialogActionEntry = WidgetEntry(
  id: 'cupertinoDialogAction',
  name: 'CupertinoDialogAction',
  genreIds: const ['cupertino'],
  summary: 'iOS の警告ダイアログのボタン',
  description:
      'CupertinoAlertDialog の actions に並べるボタンです。'
      'isDefaultAction で太字に、isDestructiveAction で赤い文字になります。'
      'onPressed が null なら押せない見た目になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDialogAction-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('OK'), source: "Text('OK')"),
    ),
    PropertySpec(
      name: 'isDefaultAction',
      typeLabel: 'bool',
      description: 'true なら、すすめる選択肢として太字にする',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'isDestructiveAction',
      typeLabel: 'bool',
      description: 'true なら、取り消せない操作として赤い文字にする',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'onPressed',
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら押せない見た目になる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoDialogAction',
);

void _pressed() {}

/// ダイアログのボタン 1 つ分の幅で、ダイアログの地の色の上に置く（ボタン自身は地を塗らない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 135,
  child: Builder(
    builder: (context) => ColoredBox(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      child: CupertinoDialogAction(
        isDefaultAction: args.valueOf<bool>('isDefaultAction') ?? false,
        isDestructiveAction: args.valueOf<bool>('isDestructiveAction') ?? false,
        onPressed: args.valueOf<VoidCallback>('onPressed'),
        // 必須のプロパティなので、常に値がある
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);
