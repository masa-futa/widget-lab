import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoSpellCheckSuggestionsToolbarEntry = WidgetEntry(
  id: 'cupertinoSpellCheckSuggestionsToolbar',
  name: 'CupertinoSpellCheckSuggestionsToolbar',
  genreIds: const ['cupertino'],
  summary: 'つづりの誤りを押したときに出る、直し方の候補のメニュー',
  description:
      'つづりの誤りに下線が引かれた語を押したときに出る、直し方の候補を並べたメニューです。'
      '候補は 3 つまでで、見た目は CupertinoTextSelectionToolbar と同じです。'
      'ふつうは TextField の spellCheckConfiguration の中で作ります（プレビューでは箱の中に直接描く）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoSpellCheckSuggestionsToolbar-class.html',
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
      description: '直し方の候補（3 つまで）。0 個なら何も出さない',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '3 つ',
            [
              ContextMenuButtonItem(label: 'hello', onPressed: _pressed),
              ContextMenuButtonItem(label: 'help', onPressed: _pressed),
              ContextMenuButtonItem(label: 'hell', onPressed: _pressed),
            ],
            "[ContextMenuButtonItem(label: 'hello', onPressed: () {}), "
                "ContextMenuButtonItem(label: 'help', onPressed: () {}), "
                "ContextMenuButtonItem(label: 'hell', onPressed: () {})]",
          ),
          Choice('1 つ', [
            ContextMenuButtonItem(label: 'hello', onPressed: _pressed),
          ], "[ContextMenuButtonItem(label: 'hello', onPressed: () {})]"),
          Choice('0 個', <ContextMenuButtonItem>[], '[]'),
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
  codeName: 'CupertinoSpellCheckSuggestionsToolbar',
);

void _pressed() {}

Widget _build(DemoArgs args) => SizedBox(
  width: 300,
  height: 120,
  // どちらも必須のプロパティなので、常に値がある
  child: CupertinoSpellCheckSuggestionsToolbar(
    anchors: args.valueOf<TextSelectionToolbarAnchors>('anchors')!,
    buttonItems: args.valueOf<List<ContextMenuButtonItem>>('buttonItems')!,
  ),
);
