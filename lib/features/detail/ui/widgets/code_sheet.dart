import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// コードの全文のシート。見出しと凡例・使った／使わない（cd-side）・全文・コピーのボタン。
///
/// どちらの側を見ているかは、シートの中だけの一時的な状態なのでここに持つ。
class CodeSheet extends ConsumerStatefulWidget {
  const CodeSheet({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends ConsumerState<CodeSheet> {
  /// 使わない側のコードを見ている。
  bool _without = false;

  @override
  Widget build(BuildContext context) {
    final entryId = widget.entryId;
    final codeWithout = ref.watch(
      detailProvider(entryId).select((s) => s.entry.codeWithout),
    );
    final without = _without && codeWithout != null;
    // 使わない側は収録データの文字列をそのまま出す（変えた行の印は付けない）
    final lines = without
        ? [for (final text in codeWithout.split('\n')) CodeLine(text: text)]
        : ref.watch(detailCodeProvider(entryId));
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
                l10n.detailCodeTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Container(
              width: CodeView.markWidth,
              height: 14,
              color: theme.colorScheme.primary,
            ),
            Gap(spacing.xxs),
            Text(
              l10n.detailCodeLegend,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (codeWithout != null) ...[
          Gap(spacing.sm),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l10n.probeSideUsed)),
              ButtonSegment(value: true, label: Text(l10n.probeSideUnused)),
            ],
            selected: {without},
            onSelectionChanged: (selected) =>
                setState(() => _without = selected.single),
          ),
        ],
        Gap(spacing.sm),
        CodeView(lines: lines),
        Gap(spacing.md),
        FilledButton.tonalIcon(
          onPressed: () async {
            final copied = await ref
                .read(detailProvider(entryId).notifier)
                .copyTapped(without: without);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: copied
                      ? _SucceededMessage(text: l10n.detailCopySucceeded)
                      : Text(l10n.detailCopyFailed),
                ),
              );
          },
          icon: const Icon(Icons.copy),
          label: Text(l10n.detailCopyCode),
        ),
      ],
    );
  }
}

class _SucceededMessage extends StatelessWidget {
  const _SucceededMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        Gap(NimiSpacing.of(context).xs),
        Expanded(child: Text(text)),
      ],
    );
  }
}
