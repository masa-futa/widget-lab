import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// build の回数の印（pv-rbld）。ProbeNotifier の自分の回数だけを見る。
/// 数が増えた瞬間だけ地を accent に光らせる（視差効果を減らす設定なら光らない）。
class RebuildBadge extends ConsumerStatefulWidget {
  const RebuildBadge({
    required this.entryId,
    required this.probeKey,
    this.textScaler = TextScaler.noScaling,
    super.key,
  });

  /// 印の地（テストで色を見る）。
  static const boxKey = Key('rebuildBadgeBox');

  final String entryId;
  final ProbeKey probeKey;

  /// アプリの文字の倍率（デモが変えた倍率ではなく）。
  final TextScaler textScaler;

  @override
  ConsumerState<RebuildBadge> createState() => _RebuildBadgeState();
}

class _RebuildBadgeState extends ConsumerState<RebuildBadge> {
  static const _flash = Duration(milliseconds: 200);

  Timer? _timer;

  bool get _flashing => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = probeProvider(widget.entryId)
        .select((s) => s.countOf(widget.probeKey));
    ref.listen(provider, (previous, next) {
      if (next <= (previous ?? 0)) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      _timer?.cancel();
      _timer = Timer(_flash, () {
        if (mounted) setState(() {});
      });
    });
    final count = ref.watch(provider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    return Semantics(
      label: l10n.probeBuildCountSemantics(widget.probeKey.label, count),
      excludeSemantics: true,
      child: Container(
        key: RebuildBadge.boxKey,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xs,
          vertical: spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: _flashing
              ? scheme.primary
              : NimiColors.of(context).surfaceMuted,
          borderRadius: BorderRadius.circular(NimiRadius.of(context).sm),
        ),
        child: Text(
          l10n.probeBuildCount(count),
          textScaler: widget.textScaler,
          style: theme.textTheme.labelSmall?.copyWith(
            color: _flashing ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
