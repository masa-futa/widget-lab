import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';

/// デモの木で、収録する Widget が包む範囲（pv-tree）。accent の点線で囲み、上に札
/// （例:「MediaQuery(textScaler: 1.5)」）を付ける。比較中は左上に側のラベルがあるので札を出さない。
///
/// 木は [DemoFit] でカードに収める。
class DemoScope extends StatelessWidget {
  const DemoScope({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final radius = NimiRadius.of(context).md;
    final framed = CustomPaint(
      painter: _DashedBorder(color: theme.colorScheme.primary, radius: radius),
      child: Padding(padding: EdgeInsets.all(spacing.xs), child: child),
    );
    return DemoFit(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!recorder.comparing) ...[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: DemoRecorder.textScalerOf(context),
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Gap(spacing.xs),
          ],
          framed,
        ],
      ),
    );
  }
}

/// デモの木をカードの幅に合わせて組み、高さが足りなければ縮める
/// （比較中の狭いカードや見本でもはみ出さない）。
class DemoFit extends StatelessWidget {
  const DemoFit({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: constraints.maxWidth,
        child: Padding(
          padding: EdgeInsets.all(NimiSpacing.of(context).sm),
          child: child,
        ),
      ),
    ),
  );
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color, required this.radius});

  static const _dash = 4.0;
  static const _gap = 3.0;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final PathMetric metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
