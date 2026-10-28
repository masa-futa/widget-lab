import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 説明タブ。ジャンル・要約・公式ドキュメントを開くボタン。
class DescriptionTab extends ConsumerWidget {
  const DescriptionTab({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailProvider(entryId));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return SingleChildScrollView(
      // タブを行き来してもスクロール位置を残す
      key: const PageStorageKey('description'),
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: spacing.xs,
            runSpacing: spacing.xs,
            children: [
              for (final genre in state.genres) _GenreChip(name: genre.name),
            ],
          ),
          Gap(spacing.md),
          Text(state.entry.description, style: theme.textTheme.bodyLarge),
          Gap(spacing.xl),
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
            iconAlignment: IconAlignment.end,
            label: Text(l10n.detailOpenDocs),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.name});

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
