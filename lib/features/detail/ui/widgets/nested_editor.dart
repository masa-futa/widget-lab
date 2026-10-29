import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_chip.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_value_control.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 入れ子のプロパティの中身。子のチップの列と、選んだ子の ON/OFF・説明・値の操作。
/// 親が OFF なら子は効かないので、子の操作を押せなくする。
class NestedEditor extends StatelessWidget {
  const NestedEditor({
    required this.spec,
    required this.value,
    required this.selectedChild,
    required this.enabled,
    required this.onChildSelected,
    required this.onChildToggled,
    required this.onChildValueChanged,
    super.key,
  });

  final PropertySpec spec;
  final NestedValue value;
  final String? selectedChild;
  final bool enabled;
  final ValueChanged<String> onChildSelected;
  final void Function(String child, bool on) onChildToggled;
  final void Function(String child, ControlValue value) onChildValueChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    final child = spec.children
        .where((c) => c.name == selectedChild)
        .firstOrNull;
    final childSetting = child == null ? null : value.settings[child.name];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.detailNestedLabel,
          style: theme.textTheme.labelMedium?.copyWith(color: secondary),
        ),
        Gap(spacing.xxs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (i, c) in spec.children.indexed) ...[
                if (i > 0) Gap(spacing.xs),
                PropertyChip(
                  name: c.name,
                  value: chipValueLabel(c.control, c.valueIn(value.settings)),
                  on: c.isOnIn(value.settings),
                  selected: c.name == selectedChild,
                  onTap: () => onChildSelected(c.name),
                ),
              ],
            ],
          ),
        ),
        if (child != null && childSetting != null) ...[
          Gap(spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  child.description,
                  style: theme.textTheme.bodySmall?.copyWith(color: secondary),
                ),
              ),
              Semantics(
                label: l10n.detailToggleLabel(child.name),
                child: Switch(
                  value: childSetting.on,
                  onChanged: enabled
                      ? (on) => onChildToggled(child.name, on)
                      : null,
                ),
              ),
            ],
          ),
          Gap(spacing.xs),
          PropertyValueControl(
            control: child.control,
            value: childSetting.value,
            enabled: enabled && childSetting.on,
            onChanged: (v) => onChildValueChanged(child.name, v),
          ),
        ],
      ],
    );
  }
}
