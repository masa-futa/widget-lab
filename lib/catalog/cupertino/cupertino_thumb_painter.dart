import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoThumbPainterEntry = WidgetEntry(
  id: 'cupertinoThumbPainter',
  name: 'CupertinoThumbPainter',
  genreIds: const ['cupertino'],
  summary: 'iOS のスライダーやスイッチのつまみを描く道具',
  description:
      'Widget ではなく、影つきの白い角丸のつまみを Canvas に描く道具です。'
      '自分の CustomPainter の paint から thumbPainter.paint(canvas, rect) と呼んで使います。'
      'スイッチのつまみには CupertinoThumbPainter.switchThumb を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoThumbPainter-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: 'つまみの色。指定しないと白',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemYellow',
            CupertinoColors.systemYellow,
            'CupertinoColors.systemYellow',
          ),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'shadows',
      group: PropertyGroup.paint,
      typeLabel: 'List<BoxShadow>',
      description: 'つまみの影。指定しないとスライダーの影',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('なし', <BoxShadow>[], '[]'),
          Choice(
            '濃い影',
            [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
            '[BoxShadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 8)]',
          ),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoThumbPainter',
);

Widget _build(DemoArgs args) {
  final color = args.valueOf<Color>('color');
  final shadows = args.valueOf<List<BoxShadow>>('shadows');
  return CustomPaint(
    size: const Size(120, 80),
    painter: _ThumbPainter(
      color == null && shadows == null
          ? const CupertinoThumbPainter()
          : CupertinoThumbPainter(
              color: color ?? CupertinoColors.white,
              shadows: shadows ?? const CupertinoThumbPainter().shadows,
            ),
    ),
  );
}

/// CupertinoThumbPainter を呼んで、真ん中につまみを描く（デモの部品）。
class _ThumbPainter extends CustomPainter {
  const _ThumbPainter(this.thumb);

  final CupertinoThumbPainter thumb;

  @override
  void paint(Canvas canvas, Size size) {
    thumb.paint(
      canvas,
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: CupertinoThumbPainter.radius,
      ),
    );
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) =>
      oldDelegate.thumb.color != thumb.color ||
      oldDelegate.thumb.shadows != thumb.shadows;
}
