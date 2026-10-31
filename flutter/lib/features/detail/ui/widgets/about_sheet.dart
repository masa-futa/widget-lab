import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 説明のシート。見出し・ジャンル・説明文・公式ドキュメントを開くボタン。
class AboutSheet extends ConsumerWidget {
  const AboutSheet({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailProvider(entryId));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailAboutTitle(state.entry.name),
          style: theme.textTheme.titleMedium,
        ),
        Gap(spacing.xs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final genre in state.genres) _GenreBadge(name: genre.name),
          ],
        ),
        Gap(spacing.md),
        Text(state.entry.description, style: theme.textTheme.bodyLarge),
        Gap(spacing.lg),
        FilledButton.tonalIcon(
          onPressed: () async {
            final opened = await ref
                .read(detailProvider(entryId).notifier)
                .openDocsTapped();
            if (opened || !context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.detailOpenDocsFailed)),
              );
          },
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.detailOpenDocs),
        ),
      ],
    );
  }
}

class _GenreBadge extends StatelessWidget {
  const _GenreBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: NimiColors.of(context).surfaceMuted,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
      ),
      child: Text(name, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
