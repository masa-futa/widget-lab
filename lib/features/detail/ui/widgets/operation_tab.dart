import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_row.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 操作タブ。プロパティの行を収録データの順に並べる。
class OperationTab extends ConsumerWidget {
  const OperationTab({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailProvider(entryId));
    final notifier = ref.read(detailProvider(entryId).notifier);
    final properties = state.entry.properties;
    if (properties.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(NimiSpacing.of(context).md),
          child: Text(
            AppLocalizations.of(context).detailNoProperties,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // 行は十数個までなので、全部を組み立てて Column に並べる
    return SingleChildScrollView(
      // タブを行き来してもスクロール位置を残す
      key: const PageStorageKey('operation'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, spec) in properties.indexed) ...[
            if (i > 0) const Divider(height: 1),
            PropertyRow(
              key: ValueKey(spec.name),
              spec: spec,
              setting: state.settings[spec.name] ?? spec.initialSetting,
              isComparing: state.comparing == spec.name,
              onToggled: (on) => notifier.propertyToggled(spec.name, on),
              onValueChanged: (value) =>
                  notifier.propertyValueChanged(spec.name, value),
              onCompareTapped: () => notifier.compareTapped(spec.name),
            ),
          ],
        ],
      ),
    );
  }
}
