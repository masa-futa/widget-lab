import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/widgets/detail_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../../fakes.dart';

void main() {
  late ProviderContainer container;

  /// relationEntry の一覧のシートを開く。
  Future<void> openSheet(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          FakeCatalogRepository([relationEntry]),
        ),
      ],
    );
    addTearDown(container.dispose);
    // 画面が見ている間と同じく、状態を持ち続ける
    final subscription = container.listen(
      detailProvider('relation'),
      (_, _) {},
    );
    addTearDown(subscription.close);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDetailSheet(
                  context,
                  (_) => const PropertyListSheet(entryId: 'relation'),
                ),
                child: const Text('開く'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
  }

  Finder inSheet(Finder matching) =>
      find.descendant(of: find.byType(PropertyListSheet), matching: matching);

  // シートの中身は SingleChildScrollView の中にあるので、外側のスクロールを使う
  final sheetScroll = find
      .ancestor(
        of: find.byType(PropertyListSheet),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('TC-94: 題と指定中の数、仲間の見出しが語彙の順で、最後に補足', (tester) async {
    await openSheet(tester);
    expect(inSheet(find.text('プロパティ（6）')), findsOneWidget);
    final on = container.read(detailProvider('relation')).onCount;
    expect(inSheet(find.text('指定中 $on')), findsOneWidget);
    final size = tester.getTopLeft(inSheet(find.text('大きさ'))).dy;
    final paint = tester.getTopLeft(inSheet(find.text('色と装飾'))).dy;
    final transform = tester.getTopLeft(inSheet(find.text('変形'))).dy;
    expect(size, lessThan(paint));
    expect(paint, lessThan(transform));
    await tester.scrollUntilVisible(
      inSheet(find.text('1 件')),
      100,
      scrollable: sheetScroll,
    );
    // 補足は見出しと行の 2 か所に出る
    expect(inSheet(find.text('補足')), findsNWidgets(2));
    expect(inSheet(find.text('1 件')), findsOneWidget);
  });

  testWidgets('TC-94: 今選んでいる行に ✓', (tester) async {
    await openSheet(tester);
    expect(
      find.descendant(
        of: find.ancestor(
          of: inSheet(find.text('width')),
          matching: find.byType(InkWell),
        ),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
  });

  testWidgets('TC-94: 行を押すと、そのプロパティを選んで閉じる', (tester) async {
    await openSheet(tester);
    await tester.tap(inSheet(find.text('color')));
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsNothing);
    expect(container.read(detailProvider('relation')).selected, 'color');
  });

  testWidgets('TC-94: 補足の行を押すと、補足を選んで閉じる', (tester) async {
    await openSheet(tester);
    await tester.scrollUntilVisible(
      inSheet(find.text('1 件')),
      100,
      scrollable: sheetScroll,
    );
    await tester.tap(inSheet(find.text('1 件')));
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsNothing);
    expect(container.read(detailProvider('relation')).showsReferences, isTrue);
  });

  testWidgets('文字を 2 倍にしても、長い名前の行がはみ出さない', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openSheet(tester);
    await tester.scrollUntilVisible(
      inSheet(find.text('transformAlignment')),
      100,
      scrollable: sheetScroll,
    );
    expect(tester.takeException(), isNull);
  });
}
