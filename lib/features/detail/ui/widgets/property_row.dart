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

/// 操作パネルの1行。名前・型・説明・ON/OFF・比べる・値の操作。
class PropertyRow extends StatelessWidget {
  const PropertyRow({
    required this.spec,
    required this.setting,
    required this.isComparing,
    required this.onToggled,
    required this.onValueChanged,
    required this.onCompareTapped,
    super.key,
  });

  final PropertySpec spec;
  final PropertySetting setting;
  final bool isComparing;
  final ValueChanged<bool> onToggled;
  final ValueChanged<ControlValue> onValueChanged;
  final VoidCallback onCompareTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spec.name, style: theme.textTheme.titleSmall),
                    Text(
                      spec.typeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: secondary,
                      ),
                    ),
                    Text(
                      spec.description,
                      style: theme.textTheme.bodySmall?.copyWith(
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
                _ToggleSwitch(
                  name: spec.name,
                  on: setting.on,
                  onToggled: onToggled,
                ),
              _CompareButton(
                isComparing: isComparing,
                onPressed: onCompareTapped,
              ),
            ],
          ),
          if (spec.control is! FixedControl) ...[
            Gap(spacing.xs),
            Semantics(
              container: true,
              label: AppLocalizations.of(context).detailValueLabel(spec.name),
              child: PropertyValueControl(
                control: spec.control,
                value: setting.value,
                enabled: spec.required || setting.on,
                onChanged: onValueChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({
    required this.name,
    required this.on,
    required this.onToggled,
  });

  final String name;
  final bool on;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).detailToggleLabel(name),
      child: Switch(value: on, onChanged: onToggled),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        style: theme.textTheme.labelMedium,
      ),
    );
  }
}

class _CompareButton extends StatelessWidget {
  const _CompareButton({required this.isComparing, required this.onPressed});

  final bool isComparing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: isComparing ? l10n.detailComparing : null,
      excludeSemantics: isComparing,
      selected: isComparing,
      button: true,
      onTap: isComparing ? onPressed : null,
      child: IconButton(
        tooltip: l10n.detailCompare,
        isSelected: isComparing,
        icon: const Icon(Icons.swap_vert),
        style: isComparing
            ? IconButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              )
            : null,
        onPressed: onPressed,
      ),
    );
  }
}
