import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDesktopTextSelectionToolbarEntry = WidgetEntry(
  id: 'cupertinoDesktopTextSelectionToolbar',
  name: 'CupertinoDesktopTextSelectionToolbar',
  genreIds: const ['cupertino'],
  summary: '文字を右クリックしたときに出る、macOS の見た目のメニュー',
  description:
      'macOS で文字を右クリックしたときに出る、縦に並ぶメニューです。'
      'anchor の点を左上の角にして出し、画面の端に当たるとずらします。'
      'ふつうは TextField の contextMenuBuilder の中で作ります（プレビューでは箱の中に直接描く）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDesktopTextSelectionToolbar-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'anchor',
      typeLabel: 'Offset',
      description: 'メニューの左上の角を置く点。ここでは横の位置を変える',
      required: true,
      control: SliderControl(
        min: 0,
        max: 200,
        divisions: 10,
        initialValue: 60,
        resolve: (v) => Offset(v, 10),
        code: (v) => 'Offset($v, 10.0)',
      ),
    ),
    const PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: 'メニューの項目',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '切り取り・コピー・貼り付け',
            [
              CupertinoDesktopTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: '切り取り',
              ),
              CupertinoDesktopTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: 'コピー',
              ),
              CupertinoDesktopTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: '貼り付け',
              ),
            ],
            "[CupertinoDesktopTextSelectionToolbarButton.text(onPressed: () {}, text: '切り取り'), "
                "CupertinoDesktopTextSelectionToolbarButton.text(onPressed: () {}, text: 'コピー'), "
                "CupertinoDesktopTextSelectionToolbarButton.text(onPressed: () {}, text: '貼り付け')]",
          ),
          Choice(
            'コピーだけ',
            [
              CupertinoDesktopTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: 'コピー',
              ),
            ],
            "[CupertinoDesktopTextSelectionToolbarButton.text(onPressed: () {}, text: 'コピー')]",
          ),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoDesktopTextSelectionToolbar',
);

void _pressed() {}

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでもはみ出さないよう、高さが足りなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 300,
    height: 140,
    // どちらも必須のプロパティなので、常に値がある
    child: CupertinoDesktopTextSelectionToolbar(
      anchor: args.valueOf<Offset>('anchor')!,
      children: args.valueOf<List<Widget>>('children')!,
    ),
  ),
);
