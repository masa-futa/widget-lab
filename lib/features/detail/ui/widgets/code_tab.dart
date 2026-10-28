import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// コードタブ。今の設定のコードと、コピーのボタン。
class CodeTab extends ConsumerWidget {
  const CodeTab({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(detailCodeProvider(entryId));
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    return SingleChildScrollView(
      // タブを行き来してもスクロール位置を残す
      key: const PageStorageKey('code'),
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CodeView(code: code),
          Gap(spacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonal(
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
              child: Text(l10n.detailCopyCode),
            ),
          ),
        ],
      ),
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
