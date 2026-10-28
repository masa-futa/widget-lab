import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';

/// プレビューのカード。子はカードの大きさの範囲（緩い制約）で中央に組み立てる。
///
/// スクロールで包まないのは、子の高さの上限がなくなり、`CrossAxisAlignment.stretch`
/// やスクロールする Widget が組み立てられなくなるため。はみ出す分は切る。
/// 地は Material にして、子の InkWell などの波紋が地の上に見えるようにする。
class PreviewCard extends StatelessWidget {
  const PreviewCard({required this.child, super.key});

  /// 子の外枠の線（テストで大きさを見る）。
  static const boundsKey = Key('previewBounds');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(NimiRadius.of(context).lg),
      clipBehavior: Clip.antiAlias,
      child: SizedBox.expand(
        child: Center(
          // Padding のように自分では何も描かない Widget でも、大きさの違いが
          // 見えるように外枠に線を引く（design-system の原則1 の例外。ui-spec の pv-card）
          child: DecoratedBox(
            key: boundsKey,
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
