import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 比較中のプレビュー。「付けた」と「付けない」（見た目を持たない Widget は「使った」と
/// 「使わない」）を同じ位置に重ね、仕切りの左に前者、右に後者を見せる。
///
/// 仕切りの位置は画面の中だけの一時的な状態なので、ここに持つ（比較をやめると捨てて、
/// 次は中央から）。
class ComparePreview extends StatefulWidget {
  const ComparePreview({
    required this.withLabel,
    required this.withoutLabel,
    required this.withSemanticsLabel,
    required this.withChild,
    required this.withoutChild,
    this.scale = 1,
    super.key,
  });

  /// 仕切りのつまみ（テストでドラッグする）。
  static const dividerKey = Key('compareDivider');

  /// 左上・右上のラベル（「付けた」「付けない」など）。右の読み上げにも使う。
  final String withLabel;
  final String withoutLabel;

  /// 左の読み上げ（「付けた、color、瑠璃」など）。
  final String withSemanticsLabel;
  final Widget withChild;
  final Widget withoutChild;

  /// 2 枚にかける見た目の倍率。
  final double scale;

  @override
  State<ComparePreview> createState() => _ComparePreviewState();
}

class _ComparePreviewState extends State<ComparePreview> {
  static const _min = 0.1;
  static const _max = 0.9;
  static const _step = 0.1;

  /// 仕切りの位置（カードの幅に対する割合）。
  double _fraction = 0.5;

  void _moveTo(double fraction) {
    // 0.1 刻みの誤差を消す
    final rounded = double.parse(fraction.toStringAsFixed(6));
    setState(() => _fraction = rounded.clamp(_min, _max));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final x = width * _fraction;
        return Stack(
          children: [
            Positioned.fill(
              // 中の Widget の読み上げは、その Widget のまま別に残す
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: widget.withSemanticsLabel,
                child: ClipRect(
                  clipper: _SideClipper(fraction: _fraction, left: true),
                  child: PreviewCard(
                    scale: widget.scale,
                    child: widget.withChild,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: widget.withoutLabel,
                child: ClipRect(
                  clipper: _SideClipper(fraction: _fraction, left: false),
                  child: PreviewCard(
                    scale: widget.scale,
                    child: widget.withoutChild,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: spacing.xs,
              start: spacing.xs,
              child: _SideLabel(icon: Icons.check, label: widget.withLabel),
            ),
            PositionedDirectional(
              top: spacing.xs,
              end: spacing.xs,
              child: _SideLabel(icon: Icons.remove, label: widget.withoutLabel),
            ),
            Positioned(
              left: x - _Divider.touchWidth / 2,
              top: 0,
              bottom: 0,
              child: Semantics(
                label: l10n.detailCompareDivider,
                value: '${(_fraction * 100).round()}%',
                increasedValue:
                    '${((_fraction + _step).clamp(_min, _max) * 100).round()}%',
                decreasedValue:
                    '${((_fraction - _step).clamp(_min, _max) * 100).round()}%',
                onIncrease: () => _moveTo(_fraction + _step),
                onDecrease: () => _moveTo(_fraction - _step),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) =>
                      _moveTo(_fraction + details.delta.dx / width),
                  child: const _Divider(key: ComparePreview.dividerKey),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// [fraction] の位置で左右に切り、[left] なら左、そうでなければ右を残す。
class _SideClipper extends CustomClipper<Rect> {
  const _SideClipper({required this.fraction, required this.left});

  final double fraction;
  final bool left;

  @override
  Rect getClip(Size size) {
    final x = size.width * fraction;
    return left
        ? Rect.fromLTRB(0, 0, x, size.height)
        : Rect.fromLTRB(x, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_SideClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.left != left;
}

/// 仕切りの縦線とつまみ（直径 32、押せる範囲 48）。
class _Divider extends StatelessWidget {
  const _Divider({super.key});

  static const touchWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: touchWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(child: Container(width: 2, color: scheme.primary)),
          Align(
            // 比較中は右下に拡大のピルがあるので、それより上に置く
            alignment: const Alignment(0, 0.4),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pause, size: 18, color: scheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 「付けた」「付けない」のラベル。色だけに頼らず、文言とアイコンで示す。
class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    // 読み上げは 2 枚の Semantics が持つ
    return ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xs,
          vertical: spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: NimiColors.of(context).surfaceMuted,
          borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: style?.fontSize, color: style?.color),
            Gap(spacing.xxs),
            Text(label, style: style),
          ],
        ),
      ),
    );
  }
}
