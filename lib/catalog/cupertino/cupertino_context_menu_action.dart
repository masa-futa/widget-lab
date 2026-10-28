import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoContextMenuActionEntry = WidgetEntry(
  id: 'cupertinoContextMenuAction',
  name: 'CupertinoContextMenuAction',
  genreIds: const ['cupertino'],
  summary: 'コンテキストメニューの項目',
  description:
      'CupertinoContextMenu の actions に並べる項目です。右端にアイコンを置けます。'
      'isDefaultAction で太字に、isDestructiveAction で赤い文字になります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoContextMenuAction-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '項目の文字',
      required: true,
      control: FixedControl(value: Text('共有'), source: "Text('共有')"),
    ),
    PropertySpec(
      name: 'trailingIcon',
      typeLabel: 'IconData?',
      description: '右端に出すアイコン',
      control: ChoiceControl(
        choices: [
          Choice('share', CupertinoIcons.share, 'CupertinoIcons.share'),
          Choice('heart', CupertinoIcons.heart, 'CupertinoIcons.heart'),
          Choice('delete', CupertinoIcons.delete, 'CupertinoIcons.delete'),
        ],
      ),
    ),
    PropertySpec(
      name: 'isDefaultAction',
      typeLabel: 'bool',
      description: 'true なら、すすめる項目として太字にする',
      initiallyOn: false,
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
      description: '押したときに呼ばれる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  build: _build,
  codeName: 'CupertinoContextMenuAction',
);

void _pressed() {}

/// メニューの幅で、メニューの地の色の上に置く（項目自身はふだん地を塗らない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 250,
  child: Builder(
    builder: (context) => ColoredBox(
      color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
      child: CupertinoContextMenuAction(
        trailingIcon: args.valueOf<IconData>('trailingIcon'),
        isDefaultAction: args.valueOf<bool>('isDefaultAction') ?? false,
        isDestructiveAction: args.valueOf<bool>('isDestructiveAction') ?? false,
        onPressed: args.valueOf<VoidCallback>('onPressed'),
        // 必須のプロパティなので、常に値がある
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);
