import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/features/catalog/ui/widgets/genre_card.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

final _basics = allGenres.firstWhere((genre) => genre.id == 'basics');
final _assets = allGenres.firstWhere((genre) => genre.id == 'assets');

Future<void> _pumpCard(
  WidgetTester tester,
  GenreTile tile, {
  VoidCallback? onTap,
  double width = 180,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: GenreCard(tile: tile, onTap: onTap ?? () {}),
          ),
        ),
      ),
    ),
  );
}

const _three = ['Container', 'Row', 'Text'];

void main() {
  testWidgets('件数・単位・ジャンル名・代表の名前を出す', (tester) async {
    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 3, examples: _three),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('件'), findsOneWidget);
    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Container・Row・Text'), findsOneWidget);
  });

  testWidgets('代表の名前に入りきらない Widget があると、末尾に「…」を付ける', (tester) async {
    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 4, examples: _three),
    );

    expect(find.text('Container・Row・Text…'), findsOneWidget);
  });

  testWidgets('件数は accent、地は surface で角丸 lg', (tester) async {
    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 3, examples: _three),
    );
    final scheme = AppTheme.light().colorScheme;

    expect(tester.widget<Text>(find.text('3')).style?.color, scheme.primary);
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(GenreCard),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, scheme.surfaceContainer);
    expect(
      material.borderRadius,
      BorderRadius.circular(NimiRadius.standard.lg),
    );
  });

  testWidgets('長いジャンル名は省略せずに折り返す', (tester) async {
    await _pumpCard(
      tester,
      GenreTile(genre: _assets, count: 1, examples: const ['Image']),
      width: 160,
    );

    final name = find.text('Assets, images, and icons');
    expect(tester.widget<Text>(name).maxLines, isNull);
    expect(tester.getSize(name).height, greaterThan(30));
    expect(tester.takeException(), isNull);
  });

  testWidgets('押すと onTap を呼ぶ', (tester) async {
    var tapped = 0;
    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 3, examples: _three),
      onTap: () => tapped++,
    );

    await tester.tap(find.byType(GenreCard));

    expect(tapped, 1);
  });

  testWidgets('3 件以下は「など」なし、4 件以上は「など」を付けて 1 つのボタンとして読む', (tester) async {
    final handle = tester.ensureSemantics();

    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 3, examples: _three),
    );
    expect(
      tester.getSemantics(find.byType(GenreCard)),
      isSemantics(
        label: 'Basics、3 件、Container、Row、Text',
        isButton: true,
        hasTapAction: true,
      ),
    );

    await _pumpCard(
      tester,
      GenreTile(genre: _basics, count: 4, examples: _three),
    );
    expect(
      tester.getSemantics(find.byType(GenreCard)),
      isSemantics(
        label: 'Basics、4 件、Container、Row、Text など',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
