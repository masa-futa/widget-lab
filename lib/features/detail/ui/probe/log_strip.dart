import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/probe/log_text.dart';
import 'package:widget_lab/features/detail/ui/probe/side_tag.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ログの帯（lg）。最新の 1 件と件数。帯全体が押せる（ログのシートを開く）。
class LogStrip extends ConsumerWidget {
  const LogStrip({required this.entryId, required this.onTap, super.key});

  static const height = 44.0;

  final String entryId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(probeProvider(entryId).select((s) => s.logs));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final latest = logs.firstOrNull;
    final latestText = latest == null
        ? l10n.probeLogEmpty
        : logText(l10n, latest);
    return Semantics(
      button: true,
      label: l10n.probeLogSemantics(logs.length, latestText),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: NimiColors.of(context).surfaceMuted,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: height),
            child: Row(
              children: [
                Gap(spacing.sm),
                if (latest != null && latest.comparing) ...[
                  SideTag(
                    text: sideText(l10n, latest.side),
                    color: scheme.surface,
                  ),
                  Gap(spacing.xs),
                ],
                Expanded(
                  child: Text(
                    latestText,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: latest == null
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                    ),
                  ),
                ),
                Gap(spacing.xs),
                Text(
                  l10n.probeLogCount(logs.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: scheme.primary),
                Gap(spacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
