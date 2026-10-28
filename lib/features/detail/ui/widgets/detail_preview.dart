import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 詳細画面のプレビュー。通常は 1 枚、比較中は「付けた」「付けない」の 2 枚。
class DetailPreview extends ConsumerWidget {
  const DetailPreview({required this.entryId, super.key});

  final String entryId;

  static const _minContentHeight = 200.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailProvider(entryId));
    final entry = state.entry;
    final spec = state.comparingSpec;
    final spacing = NimiSpacing.of(context);
    final Widget content;
    if (spec == null) {
      content = PreviewCard(
        key: const ValueKey('single'),
        child: entry.build(DemoArgs(entry, state.settings)),
      );
    } else {
      content = Column(
        key: const ValueKey('compare'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompareHeader(
            name: spec.name,
            onDismissed: ref
                .read(detailProvider(entryId).notifier)
                .compareDismissed,
          ),
          Expanded(
            child: ComparePreview(
              propertyName: spec.name,
              valueLabel: valueLabel(
                spec.control,
                spec.valueIn(state.settings),
              ),
              withChild: entry.build(
                DemoArgs(entry, state.settingsForSide(on: true)),
              ),
              withoutChild: entry.build(
                DemoArgs(entry, state.settingsForSide(on: false)),
              ),
            ),
          ),
        ],
      );
    }
    // 本体が低くてプレビューの領域が狭いときは、中身をこの高さで組んで切る
    // （比較の見出しと 2 枚のラベルが入らず、はみ出すため）
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: max(constraints.maxHeight, _minContentHeight),
          maxHeight: max(constraints.maxHeight, _minContentHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.xs,
              spacing.md,
              spacing.xs,
            ),
            child: AnimatedSwitcher(
              // 視差効果を減らす設定なら、1 枚 ↔ 2 枚の切り替えは即時
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareHeader extends StatelessWidget {
  const _CompareHeader({required this.name, required this.onDismissed});

  final String name;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.detailComparingTarget(name),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        TextButton(
          onPressed: onDismissed,
          child: Text(l10n.detailCompareDismiss),
        ),
      ],
    );
  }
}
