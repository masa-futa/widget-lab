import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final clipOvalEntry = WidgetEntry(
  id: 'clipOval',
  name: 'ClipOval',
  genreIds: const ['painting'],
  summary: '子を楕円（正方形なら円）に切り抜く',
  description:
      '自分の大きさに内接する楕円の外を切り落として描きます。'
      '正方形の子なら円になり、丸いアイコンや写真に使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ClipOval-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'clipper',
      group: PropertyGroup.transform,
      typeLabel: 'CustomClipper<Rect>?',
      description: '楕円を内接させる四角。指定しないと自分の大きさの四角',
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
      description: '切り方。antiAlias は縁をなめらかに、hardEdge は速いが縁がぎざぎざ。既定は antiAlias',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
          Choice('none', Clip.none, 'Clip.none'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '切り抜く Widget（120×56）',
      control: FixedControl(
        value: DemoTile(1, width: 120, height: 56),
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
  codeName: 'ClipOval',
);

Widget _build(DemoArgs args) => ClipOval(
  clipper: args.valueOf<CustomClipper<Rect>>('clipper'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.antiAlias,
  child: args.valueOf<Widget>('child'),
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
