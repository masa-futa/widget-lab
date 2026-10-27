import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// 余白のトークン。`Theme.of(context).extension<AppSpacing>()!` ではなく
/// `AppSpacing.of(context)` で取る。
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.s,
    required this.m,
    required this.l,
    required this.xl,
  });

  static const standard = AppSpacing(xs: 4, s: 8, m: 16, l: 24, xl: 32);

  final double xs;
  final double s;
  final double m;
  final double l;
  final double xl;

  static AppSpacing of(BuildContext context) =>
      Theme.of(context).extension<AppSpacing>() ?? standard;

  @override
  AppSpacing copyWith({
    double? xs,
    double? s,
    double? m,
    double? l,
    double? xl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      s: s ?? this.s,
      m: m ?? this.m,
      l: l ?? this.l,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other == null) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      s: lerpDouble(s, other.s, t) ?? s,
      m: lerpDouble(m, other.m, t) ?? m,
      l: lerpDouble(l, other.l, t) ?? l,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
    );
  }
}
