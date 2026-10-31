import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 補足のタブの中身。見た目が変わらない引数を、名前・型・一言の説明で読むだけに並べる。
class ReferenceList extends StatelessWidget {
  const ReferenceList({required this.references, super.key});

  final List<ReferenceArg> references;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.detailReferencesTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Gap(spacing.xxs),
        Text(
          l10n.detailReferencesNote,
          style: theme.textTheme.bodySmall?.copyWith(color: secondary),
        ),
        for (final reference in references) ...[
          Divider(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(reference.name, style: NimiTextStyles.of(context).code),
              Gap(spacing.xs),
              Text(
                reference.typeLabel,
                style: theme.textTheme.labelMedium?.copyWith(color: secondary),
              ),
            ],
          ),
          Gap(spacing.xxs),
          Text(reference.description, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}
