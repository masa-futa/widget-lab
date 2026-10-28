import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/probe/demo_probe.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/features/detail/view_model/comparing.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 詳細画面のプレビュー。通常は 1 枚、比較中は左右に分けた 2 枚。拡大のピルで ×1 / ×2。
///
/// 拡大は画面の中だけの一時的な状態なので、ここに持つ。
class DetailPreview extends ConsumerStatefulWidget {
  const DetailPreview({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<DetailPreview> createState() => _DetailPreviewState();
}

class _DetailPreviewState extends ConsumerState<DetailPreview> {
  bool _zoomed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(detailProvider(widget.entryId));
    final entry = state.entry;
    final comparing = state.comparing;
    // 計測をやり直したら（比較の開始・終了・初期状態に戻す）、デモの木を組み直す
    final epoch = entry.kind == EntryKind.behavior
        ? ref.watch(probeProvider(entry.id).select((s) => s.epoch))
        : 0;
    final spacing = NimiSpacing.of(context);
    final l10n = AppLocalizations.of(context);
    final scale = _zoomed ? 2.0 : 1.0;
    final Widget content;
    switch (comparing) {
      case null:
        content = PreviewCard(
          key: const ValueKey('single'),
          scale: scale,
          child: _probed(
            entry,
            DemoSide.used,
            entry.build(DemoArgs(entry, state.settings)),
            epoch: epoch,
          ),
        );
      case ComparingProperty():
        final spec = state.comparingSpec!;
        content = ComparePreview(
          key: const ValueKey('compare'),
          withLabel: l10n.detailCompareWith,
          withoutLabel: l10n.detailCompareWithout,
          withSemanticsLabel: l10n.detailCompareWithSemantics(
            spec.name,
            valueLabel(spec.control, spec.valueIn(state.settings)),
          ),
          scale: scale,
          withChild: entry.build(
            DemoArgs(entry, state.settingsForSide(on: true)),
          ),
          withoutChild: entry.build(
            DemoArgs(entry, state.settingsForSide(on: false)),
          ),
        );
      case ComparingUse():
        // 設定は 2 枚とも同じ。左は収録データの build、右は buildWithout
        final args = DemoArgs(entry, state.settings);
        final buildWithout = entry.buildWithout ?? entry.build;
        content = ComparePreview(
          key: const ValueKey('compareUse'),
          withLabel: l10n.probeSideUsed,
          withoutLabel: l10n.probeSideUnused,
          withSemanticsLabel: l10n.probeSideUsed,
          scale: scale,
          fitToSide: true,
          withChild: _probed(
            entry,
            DemoSide.used,
            entry.build(args),
            comparing: true,
            epoch: epoch,
          ),
          withoutChild: _probed(
            entry,
            DemoSide.unused,
            buildWithout(args),
            comparing: true,
            epoch: epoch,
          ),
        );
    }
    final zoom = _ZoomPill(
      zoomed: _zoomed,
      onTap: () => setState(() => _zoomed = !_zoomed),
    );
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            // 視差効果を減らす設定なら、1 枚 ↔ 左右の切り替えは即時
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            child: content,
          ),
        ),
        // 比較中は上の角に「付けた」「付けない」があるので、右下に置く
        if (comparing == null)
          PositionedDirectional(top: spacing.xs, end: spacing.xs, child: zoom)
        else
          PositionedDirectional(
            bottom: spacing.xs,
            end: spacing.xs,
            child: zoom,
          ),
      ],
    );
  }
}

/// 見た目を持たない Widget なら、[side] の DemoProbe で包んで build の回数とログを集める。
Widget _probed(
  WidgetEntry entry,
  DemoSide side,
  Widget child, {
  required int epoch,
  bool comparing = false,
}) => switch (entry.kind) {
  EntryKind.visual => child,
  EntryKind.behavior => DemoProbe(
    key: ValueKey(epoch),
    entryId: entry.id,
    side: side,
    comparing: comparing,
    child: child,
  ),
};

class _ZoomPill extends StatelessWidget {
  const _ZoomPill({required this.zoomed, required this.onTap});

  final bool zoomed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Semantics(
      button: true,
      label: zoomed ? l10n.detailZoom2Semantics : l10n.detailZoom1Semantics,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          // 押せる範囲は 48、見た目は小さいピル
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              // 波紋がピルの上に見えるように Ink で描く
              child: Ink(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: NimiColors.of(context).surfaceMuted,
                  borderRadius: BorderRadius.circular(
                    NimiRadius.of(context).full,
                  ),
                ),
                child: Text(
                  zoomed ? l10n.detailZoom2 : l10n.detailZoom1,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
