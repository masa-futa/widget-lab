import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final customMultiChildLayoutEntry = WidgetEntry(
  id: 'customMultiChildLayout',
  name: 'CustomMultiChildLayout',
  genreIds: const ['layout'],
  summary: '複数の子の大きさと位置を、自分で書いた delegate で決める',
  description:
      '子をそれぞれ LayoutId で包んで名前（id）を付け、'
      'MultiChildLayoutDelegate の performLayout で、id ごとに layoutChild（大きさ）と'
      'positionChild（位置）を呼びます。子同士の大きさを見て位置を決められます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/CustomMultiChildLayout-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'delegate',
      group: PropertyGroup.layout,
      typeLabel: 'MultiChildLayoutDelegate',
      description: '子の大きさと位置の決め方',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('斜めに並べる', _DiagonalDelegate(), 'DiagonalDelegate()'),
          Choice('両端と中央', _SpreadDelegate(), 'SpreadDelegate()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: 'LayoutId で id（1〜3）を付けた子',
      control: FixedControl(
        // LayoutId は const にできない
        value: <Widget>[
          LayoutId(id: 1, child: const DemoTile(1, width: 24, height: 24)),
          LayoutId(id: 2, child: const DemoTile(2, width: 24, height: 24)),
          LayoutId(id: 3, child: const DemoTile(3, width: 24, height: 24)),
        ],
        source:
            '[LayoutId(id: 1, child: Tile(1)), LayoutId(id: 2, child: Tile(2)), '
            'LayoutId(id: 3, child: Tile(3))]',
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
  codeName: 'CustomMultiChildLayout',
);

Widget _build(DemoArgs args) => CustomMultiChildLayout(
  // 必須のプロパティなので、常に値がある
  delegate: args.valueOf<MultiChildLayoutDelegate>('delegate')!,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);

const _ids = [1, 2, 3];

/// id の順に、右下へ 32・16 ずつずらして置く。
class _DiagonalDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    for (final (i, id) in _ids.indexed) {
      if (!hasChild(id)) continue;
      layoutChild(id, BoxConstraints.loose(size));
      positionChild(id, Offset(i * 32, i * 16));
    }
  }

  @override
  bool shouldRelayout(_DiagonalDelegate oldDelegate) => false;
}

/// 1 を左端、2 を中央、3 を右端に、縦は中央に置く。
class _SpreadDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    for (final (i, id) in _ids.indexed) {
      if (!hasChild(id)) continue;
      final child = layoutChild(id, BoxConstraints.loose(size));
      final x = (size.width - child.width) * i / (_ids.length - 1);
      positionChild(id, Offset(x, (size.height - child.height) / 2));
    }
  }

  @override
  bool shouldRelayout(_SpreadDelegate oldDelegate) => false;
}
