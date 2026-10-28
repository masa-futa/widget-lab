import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/detail_screen.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_row.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../fakes.dart';

void main() {
  late FakeClipboardClient clipboard;
  late FakeUrlLauncherClient launcher;

  Future<void> pumpDetail(
    WidgetTester tester,
    String entryId, {
    FakeCatalogRepository? repository,
    bool clipboardSucceeds = true,
    bool launcherSucceeds = true,
  }) async {
    // 操作パネルの行が数行見える、背の高いスマートフォンの大きさ
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    clipboard = FakeClipboardClient(succeeds: clipboardSucceeds);
    launcher = FakeUrlLauncherClient(succeeds: launcherSucceeds);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(
            repository ?? FakeCatalogRepository(),
          ),
          clipboardClientProvider.overrideWithValue(clipboard),
          urlLauncherClientProvider.overrideWithValue(launcher),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DetailScreen(entryId: entryId),
        ),
      ),
    );
  }

  /// [name] のプロパティの行。
  Finder row(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(PropertyRow));

  /// [name] の行の中の [matching]。見えるところまでスクロールしてから返す。
  Future<Finder> inRow(
    WidgetTester tester,
    String name,
    Finder matching,
  ) async {
    await tester.ensureVisible(row(name));
    await tester.pumpAndSettle();
    return find.descendant(of: row(name), matching: matching);
  }

  /// 1 枚のプレビューの中の、一番外側の [T]（デモの子の FlutterLogo の中にも
  /// Padding・Container があるため）。
  T preview<T extends Widget>(WidgetTester tester) => tester.widget<T>(
    find
        .descendant(of: find.byType(PreviewCard), matching: find.byType(T))
        .first,
  );

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(Tab, label));
    await tester.pumpAndSettle();
  }

  Future<String> shownCode(WidgetTester tester) async {
    await openTab(tester, 'コード');
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(SelectionArea),
        matching: find.byType(Text),
      ),
    );
    return text.data ?? '';
  }

  void setSlider(WidgetTester tester, Finder slider, double value) {
    tester.widget<Slider>(slider).onChanged?.call(value);
  }

  testWidgets('題が Widget 名で、タブは操作を選んでいる', (tester) async {
    await pumpDetail(tester, 'padding');

    expect(find.widgetWithText(AppBar, 'Padding'), findsOneWidget);
    expect(find.byType(PropertyRow), findsNWidgets(2));
    expect(find.text('16.0'), findsOneWidget);
  });

  testWidgets('TC-17: padding を OFF にすると余白がなくなり、コードから消える', (tester) async {
    await pumpDetail(tester, 'padding');

    await tester.tap(await inRow(tester, 'padding', find.byType(Switch)));
    await tester.pump();

    expect(preview<Padding>(tester).padding, EdgeInsets.zero);
    expect(await shownCode(tester), isNot(contains('padding:')));
  });

  testWidgets('TC-19: スライダーを 32 にすると、余白が 32 で値の表示が 32.0', (tester) async {
    await pumpDetail(tester, 'padding');

    setSlider(tester, await inRow(tester, 'padding', find.byType(Slider)), 32);
    await tester.pump();

    expect(preview<Padding>(tester).padding, const EdgeInsets.all(32));
    expect(find.text('32.0'), findsOneWidget);
  });

  testWidgets('TC-20: 真偽のスイッチで値を変えるとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'text');

    // 1 つ目は ON/OFF、2 つ目が値のスイッチ
    final switches = await inRow(tester, 'softWrap', find.byType(Switch));
    await tester.tap(switches.first);
    await tester.pump();
    await tester.tap(switches.last);
    await tester.pump();

    expect(preview<Text>(tester).softWrap, isFalse);
  });

  testWidgets('TC-21: セグメントで選ぶとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'row');

    await tester.tap(
      await inRow(tester, 'crossAxisAlignment', find.byType(Switch)),
    );
    await tester.pump();
    await tester.tap(
      await inRow(tester, 'crossAxisAlignment', find.text('start')),
    );
    await tester.pump();

    expect(preview<Row>(tester).crossAxisAlignment, CrossAxisAlignment.start);
  });

  testWidgets('TC-22: ドロップダウンで選ぶとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'row');

    await tester.tap(
      await inRow(tester, 'mainAxisAlignment', find.byType(DropdownMenu<int>)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'center').last);
    await tester.pumpAndSettle();

    expect(preview<Row>(tester).mainAxisAlignment, MainAxisAlignment.center);
  });

  testWidgets('TC-23: 色見本を選ぶとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'container');

    await tester.tap(await inRow(tester, 'color', find.bySemanticsLabel('若竹')));
    await tester.pump();

    expect(preview<Container>(tester).color, const Color(0xFF68BE8D));
  });

  testWidgets('TC-23: 文字を入れるとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'text');

    await tester.enterText(
      await inRow(tester, 'data', find.byType(TextField)),
      'さようなら',
    );
    await tester.pump();

    expect(preview<Text>(tester).data, 'さようなら');
  });

  testWidgets('TC-24: 色と余白を両方変えると、プレビューとコードに両方が出る', (tester) async {
    await pumpDetail(tester, 'container');

    await tester.tap(await inRow(tester, 'color', find.bySemanticsLabel('紅')));
    setSlider(tester, await inRow(tester, 'padding', find.byType(Slider)), 40);
    await tester.pump();

    final container = preview<Container>(tester);
    expect(container.color, const Color(0xFFD7003A));
    expect(container.padding, const EdgeInsets.all(40));
    final code = await shownCode(tester);
    expect(code, contains('  padding: EdgeInsets.all(40.0),'));
    expect(code, contains('  color: Color(0xFFD7003A),'));
  });

  testWidgets('TC-26: 必須のプロパティはスイッチの代わりに「必須」', (tester) async {
    await pumpDetail(tester, 'text');

    expect(await inRow(tester, 'data', find.text('必須')), findsOneWidget);
    expect(
      find.descendant(of: row('data'), matching: find.byType(Switch)),
      findsNothing,
    );
  });

  group('比べる', () {
    testWidgets('TC-27: 上に「付けた」下に「付けない」の 2 枚と「padding を比較中」が出る', (
      tester,
    ) async {
      await pumpDetail(tester, 'padding');

      await tester.tap(
        await inRow(tester, 'padding', find.byTooltip('付けた／付けないを比べる')),
      );
      await tester.pumpAndSettle();

      expect(find.text('padding を比較中'), findsOneWidget);
      expect(find.text('付けた'), findsOneWidget);
      expect(find.text('付けない'), findsOneWidget);
      EdgeInsetsGeometry paddingIn(Finder card) => tester
          .widget<Padding>(
            find.descendant(of: card, matching: find.byType(Padding)).first,
          )
          .padding;
      final cards = find.byKey(const Key('compareCard'));
      expect(paddingIn(cards.first), const EdgeInsets.all(16));
      expect(paddingIn(cards.last), EdgeInsets.zero);
      // 何も描かない Padding でも、外枠の線の大きさで違いが見える
      Size boundsIn(Finder card) => tester.getSize(
        find.descendant(of: card, matching: find.byKey(PreviewCard.boundsKey)),
      );
      expect(boundsIn(cards.first).width, boundsIn(cards.last).width + 16 * 2);
    });

    testWidgets('TC-29: 「比較をやめる」で 1 枚に戻り、値はそのまま', (tester) async {
      await pumpDetail(tester, 'padding');
      setSlider(
        tester,
        await inRow(tester, 'padding', find.byType(Slider)),
        24,
      );
      await tester.tap(
        await inRow(tester, 'padding', find.byTooltip('付けた／付けないを比べる')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('比較をやめる'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('compareCard')), findsNothing);
      expect(find.text('padding を比較中'), findsNothing);
      expect(preview<Padding>(tester).padding, const EdgeInsets.all(24));
    });
  });

  group('初期状態に戻す', () {
    IconButton resetButton(WidgetTester tester) => tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.restart_alt),
    );

    testWidgets('TC-33: 開いたばかりでは押せない', (tester) async {
      await pumpDetail(tester, 'padding');

      expect(find.byTooltip('初期状態に戻す'), findsOneWidget);
      expect(resetButton(tester).onPressed, isNull);
    });

    testWidgets('TC-32: 変えると押せ、押すと最初の値に戻って押せなくなる', (tester) async {
      await pumpDetail(tester, 'padding');
      setSlider(
        tester,
        await inRow(tester, 'padding', find.byType(Slider)),
        40,
      );
      await tester.pump();
      expect(resetButton(tester).onPressed, isNotNull);

      await tester.tap(find.byTooltip('初期状態に戻す'));
      await tester.pump();

      expect(preview<Padding>(tester).padding, const EdgeInsets.all(16));
      expect(resetButton(tester).onPressed, isNull);
    });
  });

  group('コード', () {
    testWidgets('TC-42: コピーすると表示中のコードが入り「コードをコピーしました」', (tester) async {
      await pumpDetail(tester, 'padding');
      final code = await shownCode(tester);

      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(clipboard.written, [code]);
      expect(find.text('コードをコピーしました'), findsOneWidget);
    });

    testWidgets('TC-43: 書けなければ「コピーできませんでした」', (tester) async {
      await pumpDetail(tester, 'padding', clipboardSucceeds: false);
      await openTab(tester, 'コード');

      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(find.text('コピーできませんでした'), findsOneWidget);
    });
  });

  group('説明', () {
    testWidgets('ジャンルと説明文が出る', (tester) async {
      await pumpDetail(tester, 'container');

      await openTab(tester, '説明');

      expect(find.text('Basics'), findsOneWidget);
      expect(find.text('Layout'), findsOneWidget);
      expect(find.text(containerEntry.description), findsOneWidget);
    });

    testWidgets('TC-44: 公式ドキュメントを開くと、その Widget の URL で開こうとする', (tester) async {
      await pumpDetail(tester, 'container');
      await openTab(tester, '説明');

      await tester.tap(find.text('公式ドキュメントを開く'));
      await tester.pump();

      expect(launcher.opened, [containerEntry.docUrl]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('TC-45: 開けなければ「ブラウザを開けませんでした」', (tester) async {
      await pumpDetail(tester, 'container', launcherSucceeds: false);
      await openTab(tester, '説明');

      await tester.tap(find.text('公式ドキュメントを開く'));
      await tester.pump();

      expect(find.text('ブラウザを開けませんでした'), findsOneWidget);
    });
  });

  testWidgets('変えられるプロパティがなければ、その旨を出す', (tester) async {
    final empty = WidgetEntry(
      id: 'empty',
      name: 'Empty',
      genreIds: const ['basics'],
      summary: '',
      description: '',
      docUrl: Uri.parse('https://api.flutter.dev/'),
      properties: const [],
      build: (args) => const SizedBox(),
      codeName: 'Empty',
    );
    await pumpDetail(
      tester,
      'empty',
      repository: FakeCatalogRepository([empty]),
    );

    expect(find.text('この Widget には変えられるプロパティがありません'), findsOneWidget);
  });

  group('プレビューの高さ', () {
    double previewHeight(WidgetTester tester) =>
        tester.getSize(find.byKey(DetailScreen.previewAreaKey)).height;

    testWidgets('画面の高さの約 4 割', (tester) async {
      await pumpDetail(tester, 'padding');

      expect(previewHeight(tester), closeTo(844 * 0.4, 1));
    });

    testWidgets('キーボードが出たら、画面の高さの約 2.5 割に縮める', (tester) async {
      await pumpDetail(tester, 'text');

      tester.view.viewInsets = const FakeViewPadding(bottom: 1000);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(previewHeight(tester), closeTo(844 * 0.25, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('横向きでキーボードを出し比較しても、はみ出さず操作パネルが残る', (tester) async {
      await pumpDetail(tester, 'text');
      await tester.tap(
        await inRow(tester, 'style', find.byTooltip('付けた／付けないを比べる')),
      );
      await tester.pumpAndSettle();

      // 844×390 の横向きに、高さ 120 のキーボード
      tester.view.physicalSize = const Size(2532, 1170);
      tester.view.viewInsets = const FakeViewPadding(bottom: 360);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(TabBarView)).height,
        greaterThanOrEqualTo(96),
      );
      expect(previewHeight(tester), greaterThan(0));
    });
  });

  testWidgets('タブを行き来しても、操作タブのスクロール位置が残る', (tester) async {
    await pumpDetail(tester, 'container');
    final operation = find.byKey(const PageStorageKey('operation'));
    await tester.drag(operation, const Offset(0, -300));
    await tester.pumpAndSettle();
    final scrolled = tester
        .state<ScrollableState>(
          find
              .descendant(of: operation, matching: find.byType(Scrollable))
              .first,
        )
        .position
        .pixels;
    expect(scrolled, greaterThan(0));

    await openTab(tester, 'コード');
    await openTab(tester, '操作');

    expect(
      tester
          .state<ScrollableState>(
            find
                .descendant(of: operation, matching: find.byType(Scrollable))
                .first,
          )
          .position
          .pixels,
      scrolled,
    );
  });
}
