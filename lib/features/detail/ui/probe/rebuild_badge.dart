import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// build の回数の印（pv-rbld）。ProbeNotifier の自分の回数だけを見る。
class RebuildBadge extends ConsumerWidget {
  const RebuildBadge({
    required this.entryId,
    required this.probeKey,
    this.textScaler = TextScaler.noScaling,
    super.key,
  });

  final String entryId;
  final ProbeKey probeKey;

  /// アプリの文字の倍率（デモが変えた倍率ではなく）。
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      probeProvider(entryId).select((s) => s.countOf(probeKey)),
    );
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
        AppLocalizations.of(context).probeBuildCount(count),
        textScaler: textScaler,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
