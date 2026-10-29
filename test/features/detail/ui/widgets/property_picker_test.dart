import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_list_sheet.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_picker.dart';
import 'package:widget_lab/features/detail/view_model/detail_notifier.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../../fakes.dart';

/// プロパティ 1 つ・補足なしの Widget（選ぶ欄は 1 件だけ）。
final singleEntry = WidgetEntry(
  id: 'single',
  name: 'Single',
  genreIds: const ['basics'],
  summary: '',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: const [
    PropertySpec(
      name: 'only',
      typeLabel: 'bool?',
      description: '',
      control: SwitchControl(initialValue: true),
    ),
  ],
  build: (args) => const SizedBox(),
  codeName: 'Single',
);

void main() {
  late ProviderContainer container;

  /// relationEntry の選ぶ欄を出す（並び: width・height・color・decoration・
  /// transform・transformAlignment・補足。開いたときは width）。
  Future<void> pumpPicker(WidgetTester tester, {WidgetEntry? entry}) async {
    container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          FakeCatalogRepository([entry ?? relationEntry]),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: PropertyPicker(entryId: entry?.id ?? 'relation'),
            ),
          ),
        ),
      ),
    );
  }

  final card = find.byKey(PropertyPicker.cardKey);
  Finder inCard(String text) =>
      find.descendant(of: card, matching: find.text(text));
  IconButton button(WidgetTester tester, String tooltip) =>
      tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, switch (tooltip) {
          '前のプロパティ' => Icons.chevron_left,
          _ => Icons.chevron_right,
        }),
      );

  testWidgets('TC-91: カードに名前と「仲間 ・ 値」、先頭では ‹ が押せない', (tester) async {
    await pumpPicker(tester);
    expect(inCard('width'), findsOneWidget);
    expect(inCard('大きさ ・ true'), findsOneWidget);
    expect(button(tester, '前のプロパティ').onPressed, isNull);
    expect(button(tester, '次のプロパティ').onPressed, isNotNull);
  });

  testWidgets('TC-91: › で次へ、‹ で前へ送る', (tester) async {
    await pumpPicker(tester);
    await tester.tap(find.byTooltip('次のプロパティ'));
    await tester.pumpAndSettle();
    expect(inCard('height'), findsOneWidget);
    // height は既定（OFF）
    expect(inCard('大きさ ・ 既定'), findsOneWidget);
    await tester.tap(find.byTooltip('前のプロパティ'));
    await tester.pumpAndSettle();
    expect(inCard('width'), findsOneWidget);
  });

  testWidgets('TC-91: 最後は補足で、› が押せない', (tester) async {
    await pumpPicker(tester);
    container.read(detailProvider('relation').notifier).referencesSelected();
    await tester.pumpAndSettle();
    expect(inCard('補足'), findsOneWidget);
    expect(inCard('1 件 ・ 読むだけ'), findsOneWidget);
    expect(button(tester, '次のプロパティ').onPressed, isNull);
  });

  testWidgets('TC-91: requires の相手が OFF のプロパティは、カードを薄く出す', (tester) async {
    await pumpPicker(tester);
    container
        .read(detailProvider('relation').notifier)
        .propertySelected('transformAlignment');
    await tester.pumpAndSettle();
    final opacity = tester.widget<Opacity>(
      find.descendant(of: card, matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('TC-91: 効かないプロパティのカードは、読み上げに「今は効かない」を足す', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    expect(tester.getSemantics(card).label, isNot(contains('今は効かない')));
    container
        .read(detailProvider('relation').notifier)
        .propertySelected('transformAlignment');
    await tester.pumpAndSettle();
    final label = tester.getSemantics(card).label;
    expect(label, contains('今は効かない'));
    expect(label, startsWith('transformAlignment、'));
    expect(label, endsWith('、6 / 7'));
    handle.dispose();
  });

  testWidgets('TC-91: 1 件だけなら、カードだけを出して ‹ › と点は出さない', (tester) async {
    await pumpPicker(tester, entry: singleEntry);
    expect(card, findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byKey(const ValueKey('pickerDot-0')), findsNothing);
  });

  testWidgets('TC-91: 点はプロパティと補足の数だけ並び、読み上げない', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    expect(find.byKey(const ValueKey('pickerDot-6')), findsOneWidget);
    expect(find.byKey(const ValueKey('pickerDot-7')), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('pickerDot-0')),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('TC-91: 読み上げの上下の操作で前後に送れる', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPicker(tester);
    tester.semantics.increase(find.semantics.byLabel(RegExp('^width、')));
    await tester.pumpAndSettle();
    expect(inCard('height'), findsOneWidget);
    tester.semantics.decrease(find.semantics.byLabel(RegExp('^height、')));
    await tester.pumpAndSettle();
    expect(inCard('width'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('TC-91: カードを押すと一覧のシートが開く', (tester) async {
    await pumpPicker(tester);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(PropertyListSheet), findsOneWidget);
  });

  testWidgets('TC-91: 文字を 2 倍にしてもはみ出さない', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpPicker(tester);
    expect(tester.takeException(), isNull);
  });
}
