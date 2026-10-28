import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../fake_catalog_repository.dart';

/// 全ジャンルに 3 件ずつと、名前に pad を含む 2 件。
final _repository = FakeCatalogRepository(
  genreList: allGenres,
  entryList: [
    for (final genre in allGenres)
      for (var i = 1; i <= 3; i++) fakeEntry('${genre.id}Widget$i', [genre.id]),
    fakeEntry('Padding', ['layout', 'styling']),
    fakeEntry('SliverPadding', ['layout', 'scrolling']),
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

/// 一覧に出ている見出しのジャンル名（上から順）。
List<String> _headerNames(WidgetTester tester) => [
  for (final header in tester.widgetList<CatalogSectionHeader>(
    find.byType(CatalogSectionHeader),
  ))
    header.genre.name,
];

/// チップの行に出ているジャンル名（左から順）。
List<String> _chipNames(WidgetTester tester) => [
  for (final chip in tester.widgetList<ActionChip>(find.byType(ActionChip)))
    (chip.label as Text).data ?? '',
];

Finder _header(String name) => find.widgetWithText(CatalogSectionHeader, name);

final _clearButton = find.byTooltip('検索を消す');

/// 見出しと行が並ぶ、縦にスクロールする一覧。
final _list = find.ancestor(
  of: find.byType(CatalogSectionHeader).first,
  matching: find.byType(SingleChildScrollView),
);

void main() {
  testWidgets('TC-01: 公式カタログのジャンルが全部、公式と同じ順で見出しに出る', (tester) async {
    await _pumpCatalog(tester);

    final names = [for (final genre in allGenres) genre.name];
    expect(_headerNames(tester), names);
    expect(_chipNames(tester), names);
  });

  testWidgets('TC-10: 一致した Widget があるジャンルの見出しとチップだけが残り、件数は一致した数', (
    tester,
  ) async {
    await _pumpCatalog(tester);

    await _search(tester, 'pad');

    expect(_headerNames(tester), ['Layout', 'Scrolling', 'Styling']);
    expect(_chipNames(tester), ['Layout', 'Scrolling', 'Styling']);
    expect(
      find.descendant(of: _header('Layout'), matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('Padding'), findsNWidgets(2));
    expect(find.text('SliverPadding'), findsNWidgets(2));
    expect(find.text('layoutWidget1'), findsNothing);
  });

  testWidgets('TC-11: 消すボタンで全件に戻り、消すボタンが消える', (tester) async {
    await _pumpCatalog(tester);
    expect(_clearButton, findsNothing);

    await _search(tester, 'pad');
    expect(_clearButton, findsOneWidget);

    await tester.tap(_clearButton);
    await tester.pumpAndSettle();

    expect(_headerNames(tester), hasLength(allGenres.length));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(_clearButton, findsNothing);
  });

  testWidgets('TC-12: 一致が 0 件なら空状態と「検索を消す」が出て、チップの行が消える', (tester) async {
    await _pumpCatalog(tester);

    await _search(tester, 'zzzz');

    expect(find.text('「zzzz」に一致する Widget はありません'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '検索を消す'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
    expect(find.byType(CatalogSectionHeader), findsNothing);
  });

  testWidgets('TC-13: 空状態の「検索を消す」で全件に戻る', (tester) async {
    await _pumpCatalog(tester);
    await _search(tester, 'zzzz');

    await tester.tap(find.widgetWithText(TextButton, '検索を消す'));
    await tester.pumpAndSettle();

    expect(_headerNames(tester), hasLength(allGenres.length));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
    expect(find.text('「zzzz」に一致する Widget はありません'), findsNothing);
  });

  testWidgets('TC-14: ジャンルのチップを押すと、その見出しが一覧の上端に来る', (tester) async {
    await _pumpCatalog(tester);
    final listTop = tester.getTopLeft(_list).dy;
    expect(tester.getTopLeft(_header('Layout')).dy, greaterThan(listTop));

    await tester.ensureVisible(find.widgetWithText(ActionChip, 'Layout'));
    await tester.tap(find.widgetWithText(ActionChip, 'Layout'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(_header('Layout')).dy, listTop);
  });

  testWidgets('入力を変えると、一覧の先頭に戻る', (tester) async {
    await _pumpCatalog(tester);
    await tester.drag(_list, const Offset(0, -1500));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(_header('Cupertino')).dy,
      lessThan(tester.getTopLeft(_list).dy),
    );

    await _search(tester, 'Widget1');

    expect(
      tester.getTopLeft(_header('Cupertino')).dy,
      tester.getTopLeft(_list).dy,
    );
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

  testWidgets('広い画面では、本文を幅 640 にして中央に置く', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpCatalog(tester);

    final rect = tester.getRect(_list);
    expect(rect.width, 640);
    expect(rect.center.dx, 600);
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
  });

  testWidgets('検索欄は地が surface で角丸 md、チップは地が surface-muted のピル形', (
    tester,
  ) async {
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

    final chip = tester.widget<ActionChip>(find.byType(ActionChip).first);
    expect(chip.backgroundColor, NimiColors.light.surfaceMuted);
    expect(chip.side, BorderSide.none);
    expect(
      chip.shape,
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NimiRadius.standard.full),
      ),
    );
  });

  testWidgets('見出しは「ジャンル名、件数 件」と見出しとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCatalog(tester);

    expect(
      tester.getSemantics(_header('Basics')),
      isSemantics(label: 'Basics、3 件', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('一覧の行は名前と要約を 1 つのボタンとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCatalog(tester);

    expect(
      tester.getSemantics(find.widgetWithText(ListTile, 'basicsWidget1')),
      isSemantics(label: 'basicsWidget1\nbasicsWidget1 の要約', isButton: true),
    );
    handle.dispose();
  });

  testWidgets('TC-15: 行を押すと、その Widget の ID を知らせる', (tester) async {
    String? tapped;
    await _pumpCatalog(tester, onEntryTapped: (_, entryId) => tapped = entryId);
    await _search(tester, 'pad');

    await tester.tap(find.widgetWithText(ListTile, 'SliverPadding').first);

    expect(tapped, 'sliverpadding');
  });
}
