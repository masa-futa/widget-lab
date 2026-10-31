import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';

/// アプリ自体の UI のテーマ。部品は Material 3、値は自社の土台（docs/design-system.md）。
/// 収録する Widget の見た目には手を加えない。
abstract final class AppTheme {
  static ThemeData light() => _build(_lightScheme, NimiColors.light);

  static ThemeData dark() => _build(_darkScheme, NimiColors.dark);

  // 土台の名前 → ColorScheme: canvas → surface、surface → surfaceContainer 系、
  // ink → onSurface、ink-secondary → onSurfaceVariant、accent（瑠璃）→ primary。
  // primaryContainer・secondaryContainer・inverse 系は土台にない差分
  // （docs/design-system.md の「土台との差分」。未指定だと primary に落ちて、
  // スイッチのつまみや選択中の地がトラック・主な操作と同じ色になる）。
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E50A2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE5F4),
    onPrimaryContainer: Color(0xFF18181B),
    secondary: Color(0xFF1E50A2),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDCE5F4),
    onSecondaryContainer: Color(0xFF18181B),
    error: Color(0xFFB8342A),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFEFEFF0),
    onSurface: Color(0xFF18181B),
    onSurfaceVariant: Color(0xFF5E5E64),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHigh: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFE7E7E9),
    outline: Color(0xFF88888E),
    outlineVariant: Color(0xFFDEDEE0),
    inverseSurface: Color(0xFF18181B),
    onInverseSurface: Color(0xFFF3F3F4),
    inversePrimary: Color(0xFF709DE6),
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF709DE6),
    onPrimary: Color(0xFF18181B),
    primaryContainer: Color(0xFF2A3F66),
    onPrimaryContainer: Color(0xFFF3F3F4),
    secondary: Color(0xFF709DE6),
    onSecondary: Color(0xFF18181B),
    secondaryContainer: Color(0xFF2A3F66),
    onSecondaryContainer: Color(0xFFF3F3F4),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF18181B),
    surface: Color(0xFF101012),
    onSurface: Color(0xFFF3F3F4),
    onSurfaceVariant: Color(0xFFA6A6AB),
    surfaceContainerLowest: Color(0xFF1D1D20),
    surfaceContainerLow: Color(0xFF1D1D20),
    surfaceContainer: Color(0xFF1D1D20),
    surfaceContainerHigh: Color(0xFF1D1D20),
    surfaceContainerHighest: Color(0xFF28282C),
    outline: Color(0xFF76767C),
    outlineVariant: Color(0xFF2E2E32),
    inverseSurface: Color(0xFFF3F3F4),
    onInverseSurface: Color(0xFF18181B),
    inversePrimary: Color(0xFF1E50A2),
  );

  // 見出しは Murecho の予定。同梱するかが決まるまではシステムの書体で組む
  // （docs/design-system.md の未決事項）。
  static const _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 44 / 34,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 36 / 28,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 30 / 22,
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
    ),
    titleSmall: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 24 / 17,
    ),
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 24 / 17,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 26 / 17,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 22 / 15,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 18 / 13,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 16 / 12,
    ),
  );

  static ThemeData _build(ColorScheme scheme, NimiColors colors) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme,
      // スクロールしても AppBar の地を canvas のままにする。
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      // 値のない側のトラックを図形の 3:1 に届かせる（surfaceContainerHighest だと 1.23:1）。
      sliderTheme: SliderThemeData(inactiveTrackColor: scheme.outline),
      extensions: [
        colors,
        NimiSpacing.standard,
        NimiRadius.standard,
        NimiTextStyles.standard,
      ],
    );
  }
}
