import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
import 'package:widget_lab/features/catalog/ui/genre_screen.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/features/catalog/ui/widgets/genre_card.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../fake_catalog_repository.dart';

/// 全ジャンルに 3 件ずつ（Async だけ 0 件、Basics は 4 件）と、名前に pad を含む 2 件。
final _repository = FakeCatalogRepository(
  genreList: allGenres,
  entryList: [
    for (final genre in allGenres)
      if (genre.id != 'async')
        for (var i = 1; i <= 3; i++)
          fakeEntry('${genre.id}Widget$i', [genre.id]),
    fakeEntry('basicsWidget4', ['basics']),
    fakeEntry('SliverPadding', ['layout', 'scrolling']),
    fakeEntry('Padding', ['layout', 'styling']),
  ],
);

Future<void> _pumpCatalog(
  WidgetTester tester, {
  void Function(BuildContext context, String entryId)? onEntryTapped,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [catalogRepositoryProvider.overrideWithValue(_repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CatalogScreen(onEntryTapped: onEntryTapped ?? (_, _) {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

/// 出ているタイルのジャンル名（上から下、左から右）。
List<String> _tileNames(WidgetTester tester) => [
  for (final card in tester.widgetList<GenreCard>(find.byType(GenreCard)))
    card.tile.genre.name,
];

/// 出ている結果の行の Widget 名（上から順）。
List<String> _rowNames(WidgetTester tester) => [
  for (final row in tester.widgetList<EntryTile>(find.byType(EntryTile)))
    row.entry.name,
];

Finder _card(String genreName) => find.widgetWithText(GenreCard, genreName);

final _clearButton = find.byTooltip('検索を消す');

/// 本文の縦にスクロールする部分。
final _body = find.byType(Scrollable).last;

void main() {
  testWidgets('TC-01: 収録のあるジャンルのタイルが、2 つの段に分かれて公式の順で出る', (tester) async {
    await _pumpCatalog(tester);

    expect(find.text('デザインシステム'), findsOneWidget);
    expect(find.text('基本の Widget'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('デザインシステム')).dy,
      lessThan(tester.getTopLeft(find.text('基本の Widget')).dy),
    );
    expect(_tileNames(tester), [
      for (final genre in allGenres)
        if (genre.id != 'async') genre.name,
    ]);
  });

  testWidgets('TC-01: タイルは 2 列で、同じ行のタイルは高さがそろう', (tester) async {
    await _pumpCatalog(tester);

    final cupertino = tester.getRect(_card('Cupertino'));
    final material = tester.getRect(_card('Material design'));
    expect(material.top, cupertino.top);
    expect(material.left, greaterThan(cupertino.right));
    expect(material.height, cupertino.height);

    // 長い名前（折り返す）と短い名前が同じ行に並ぶ。
    final animation = tester.getRect(_card('Animation and motion'));
    final accessibility = tester.getRect(_card('Accessibility'));
    expect(animation.top, accessibility.top);
    expect(animation.height, accessibility.height);
  });

  testWidgets('TC-02: タイルに件数と、収録の順の最初の 3 件の名前が出る', (tester) async {
    await _pumpCatalog(tester);

    final basics = _card('Basics');
    expect(find.descendant(of: basics, matching: find.text('4')), findsOne);
    expect(find.descendant(of: basics, matching: find.text('件')), findsOne);
    expect(
      find.descendant(
        of: basics,
        matching: find.text('basicsWidget1・basicsWidget2・basicsWidget3…'),
      ),
      findsOne,
    );
    // 3 件ちょうどなら「…」を付けない。
    expect(
      find.descendant(
        of: _card('Cupertino'),
        matching: find.text(
          'cupertinoWidget1・cupertinoWidget2・cupertinoWidget3',
        ),
      ),
      findsOne,
    );
  });

  testWidgets('TC-10: 検索すると、タイルの代わりに見本つきの行が名前の ABC 順で出る', (tester) async {
    await _pumpCatalog(tester);

    await _search(tester, 'pad');

    expect(find.byType(GenreCard), findsNothing);
    expect(find.text('基本の Widget'), findsNothing);
    expect(_rowNames(tester), ['Padding', 'SliverPadding']);
    expect(
      find.descendant(
        of: find.widgetWithText(EntryTile, 'Padding'),
        matching: find.text('Layout・Styling'),
      ),
      findsOne,
    );
  });

  testWidgets('TC-11: 消すボタンでタイルに戻り、消すボタンが消える', (tester) async {
    await _pumpCatalog(tester);
    expect(_clearButton, findsNothing);

    await _search(tester, 'pad');
    expect(_clearButton, findsOneWidget);

    await tester.tap(_clearButton);
    await tester.pumpAndSettle();

    expect(find.byType(GenreCard), findsWidgets);
    expect(find.byType(EntryTile), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(_clearButton, findsNothing);
  });

  testWidgets('TC-12: 一致が 0 件なら空状態と「検索を消す」が出て、タイルは出ない', (tester) async {
    await _pumpCatalog(tester);

    await _search(tester, 'zzzz');

    expect(find.text('「zzzz」に一致する Widget はありません'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '検索を消す'), findsOneWidget);
    expect(find.byType(GenreCard), findsNothing);
    expect(find.byType(EntryTile), findsNothing);
  });

  testWidgets('TC-13: 空状態の「検索を消す」でタイルに戻る', (tester) async {
    await _pumpCatalog(tester);
    await _search(tester, 'zzzz');

    await tester.tap(find.widgetWithText(TextButton, '検索を消す'));
    await tester.pumpAndSettle();

    expect(find.byType(GenreCard), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(find.text('「zzzz」に一致する Widget はありません'), findsNothing);
  });

  testWidgets('TC-14: 「Basics」のタイルを押すと、Basics のジャンル画面が開く', (tester) async {
    await _pumpCatalog(tester);

    await tester.tap(_card('Basics'));
    await tester.pumpAndSettle();

    expect(find.byType(GenreScreen), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Basics'), findsOneWidget);
  });

  testWidgets('TC-15: ジャンル画面の行を押すと、その Widget の ID を知らせる', (tester) async {
    String? tapped;
    await _pumpCatalog(tester, onEntryTapped: (_, entryId) => tapped = entryId);
    await tester.ensureVisible(_card('Layout'));
    await tester.tap(_card('Layout'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(EntryTile, 'Padding'));

    expect(tapped, 'padding');
  });

  testWidgets('TC-15: 検索の結果の行を押すと、その Widget の ID を知らせる', (tester) async {
    String? tapped;
    await _pumpCatalog(tester, onEntryTapped: (_, entryId) => tapped = entryId);
    await _search(tester, 'pad');

    await tester.tap(find.widgetWithText(EntryTile, 'SliverPadding'));

    expect(tapped, 'sliverpadding');
  });

  testWidgets('入力を変えると、本文の先頭に戻る', (tester) async {
    await _pumpCatalog(tester);
    await _search(tester, 'Widget');
    await tester.drag(_body, const Offset(0, -1500));
    await tester.pumpAndSettle();
    final firstRow = find.widgetWithText(EntryTile, 'accessibilityWidget1');
    expect(firstRow, findsNothing);

    await _search(tester, 'Widget1');

    expect(tester.getTopLeft(firstRow).dy, tester.getTopLeft(_body).dy);
  });

  testWidgets('消すボタンを押しても、キーボードを閉じない', (tester) async {
    await _pumpCatalog(tester);
    await tester.showKeyboard(find.byType(TextField));
    await _search(tester, 'pad');

    await tester.tap(_clearButton);
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('検索欄は最大 50 文字で、自動修正と予測変換を使わない英字のキーボード', (tester) async {
    await _pumpCatalog(tester);

    await _search(tester, 'a' * 51);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'a' * 50);
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
    expect(field.keyboardType, TextInputType.text);
    expect(field.textCapitalization, TextCapitalization.none);
  });

  testWidgets('検索欄は地が surface で角丸 md', (tester) async {
    await _pumpCatalog(tester);
    final scheme = AppTheme.light().colorScheme;

    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration;
    expect(decoration?.fillColor, scheme.surfaceContainer);
    expect(
      (decoration?.border as OutlineInputBorder?)?.borderRadius,
      BorderRadius.circular(NimiRadius.standard.md),
    );
  });

  testWidgets('広い画面では、本文を幅 640 にして中央に置き、タイルは 2 列のまま', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpCatalog(tester);

    final rect = tester.getRect(_body);
    expect(rect.width, 640);
    expect(rect.center.dx, 600);
    expect(
      tester.getTopLeft(_card('Material design')).dy,
      tester.getTopLeft(_card('Cupertino')).dy,
    );
  });

  testWidgets('文字を 2 倍にしてキーボードを出しても、小さい画面で崩れない', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpCatalog(tester);
    expect(tester.takeException(), isNull);

    await _search(tester, 'pad');
    expect(tester.takeException(), isNull);
  });

  testWidgets('題は左に寄せる（Figma の案B）', (tester) async {
    await _pumpCatalog(tester);

    expect(tester.widget<AppBar>(find.byType(AppBar)).centerTitle, isFalse);
  });

  testWidgets('タイルの最後の行が、ホームインジケーターの下に隠れない', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.reset);
    await _pumpCatalog(tester);

    await tester.drag(_body, const Offset(0, -3000));
    await tester.pumpAndSettle();

    final lastCard = tester.getRect(find.byType(GenreCard).last);
    expect(lastCard.bottom, lessThanOrEqualTo(874 - 34));
  });

  testWidgets('段の見出しは見出しとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCatalog(tester);

    expect(
      tester.getSemantics(find.text('基本の Widget')),
      isSemantics(label: '基本の Widget', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('タイルは「ジャンル名、件数、代表の名前」を 1 つのボタンとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCatalog(tester);

    expect(
      tester.getSemantics(_card('Basics')),
      isSemantics(
        label: 'Basics、4 件、basicsWidget1、basicsWidget2、basicsWidget3 など',
        isButton: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(_card('Cupertino')),
      isSemantics(
        label:
            'Cupertino、3 件、cupertinoWidget1、cupertinoWidget2、cupertinoWidget3',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('検索の結果の行は、載っているジャンルも添えて 1 つのボタンとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCatalog(tester);
    await _search(tester, 'pad');

    expect(
      tester.getSemantics(find.widgetWithText(EntryTile, 'Padding')),
      isSemantics(
        label: 'Padding、Padding の要約、0 プロパティ、Layout、Styling',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
