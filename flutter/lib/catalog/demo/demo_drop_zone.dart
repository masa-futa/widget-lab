import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_value.dart';

/// Draggable・LongPressDraggable のデモで、落とした値を受け取って出す場所。コードには出さない。
///
/// [draggable] を左に、受け取る場所を右に並べる。
class DemoDropZone extends StatelessWidget {
  const DemoDropZone({required this.draggable, super.key});

  final Widget draggable;

  @override
  Widget build(BuildContext context) => DemoValue<int?>(
    initial: null,
    builder: (context, received, onChanged) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        draggable,
        DragTarget<int>(
          onAcceptWithDetails: (details) => onChanged(details.data),
          builder: (context, candidates, rejected) => DemoDropArea(
            highlighted: candidates.isNotEmpty,
            label: received == null ? 'ここへ落とす' : '受け取った: $received',
          ),
        ),
      ],
    ),
  );
}

/// 落とす先の枠。重ねている間は [highlighted] で色を変える。
class DemoDropArea extends StatelessWidget {
  const DemoDropArea({
    required this.highlighted,
    required this.label,
    this.rejected = false,
    super.key,
  });

  final bool highlighted;
  final bool rejected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 112,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rejected
            ? scheme.errorContainer
            : highlighted
            ? scheme.primaryContainer
            : scheme.surface,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: scheme.onSurface)),
    );
  }
}
