import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// 土台の余白（docs/design-system.md）。土台の名前との対応:
/// 2xs → xxs、2xl → xxl、3xl → xxxl（Dart の名前は数字で始められないため）。
@immutable
class NimiSpacing extends ThemeExtension<NimiSpacing> {
  const NimiSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  static const standard = NimiSpacing(
    xxs: 4,
    xs: 8,
    sm: 12,
    md: 16,
    lg: 20,
    xl: 24,
    xxl: 32,
    xxxl: 40,
  );

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  static NimiSpacing of(BuildContext context) =>
      Theme.of(context).extension<NimiSpacing>() ?? standard;

  @override
  NimiSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return NimiSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  NimiSpacing lerp(NimiSpacing? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => lerpDouble(a, b, t) ?? a;
    return NimiSpacing(
      xxs: l(xxs, other.xxs),
      xs: l(xs, other.xs),
      sm: l(sm, other.sm),
      md: l(md, other.md),
      lg: l(lg, other.lg),
      xl: l(xl, other.xl),
      xxl: l(xxl, other.xxl),
      xxxl: l(xxxl, other.xxxl),
    );
  }
}
