import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// コードの全文のシート。見出しと凡例・全文・コピーのボタン。
class CodeSheet extends ConsumerWidget {
  const CodeSheet({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(detailCodeProvider(entryId));
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
        Gap(spacing.sm),
        CodeView(lines: lines),
        Gap(spacing.md),
        FilledButton.tonalIcon(
          onPressed: () async {
            final copied = await ref
                .read(detailProvider(entryId).notifier)
                .copyTapped();
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
