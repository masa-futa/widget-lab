import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/app.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
import 'package:widget_lab/features/detail/ui/detail_screen.dart';

void main() {
  testWidgets('起動すると一覧画面がアプリ名つきで表示される', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WidgetLabApp()));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.text('Widget Lab'), findsOneWidget);
  });

  testWidgets('ライトとダークの両方のテーマが土台の色の拡張を持つ', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WidgetLabApp()));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.theme?.extension<NimiColors>(), NimiColors.light);
    expect(app.darkTheme?.extension<NimiColors>(), NimiColors.dark);
  });

  group('一覧から詳細へ', () {
    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: WidgetLabApp()));
      await tester.pumpAndSettle();
    }

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(
        find.descendant(
          of: find.byType(CatalogScreen),
          matching: find.byType(TextField),
        ),
        text,
      );
      await tester.pumpAndSettle();
    }

    Future<void> openPadding(WidgetTester tester) async {
      final row = find.widgetWithText(ListTile, 'Padding').first;
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
    }

    /// OS の戻る操作（Android の戻る）。
    Future<void> goBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('TC-15: 「Padding」の行を押すと、題が「Padding」の詳細画面が開く', (tester) async {
      await pumpApp(tester);

      await openPadding(tester);

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Padding'), findsOneWidget);
    });

    testWidgets('TC-16: 「pad」で絞って詳細を開き、戻ると検索と絞った結果が残る', (tester) async {
      await pumpApp(tester);
      await search(tester, 'pad');

      await openPadding(tester);
      await goBack(tester);

      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(CatalogScreen),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller?.text, 'pad');
      expect(find.widgetWithText(ListTile, 'Container'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Padding'), findsWidgets);
    });

    testWidgets('TC-46: 詳細で値を変えて戻り、もう一度開くと最初の値に戻っている', (tester) async {
      await pumpApp(tester);
      await openPadding(tester);
      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(32);
      await tester.pump();
      expect(find.text('32.0'), findsOneWidget);

      await goBack(tester);
      await openPadding(tester);

      expect(find.text('16.0'), findsOneWidget);
    });
  });
}
