import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// 土台の角丸（docs/design-system.md）。
@immutable
class NimiRadius extends ThemeExtension<NimiRadius> {
  const NimiRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.full,
  });

  static const standard = NimiRadius(sm: 8, md: 12, lg: 20, full: 9999);

  final double sm;
  final double md;
  final double lg;
  final double full;

  static NimiRadius of(BuildContext context) =>
      Theme.of(context).extension<NimiRadius>() ?? standard;

  @override
  NimiRadius copyWith({double? sm, double? md, double? lg, double? full}) {
    return NimiRadius(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      full: full ?? this.full,
    );
  }

  @override
  NimiRadius lerp(NimiRadius? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => lerpDouble(a, b, t) ?? a;
    return NimiRadius(
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      full: l(full, other.full),
    );
  }
}
