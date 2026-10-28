import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/app.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
import 'package:widget_lab/features/catalog/ui/genre_screen.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/features/catalog/ui/widgets/genre_card.dart';
import 'package:widget_lab/features/detail/ui/detail_screen.dart';

void main() {
  testWidgets('起動するとホーム画面がアプリ名つきで表示される', (tester) async {
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

  group('ホームから詳細へ', () {
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

    Future<void> tap(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    /// Layout のジャンル画面から Padding の詳細を開く。
    Future<void> openPadding(WidgetTester tester) async {
      await tap(tester, find.widgetWithText(GenreCard, 'Layout'));
      await tap(tester, find.widgetWithText(EntryTile, 'Padding'));
    }

    /// OS の戻る操作（Android の戻る）。
    Future<void> goBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('TC-15: Layout のジャンル画面で「Padding」の行を押すと、題が「Padding」の詳細画面が開く', (
      tester,
    ) async {
      await pumpApp(tester);

      await openPadding(tester);

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Padding'), findsOneWidget);
    });

    testWidgets('詳細から戻るとジャンル画面、もう一度戻るとホーム', (tester) async {
      await pumpApp(tester);
      await openPadding(tester);

      await goBack(tester);
      expect(find.byType(GenreScreen), findsOneWidget);
      expect(find.byType(DetailScreen), findsNothing);

      await goBack(tester);
      expect(find.byType(GenreScreen), findsNothing);
      expect(find.byType(GenreCard), findsWidgets);
    });

    testWidgets('TC-16: 「pad」で探して詳細を開き、戻ると検索と結果の行が残る', (tester) async {
      await pumpApp(tester);
      await search(tester, 'pad');

      await tap(tester, find.widgetWithText(EntryTile, 'Padding'));
      expect(find.byType(DetailScreen), findsOneWidget);
      await goBack(tester);

      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byType(CatalogScreen),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller?.text, 'pad');
      expect(find.byType(GenreCard), findsNothing);
      expect(find.widgetWithText(EntryTile, 'Padding'), findsOneWidget);
    });

    testWidgets('TC-46: 詳細で値を変えて戻り、もう一度開くと最初の値に戻っている', (tester) async {
      await pumpApp(tester);
      await openPadding(tester);
      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(32);
      await tester.pump();
      expect(find.text('32.0'), findsOneWidget);

      await goBack(tester);
      await tap(tester, find.widgetWithText(EntryTile, 'Padding'));

      expect(find.text('16.0'), findsOneWidget);
    });
  });
}
