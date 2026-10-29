import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final customSingleChildLayoutEntry = WidgetEntry(
  id: 'customSingleChildLayout',
  name: 'CustomSingleChildLayout',
  genreIds: const ['layout'],
  summary: '子の大きさと位置を、自分で書いた delegate で決める',
  description:
      'SingleChildLayoutDelegate に、自分の大きさ（getSize）・子に渡す制約'
      '（getConstraintsForChild）・子の位置（getPositionForChild）を書いて組みます。'
      '既定では使える広さいっぱいに広がります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/CustomSingleChildLayout-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'delegate',
      group: PropertyGroup.layout,
      typeLabel: 'SingleChildLayoutDelegate',
      description: '大きさと位置の決め方',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('右下に寄せる', _CornerDelegate(), 'const CornerDelegate()'),
          Choice('半分の大きさで中央', _HalfDelegate(), 'const HalfDelegate()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '置く Widget',
      control: FixedControl(
        value: DemoTile(1, width: 48, height: 48),
        source: 'Tile(1)',
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
  codeName: 'CustomSingleChildLayout',
);

Widget _build(DemoArgs args) => CustomSingleChildLayout(
  // 必須のプロパティなので、常に値がある
  delegate: args.valueOf<SingleChildLayoutDelegate>('delegate')!,
  child: args.valueOf<Widget>('child'),
);

/// 子をそのままの大きさで、右下の角に置く。
class _CornerDelegate extends SingleChildLayoutDelegate {
  const _CornerDelegate();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      Offset(size.width - childSize.width, size.height - childSize.height);

  @override
  bool shouldRelayout(_CornerDelegate oldDelegate) => false;
}

/// 子を自分の半分の大きさにして、中央に置く。
class _HalfDelegate extends SingleChildLayoutDelegate {
  const _HalfDelegate();

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(constraints.biggest / 2);

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      Offset(size.width - childSize.width, size.height - childSize.height) / 2;

  @override
  bool shouldRelayout(_HalfDelegate oldDelegate) => false;
}
