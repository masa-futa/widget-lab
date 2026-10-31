import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_sample.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 見本つきの行（cc_gnr の ls-item、ca_lst の rs-item）。
///
/// 見本・名前・一行の要約・プロパティ数の印。[genres] を渡すと（検索の結果）、
/// 印の横に載っているジャンル名を添える。
class EntryTile extends StatelessWidget {
  const EntryTile({
    required this.entry,
    required this.onTap,
    this.genres = const [],
    super.key,
  });

  final WidgetEntry entry;
  final List<Genre> genres;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final count = entry.properties.length;
    final label = genres.isEmpty
        ? l10n.catalogEntrySemantics(entry.name, entry.summary, count)
        : l10n.catalogEntrySemanticsWithGenres(
            entry.name,
            entry.summary,
            count,
            genres.map((genre) => genre.name).join(l10n.catalogReadSeparator),
          );
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(left: spacing.md),
          child: Row(
            children: [
              EntrySample(entry: entry),
              Gap(spacing.md),
              Expanded(
                child: DecoratedBox(
                  // 区切り線は見本の右から引く。
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Texts(entry: entry, genres: genres),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                          child: Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 名前・一行の要約・プロパティ数の印（と、載っているジャンル名）。
class _Texts extends StatelessWidget {
  const _Texts({required this.entry, required this.genres});

  final WidgetEntry entry;
  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 名前は省略しない（長い名前は折り返す）。
        Text(
          entry.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          entry.summary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
        ),
        Gap(spacing.xxs),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: NimiColors.of(context).surfaceMuted,
                borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.xs,
                  vertical: spacing.xxs / 2,
                ),
                child: Text(
                  l10n.catalogPropertyCount(entry.properties.length),
                  style: theme.textTheme.labelSmall?.copyWith(color: secondary),
                ),
              ),
            ),
            if (genres.isNotEmpty)
              Text(
                genres
                    .map((genre) => genre.name)
                    .join(l10n.catalogNameSeparator),
                style: theme.textTheme.labelMedium?.copyWith(color: secondary),
              ),
          ],
        ),
      ],
    );
  }
}
