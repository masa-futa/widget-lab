import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/probe/log_text.dart';
import 'package:widget_lab/features/detail/ui/probe/side_tag.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ログのシート（lgs）。見出しと「ログを消す」、新しい順の全件。
/// 開いている間に起きたものもすぐ足す。
class LogSheet extends ConsumerWidget {
  const LogSheet({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = probeProvider(entryId);
    final logs = ref.watch(provider.select((s) => s.logs));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.probeLogTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: ref.read(provider.notifier).logCleared,
              child: Text(l10n.probeLogClear),
            ),
          ],
        ),
        Gap(spacing.xs),
        if (logs.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xl),
            child: Text(
              l10n.probeLogEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final (i, log) in logs.indexed) ...[
            if (i > 0) const Divider(height: 1),
            _LogRow(log: log),
          ],
      ],
    );
  }
}

/// 1 行に時刻・側の札（比較中に起きたものだけ）・文。
class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});

  final ProbeLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Row(
        children: [
          Text(
            logTime(log.time),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Gap(spacing.xs),
          if (log.comparing) ...[
            SideTag(
              text: sideText(l10n, log.side),
              color: NimiColors.of(context).surfaceMuted,
            ),
            Gap(spacing.xs),
          ],
          Expanded(
            child: Text(logText(l10n, log), style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
