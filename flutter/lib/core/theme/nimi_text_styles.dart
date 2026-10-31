import 'package:flutter/material.dart';

/// `TextTheme` に載らない文字のスタイル（docs/design-system.md）。
@immutable
class NimiTextStyles extends ThemeExtension<NimiTextStyles> {
  const NimiTextStyles({required this.caption2, required this.code});

  static const standard = NimiTextStyles(
    caption2: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 14 / 11,
    ),
    // 土台との差分: コードの表示に使う等幅の文字。
    code: TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: ['Menlo', 'Courier'],
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
    ),
  );

  final TextStyle caption2;
  final TextStyle code;

  static NimiTextStyles of(BuildContext context) =>
      Theme.of(context).extension<NimiTextStyles>() ?? standard;

  @override
  NimiTextStyles copyWith({TextStyle? caption2, TextStyle? code}) {
    return NimiTextStyles(
      caption2: caption2 ?? this.caption2,
      code: code ?? this.code,
    );
  }

  @override
  NimiTextStyles lerp(NimiTextStyles? other, double t) {
    if (other == null) return this;
    return NimiTextStyles(
      caption2: TextStyle.lerp(caption2, other.caption2, t) ?? caption2,
      code: TextStyle.lerp(code, other.code, t) ?? code,
    );
  }
}
