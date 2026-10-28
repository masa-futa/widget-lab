import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';

/// WCAG 2.x のコントラスト比。
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('TC-56: ライトのテーマが土台の値（アプリの色は瑠璃）になる', () {
    final theme = AppTheme.light();
    final scheme = theme.colorScheme;

    test('ColorScheme', () {
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, const Color(0xFF1E50A2));
      expect(scheme.onPrimary, const Color(0xFFFFFFFF));
      expect(scheme.primaryContainer, const Color(0xFFDCE5F4));
      expect(scheme.onPrimaryContainer, const Color(0xFF18181B));
      expect(scheme.secondary, const Color(0xFF1E50A2));
      expect(scheme.onSecondary, const Color(0xFFFFFFFF));
      expect(scheme.secondaryContainer, const Color(0xFFDCE5F4));
      expect(scheme.onSecondaryContainer, const Color(0xFF18181B));
      expect(scheme.surface, const Color(0xFFEFEFF0));
      expect(scheme.surfaceContainer, const Color(0xFFFFFFFF));
      expect(scheme.surfaceContainerHighest, const Color(0xFFE7E7E9));
      expect(scheme.onSurface, const Color(0xFF18181B));
      expect(scheme.onSurfaceVariant, const Color(0xFF5E5E64));
      expect(scheme.error, const Color(0xFFB8342A));
      expect(scheme.onError, const Color(0xFFFFFFFF));
      expect(scheme.outline, const Color(0xFF88888E));
      expect(scheme.outlineVariant, const Color(0xFFDEDEE0));
      expect(scheme.inverseSurface, const Color(0xFF18181B));
      expect(scheme.onInverseSurface, const Color(0xFFF3F3F4));
      expect(scheme.inversePrimary, const Color(0xFF709DE6));
    });

    test('NimiColors', () {
      final colors = theme.extension<NimiColors>();
      expect(colors?.surfaceMuted, const Color(0xFFE7E7E9));
      expect(colors?.brand, const Color(0xFFF8B500));
      expect(colors?.onBrand, const Color(0xFF18181B));
      expect(colors?.brandText, const Color(0xFF8A6500));
      expect(colors?.success, const Color(0xFF1A7A4C));
      expect(colors?.onSuccess, const Color(0xFFFFFFFF));
      expect(colors?.warning, const Color(0xFFA84B08));
      expect(colors?.onWarning, const Color(0xFFFFFFFF));
    });
  });

  group('TC-57: ダークのテーマが土台の値（アプリの色は瑠璃）になる', () {
    final theme = AppTheme.dark();
    final scheme = theme.colorScheme;

    test('ColorScheme', () {
      expect(scheme.brightness, Brightness.dark);
      expect(scheme.primary, const Color(0xFF709DE6));
      expect(scheme.onPrimary, const Color(0xFF18181B));
      expect(scheme.primaryContainer, const Color(0xFF2A3F66));
      expect(scheme.onPrimaryContainer, const Color(0xFFF3F3F4));
      expect(scheme.secondaryContainer, const Color(0xFF2A3F66));
      expect(scheme.onSecondaryContainer, const Color(0xFFF3F3F4));
      expect(scheme.surface, const Color(0xFF101012));
      expect(scheme.surfaceContainer, const Color(0xFF1D1D20));
      expect(scheme.surfaceContainerHighest, const Color(0xFF28282C));
      expect(scheme.onSurface, const Color(0xFFF3F3F4));
      expect(scheme.onSurfaceVariant, const Color(0xFFA6A6AB));
      expect(scheme.error, const Color(0xFFFF8A80));
      expect(scheme.onError, const Color(0xFF18181B));
      expect(scheme.outline, const Color(0xFF76767C));
      expect(scheme.outlineVariant, const Color(0xFF2E2E32));
      expect(scheme.inverseSurface, const Color(0xFFF3F3F4));
      expect(scheme.onInverseSurface, const Color(0xFF18181B));
      expect(scheme.inversePrimary, const Color(0xFF1E50A2));
    });

    test('NimiColors', () {
      final colors = theme.extension<NimiColors>();
      expect(colors?.surfaceMuted, const Color(0xFF28282C));
      expect(colors?.brand, const Color(0xFFF8B500));
      expect(colors?.brandText, const Color(0xFFF8B500));
      expect(colors?.success, const Color(0xFF4CD69A));
      expect(colors?.onSuccess, const Color(0xFF18181B));
      expect(colors?.warning, const Color(0xFFFF9F5A));
      expect(colors?.onWarning, const Color(0xFF18181B));
    });
  });

  test('TC-58: 文字と背景の組が、ライト・ダークとも 4.5:1 以上になる', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      final s = theme.colorScheme;
      final n = theme.extension<NimiColors>() ?? NimiColors.light;
      final pairs = <String, (Color, Color)>{
        'ink × canvas': (s.onSurface, s.surface),
        'ink × surface': (s.onSurface, s.surfaceContainer),
        'ink × surface-muted': (s.onSurface, n.surfaceMuted),
        'ink-secondary × canvas': (s.onSurfaceVariant, s.surface),
        'ink-secondary × surface': (s.onSurfaceVariant, s.surfaceContainer),
        'ink-secondary × surface-muted': (s.onSurfaceVariant, n.surfaceMuted),
        'on-accent × accent': (s.onPrimary, s.primary),
        'onPrimaryContainer × primaryContainer': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'onSecondaryContainer × secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'onInverseSurface × inverseSurface': (
          s.onInverseSurface,
          s.inverseSurface,
        ),
        'inversePrimary × inverseSurface': (s.inversePrimary, s.inverseSurface),
        'onError × error': (s.onError, s.error),
        'brand-text × surface': (n.brandText, s.surfaceContainer),
        'on-brand × brand': (n.onBrand, n.brand),
        'on-success × success': (n.onSuccess, n.success),
        'on-warning × warning': (n.onWarning, n.warning),
      };
      pairs.forEach((name, pair) {
        expect(
          contrast(pair.$1, pair.$2),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.brightness.name}: $name',
        );
      });
      // 図形（部品の境界・スライダーのトラック）は 3:1。
      expect(contrast(s.outline, s.surfaceContainer), greaterThanOrEqualTo(3));
    }
  });

  test('TC-59: 余白・角丸・文字が土台の段階とサイズになる', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(theme.extension<NimiSpacing>(), NimiSpacing.standard);
      expect(theme.extension<NimiRadius>(), NimiRadius.standard);
      expect(theme.extension<NimiTextStyles>(), NimiTextStyles.standard);
    }
    const s = NimiSpacing.standard;
    expect(
      [s.xxs, s.xs, s.sm, s.md, s.lg, s.xl, s.xxl, s.xxxl],
      [4, 8, 12, 16, 20, 24, 32, 40],
    );
    const r = NimiRadius.standard;
    expect([r.sm, r.md, r.lg, r.full], [8, 12, 20, 9999]);

    final text = AppTheme.light().textTheme;
    void check(TextStyle? style, double size, FontWeight weight, double line) {
      expect(style?.fontSize, size);
      expect(style?.fontWeight, weight);
      expect(style?.height, closeTo(line / size, 0.0001));
    }

    check(text.displaySmall, 34, FontWeight.w700, 44);
    check(text.headlineMedium, 28, FontWeight.w700, 36);
    check(text.titleLarge, 22, FontWeight.w700, 30);
    check(text.titleMedium, 20, FontWeight.w600, 28);
    check(text.titleSmall, 17, FontWeight.w600, 24);
    check(text.labelLarge, 17, FontWeight.w600, 24);
    check(text.bodyLarge, 17, FontWeight.w400, 26);
    check(text.bodyMedium, 16, FontWeight.w400, 24);
    check(text.bodySmall, 15, FontWeight.w400, 22);
    check(text.labelMedium, 13, FontWeight.w400, 18);
    check(text.labelSmall, 12, FontWeight.w400, 16);

    const styles = NimiTextStyles.standard;
    check(styles.caption2, 11, FontWeight.w400, 14);
    check(styles.code, 14, FontWeight.w400, 20);
    expect(styles.code.fontFamily, 'monospace');
    expect(styles.code.fontFamilyFallback, contains('Menlo'));
  });

  group('TC-60: ライトとダークを切り替えても値が崩れない', () {
    test('NimiColors の lerp は端で両端の値、中間で中間の色になる', () {
      const a = NimiColors.light;
      const b = NimiColors.dark;
      expect(a.lerp(b, 0).surfaceMuted, a.surfaceMuted);
      expect(a.lerp(b, 1).surfaceMuted, b.surfaceMuted);
      expect(
        a.lerp(b, 0.5).surfaceMuted,
        Color.lerp(a.surfaceMuted, b.surfaceMuted, 0.5),
      );
      expect(a.lerp(null, 0.5), same(a));
    });

    test('余白・角丸・文字の lerp と copyWith', () {
      const s = NimiSpacing.standard;
      expect(s.lerp(s.copyWith(md: 32), 0.5).md, 24);
      expect(s.copyWith().xxxl, s.xxxl);
      const r = NimiRadius.standard;
      expect(r.lerp(r.copyWith(lg: 40), 0.5).lg, 30);
      const t = NimiTextStyles.standard;
      expect(t.lerp(t.copyWith(), 0.5).code.fontSize, 14);
      expect(NimiColors.light.copyWith().brand, NimiColors.light.brand);
    });

    test('ThemeData.lerp がライトからダークまで例外を出さない', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      for (final t in [0.0, 0.5, 1.0]) {
        final theme = ThemeData.lerp(light, dark, t);
        expect(theme.extension<NimiColors>(), isNotNull);
      }
    });
  });

  testWidgets('TC-56: 画面の地は canvas、AppBar はスクロールしても canvas のまま', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(appBar: AppBar(title: const Text('題'))),
      ),
    );
    final scaffold = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(Scaffold),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(scaffold.color, const Color(0xFFEFEFF0));
    final theme = AppTheme.light();
    expect(theme.appBarTheme.backgroundColor, const Color(0xFFEFEFF0));
    expect(theme.appBarTheme.scrolledUnderElevation, 0);
  });

  test('TC-58: スライダーの値のない側のトラックは outline', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(theme.sliderTheme.inactiveTrackColor, theme.colorScheme.outline);
    }
  });
}
