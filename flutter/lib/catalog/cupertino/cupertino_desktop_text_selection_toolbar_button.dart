import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDesktopTextSelectionToolbarButtonEntry = WidgetEntry(
  id: 'cupertinoDesktopTextSelectionToolbarButton',
  name: 'CupertinoDesktopTextSelectionToolbarButton',
  genreIds: const ['cupertino'],
  summary: '右クリックのメニューの、macOS の見た目の項目',
  description:
      'CupertinoDesktopTextSelectionToolbar に並べる項目です。'
      'マウスを乗せると地が主な色になり、文字が白くなります。'
      'プレビューでは、項目 1 つだけのメニューに入れて描きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDesktopTextSelectionToolbarButton-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'text',
      group: PropertyGroup.content,
      typeLabel: 'String',
      description: '項目の文字',
      required: true,
      control: TextControl(initialValue: 'コピー'),
    ),
    PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押したときに呼ばれる。null なら文字が薄くなり押せない',
      control: FixedControl(value: _pressed, source: '() {}'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'CupertinoDesktopTextSelectionToolbarButton.text',
);

void _pressed() {}

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでもはみ出さないよう、高さが足りなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 300,
    height: 100,
    child: CupertinoDesktopTextSelectionToolbar(
      anchor: const Offset(60, 10),
      children: [
        CupertinoDesktopTextSelectionToolbarButton.text(
          onPressed: args.valueOf<VoidCallback>('onPressed'),
          // 必須のプロパティなので、常に値がある
          text: args.valueOf<String>('text')!,
        ),
      ],
    ),
  ),
);
