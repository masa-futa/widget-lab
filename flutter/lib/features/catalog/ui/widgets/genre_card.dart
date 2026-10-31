import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ジャンルのタイル（ca_lst の gt-tile）。件数・ジャンル名・代表の名前。
class GenreCard extends StatelessWidget {
  const GenreCard({required this.tile, required this.onTap, super.key});

  final GenreTile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    final examples = tile.examples.join(l10n.catalogNameSeparator);
    final spoken = tile.examples.join(l10n.catalogReadSeparator);
    return Semantics(
      button: true,
      label: tile.hasMore
          ? l10n.catalogTileSemanticsMore(tile.genre.name, tile.count, spoken)
          : l10n.catalogTileSemantics(tile.genre.name, tile.count, spoken),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${tile.count}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    // Gap はベースラインを計れず、行の高さをそろえる IntrinsicHeight
                    // の中の baseline 揃えの Row で落ちるので、余白は Padding で入れる。
                    Padding(
                      padding: EdgeInsets.only(left: spacing.xxs),
                      child: Text(
                        l10n.catalogCountUnit,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(spacing.xxs),
                // ジャンル名は省略しない（長い名前は折り返す）。
                Text(
                  tile.genre.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Gap(spacing.xxs),
                Text(
                  tile.hasMore ? l10n.catalogExamplesMore(examples) : examples,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
