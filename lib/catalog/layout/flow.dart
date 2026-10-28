import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final flowEntry = WidgetEntry(
  id: 'flow',
  name: 'Flow',
  genreIds: const ['layout'],
  summary: '子の位置を、描くときの変形（Matrix4）で決める',
  description:
      'FlowDelegate の paintChildren で、子ごとに変形の行列を渡して描きます。'
      '組み直さずに描き直すだけで位置を変えられるので、'
      '開閉するメニューのように子が動くものに向きます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Flow-class.html'),
  properties: const [
    PropertySpec(
      name: 'delegate',
      typeLabel: 'FlowDelegate',
      description: '子の描き方',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('横に並べる', _RowDelegate(), 'const RowDelegate()'),
          Choice('重ねてずらす', _StackDelegate(), 'const StackDelegate()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '描く子（40×40）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1, width: 40, height: 40),
          DemoTile(2, width: 40, height: 40),
          DemoTile(3, width: 40, height: 40),
          DemoTile(4, width: 40, height: 40),
        ],
        source: '[Tile(1), Tile(2), Tile(3), Tile(4)]',
      ),
    ),
  ],
  build: _build,
  codeName: 'Flow',
);

Widget _build(DemoArgs args) => Flow(
  // 必須のプロパティなので、常に値がある
  delegate: args.valueOf<FlowDelegate>('delegate')!,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);

/// 左から 8 ずつあけて横に並べる。
class _RowDelegate extends FlowDelegate {
  const _RowDelegate();

  @override
  void paintChildren(FlowPaintingContext context) {
    var x = 0.0;
    for (var i = 0; i < context.childCount; i++) {
      context.paintChild(i, transform: Matrix4.translationValues(x, 0, 0));
      x += (context.getChildSize(i)?.width ?? 0) + 8;
    }
  }

  @override
  bool shouldRepaint(_RowDelegate oldDelegate) => false;
}

/// 右下へ 12・4 ずつずらして重ねる。
class _StackDelegate extends FlowDelegate {
  const _StackDelegate();

  @override
  void paintChildren(FlowPaintingContext context) {
    for (var i = 0; i < context.childCount; i++) {
      context.paintChild(
        i,
        transform: Matrix4.translationValues(i * 12.0, i * 4.0, 0),
      );
    }
  }

  @override
  bool shouldRepaint(_StackDelegate oldDelegate) => false;
}
