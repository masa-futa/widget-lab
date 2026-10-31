import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final clipRectEntry = WidgetEntry(
  id: 'clipRect',
  name: 'ClipRect',
  genreIds: const ['painting'],
  summary: '自分の四角の外にはみ出した子を切り落とす',
  description:
      '子が自分の大きさからはみ出して描かれるとき、はみ出した所を切り落とします。'
      'ここでは 64×32 の枠（SizedBox）の中で、OverflowBox で 120×56 にはみ出させた子を包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ClipRect-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'clipper',
      group: PropertyGroup.transform,
      typeLabel: 'CustomClipper<Rect>?',
      description: '切り抜く四角。指定しないと自分の大きさの四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('左半分', _LeftHalfClipper(), 'const LeftHalfClipper()'),
          Choice('内側 8', _InsetClipper(), 'const InsetClipper()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '切り方。none にすると切らない。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
          Choice('none', Clip.none, 'Clip.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'はみ出す Widget',
      control: FixedControl(
        value: OverflowBox(
          maxWidth: 120,
          maxHeight: 56,
          child: DemoTile(1, width: 120, height: 56),
        ),
        source: 'OverflowBox(maxWidth: 120, maxHeight: 56, child: Tile(1))',
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
  codeName: 'ClipRect',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 64,
  height: 32,
  child: ClipRect(
    clipper: args.valueOf<CustomClipper<Rect>>('clipper'),
    clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
    child: args.valueOf<Widget>('child'),
  ),
);

/// 左半分の四角。
class _LeftHalfClipper extends CustomClipper<Rect> {
  const _LeftHalfClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width / 2, size.height);

  @override
  bool shouldReclip(_LeftHalfClipper oldClipper) => false;
}

/// 四辺を 8 ずつ内側に寄せた四角。
class _InsetClipper extends CustomClipper<Rect> {
  const _InsetClipper();

  @override
  Rect getClip(Size size) => (Offset.zero & size).deflate(8);

  @override
  bool shouldReclip(_InsetClipper oldClipper) => false;
}
