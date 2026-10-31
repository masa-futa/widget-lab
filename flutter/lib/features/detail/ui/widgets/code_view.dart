import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

/// コードの全文。行番号を付け、既定から変えた行は accent-container の地と
/// 左の accent の線で示す。折り返さずに横へスクロールし、長押しで文字を選べる。
class CodeView extends StatelessWidget {
  const CodeView({required this.lines, super.key});

  final List<CodeLine> lines;

  /// [number] 行目（1 から）の変えた印（テストで見る）。
  static Key changedKey(int number) => ValueKey('changedLine-$number');

  /// 変えた行の左の線の太さ（帯・凡例も同じ）。
  static const markWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spacing = NimiSpacing.of(context);
    final style = NimiTextStyles.of(context).code
        .copyWith(color: scheme.onSurface);
    // 行番号とコードの列で行の高さを揃える
    final lineHeight = MediaQuery.textScalerOf(context)
        .scale((style.fontSize ?? 14) * (style.height ?? 1));
    Color? background(CodeLine line) =>
        line.changed ? scheme.primaryContainer : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
      child: ColoredBox(
        color: NimiColors.of(context).surfaceMuted,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  for (final (i, line) in lines.indexed)
                    Container(
                      key: line.changed ? changedKey(i + 1) : null,
                      height: lineHeight,
                      padding: EdgeInsets.only(
                        left: spacing.sm,
                        right: spacing.xs,
                      ),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: background(line),
                        border: Border(
                          left: BorderSide(
                            color: line.changed
                                ? scheme.primary
                                : Colors.transparent,
                            width: markWidth,
                          ),
                        ),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: style.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
              Expanded(
                // 選べる範囲をスクロールの内側に置くと、Android で文字の上の横のドラッグが
                // 選択に取られてスクロールできない（SelectableText も同じ）
                child: SelectionArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        // 変えた行の地を、短い行でも右端まで塗る
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final line in lines)
                                Container(
                                  height: lineHeight,
                                  padding: EdgeInsets.only(right: spacing.md),
                                  alignment: Alignment.centerLeft,
                                  color: background(line),
                                  child: Text(
                                    line.text,
                                    softWrap: false,
                                    style: style,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
