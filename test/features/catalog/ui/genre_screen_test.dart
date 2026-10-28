import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/genre_screen.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_sample.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../fake_catalog_repository.dart';

/// 本物のジャンルと、本物の収録データ 4 件。
final _repository = FakeCatalogRepository(
  genreList: allGenres,
  entryList: [containerEntry, rowEntry, textEntry, paddingEntry],
);

Future<void> _pumpGenre(
  WidgetTester tester,
  String genreId, {
  void Function(BuildContext context, String entryId)? onEntryTapped,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [catalogRepositoryProvider.overrideWithValue(_repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GenreScreen(
          genreId: genreId,
          onEntryTapped: onEntryTapped ?? (_, _) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> _rowNames(WidgetTester tester) => [
  for (final row in tester.widgetList<EntryTile>(find.byType(EntryTile)))
    row.entry.name,
];

void main() {
  testWidgets('TC-14: 題がジャンル名で、件数と一言の説明、収録の順の見本つきの行が出る', (tester) async {
    await _pumpGenre(tester, 'basics');

    expect(find.widgetWithText(AppBar, 'Basics'), findsOneWidget);
    expect(find.text('3 件・アプリの骨組みになる基本の Widget'), findsOneWidget);
    expect(_rowNames(tester), ['Container', 'Row', 'Text']);
    expect(find.byType(EntrySample), findsNWidgets(3));
  });

  testWidgets('行に名前・一行の要約・プロパティ数が出る', (tester) async {
    await _pumpGenre(tester, 'layout');

    final row = find.widgetWithText(EntryTile, 'Padding');
    expect(
      find.descendant(of: row, matching: find.text(paddingEntry.summary)),
      findsOne,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.text('${paddingEntry.properties.length} プロパティ'),
      ),
      findsOne,
    );
  });

  testWidgets('TC-15: 行を押すと、その Widget の ID を知らせる', (tester) async {
    String? tapped;
    await _pumpGenre(
      tester,
      'layout',
      onEntryTapped: (_, entryId) => tapped = entryId,
    );

    await tester.tap(find.widgetWithText(EntryTile, 'Padding'));

    expect(tapped, 'padding');
  });

  testWidgets('行は「名前、要約、プロパティ数」を 1 つのボタンとして読む', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpGenre(tester, 'layout');

    expect(
      tester.getSemantics(find.widgetWithText(EntryTile, 'Padding')),
      isSemantics(
        label:
            'Padding、${paddingEntry.summary}、'
            '${paddingEntry.properties.length} プロパティ',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('長いジャンル名でも題を省略しない', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpGenre(tester, 'assets');

    final title = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Assets, images, and icons'),
      ),
    );
    expect(title.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });

  testWidgets('広い画面では、本文を幅 640 にして中央に置く', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpGenre(tester, 'basics');

    final rect = tester.getRect(find.byType(Scrollable).last);
    expect(rect.width, 640);
    expect(rect.center.dx, 600);
  });

  testWidgets('文字を 2 倍にしても、小さい画面で崩れない', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpGenre(tester, 'layout');

    expect(tester.takeException(), isNull);
  });
}
