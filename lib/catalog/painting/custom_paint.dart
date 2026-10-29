import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final customPaintEntry = WidgetEntry(
  id: 'customPaint',
  name: 'CustomPaint',
  genreIds: const ['painting'],
  summary: 'Canvas に自分で絵を描く',
  description:
      'CustomPainter の paint で、Canvas に線・円・Path などを描きます。'
      'painter は子の後ろに、foregroundPainter は子の前に描きます。'
      '子がなければ size の大きさになります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/CustomPaint-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'painter',
      group: PropertyGroup.paint,
      typeLabel: 'CustomPainter?',
      description: '子の後ろに描く絵',
      control: ChoiceControl(
        choices: [
          Choice('円', _CirclePainter(), 'const CirclePainter()'),
          Choice('波線', _WavePainter(), 'const WavePainter()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'foregroundPainter',
      group: PropertyGroup.paint,
      typeLabel: 'CustomPainter?',
      description: '子の前に描く絵',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('円', _CirclePainter(), 'const CirclePainter()'),
          Choice('波線', _WavePainter(), 'const WavePainter()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'size',
      group: PropertyGroup.size,
      typeLabel: 'Size',
      description: '子がないときの大きさ。既定は Size.zero（何も見えない）',
      control: ChoiceControl(
        choices: [
          Choice('160×56', Size(160, 56), 'Size(160, 56)'),
          Choice('56×56', Size(56, 56), 'Size(56, 56)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '絵と重ねる Widget。あると大きさは子に合わせる',
      initiallyOn: false,
      control: FixedControl(
        value: DemoTile(1, width: 96, height: 40),
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
    ReferenceArg(
      name: 'isComplex',
      typeLabel: 'bool',
      description: '絵が複雑で、描いた結果を取っておく（キャッシュする）価値があるかの目安。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'willChange',
      typeLabel: 'bool',
      description: '絵が次のフレームで変わりそうかの目安。キャッシュするかの判断に使い、見た目は変わらない',
    ),
  ],
  build: _build,
  codeName: 'CustomPaint',
);

Widget _build(DemoArgs args) => CustomPaint(
  painter: args.valueOf<CustomPainter>('painter'),
  foregroundPainter: args.valueOf<CustomPainter>('foregroundPainter'),
  size: args.valueOf<Size>('size') ?? Size.zero,
  child: args.valueOf<Widget>('child'),
);

/// 大きさに内接する円を、紅の線で描く。
class _CirclePainter extends CustomPainter {
  const _CirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DemoTile.colors[3]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => false;
}

/// 横いっぱいの波線を、山吹の線で描く。
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DemoTile.colors[1]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path = Path()..moveTo(0, size.height / 2);
    const waves = 4;
    final step = size.width / waves;
    for (var i = 0; i < waves; i++) {
      final x = i * step;
      path.quadraticBezierTo(
        x + step / 2,
        i.isEven ? 0 : size.height,
        x + step,
        size.height / 2,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
