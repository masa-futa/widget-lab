import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_value_control.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 編集パネル。選んでいる 1 つのプロパティの名前・型・ON/OFF・説明・値の操作・
/// 比べる・既定に戻す。
class EditorPanel extends StatelessWidget {
  const EditorPanel({
    required this.spec,
    required this.setting,
    required this.isComparing,
    required this.isDefault,
    required this.onToggled,
    required this.onValueChanged,
    required this.onCompareTapped,
    required this.onDefaultTapped,
    this.comparesUse = false,
    super.key,
  });

  final PropertySpec spec;
  final PropertySetting setting;
  final bool isComparing;

  /// プロパティではなく Widget そのものを使った／使わないで比べる（見た目を持たない Widget）。
  final bool comparesUse;

  /// 最初の値のまま（既定に戻すを押せない）。
  final bool isDefault;
  final ValueChanged<bool> onToggled;
  final ValueChanged<ControlValue> onValueChanged;
  final VoidCallback onCompareTapped;
  final VoidCallback onDefaultTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    final control = PropertyValueControl(
      control: spec.control,
      value: setting.value,
      enabled: spec.required || setting.on,
      onChanged: onValueChanged,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spec.name, style: theme.textTheme.titleMedium),
                  Text(
                    spec.typeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
            Gap(spacing.xs),
            if (spec.required)
              const _RequiredBadge()
            else
              Semantics(
                label: AppLocalizations.of(context)
                    .detailToggleLabel(spec.name),
                child: Switch(value: setting.on, onChanged: onToggled),
              ),
          ],
        ),
        Gap(spacing.xs),
        Text(
          spec.description,
          style: theme.textTheme.bodySmall?.copyWith(color: secondary),
        ),
        Gap(spacing.md),
        if (spec.control is FixedControl)
          control
        else
          Semantics(
            container: true,
            label: AppLocalizations.of(context).detailValueLabel(spec.name),
            child: control,
          ),
        Gap(spacing.md),
        _Actions(
          isComparing: isComparing,
          comparesUse: comparesUse,
          isDefault: isDefault,
          onCompareTapped: onCompareTapped,
          onDefaultTapped: onDefaultTapped,
        ),
      ],
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

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
      child: Text(
        AppLocalizations.of(context).detailRequired,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isComparing,
    required this.comparesUse,
    required this.isDefault,
    required this.onCompareTapped,
    required this.onDefaultTapped,
  });

  final bool isComparing;
  final bool comparesUse;
  final bool isDefault;
  final VoidCallback onCompareTapped;
  final VoidCallback onDefaultTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const compareIcon = Icon(Icons.swap_vert);
    return Wrap(
      spacing: NimiSpacing.of(context).xs,
      runSpacing: NimiSpacing.of(context).xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 比較中は地を accent にして、押すとやめられることを示す
        if (isComparing)
          FilledButton.icon(
            onPressed: onCompareTapped,
            icon: compareIcon,
            label: Text(l10n.detailCompareStop),
          )
        else
          FilledButton.tonalIcon(
            onPressed: onCompareTapped,
            icon: compareIcon,
            label: Text(
              comparesUse ? l10n.detailCompareUse : l10n.detailCompare,
            ),
          ),
        TextButton.icon(
          onPressed: isDefault ? null : onDefaultTapped,
          icon: const Icon(Icons.replay),
          label: Text(l10n.detailDefault),
        ),
      ],
    );
  }
}
