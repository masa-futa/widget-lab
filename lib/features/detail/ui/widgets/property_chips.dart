import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_chip.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';

/// プロパティのチップの列。収録データの順に横に並べ、横にスクロールする。
/// 選んだチップが画面の外なら、見える位置まで送る。
class PropertyChips extends ConsumerStatefulWidget {
  const PropertyChips({required this.entryId, super.key});

  final String entryId;

  @override
  ConsumerState<PropertyChips> createState() => _PropertyChipsState();
}

class _PropertyChipsState extends ConsumerState<PropertyChips> {
  /// チップごとに固定のキー（選択が変わってもチップを作り直さない）。
  final _keys = <String, GlobalKey>{};

  GlobalKey _keyOf(String name) => _keys.putIfAbsent(name, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final provider = detailProvider(widget.entryId);
    ref.listen(provider.select((s) => s.selected), (_, selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = selected == null
            ? null
            : _keys[selected]?.currentContext;
        if (context == null || !context.mounted) return;
        // 見えていても、選んだものを列の中央に寄せる（左右どちらの外にあっても届く）
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
        );
      });
    });
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final spacing = NimiSpacing.of(context);
    if (state.showsReferences) return const SizedBox.shrink();
    // チップは十数個までなので、全部を組み立てて Row に並べる
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Row(
        children: [
          for (final (i, spec) in state.specsInSelectedGroup.indexed) ...[
            if (i > 0) Gap(spacing.xs),
            PropertyChip(
              key: _keyOf(spec.name),
              name: spec.name,
              value: chipValueLabel(spec.control, spec.valueIn(state.settings)),
              on: spec.isOnIn(state.settings),
              selected: spec.name == state.selected,
              dimmed: !state.isEffective(spec.name),
              onTap: () => notifier.propertySelected(spec.name),
            ),
          ],
        ],
      ),
    );
  }
}
