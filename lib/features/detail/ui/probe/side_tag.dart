import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';

/// ログの行の前に付ける側の札（「使った」「使わない」）。
class SideTag extends StatelessWidget {
  const SideTag({required this.text, required this.color, super.key});

  final String text;

  /// 札の地（置く場所の地と違う色にする）。
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
