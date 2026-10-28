import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final clipPathEntry = WidgetEntry(
  id: 'clipPath',
  name: 'ClipPath',
  genreIds: const ['painting'],
  summary: '子を好きな形（Path）に切り抜く',
  description:
      'CustomClipper<Path> の getClip で返した Path の外を切り落として描きます。'
      '形が決まっているなら ClipPath.shape に ShapeBorder を渡す書き方もあります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ClipPath-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'clipper',
      typeLabel: 'CustomClipper<Path>?',
      description: '切り抜く形。指定しないと子の大きさの四角（見た目は変わらない）',
      control: ChoiceControl(
        choices: [
          Choice('三角', _TriangleClipper(), 'const TriangleClipper()'),
          Choice('矢印', _ArrowClipper(), 'const ArrowClipper()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '切り方。既定は antiAlias（縁をなめらかに）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('antiAlias', Clip.antiAlias, 'Clip.antiAlias'),
          Choice('hardEdge', Clip.hardEdge, 'Clip.hardEdge'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '切り抜く Widget（96×56）',
      control: FixedControl(
        value: DemoTile(1, width: 96, height: 56),
        source: 'Tile(1)',
      ),
    ),
  ],
  build: _build,
  codeName: 'ClipPath',
);

Widget _build(DemoArgs args) => ClipPath(
  clipper: args.valueOf<CustomClipper<Path>>('clipper'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.antiAlias,
  child: args.valueOf<Widget>('child'),
);

/// 上の辺の中央を頂点にした三角。
class _TriangleClipper extends CustomClipper<Path> {
  const _TriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_TriangleClipper oldClipper) => false;
}

/// 右向きの矢印（左の 3 分の 2 が軸、右が矢じり）。
class _ArrowClipper extends CustomClipper<Path> {
  const _ArrowClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h * 0.3)
      ..lineTo(w * 0.6, h * 0.3)
      ..lineTo(w * 0.6, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w * 0.6, h)
      ..lineTo(w * 0.6, h * 0.7)
      ..lineTo(0, h * 0.7)
      ..close();
  }

  @override
  bool shouldReclip(_ArrowClipper oldClipper) => false;
}
