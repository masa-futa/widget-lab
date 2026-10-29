import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_group_label.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 一覧のシート。全部のプロパティを仲間ごとの見出しで並べ、最後に補足を置く。
/// 行を押すとそれを選んで閉じる。開いたら今選んでいる行を見える位置まで送る。
class PropertyListSheet extends ConsumerStatefulWidget {
  const PropertyListSheet({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<PropertyListSheet> createState() => _PropertyListSheetState();
}

class _PropertyListSheetState extends ConsumerState<PropertyListSheet> {
  final _currentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _currentKey.currentContext;
      if (context == null || !context.mounted) return;
      Scrollable.ensureVisible(context, alignment: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = detailProvider(widget.entryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final items = state.pickerItems;
    final current = state.pickerIndex;
    final settings = state.settings;

    void choose(PickerItem item) {
      switch (item) {
        case PickerProperty(:final spec):
          notifier.propertySelected(spec.name);
        case PickerReferences():
          notifier.referencesSelected();
      }
      Navigator.of(context).pop();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.detailPickerSheetTitle(state.entry.properties.length),
                style: theme.textTheme.titleMedium,
              ),
              Gap(spacing.xs),
              Text(
                l10n.detailPickerSheetOnCount(state.onCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        for (final (i, item) in items.indexed) ...[
          if (i == 0 || items[i - 1].section != item.section)
            _SectionHeader(
              icon: switch (item) {
                PickerProperty(:final spec) => groupIcon(spec.group),
                PickerReferences() => referencesIcon,
              },
              label: switch (item) {
                PickerProperty(:final spec) => groupLabel(l10n, spec.group),
                PickerReferences() => l10n.detailReferencesLabel,
              },
            ),
          switch (item) {
            PickerProperty(:final spec) => _Row(
              key: i == current ? _currentKey : null,
              name: spec.name,
              value: spec.isOnIn(settings)
                  ? chipValueLabel(spec.control, spec.valueIn(settings))
                  : l10n.detailChipDefault,
              on: spec.isOnIn(settings),
              dimmed: !state.isEffective(spec.name),
              selected: i == current,
              onTap: () => choose(item),
            ),
            PickerReferences() => _Row(
              key: i == current ? _currentKey : null,
              name: l10n.detailReferencesLabel,
              value: l10n.detailPickerReferencesCount(
                state.entry.references.length,
              ),
              on: false,
              dimmed: false,
              selected: i == current,
              onTap: () => choose(item),
            ),
          },
        ],
      ],
    );
  }
}

/// 仲間の見出し（アイコンと名前）。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final color = theme.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.xxs),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            Gap(spacing.xxs),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 行。● は指定中、○ は既定。今選んでいる行は地を塗り ✓ を付ける。
class _Row extends StatelessWidget {
  const _Row({
    required this.name,
    required this.value,
    required this.on,
    required this.dimmed,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String name;
  final String value;
  final bool on;
  final bool dimmed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final radius = BorderRadius.circular(NimiRadius.of(context).sm);
    return Semantics(
      label: [
        name,
        value,
        if (selected) l10n.detailChipSelected,
        if (dimmed) l10n.detailChipInactive,
      ].join('、'),
      button: true,
      selected: selected,
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : null,
              borderRadius: radius,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.xs),
                child: Row(
                  children: [
                    Icon(
                      on ? Icons.circle : Icons.circle_outlined,
                      size: 10,
                      color: on ? scheme.primary : scheme.outline,
                    ),
                    Gap(spacing.xs),
                    Flexible(
                      flex: 2,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    Gap(spacing.sm),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      Gap(spacing.xs),
                      Icon(Icons.check, size: 18, color: scheme.primary),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
