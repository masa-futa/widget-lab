import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';

/// プレビューのカード。地に方眼を描き、子はカードの大きさの範囲（緩い制約）で中央に組み立てる。
///
/// スクロールで包まないのは、子の高さの上限がなくなり、`CrossAxisAlignment.stretch`
/// やスクロールする Widget が組み立てられなくなるため。はみ出す分は切る。
/// 地は Material にして、子の InkWell などの波紋が地の上に見えるようにする。
class PreviewCard extends StatelessWidget {
  const PreviewCard({required this.child, this.scale = 1, super.key});

  /// 子の外枠の線（テストで大きさを見る）。
  static const boundsKey = Key('previewBounds');

  /// 地の方眼（テストで見る）。
  static const gridKey = Key('previewGrid');

  final Widget child;

  /// 見た目の倍率（×1 / ×2）。レイアウトの大きさは変えない。
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(NimiRadius.of(context).lg),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        key: gridKey,
        painter: _GridPainter(color: scheme.outlineVariant),
        child: SizedBox.expand(
          child: Center(
            child: Transform.scale(
              scale: scale,
              // Padding のように自分では何も描かない Widget でも、大きさの違いが
              // 見えるように外枠に線を引く（design-system の原則1 の例外。ui-spec の pv-card）
              child: DecoratedBox(
                key: boundsKey,
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 24 ごとの方眼。
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  static const _step = 24.0;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = _step; x < size.width; x += _step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = _step; y < size.height; y += _step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
