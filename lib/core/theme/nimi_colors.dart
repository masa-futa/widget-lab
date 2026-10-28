import 'package:flutter/material.dart';

/// 土台の色のうち、`ColorScheme` に載らないもの（docs/design-system.md）。
@immutable
class NimiColors extends ThemeExtension<NimiColors> {
  const NimiColors({
    required this.surfaceMuted,
    required this.brand,
    required this.onBrand,
    required this.brandText,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  static const light = NimiColors(
    surfaceMuted: Color(0xFFE7E7E9),
    brand: Color(0xFFF8B500),
    onBrand: Color(0xFF18181B),
    brandText: Color(0xFF8A6500),
    success: Color(0xFF1A7A4C),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFA84B08),
    onWarning: Color(0xFFFFFFFF),
  );

  static const dark = NimiColors(
    surfaceMuted: Color(0xFF28282C),
    brand: Color(0xFFF8B500),
    onBrand: Color(0xFF18181B),
    brandText: Color(0xFFF8B500),
    success: Color(0xFF4CD69A),
    onSuccess: Color(0xFF18181B),
    warning: Color(0xFFFF9F5A),
    onWarning: Color(0xFF18181B),
  );

  final Color surfaceMuted;
  final Color brand;
  final Color onBrand;
  final Color brandText;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  static NimiColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<NimiColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  NimiColors copyWith({
    Color? surfaceMuted,
    Color? brand,
    Color? onBrand,
    Color? brandText,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) {
    return NimiColors(
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      brandText: brandText ?? this.brandText,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  NimiColors lerp(NimiColors? other, double t) {
    if (other == null) return this;
    return NimiColors(
      surfaceMuted:
          Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      onBrand: Color.lerp(onBrand, other.onBrand, t) ?? onBrand,
      brandText: Color.lerp(brandText, other.brandText, t) ?? brandText,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
    );
  }
}
