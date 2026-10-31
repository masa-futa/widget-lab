import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// コードの帯。選んでいるプロパティのコードの 1 行と「全文 ›」。帯全体が押せる。
class CodeStrip extends StatelessWidget {
  const CodeStrip({
    required this.propertyName,
    required this.line,
    required this.onTap,
    super.key,
  });

  /// 左の変えた印（テストで見る）。
  static const changedKey = Key('codeStripChanged');

  final String propertyName;

  /// 選んでいるプロパティの行。OFF で行がなければ `null`。
  final CodeLine? line;
  final VoidCallback onTap;

  static const _height = 44.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final code = NimiTextStyles.of(context).code;
    final line = this.line;
    return Material(
      color: NimiColors.of(context).surfaceMuted,
      borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _height),
          // 文字を大きくして帯が高くなっても、左の線を帯の高さに合わせる
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 変えた行なら左に accent の線
                Container(
                  key: line?.changed ?? false ? changedKey : null,
                  width: CodeView.markWidth,
                  color: line?.changed ?? false ? scheme.primary : null,
                ),
                Gap(spacing.sm),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      line?.text.trim() ?? l10n.detailCodeUnset(propertyName),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: code.copyWith(
                        color: line == null
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Gap(spacing.xs),
                Center(
                  child: Text(
                    l10n.detailCodeOpen,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: scheme.primary),
                Gap(spacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
