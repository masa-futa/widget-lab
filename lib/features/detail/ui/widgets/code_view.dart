import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';

/// コードの表示。折り返さずに横へスクロールし、長押しで文字を選べる。
class CodeView extends StatelessWidget {
  const CodeView({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NimiColors.of(context).surfaceMuted,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
      ),
      // 選べる範囲をスクロールの内側に置くと、Android で文字の上の横のドラッグが
      // 選択に取られてスクロールできない（SelectableText も同じ）
      child: SelectionArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(spacing.md),
          child: Text(
            code,
            softWrap: false,
            style: NimiTextStyles.of(context).code
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
