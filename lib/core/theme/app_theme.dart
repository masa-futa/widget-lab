import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/app_spacing.dart';

/// アプリ自体の UI のテーマ（Material 3）。収録する Widget の見た目には手を加えない。
abstract final class AppTheme {
  static const _seedColor = Color(0xFF0175C2);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      extensions: const [AppSpacing.standard],
    );
  }
}
