import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('OK'), source: "Text('OK')"),
    ),
    PropertySpec(
      name: 'isDefaultAction',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら、すすめる選択肢として太字にする',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'isDestructiveAction',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら、取り消せない操作として赤い文字にする',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'textStyle',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle?',
      description: 'ボタンの文字の書式。iOS の既定の書式に重ねる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('大きく', TextStyle(fontSize: 22), 'TextStyle(fontSize: 22)'),
          Choice(
            '若竹の文字',
            TextStyle(color: Color(0xFF68BE8D)),
            'TextStyle(color: Color(0xFF68BE8D))',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら押せない見た目になる',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスを乗せたときのカーソルの形。タッチの画面では出ない',
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
        textStyle: args.valueOf<TextStyle>('textStyle'),
        onPressed: args.valueOf<VoidCallback>('onPressed'),
        // 必須のプロパティなので、常に値がある
        child: args.valueOf<Widget>('child')!,
      ),
    ),
  ),
);
