import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 仲間のタブ。チップの列の上に置き、横に収まらなければ横にスクロールする。
/// 名前の横に、その仲間で ON のプロパティの数を出す（開いていないタブで効いているものを見落とさない）。
class GroupTabs extends ConsumerWidget {
  const GroupTabs({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detailProvider(entryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      child: Row(
        children: [
          for (final group in state.entry.groups)
            _Tab(
              label: groupLabel(l10n, group),
              count: state.onCountIn(group),
              selected: !state.showsReferences && group == state.selectedGroup,
              onTap: () => notifier.groupSelected(group),
            ),
          if (state.entry.references.isNotEmpty)
            _Tab(
              label: l10n.detailTabReferences,
              selected: state.showsReferences,
              onTap: notifier.referencesSelected,
            ),
        ],
      ),
    );
  }
}

/// 仲間の名前。仲間を決めていない収録は「プロパティ」。
String groupLabel(AppLocalizations l10n, PropertyGroup? group) =>
    switch (group) {
      PropertyGroup.size => l10n.detailGroupSize,
      PropertyGroup.spacing => l10n.detailGroupSpacing,
      PropertyGroup.layout => l10n.detailGroupLayout,
      PropertyGroup.paint => l10n.detailGroupPaint,
      PropertyGroup.transform => l10n.detailGroupTransform,
      PropertyGroup.text => l10n.detailGroupText,
      PropertyGroup.behavior => l10n.detailGroupBehavior,
      PropertyGroup.content => l10n.detailGroupContent,
      null => l10n.detailGroupAll,
    };

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;

  /// ON の数。補足のタブは `null`（数を出さない）。
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final count = this.count;
    return Semantics(
      selected: selected,
      button: true,
      label: count == null
          ? label
          : AppLocalizations.of(context).detailTabOnCount(label, count),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? scheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
              if (count != null && count > 0) ...[
                Gap(spacing.xxs),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: scheme.primaryContainer,
                    shape: const StadiumBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
