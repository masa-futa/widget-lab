import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
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
    super.key,
  });

  /// 印の地（テストで色を見る）。
  static const boxKey = Key('rebuildBadgeBox');

  final String entryId;
  final ProbeKey probeKey;

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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    ref.listen(provider, (previous, next) {
      // 最初の組み立て（0 → 1）と、減ったとき（ログを消す）は光らせない
      final before = previous ?? 0;
      if (before == 0 || next <= before || reduceMotion) return;
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
          // デモが変えた倍率ではなく、アプリの倍率で描く
          textScaler: DemoRecorder.textScalerOf(context),
          style: theme.textTheme.labelSmall?.copyWith(
            color: _flashing ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
