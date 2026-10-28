import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_sample.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../../fake_catalog_repository.dart';

final _layout = allGenres.firstWhere((genre) => genre.id == 'layout');
final _styling = allGenres.firstWhere((genre) => genre.id == 'styling');

Future<void> _pumpTile(
  WidgetTester tester,
  WidgetEntry entry, {
  List<Genre> genres = const [],
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: EntryTile(entry: entry, genres: genres, onTap: onTap ?? () {}),
      ),
    ),
  );
}

void main() {
  testWidgets('見本・名前・一行の要約・プロパティ数の印を出す', (tester) async {
    await _pumpTile(tester, paddingEntry);

    expect(find.byType(EntrySample), findsOneWidget);
    expect(find.text('Padding'), findsOneWidget);
    expect(find.text(paddingEntry.summary), findsOneWidget);
    expect(
      find.text('${paddingEntry.properties.length} プロパティ'),
      findsOneWidget,
    );
  });

  testWidgets('ジャンルを渡すと、印の横に「・」でつないで添える', (tester) async {
    await _pumpTile(tester, paddingEntry, genres: [_layout, _styling]);

    expect(find.text('Layout・Styling'), findsOneWidget);
  });

  testWidgets('ジャンルを渡さなければ、ジャンル名を出さない', (tester) async {
    await _pumpTile(tester, paddingEntry);

    expect(find.text('Layout・Styling'), findsNothing);
  });

  testWidgets('要約は 1 行で末尾を省略し、名前は省略しない', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final entry = fakeEntry('AnimatedCrossFadeWithAVeryLongName', ['basics']);
    await _pumpTile(tester, entry);

    final summary = tester.widget<Text>(find.text('${entry.name} の要約'));
    expect(summary.maxLines, 1);
    expect(summary.overflow, TextOverflow.ellipsis);
    final name = tester.widget<Text>(find.text(entry.name));
    expect(name.maxLines, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('押すと onTap を呼ぶ', (tester) async {
    var tapped = 0;
    await _pumpTile(tester, paddingEntry, onTap: () => tapped++);

    await tester.tap(find.byType(EntryTile));

    expect(tapped, 1);
  });

  testWidgets('ジャンルなしは「名前、要約、プロパティ数」、ありはジャンルを添えて読む', (tester) async {
    final handle = tester.ensureSemantics();
    final count = paddingEntry.properties.length;

    await _pumpTile(tester, paddingEntry);
    expect(
      tester.getSemantics(find.byType(EntryTile)),
      isSemantics(
        label: 'Padding、${paddingEntry.summary}、$count プロパティ',
        isButton: true,
        hasTapAction: true,
      ),
    );

    await _pumpTile(tester, paddingEntry, genres: [_layout, _styling]);
    expect(
      tester.getSemantics(find.byType(EntryTile)),
      isSemantics(
        label: 'Padding、${paddingEntry.summary}、$count プロパティ、Layout、Styling',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
