import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/nested_editor.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_value_control.dart';
import 'package:widget_lab/features/detail/ui/widgets/relation_rows.dart';
import 'package:widget_lab/features/detail/view_model/exclusion_notice.dart';
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
    required this.onRelationTapped,
    required this.onNoticeDismissed,
    required this.selectedChild,
    required this.onChildSelected,
    required this.onChildToggled,
    required this.onChildValueChanged,
    this.effective = true,
    this.notice,
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

  /// requires の相手が ON か。
  final bool effective;

  /// 同時に使えない相手を OFF にした知らせ。
  final ExclusionNotice? notice;
  final ValueChanged<String> onRelationTapped;
  final VoidCallback onNoticeDismissed;

  /// 入れ子のプロパティで選んでいる子。
  final String? selectedChild;
  final ValueChanged<String> onChildSelected;
  final void Function(String child, bool on) onChildToggled;
  final void Function(String child, ControlValue value) onChildValueChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    final enabled = spec.required || setting.on;
    final Widget control = switch ((spec.control, setting.value)) {
      (NestedControl(), final NestedValue nested) => NestedEditor(
        spec: spec,
        value: nested,
        selectedChild: selectedChild,
        enabled: enabled,
        onChildSelected: onChildSelected,
        onChildToggled: onChildToggled,
        onChildValueChanged: onChildValueChanged,
      ),
      _ => PropertyValueControl(
        control: spec.control,
        value: setting.value,
        enabled: enabled,
        onChanged: onValueChanged,
      ),
    };
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
        // 入れ子は中のチップとスイッチがそれぞれ読み上げられるので、まとめない
        if (spec.control is FixedControl || spec.control is NestedControl)
          control
        else
          Semantics(
            container: true,
            label: AppLocalizations.of(context).detailValueLabel(spec.name),
            child: control,
          ),
        if (spec.pairsWith.isNotEmpty ||
            spec.requires != null ||
            spec.excludes.isNotEmpty) ...[
          Gap(spacing.xs),
          RelationRows(
            spec: spec,
            effective: effective,
            onTapped: onRelationTapped,
          ),
        ],
        if (notice case final notice? when notice.turnedOn == spec.name) ...[
          Gap(spacing.xs),
          _Notice(notice: notice, onDismissed: onNoticeDismissed),
        ],
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

/// 同時に使えない相手を OFF にした知らせ。3 秒で自分から消える。
class _Notice extends StatefulWidget {
  const _Notice({required this.notice, required this.onDismissed});

  final ExclusionNotice notice;
  final VoidCallback onDismissed;

  @override
  State<_Notice> createState() => _NoticeState();
}

class _NoticeState extends State<_Notice> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(_Notice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notice != widget.notice) _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () => widget.onDismissed());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.all(spacing.xs),
        decoration: BoxDecoration(
          color: NimiColors.of(context).surfaceMuted,
          borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
        ),
        child: Text(
          AppLocalizations.of(context).detailExclusionNotice(
            widget.notice.turnedOn,
            widget.notice.turnedOff,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
