import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 編集パネルの関係の行（組で使う・ON のときだけ効く・同時に使えない）。
/// 相手の名前を押すと、相手のタブとチップに移る。
class RelationRows extends StatelessWidget {
  const RelationRows({
    required this.spec,
    required this.effective,
    required this.onTapped,
    super.key,
  });

  final PropertySpec spec;

  /// requires の相手が ON か（OFF なら「今は OFF」を足す）。
  final bool effective;
  final ValueChanged<String> onTapped;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final requires = spec.requires;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final other in spec.pairsWith)
          _Row(
            icon: Icons.sync_alt,
            other: other,
            text: l10n.detailRelationPairs,
            onTapped: onTapped,
          ),
        if (requires != null)
          _Row(
            icon: Icons.warning_amber,
            other: requires,
            text: effective
                ? l10n.detailRelationRequires
                : '${l10n.detailRelationRequires}'
                      '${l10n.detailRelationRequiresOff}',
            onTapped: onTapped,
          ),
        for (final other in spec.excludes)
          _Row(
            icon: Icons.block,
            other: other,
            text: l10n.detailRelationExcludes,
            onTapped: onTapped,
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.other,
    required this.text,
    required this.onTapped,
  });

  final IconData icon;
  final String other;
  final String text;
  final ValueChanged<String> onTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: secondary),
        TextButton(onPressed: () => onTapped(other), child: Text(other)),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
          ),
        ),
      ],
    );
  }
}
