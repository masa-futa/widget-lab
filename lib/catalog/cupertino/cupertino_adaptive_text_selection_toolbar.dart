import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoAdaptiveTextSelectionToolbarEntry = WidgetEntry(
  id: 'cupertinoAdaptiveTextSelectionToolbar',
  name: 'CupertinoAdaptiveTextSelectionToolbar',
  genreIds: const ['cupertino'],
  summary: '端末に合わせて形を変える、文字を選んだときのメニュー',
  description:
      '文字を選んだときのメニューを、端末に合わせて出し分けます。iOS・Android では横長の'
      'CupertinoTextSelectionToolbar、macOS などのデスクトップでは縦に並ぶメニューになります。'
      'buttonItems のボタンの文字は、種類（コピーなど）から端末の言語で決まります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoAdaptiveTextSelectionToolbar-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'anchors',
      group: PropertyGroup.layout,
      typeLabel: 'TextSelectionToolbarAnchors',
      description: 'メニューを出す点。ここでは横の位置を変える',
      required: true,
      control: SliderControl(
        min: 40,
        max: 260,
        divisions: 11,
        initialValue: 150,
        resolve: (v) =>
            TextSelectionToolbarAnchors(primaryAnchor: Offset(v, 60)),
        code: (v) =>
            'TextSelectionToolbarAnchors(primaryAnchor: Offset($v, 60.0))',
      ),
    ),
    const PropertySpec(
      name: 'buttonItems',
      group: PropertyGroup.content,
      typeLabel: 'List<ContextMenuButtonItem>',
      description: 'ボタンの種類と押したときの処理。文字は種類から決まる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '切り取り・コピー・貼り付け',
            [
              ContextMenuButtonItem(
                type: ContextMenuButtonType.cut,
                onPressed: _pressed,
              ),
              ContextMenuButtonItem(
                type: ContextMenuButtonType.copy,
                onPressed: _pressed,
              ),
              ContextMenuButtonItem(
                type: ContextMenuButtonType.paste,
                onPressed: _pressed,
              ),
            ],
            '[ContextMenuButtonItem(type: ContextMenuButtonType.cut, onPressed: () {}), '
                'ContextMenuButtonItem(type: ContextMenuButtonType.copy, onPressed: () {}), '
                'ContextMenuButtonItem(type: ContextMenuButtonType.paste, onPressed: () {})]',
          ),
          Choice(
            'コピー・すべて選択',
            [
              ContextMenuButtonItem(
                type: ContextMenuButtonType.copy,
                onPressed: _pressed,
              ),
              ContextMenuButtonItem(
                type: ContextMenuButtonType.selectAll,
                onPressed: _pressed,
              ),
            ],
            '[ContextMenuButtonItem(type: ContextMenuButtonType.copy, onPressed: () {}), '
                'ContextMenuButtonItem(type: ContextMenuButtonType.selectAll, onPressed: () {})]',
          ),
        ],
      ),
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
  codeName: 'CupertinoAdaptiveTextSelectionToolbar.buttonItems',
);

void _pressed() {}

Widget _build(DemoArgs args) => SizedBox(
  width: 300,
  height: 140,
  // どちらも必須のプロパティなので、常に値がある
  child: CupertinoAdaptiveTextSelectionToolbar.buttonItems(
    anchors: args.valueOf<TextSelectionToolbarAnchors>('anchors')!,
    buttonItems: args.valueOf<List<ContextMenuButtonItem>>('buttonItems')!,
  ),
);
