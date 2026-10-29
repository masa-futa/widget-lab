import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_group_label.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/picker_item.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// プロパティの選ぶ欄。真ん中に今のプロパティのカード、左右に丸い ‹ ›、下に点。
/// カードを押すと一覧のシートを開く。1 か所しかなければカードだけを出す。
class PropertyPicker extends ConsumerWidget {
  const PropertyPicker({
    required this.entryId,
    this.showsDots = true,
    super.key,
  });

  final String entryId;

  /// 点の行を出すか。キーボードが出ている間は、編集パネルの高さを守るため隠す。
  final bool showsDots;

  /// カードの高さ。文字を大きくしたら中身に合わせて高くする。
  static const cardHeight = 56.0;

  /// 点の行の高さ。
  static const dotsHeight = 16.0;

  /// カード（テストで探す）。
  static const cardKey = Key('pickerCard');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = detailProvider(entryId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    final items = state.pickerItems;
    final index = state.pickerIndex;
    if (index < 0) return const SizedBox.shrink();
    final settings = state.settings;
    final (icon, name, value, fullValue, on, dimmed) = switch (items[index]) {
      PickerProperty(:final spec) => (
        groupIcon(spec.group),
        spec.name,
        l10n.detailPickerCardValue(
          groupLabel(l10n, spec.group),
          shortValueLabel(spec, settings) ?? l10n.detailChipDefault,
        ),
        l10n.detailPickerSemanticsValue(
          groupLabel(l10n, spec.group),
          spec.isOnIn(settings)
              ? valueLabel(spec.control, spec.valueIn(settings))
              : l10n.detailChipDefault,
        ),
        spec.isOnIn(settings),
        !state.isEffective(spec.name),
      ),
      PickerReferences() => (
        referencesIcon,
        l10n.detailReferencesLabel,
        l10n.detailPickerReferencesValue(state.entry.references.length),
        l10n.detailPickerReferencesValue(state.entry.references.length),
        false,
        false,
      ),
    };
    final card = _PickerCard(
      key: cardKey,
      icon: icon,
      name: name,
      value: value,
      on: on,
      dimmed: dimmed,
      semanticsLabel: l10n.detailPickerSemantics(
        name,
        dimmed
            ? l10n.detailPickerSemanticsInactive(
                fullValue,
                l10n.detailChipInactive,
              )
            : fullValue,
        index + 1,
        items.length,
      ),
      onTap: () =>
          showDetailSheet(context, (_) => PropertyListSheet(entryId: entryId)),
      onIncrease: state.hasNext ? notifier.nextTapped : null,
      onDecrease: state.hasPrevious ? notifier.previousTapped : null,
    );
    if (items.length == 1) return card;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: l10n.detailPickerPrevious,
              onPressed: state.hasPrevious ? notifier.previousTapped : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Gap(spacing.xxs),
            Expanded(child: card),
            Gap(spacing.xxs),
            IconButton.filledTonal(
              tooltip: l10n.detailPickerNext,
              onPressed: state.hasNext ? notifier.nextTapped : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (showsDots)
          SizedBox(
            height: dotsHeight,
            child: _PickerDots(
              items: items,
              index: index,
              on: [
                for (final item in items)
                  item is PickerProperty && item.spec.isOnIn(settings),
              ],
            ),
          ),
      ],
    );
  }
}

/// 今のプロパティのカード。指定中は塗り、既定は枠だけ、効かないものは薄く出す。
class _PickerCard extends StatelessWidget {
  const _PickerCard({
    required this.icon,
    required this.name,
    required this.value,
    required this.on,
    required this.dimmed,
    required this.semanticsLabel,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    super.key,
  });

  final IconData icon;
  final String name;

  /// 2 行目（「仲間 ・ 短い値」）。
  final String value;
  final bool on;
  final bool dimmed;
  final String semanticsLabel;
  final VoidCallback onTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final radius = BorderRadius.circular(NimiRadius.of(context).md);
    final (background, foreground, secondary) = on
        ? (scheme.primary, scheme.onPrimary, scheme.onPrimary)
        : (null, scheme.onSurface, scheme.onSurfaceVariant);
    return Semantics(
      label: semanticsLabel,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Ink(
              decoration: ShapeDecoration(
                color: background,
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: background == null
                      ? BorderSide(color: scheme.outline)
                      : BorderSide.none,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PropertyPicker.cardHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.xxs,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: foreground),
                      Gap(spacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: foreground,
                              ),
                            ),
                            Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.expand_more, color: foreground),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 位置と指定中を示す点。仲間の境目で間を空け、補足は輪で出す。飾りなので読み上げない。
class _PickerDots extends StatelessWidget {
  const _PickerDots({
    required this.items,
    required this.index,
    required this.on,
  });

  final List<PickerItem> items;
  final int index;

  /// [items] と同じ順の、指定中か。
  final List<bool> on;

  /// 点の直径と、今の位置の点の横幅。
  static const _size = 6.0;
  static const _currentWidth = 18.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spacing = NimiSpacing.of(context);
    return ExcludeSemantics(
      child: Center(
        // 21 件と補足でも画面の幅に収まらなければ、全体を縮める
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, item) in items.indexed) ...[
                if (i > 0)
                  Gap(
                    item.section == items[i - 1].section
                        ? spacing.xxs
                        : spacing.xs,
                  ),
                Container(
                  key: ValueKey('pickerDot-$i'),
                  width: i == index ? _currentWidth : _size,
                  height: _size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_size / 2),
                    color: switch ((i == index, item, on[i])) {
                      (true, _, _) => scheme.primary,
                      (false, PickerReferences(), _) => null,
                      (false, _, true) => scheme.primary.withValues(alpha: 0.4),
                      (false, _, false) => scheme.outlineVariant,
                    },
                    border: item is PickerReferences && i != index
                        ? Border.all(color: scheme.outline)
                        : null,
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
