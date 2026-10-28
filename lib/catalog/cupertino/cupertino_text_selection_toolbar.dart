import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoTextSelectionToolbarEntry = WidgetEntry(
  id: 'cupertinoTextSelectionToolbar',
  name: 'CupertinoTextSelectionToolbar',
  genreIds: const ['cupertino'],
  summary: '文字を選んだときに出る、iOS の見た目のメニュー',
  description:
      '文字を選んだときに出る、黒っぽい横長のメニューです。anchorAbove の上に出し、'
      '上に場所がなければ anchorBelow の下に出します。'
      'ふつうは TextField の contextMenuBuilder の中で作ります（プレビューでは箱の中に直接描く）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoTextSelectionToolbar-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'anchorAbove',
      typeLabel: 'Offset',
      description: 'メニューの矢印が指す点（メニューを上に出すとき）。ここでは横の位置を変える',
      required: true,
      control: SliderControl(
        min: 40,
        max: 260,
        divisions: 11,
        initialValue: 150,
        resolve: (v) => Offset(v, 60),
        code: (v) => 'Offset($v, 60.0)',
      ),
    ),
    const PropertySpec(
      name: 'anchorBelow',
      typeLabel: 'Offset',
      description: '上に場所がないときに、メニューの矢印が指す点（メニューは下に出る）',
      required: true,
      control: FixedControl(
        value: Offset(150, 80),
        source: 'Offset(150.0, 80.0)',
      ),
    ),
    const PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: 'メニューのボタン。入り切らないと、矢印で次の頁へ送る',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '切り取り・コピー・貼り付け',
            [
              CupertinoTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: '切り取り',
              ),
              CupertinoTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: 'コピー',
              ),
              CupertinoTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: '貼り付け',
              ),
            ],
            "[CupertinoTextSelectionToolbarButton.text(onPressed: () {}, text: '切り取り'), "
                "CupertinoTextSelectionToolbarButton.text(onPressed: () {}, text: 'コピー'), "
                "CupertinoTextSelectionToolbarButton.text(onPressed: () {}, text: '貼り付け')]",
          ),
          Choice(
            'コピーだけ',
            [
              CupertinoTextSelectionToolbarButton.text(
                onPressed: _pressed,
                text: 'コピー',
              ),
            ],
            "[CupertinoTextSelectionToolbarButton.text(onPressed: () {}, text: 'コピー')]",
          ),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoTextSelectionToolbar',
);

void _pressed() {}

/// メニューを描く箱の大きさ。アンカーはこの箱の中の座標。
const _box = Size(300, 120);

Widget _build(DemoArgs args) => SizedBox.fromSize(
  size: _box,
  // どれも必須のプロパティなので、常に値がある
  child: CupertinoTextSelectionToolbar(
    anchorAbove: args.valueOf<Offset>('anchorAbove')!,
    anchorBelow: args.valueOf<Offset>('anchorBelow')!,
    children: args.valueOf<List<Widget>>('children')!,
  ),
);
