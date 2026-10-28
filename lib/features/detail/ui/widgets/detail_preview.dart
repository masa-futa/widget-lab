import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
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
    final spec = state.comparingSpec;
    final spacing = NimiSpacing.of(context);
    final scale = _zoomed ? 2.0 : 1.0;
    final Widget content;
    if (spec == null) {
      content = PreviewCard(
        key: const ValueKey('single'),
        scale: scale,
        child: entry.build(DemoArgs(entry, state.settings)),
      );
    } else {
      content = ComparePreview(
        key: const ValueKey('compare'),
        propertyName: spec.name,
        valueLabel: valueLabel(spec.control, spec.valueIn(state.settings)),
        scale: scale,
        withChild: entry.build(
          DemoArgs(entry, state.settingsForSide(on: true)),
        ),
        withoutChild: entry.build(
          DemoArgs(entry, state.settingsForSide(on: false)),
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
        if (spec == null)
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
