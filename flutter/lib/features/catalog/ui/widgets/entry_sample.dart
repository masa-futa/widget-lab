import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';

/// 見本つきの行の見本（ls-item）。その Widget を最初の値で組み立てて縮めたもの。
///
/// 中は押せず、読み上げない。組み立てが例外を出したら空の枠にする
/// （docs/design/functions/demo-engine.md の「見本」）。
class EntrySample extends StatelessWidget {
  const EntrySample({required this.entry, super.key});

  static const size = 64.0;

  /// 縮める前の、組み立てる範囲の上限。広がる Widget（`Container` の
  /// `alignment` など）も、この大きさで組み立ててから縮める。
  static const _canvas = 240.0;

  final WidgetEntry entry;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    final radius = NimiRadius.of(context).md;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: EdgeInsets.all(spacing.xs),
            child: Center(
              // 見本は実物の Widget なので、押す・読み上げに加えて、
              // フォーカスを取ること（autofocus）と動き続けることも止める。
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ExcludeFocus(
                    child: TickerMode(enabled: false, child: _content(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    if (entry.kind == EntryKind.behavior) {
      // 見た目を持たない Widget は組み立てず、どれも同じアイコン（区別は行の名前と説明で）
      return Icon(
        Icons.account_tree_outlined,
        size: 24,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }
    final Widget demo;
    try {
      demo = entry.build(DemoArgs(entry, entry.initialSettings()));
    } on Object {
      // 収録データの不備（DemoArgs の ArgumentError・StateError など）は全件の
      // テストで防ぐ。それでも出たら、見本だけ空の枠にして一覧を守る。
      return const SizedBox.shrink();
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _canvas,
          maxHeight: _canvas,
        ),
        child: demo,
      ),
    );
  }
}
