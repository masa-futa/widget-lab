import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'ボタンの中身',
      required: true,
      control: FixedControl(value: Text('削除'), source: "Text('削除')"),
    ),
    PropertySpec(
      name: 'isDefaultAction',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら、すすめる選択肢として太字にする',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'isDestructiveAction',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'true なら、取り消せない操作として赤い文字にする',
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback',
      description: '押したときに呼ばれる',
      required: true,
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
      description: 'マウスを重ねたときのカーソルの形。指定しないと Web では指の形',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'キーボードの操作の行き先を、外から決める・読むときに渡す',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードの操作の行き先になったときの地の色（プレビューでは見えない）',
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
