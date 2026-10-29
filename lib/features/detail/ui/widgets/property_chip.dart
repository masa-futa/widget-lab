import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// プロパティのチップ。名前と今の値（OFF なら「既定」）。
///
/// 選択中は accent、指定中（ON）は accent-container、既定（OFF）は outline の枠。
class PropertyChip extends StatelessWidget {
  const PropertyChip({
    required this.name,
    required this.value,
    required this.on,
    required this.selected,
    required this.onTap,
    this.dimmed = false,
    super.key,
  });

  final String name;

  /// 今の値の短い表示。OFF のときは出さない。
  final String value;
  final bool on;
  final bool selected;
  final VoidCallback onTap;

  /// requires の相手が OFF で効かない（薄く出す）。
  final bool dimmed;

  /// チップの見た目の高さ。押せる範囲は 48。
  static const _height = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final (background, foreground, secondary) = switch ((selected, on)) {
      (true, _) => (scheme.primary, scheme.onPrimary, scheme.onPrimary),
      (false, true) => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        scheme.onPrimaryContainer,
      ),
      (false, false) => (null, scheme.onSurface, scheme.onSurfaceVariant),
    };
    final shownValue = on ? value : l10n.detailChipDefault;
    return Semantics(
      label: [
        name,
        shownValue,
        if (selected) l10n.detailChipSelected,
      ].join('、'),
      button: true,
      selected: selected,
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: Material(
          type: MaterialType.transparency,
          // 押せる範囲は高さ 48、見た目は 40 のピル
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: background,
                    shape: StadiumBorder(
                      side: background == null
                          ? BorderSide(color: scheme.outline)
                          : BorderSide.none,
                    ),
                  ),
                  child: ConstrainedBox(
                    // 文字を大きくしたときは中身に合わせて高くする
                    constraints: const BoxConstraints(minHeight: _height),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: foreground,
                            ),
                          ),
                          Gap(spacing.xxs),
                          Text(
                            shownValue,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
