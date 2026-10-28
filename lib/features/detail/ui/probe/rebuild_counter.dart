import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/probe/demo_probe.dart';
import 'package:widget_lab/features/detail/ui/probe/rebuild_badge.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

/// デモの木で build の回数を数える子（pv-tree の 1 つの枠）。
///
/// 自分の build のたびに記録してから [builder] を呼ぶ。[builder] はこの Widget の context で
/// `MediaQuery.of` などを読むので、依存がここに付き、「誰が組み直されたか」がそのまま数になる。
/// 枠・名前の札・回数の印は別の Widget にして、印が書き変わってもここは組み直さない。
class RebuildCounter extends StatelessWidget {
  const RebuildCounter({required this.label, required this.builder, super.key});

  /// 名前の札とログに出す名前（例:「倍率を読む子」）。
  final String label;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final probe = DemoProbe.of(context)..recordBuild(label);
    return _CounterFrame(label: label, probe: probe, child: builder(context));
  }
}

/// 子の枠と名前の札、右上（狭ければ名前の下）に回数の印。
class _CounterFrame extends StatelessWidget {
  const _CounterFrame({
    required this.label,
    required this.probe,
    required this.child,
  });

  /// これより狭いと、回数の印を名前の下に置く。
  static const _narrow = 200.0;

  final String label;
  final DemoProbeHandle probe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    final entryId = probe.entryId;
    final name = Text(
      label,
      textScaler: probe.appTextScaler,
      style: theme.textTheme.bodyMedium,
    );
    final badge = entryId == null
        ? null
        : RebuildBadge(
            entryId: entryId,
            probeKey: ProbeKey(probe.side, label),
            textScaler: probe.appTextScaler,
          );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _narrow) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                name,
                child,
                if (badge != null) ...[Gap(spacing.xxs), badge],
              ],
            );
          }
          return Row(
            children: [
              name,
              Gap(spacing.xs),
              Expanded(child: child),
              ?badge,
            ],
          );
        },
      ),
    );
  }
}
