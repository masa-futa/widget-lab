import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.layout,
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
      group: PropertyGroup.layout,
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
      group: PropertyGroup.content,
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
    const PropertySpec(
      name: 'toolbarBuilder',
      group: PropertyGroup.paint,
      typeLabel: 'CupertinoToolbarBuilder',
      description: 'ボタンの列を包むメニューの地を組み立てる。指定しないと矢印つきの黒っぽい地',
      initiallyOn: false,
      control: FixedControl(value: _toolbar, source: _toolbarSource),
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
  codeName: 'CupertinoTextSelectionToolbar',
);

void _pressed() {}

Widget _toolbar(
  BuildContext context,
  Offset anchorAbove,
  Offset anchorBelow,
  Widget child,
) => DecoratedBox(
  decoration: BoxDecoration(
    color: const Color(0xFF1E50A2),
    borderRadius: BorderRadius.circular(16),
  ),
  child: child,
);
const _toolbarSource =
    '(context, anchorAbove, anchorBelow, child) => DecoratedBox('
    'decoration: BoxDecoration(color: Color(0xFF1E50A2), '
    'borderRadius: BorderRadius.circular(16)), child: child)';

/// メニューを描く箱の大きさ。アンカーはこの箱の中の座標。
const _box = Size(300, 120);

Widget _build(DemoArgs args) {
  // どれも必須のプロパティなので、常に値がある
  final anchorAbove = args.valueOf<Offset>('anchorAbove')!;
  final anchorBelow = args.valueOf<Offset>('anchorBelow')!;
  final children = args.valueOf<List<Widget>>('children')!;
  final toolbarBuilder = args.valueOf<CupertinoToolbarBuilder>(
    'toolbarBuilder',
  );
  return SizedBox.fromSize(
    size: _box,
    // toolbarBuilder の既定は SDK の中の関数で渡せないので、OFF なら省く
    child: toolbarBuilder == null
        ? CupertinoTextSelectionToolbar(
            anchorAbove: anchorAbove,
            anchorBelow: anchorBelow,
            children: children,
          )
        : CupertinoTextSelectionToolbar(
            anchorAbove: anchorAbove,
            anchorBelow: anchorBelow,
            toolbarBuilder: toolbarBuilder,
            children: children,
          ),
  );
}
