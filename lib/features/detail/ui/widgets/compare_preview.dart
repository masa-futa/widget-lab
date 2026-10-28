import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 比較中のプレビュー。上に「付けた」、下に「付けない」を同じ高さで並べる。
class ComparePreview extends StatelessWidget {
  const ComparePreview({
    required this.propertyName,
    required this.valueLabel,
    required this.withChild,
    required this.withoutChild,
    super.key,
  });

  /// 比べているプロパティ。読み上げに使う。
  final String propertyName;

  /// 「付けた」側の値の表示。読み上げに使う。
  final String valueLabel;
  final Widget withChild;
  final Widget withoutChild;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _LabeledCard(
            icon: Icons.check,
            label: l10n.detailCompareWith,
            semanticsLabel: l10n.detailCompareWithSemantics(
              propertyName,
              valueLabel,
            ),
            child: withChild,
          ),
        ),
        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        Expanded(
          child: _LabeledCard(
            icon: Icons.remove,
            label: l10n.detailCompareWithout,
            semanticsLabel: l10n.detailCompareWithoutSemantics(propertyName),
            child: withoutChild,
          ),
        ),
      ],
    );
  }
}

class _LabeledCard extends StatelessWidget {
  const _LabeledCard({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.child,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final style = theme.textTheme.labelSmall;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: semanticsLabel,
            excludeSemantics: true,
            child: Row(
              children: [
                Icon(icon, size: style?.fontSize),
                Gap(spacing.xxs),
                Text(label, style: style),
              ],
            ),
          ),
          Gap(spacing.xxs),
          Expanded(
            child: PreviewCard(key: const Key('compareCard'), child: child),
          ),
        ],
      ),
    );
  }
}
