import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/scrolling/notification_listener.dart';
import 'package:widget_lab/catalog/styling/media_query.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/detail/ui/detail_screen.dart';
import 'package:widget_lab/features/detail/ui/probe/log_sheet.dart';
import 'package:widget_lab/features/detail/ui/probe/log_strip.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_strip.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';
import 'package:widget_lab/features/detail/ui/widgets/editor_panel.dart';
import 'package:widget_lab/features/detail/ui/widgets/group_tabs.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';
import 'package:widget_lab/features/detail/ui/widgets/property_chip.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

import '../fakes.dart';

void main() {
  late FakeClipboardClient clipboard;
  late FakeUrlLauncherClient launcher;

  /// [entryId] の詳細を開く。[viaHome] なら、ボタンで詳細へ進むだけの画面から始める。
  Future<void> pumpDetail(
    WidgetTester tester,
    String entryId, {
    FakeCatalogRepository? repository,
    bool clipboardSucceeds = true,
    bool launcherSucceeds = true,
    bool viaHome = false,
  }) async {
    // 背の高いスマートフォンの大きさ（402×874）
    tester.view.physicalSize = const Size(1206, 2622);
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
          home: viaHome
              ? Builder(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DetailScreen(entryId: entryId),
                        ),
                      ),
                      child: const Text('開く'),
                    ),
                  ),
                )
              : DetailScreen(entryId: entryId),
        ),
      ),
    );
  }

  /// [name] のチップ。
  Finder chip(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(PropertyChip));

  /// [name] のチップの値の表示。
  String chipValue(WidgetTester tester, String name) => tester
      .widgetList<Text>(
        find.descendant(of: chip(name), matching: find.byType(Text)),
      )
      .last
      .data!;

  /// [name] のチップがいま見えていなければ、それを持つ仲間のタブを順に開いて探す
  /// （チップは選んでいる仲間の分だけ並ぶ）。
  Future<void> openTabOf(WidgetTester tester, String name) async {
    if (chip(name).evaluate().isNotEmpty) return;
    final tabs = find.descendant(
      of: find.byType(GroupTabs),
      matching: find.byType(InkWell),
    );
    for (var i = 0; i < tabs.evaluate().length; i++) {
      await tester.tap(tabs.at(i));
      await tester.pumpAndSettle();
      if (chip(name).evaluate().isNotEmpty) return;
    }
  }

  Future<void> select(WidgetTester tester, String name) async {
    await openTabOf(tester, name);
    await tester.ensureVisible(chip(name));
    await tester.pumpAndSettle();
    await tester.tap(chip(name));
    await tester.pumpAndSettle();
  }

  /// 編集パネルの中の [matching]。
  Finder inPanel(Finder matching) =>
      find.descendant(of: find.byType(EditorPanel), matching: matching);

  /// ON/OFF のスイッチ（編集パネルの最初のスイッチ）。
  Future<void> toggle(WidgetTester tester) async {
    await tester.tap(inPanel(find.byType(Switch)).first);
    await tester.pumpAndSettle();
  }

  /// 1 枚のプレビューの中の、一番外側の [T]（デモの子の FlutterLogo の中にも
  /// Padding・Container があるため）。
  T preview<T extends Widget>(WidgetTester tester) => tester.widget<T>(
    find
        .descendant(of: find.byType(PreviewCard), matching: find.byType(T))
        .first,
  );

  String stripText(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(CodeStrip),
          matching: find.byType(Text),
        ),
      )
      .first
      .data!;

  Future<void> setSlider(WidgetTester tester, double value) async {
    tester.widget<Slider>(inPanel(find.byType(Slider))).onChanged?.call(value);
    await tester.pumpAndSettle();
  }

  Future<void> openCodeSheet(WidgetTester tester) async {
    await tester.tap(find.byType(CodeStrip));
    await tester.pumpAndSettle();
  }

  Future<void> openAboutSheet(WidgetTester tester) async {
    await tester.tap(find.byTooltip('この Widget について'));
    await tester.pumpAndSettle();
  }

  testWidgets('TC-61: 題が Widget 名で、最初の ON のプロパティを選んでいる', (tester) async {
    await pumpDetail(tester, 'container');

    expect(find.widgetWithText(AppBar, 'Container'), findsOneWidget);
    expect(tester.widget<PropertyChip>(chip('padding')).selected, isTrue);
    expect(inPanel(find.text('padding')), findsOneWidget);
    expect(stripText(tester), 'padding: EdgeInsets.all(16.0),');
    // チップは選んでいる仲間（余白）の分だけ、収録データの順に
    final spacingCount = containerEntry.properties
        .where((spec) => spec.group == PropertyGroup.spacing)
        .length;
    expect(find.byType(PropertyChip), findsNWidgets(spacingCount));
  });

  testWidgets('TC-17: padding を OFF にすると余白がなくなり、チップが「既定」、帯が指定なし', (
    tester,
  ) async {
    await pumpDetail(tester, 'padding');

    await toggle(tester);

    expect(preview<Padding>(tester).padding, EdgeInsets.zero);
    expect(chipValue(tester, 'padding'), '既定');
    expect(stripText(tester), '// padding は指定なし（既定値）');
  });

  testWidgets('TC-19: スライダーを 32 にすると、余白が 32、吹き出しが 32.0、チップが 32', (
    tester,
  ) async {
    await pumpDetail(tester, 'padding');

    await setSlider(tester, 32);

    expect(preview<Padding>(tester).padding, const EdgeInsets.all(32));
    expect(inPanel(find.text('32.0')), findsOneWidget);
    expect(chipValue(tester, 'padding'), '32');
  });

  testWidgets('TC-20: 真偽のスイッチで値を変えるとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'text');
    await select(tester, 'softWrap');

    await toggle(tester);
    // 2 つ目が値のスイッチ
    await tester.tap(inPanel(find.byType(Switch)).last);
    await tester.pumpAndSettle();

    expect(preview<Text>(tester).softWrap, isFalse);
  });

  testWidgets('TC-21: セグメントで選ぶとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'row');
    await select(tester, 'crossAxisAlignment');

    await toggle(tester);
    await tester.tap(inPanel(find.text('start')));
    await tester.pumpAndSettle();

    expect(preview<Row>(tester).crossAxisAlignment, CrossAxisAlignment.start);
  });

  testWidgets('TC-22: ドロップダウンで選ぶとプレビューに反映される', (tester) async {
    await pumpDetail(tester, 'row');
    await select(tester, 'mainAxisAlignment');

    await tester.tap(inPanel(find.byType(DropdownMenu<int>)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'center').last);
    await tester.pumpAndSettle();

    expect(preview<Row>(tester).mainAxisAlignment, MainAxisAlignment.center);
  });

  testWidgets('TC-23: 色見本を選ぶとプレビューとチップの値に反映される', (tester) async {
    await pumpDetail(tester, 'container');
    await select(tester, 'color');

    await tester.tap(inPanel(find.bySemanticsLabel('若竹')));
    await tester.pumpAndSettle();

    expect(preview<Container>(tester).color, const Color(0xFF68BE8D));
    expect(chipValue(tester, 'color'), '若竹');
  });

  testWidgets('TC-23: 文字を入れるとプレビューとチップの値に反映される', (tester) async {
    await pumpDetail(tester, 'text');

    await tester.enterText(inPanel(find.byType(TextField)), 'さようなら');
    await tester.pumpAndSettle();

    expect(preview<Text>(tester).data, 'さようなら');
    expect(chipValue(tester, 'data'), 'さようなら');
  });

  testWidgets('TC-24: 色と余白を両方変えると、プレビューとコードに両方が出る', (tester) async {
    await pumpDetail(tester, 'container');

    await setSlider(tester, 40);
    await select(tester, 'color');
    await tester.tap(inPanel(find.bySemanticsLabel('紅')));
    await tester.pumpAndSettle();

    final container = preview<Container>(tester);
    expect(container.color, const Color(0xFFD7003A));
    expect(container.padding, const EdgeInsets.all(40));
    await openCodeSheet(tester);
    expect(find.text('  padding: EdgeInsets.all(40.0),'), findsOneWidget);
    expect(find.text('  color: Color(0xFFD7003A),'), findsOneWidget);
  });

  testWidgets('TC-26: 必須のプロパティはスイッチの代わりに「必須」', (tester) async {
    await pumpDetail(tester, 'text');

    expect(inPanel(find.text('data')), findsOneWidget);
    expect(inPanel(find.text('必須')), findsOneWidget);
    expect(inPanel(find.byType(Switch)), findsNothing);
  });

  group('比べる', () {
    Future<void> compare(WidgetTester tester) async {
      await tester.tap(inPanel(find.text('比べる')));
      await tester.pumpAndSettle();
    }

    testWidgets('TC-27: 左に「付けた」右に「付けない」、仕切りが中央、ボタンが「比べるのをやめる」', (tester) async {
      await pumpDetail(tester, 'padding');

      await compare(tester);

      expect(find.byType(ComparePreview), findsOneWidget);
      expect(find.text('付けた'), findsOneWidget);
      expect(find.text('付けない'), findsOneWidget);
      final area = find.byType(ComparePreview);
      expect(
        tester.getCenter(find.byKey(ComparePreview.dividerKey)).dx,
        closeTo(tester.getCenter(area).dx, 1),
      );
      expect(inPanel(find.text('比べるのをやめる')), findsOneWidget);
      EdgeInsetsGeometry paddingIn(int i) => tester
          .widget<Padding>(
            find
                .descendant(
                  of: find.byType(PreviewCard).at(i),
                  matching: find.byType(Padding),
                )
                .first,
          )
          .padding;
      expect(paddingIn(0), const EdgeInsets.all(16));
      expect(paddingIn(1), EdgeInsets.zero);
    });

    testWidgets('TC-29: 「比べるのをやめる」で 1 枚に戻り、値はそのまま', (tester) async {
      await pumpDetail(tester, 'padding');
      await setSlider(tester, 24);
      await compare(tester);

      await tester.tap(inPanel(find.text('比べるのをやめる')));
      await tester.pumpAndSettle();

      expect(find.byType(ComparePreview), findsNothing);
      expect(preview<Padding>(tester).padding, const EdgeInsets.all(24));
    });

    testWidgets('TC-28: 比較中に child のチップを選ぶと、比較をやめて child を編集する', (
      tester,
    ) async {
      await pumpDetail(tester, 'padding');
      await compare(tester);

      await select(tester, 'child');

      expect(find.byType(ComparePreview), findsNothing);
      expect(inPanel(find.text('child')), findsOneWidget);
    });

    testWidgets('TC-68: 仕切りをドラッグすると動く', (tester) async {
      await pumpDetail(tester, 'padding');
      await compare(tester);
      final before = tester.getCenter(find.byKey(ComparePreview.dividerKey));

      await tester.drag(
        find.byKey(ComparePreview.dividerKey),
        const Offset(60, 0),
      );
      await tester.pump();

      expect(
        tester.getCenter(find.byKey(ComparePreview.dividerKey)).dx,
        closeTo(before.dx + 60, 1),
      );
    });
  });

  group('拡大', () {
    double scaleOf(WidgetTester tester, int i) => tester
        .widget<Transform>(
          find
              .descendant(
                of: find.byType(PreviewCard).at(i),
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .getMaxScaleOnAxis();

    testWidgets('TC-67: 「×1」を押すと「×2」になり、2 倍で描く。比較中も 2 枚とも', (tester) async {
      await pumpDetail(tester, 'padding');
      expect(scaleOf(tester, 0), 1);

      await tester.tap(find.text('×1'));
      await tester.pumpAndSettle();

      expect(find.text('×2'), findsOneWidget);
      expect(scaleOf(tester, 0), 2);

      await tester.tap(inPanel(find.text('比べる')));
      await tester.pumpAndSettle();

      expect(scaleOf(tester, 0), 2);
      expect(scaleOf(tester, 1), 2);
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

    testWidgets('TC-32: 変えると押せ、押すと最初の値と選択に戻って押せなくなる', (tester) async {
      await pumpDetail(tester, 'container');
      await setSlider(tester, 40);
      await select(tester, 'color');
      expect(resetButton(tester).onPressed, isNotNull);

      await tester.tap(find.byTooltip('初期状態に戻す'));
      await tester.pumpAndSettle();

      expect(preview<Container>(tester).padding, const EdgeInsets.all(16));
      expect(inPanel(find.text('padding')), findsOneWidget);
      expect(resetButton(tester).onPressed, isNull);
    });
  });

  testWidgets('TC-65: 既定に戻すと、そのプロパティだけ最初の値に戻る', (tester) async {
    await pumpDetail(tester, 'container');
    await select(tester, 'color');
    await tester.tap(inPanel(find.bySemanticsLabel('紅')));
    await select(tester, 'padding');
    await setSlider(tester, 32);

    await tester.tap(inPanel(find.text('既定に戻す')));
    await tester.pumpAndSettle();

    expect(preview<Container>(tester).padding, const EdgeInsets.all(16));
    expect(preview<Container>(tester).color, const Color(0xFFD7003A));
  });

  testWidgets('TC-66: alignment の左上のマスを押すと、子が左上に動き名前とコードが出る', (tester) async {
    await pumpDetail(tester, 'container');
    await select(tester, 'alignment');
    await toggle(tester);

    await tester.tap(inPanel(find.bySemanticsLabel('topLeft')));
    await tester.pumpAndSettle();

    expect(preview<Container>(tester).alignment, Alignment.topLeft);
    expect(inPanel(find.text('topLeft')), findsOneWidget);
    expect(inPanel(find.text('Alignment.topLeft')), findsOneWidget);
  });

  testWidgets('プロパティを切り替えると、編集パネルを先頭から見せる', (tester) async {
    await pumpDetail(tester, 'container');
    // 編集パネルがスクロールする、横向きの低い画面
    tester.view.physicalSize = const Size(2622, 1206);
    await tester.pumpAndSettle();
    await select(tester, 'color');
    final scrollable = find
        .ancestor(
          of: find.byType(EditorPanel),
          matching: find.byType(Scrollable),
        )
        .first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(80);
    await tester.pump();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 80);

    await select(tester, 'padding');

    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
  });

  testWidgets('チップを選び替えても、スライダーの吹き出しが出る', (tester) async {
    await pumpDetail(tester, 'container');

    await select(tester, 'color');
    await select(tester, 'padding');

    expect(inPanel(find.text('16.0')), findsOneWidget);
  });

  testWidgets('初期状態に戻すと、画面の外の最初のチップを見える位置まで送る', (tester) async {
    await pumpDetail(tester, 'text');
    await select(tester, 'overflow');
    await toggle(tester);
    expect(tester.getRect(chip('data')).right, lessThan(0));

    await tester.tap(find.byTooltip('初期状態に戻す'));
    await tester.pumpAndSettle();

    final screen = tester.getRect(find.byType(DetailScreen));
    expect(screen.contains(tester.getRect(chip('data')).center), isTrue);
  });

  group('コードの帯', () {
    testWidgets('TC-62: padding を 24 にすると帯がその行になり、変えた印が付く', (tester) async {
      await pumpDetail(tester, 'container');
      expect(find.byKey(CodeStrip.changedKey), findsNothing);

      await setSlider(tester, 24);

      expect(stripText(tester), 'padding: EdgeInsets.all(24.0),');
      expect(find.byKey(CodeStrip.changedKey), findsOneWidget);
    });

    testWidgets('TC-63: width（OFF）を選ぶと「// width は指定なし（既定値）」', (tester) async {
      await pumpDetail(tester, 'container');

      await select(tester, 'width');

      expect(stripText(tester), '// width は指定なし（既定値）');
    });
  });

  group('コードの全文', () {
    testWidgets('横向きでも、シートは本文が見える高さで開く', (tester) async {
      await pumpDetail(tester, 'container');
      // 874×402 の横向き
      tester.view.physicalSize = const Size(2622, 1206);
      await tester.pumpAndSettle();

      await openCodeSheet(tester);

      expect(
        tester.getSize(find.byType(BottomSheet)).height,
        greaterThanOrEqualTo(360),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-42: 帯から開き、コピーすると全文が入り「コードをコピーしました」', (tester) async {
      await pumpDetail(tester, 'container');
      await setSlider(tester, 24);
      await openCodeSheet(tester);

      expect(find.text('コード'), findsOneWidget);
      expect(find.text('既定から変えた行'), findsOneWidget);
      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(clipboard.written, [
        'Container(\n'
            '  padding: EdgeInsets.all(24.0),\n'
            '  color: Color(0xFF1E50A2),\n'
            '  child: FlutterLogo(),\n'
            ')',
      ]);
      expect(find.text('コードをコピーしました'), findsOneWidget);
    });

    testWidgets('TC-43: 書けなければ「コピーできませんでした」', (tester) async {
      await pumpDetail(tester, 'padding', clipboardSucceeds: false);
      await openCodeSheet(tester);

      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(find.text('コピーできませんでした'), findsOneWidget);
    });
  });

  group('説明のシート', () {
    testWidgets('ⓘ から開き、見出し・ジャンル・説明文が出る', (tester) async {
      await pumpDetail(tester, 'container');

      await openAboutSheet(tester);

      expect(find.text('Container について'), findsOneWidget);
      expect(find.text('Basics'), findsOneWidget);
      expect(find.text('Layout'), findsOneWidget);
      expect(find.text(containerEntry.description), findsOneWidget);
    });

    testWidgets('TC-44: 公式ドキュメントを開くと、その Widget の URL で開こうとする', (tester) async {
      await pumpDetail(tester, 'container');
      await openAboutSheet(tester);

      await tester.tap(find.text('公式ドキュメントを開く'));
      await tester.pump();

      expect(launcher.opened, [containerEntry.docUrl]);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('TC-45: 開けなければ「ブラウザを開けませんでした」', (tester) async {
      await pumpDetail(tester, 'container', launcherSucceeds: false);
      await openAboutSheet(tester);

      await tester.tap(find.text('公式ドキュメントを開く'));
      await tester.pump();

      expect(find.text('ブラウザを開けませんでした'), findsOneWidget);
    });
  });

  testWidgets('TC-46: 値を変えて戻り、もう一度開くと最初の値に戻っている', (tester) async {
    await pumpDetail(tester, 'padding', viaHome: true);
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();
    await setSlider(tester, 40);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    expect(preview<Padding>(tester).padding, const EdgeInsets.all(16));
  });

  testWidgets('変えられるプロパティがなければ、その旨を出し、チップと帯を出さない', (tester) async {
    await pumpDetail(
      tester,
      'none',
      repository: FakeCatalogRepository([noPropertyEntry]),
    );

    expect(find.text('この Widget には変えられるプロパティがありません'), findsOneWidget);
    expect(find.byType(PropertyChip), findsNothing);
    expect(find.byType(CodeStrip), findsNothing);
  });

  group('プレビューの高さ', () {
    double previewHeight(WidgetTester tester) =>
        tester.getSize(find.byKey(DetailScreen.previewAreaKey)).height;

    testWidgets('画面の高さの約 3.5 割', (tester) async {
      await pumpDetail(tester, 'padding');

      expect(previewHeight(tester), closeTo(874 * 0.35, 1));
    });

    testWidgets('キーボードが出たら、画面の高さの約 2 割に縮める', (tester) async {
      await pumpDetail(tester, 'text');

      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(previewHeight(tester), closeTo(874 * 0.2, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('文字を 2 倍にして横向きでキーボードを出しても、はみ出さない', (tester) async {
      await pumpDetail(tester, 'text');
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.physicalSize = const Size(2622, 1206);
      tester.view.viewInsets = const FakeViewPadding(bottom: 360);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(DetailScreen.panelAreaKey)).height,
        greaterThanOrEqualTo(96),
      );
    });

    testWidgets('仲間のタブがある Container を低い画面で開いても、はみ出さず編集パネルが残る', (tester) async {
      await pumpDetail(tester, 'container');
      // 874×402 の横向き
      tester.view.physicalSize = const Size(2622, 1206);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(GroupTabs), findsOneWidget);
      expect(
        tester.getSize(find.byKey(DetailScreen.panelAreaKey)).height,
        greaterThanOrEqualTo(96),
      );
    });

    testWidgets('横向きでキーボードを出し比較しても、はみ出さず編集パネルが残る', (tester) async {
      await pumpDetail(tester, 'text');
      await tester.tap(inPanel(find.text('比べる')));
      await tester.pumpAndSettle();

      // 874×402 の横向きに、高さ 120 のキーボード
      tester.view.physicalSize = const Size(2622, 1206);
      tester.view.viewInsets = const FakeViewPadding(bottom: 360);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(DetailScreen.panelAreaKey)).height,
        greaterThanOrEqualTo(96),
      );
    });
  });

  group('ログの帯（見た目を持たない Widget）', () {
    Future<void> pumpBehavior(WidgetTester tester) async {
      await pumpDetail(
        tester,
        'behavior',
        repository: FakeCatalogRepository([behaviorEntry]),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('TC-74: 最初の組み立てのログと件数を出し、押すとシートに全件', (tester) async {
      await pumpBehavior(tester);

      expect(find.byType(LogStrip), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LogStrip),
          matching: find.text('読む子を build（1 回目）'),
        ),
        findsOneWidget,
      );
      expect(find.text('build 1 回'), findsOneWidget);

      await tester.tap(find.byType(LogStrip));
      await tester.pumpAndSettle();

      expect(find.byType(LogSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LogSheet),
          matching: find.text('読む子を build（1 回目）'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-74: 見た目を持つ Widget では帯を出さない', (tester) async {
      await pumpDetail(tester, 'padding');

      expect(find.byType(LogStrip), findsNothing);
    });

    testWidgets('TC-37: シートで「ログを消す」と帯も空になり、回数の印が 0 回', (tester) async {
      await pumpBehavior(tester);
      await tester.tap(find.byType(LogStrip));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ログを消す'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(LogSheet),
          matching: find.text('まだ何も起きていません'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(LogStrip),
          matching: find.text('まだ何も起きていません'),
        ),
        findsOneWidget,
      );
      expect(find.text('build 0 回'), findsOneWidget);
    });
  });

  group('比べる（見た目を持たない Widget）', () {
    Future<void> pumpBehavior(
      WidgetTester tester, [
      String id = 'behavior',
    ]) async {
      await pumpDetail(
        tester,
        id,
        repository: FakeCatalogRepository([
          behaviorEntry,
          behaviorWithCodeEntry,
        ]),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('TC-75: 「使わない場合と比べる」で左に「使った」右に「使わない」、左右で別に数える', (tester) async {
      await pumpBehavior(tester);

      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pumpAndSettle();

      expect(find.byType(ComparePreview), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ComparePreview),
          matching: find.text('使った'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ComparePreview),
          matching: find.text('使わない'),
        ),
        findsOneWidget,
      );
      expect(inPanel(find.text('比べるのをやめる')), findsOneWidget);
      // 比べ始めると計測をやり直し、左右とも 1 回目から数える
      expect(find.text('build 1 回'), findsNWidgets(2));
      // ログの帯の最新に側の札
      expect(
        find.descendant(
          of: find.byType(LogStrip),
          matching: find.textContaining('使'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TC-76: 比較中に別のチップを選んでも比較が続く', (tester) async {
      await pumpBehavior(tester);
      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pumpAndSettle();

      await tester.tap(chip('mode'));
      await tester.pumpAndSettle();

      expect(find.byType(ComparePreview), findsOneWidget);
      expect(inPanel(find.text('比べるのをやめる')), findsOneWidget);
    });

    testWidgets('cd-side: 使わない側のコードに切り替えると、印なしで出てコピーもそのコード', (tester) async {
      await pumpBehavior(tester, 'behaviorCode');
      await openCodeSheet(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<bool>),
          matching: find.text('使わない'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(find.textContaining('class Plain'), findsOneWidget);
      expect(clipboard.written, [behaviorWithCodeEntry.codeWithout]);
    });

    testWidgets('cd-side: 使わない側のコードがなければ切り替えを出さない', (tester) async {
      await pumpBehavior(tester);
      await openCodeSheet(tester);

      expect(find.byType(SegmentedButton<bool>), findsNothing);
    });
  });

  group('MediaQuery', () {
    Future<void> pumpMediaQuery(WidgetTester tester) async {
      await pumpDetail(
        tester,
        'mediaQuery',
        repository: FakeCatalogRepository([mediaQueryEntry]),
      );
      await tester.pumpAndSettle();
    }

    /// [label] の子の回数の印の文。[nth] は左右の何枚目か（0 が左・使った）。
    String badgeOf(WidgetTester tester, String label, {int nth = 0}) => tester
        .widget<Semantics>(
          find
              .descendant(
                of: find.byType(DetailScreen),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is Semantics &&
                      (w.properties.label?.startsWith('$label、') ?? false),
                ),
              )
              .at(nth),
        )
        .properties
        .label!;

    testWidgets('TC-34: 倍率を 1.5 にすると、倍率を読む子だけ build が増える', (tester) async {
      await pumpMediaQuery(tester);

      expect(badgeOf(tester, '倍率を読む子'), '倍率を読む子、build 1 回');
      expect(badgeOf(tester, '明るさを読む子'), '明るさを読む子、build 1 回');
      expect(badgeOf(tester, '読まない子'), '読まない子、build 1 回');

      await setSlider(tester, 1.5);

      expect(find.text('倍率 1.5'), findsOneWidget);
      expect(badgeOf(tester, '倍率を読む子'), '倍率を読む子、build 2 回');
      expect(badgeOf(tester, '明るさを読む子'), '明るさを読む子、build 1 回');
      expect(badgeOf(tester, '読まない子'), '読まない子、build 1 回');
      expect(stripText(tester), 'textScaler: TextScaler.linear(1.5),');
    });

    testWidgets('TC-75: 比べると、左の倍率を読む子だけ増え、右は増えない。ログに側の札', (tester) async {
      await pumpMediaQuery(tester);
      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pumpAndSettle();
      final usedBefore = badgeOf(tester, '倍率を読む子');
      final unusedBefore = badgeOf(tester, '倍率を読む子', nth: 1);

      await setSlider(tester, 1.5);

      expect(usedBefore, '倍率を読む子、build 1 回');
      expect(badgeOf(tester, '倍率を読む子'), '倍率を読む子、build 2 回');
      expect(unusedBefore, '倍率を読む子、build 1 回');
      expect(badgeOf(tester, '倍率を読む子', nth: 1), '倍率を読む子、build 1 回');
      expect(
        find.descendant(of: find.byType(LogStrip), matching: find.text('使った')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('明るさを dark にすると、明るさを読む子だけ build が増える', (tester) async {
      await pumpMediaQuery(tester);
      await select(tester, 'platformBrightness');
      await toggle(tester);
      await tester.tap(inPanel(find.text('dark')));
      await tester.pumpAndSettle();

      expect(find.text('dark'), findsWidgets);
      expect(badgeOf(tester, '倍率を読む子'), '倍率を読む子、build 1 回');
      // ON にしただけの light は親と同じ値なので知らせが来ず、dark で 1 回増える
      expect(badgeOf(tester, '明るさを読む子'), '明るさを読む子、build 2 回');
    });
  });

  group('StreamBuilder', () {
    Future<void> pumpStream(WidgetTester tester) async {
      await pumpDetail(
        tester,
        'streamBuilder',
        repository: FakeCatalogRepository([
          streamBuilderEntry,
          mediaQueryEntry,
        ]),
      );
      await tester.pumpAndSettle();
    }

    /// 収録データが出したログの文（ProbeState は新しい順なので、反転して古い順に）。
    /// [side] を渡せばその側だけ。
    List<String> textLogs(WidgetTester tester, {DemoSide? side}) =>
        ProviderScope.containerOf(tester.element(find.byType(DetailScreen)))
            .read(probeProvider('streamBuilder'))
            .logs
            .reversed
            .where((log) => side == null || log.side == side)
            .map((log) => log.message)
            .whereType<TextMessage>()
            .map((message) => message.text)
            .toList();

    /// [label] の子の回数の印の文。[nth] は左右の何枚目か（0 が左・使った）。
    String badgeOf(WidgetTester tester, String label, {int nth = 0}) => tester
        .widget<Semantics>(
          find
              .descendant(
                of: find.byType(DetailScreen),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is Semantics &&
                      (w.properties.label?.startsWith('$label、') ?? false),
                ),
              )
              .at(nth),
        )
        .properties
        .label!;

    /// 時を 1 秒ずつ [seconds] 秒進める（値は 1 秒おきに来るので、1 つずつフレームに出す）。
    Future<void> elapse(WidgetTester tester, int seconds) async {
      for (var i = 0; i < seconds; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();
    }

    Future<void> restart(WidgetTester tester, {int nth = 0}) async {
      await tester.tap(find.text('最初から流す').at(nth));
      await tester.pump();
    }

    testWidgets('TC-81: 開くと流れ始め、waiting から値が順に来て閉じる', (tester) async {
      await pumpStream(tester);
      expect(textLogs(tester), ['waiting']);

      await elapse(tester, 4);

      expect(textLogs(tester), [
        'waiting',
        'active: 1',
        'active: 2',
        'active: 3',
        'done: 3',
      ]);
    });

    testWidgets('TC-81: 「最初から流す」で waiting から流し直し、外の子は増えない', (tester) async {
      await pumpStream(tester);
      await elapse(tester, 2);

      await restart(tester);
      await elapse(tester, 4);

      expect(textLogs(tester).skip(3), [
        'waiting',
        'active: 1',
        'active: 2',
        'active: 3',
        'done: 3',
      ]);
      expect(badgeOf(tester, '外の子'), '外の子、build 1 回');
      expect(find.text('done: 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC-81: 比較中の「使わない」側では、値が来るたびに外の子も増える', (tester) async {
      await pumpStream(tester);
      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pump();

      await elapse(tester, 4);

      expect(textLogs(tester, side: DemoSide.unused), [
        'waiting',
        'active: 1',
        'active: 2',
        'active: 3',
        'done: 3',
      ]);
      expect(badgeOf(tester, '外の子'), '外の子、build 1 回');
      // 最初の 1 回 + 値 3 回 + 閉じた 1 回
      expect(badgeOf(tester, '外の子', nth: 1), '外の子、build 5 回');
    });

    testWidgets('比較中の「使わない」側も「最初から流す」で waiting から流し直す', (tester) async {
      await pumpStream(tester);
      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pump();
      await elapse(tester, 2);

      await restart(tester, nth: 1);
      await elapse(tester, 4);

      expect(textLogs(tester, side: DemoSide.unused).skip(3), [
        'waiting',
        'active: 1',
        'active: 2',
        'active: 3',
        'done: 3',
      ]);
    });

    testWidgets('途中でエラーに選び替えると流し直し、エラーを持ったまま閉じる', (tester) async {
      await pumpStream(tester);
      await select(tester, 'stream');
      final before = textLogs(tester).length;
      await tester.tap(inPanel(find.text('途中でエラー')));
      await tester.pump();

      await elapse(tester, 3);

      expect(textLogs(tester).skip(before), [
        'waiting',
        'active: 1',
        'active: Exception: 途中で失敗',
        'done: Exception: 途中で失敗',
      ]);
    });

    testWidgets('何も流さないと waiting のまま', (tester) async {
      await pumpStream(tester);
      await select(tester, 'stream');
      final before = textLogs(tester).length;
      await tester.tap(inPanel(find.text('何も流さない')));
      await tester.pump();

      await elapse(tester, 4);

      expect(textLogs(tester).skip(before), ['waiting']);
    });

    testWidgets('stream を OFF にすると none のまま', (tester) async {
      await pumpStream(tester);
      await select(tester, 'stream');
      await toggle(tester);
      final before = textLogs(tester).length;

      await elapse(tester, 4);

      expect(textLogs(tester).last, 'none');
      expect(textLogs(tester).skip(before), isEmpty);
    });

    testWidgets('initialData を ON にすると、待っている間も 0 を持つ', (tester) async {
      await pumpStream(tester);
      await select(tester, 'initialData');
      await toggle(tester);

      expect(textLogs(tester).last, 'waiting: 0');
      expect(stripText(tester), 'initialData: 0,');
    });

    testWidgets('TC-77: コードのシートで「使わない」を選ぶと listen する書き方が出て、コピーもそれ', (
      tester,
    ) async {
      await pumpStream(tester);
      await openCodeSheet(tester);

      expect(find.textContaining('=> Status(snapshot)'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<bool>),
          matching: find.text('使わない'),
        ),
      );
      await tester.pumpAndSettle();
      // 長いコードでボタンが下へ押し出されるので、見える位置まで送る
      await tester.ensureVisible(find.text('コードをコピー'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('コードをコピー'));
      await tester.pump();

      expect(find.textContaining('.listen('), findsOneWidget);
      expect(clipboard.written, [streamBuilderEntry.codeWithout]);
    });

    testWidgets('TC-77: MediaQuery では「使った／使わない」の切り替えが出ない', (tester) async {
      await pumpDetail(
        tester,
        'mediaQuery',
        repository: FakeCatalogRepository([mediaQueryEntry]),
      );
      await tester.pumpAndSettle();
      await openCodeSheet(tester);

      expect(find.byType(SegmentedButton<bool>), findsNothing);
    });
  });

  group('計測のやり直し', () {
    Future<void> pumpMediaQuery(WidgetTester tester) async {
      await pumpDetail(
        tester,
        'mediaQuery',
        repository: FakeCatalogRepository([mediaQueryEntry]),
      );
      await tester.pumpAndSettle();
    }

    int logCount(WidgetTester tester) => int.parse(
      tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(LogStrip),
              matching: find.textContaining(' 件'),
            ),
          )
          .single
          .data!
          .split(' ')
          .first,
    );

    testWidgets('TC-73: 初期状態に戻すと、開いたときと同じ（どの子も 1 回・その分のログだけ）', (tester) async {
      await pumpMediaQuery(tester);
      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(1.5);
      await tester.pumpAndSettle();
      expect(find.text('build 2 回'), findsOneWidget);

      await tester.tap(find.byTooltip('初期状態に戻す'));
      await tester.pumpAndSettle();

      expect(find.text('build 1 回'), findsNWidgets(3));
      expect(find.text('build 2 回'), findsNothing);
      expect(logCount(tester), 3);
    });

    testWidgets('比べるのをやめても、計測をやり直す', (tester) async {
      await pumpMediaQuery(tester);
      await tester.tap(find.text('使わない場合と比べる'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('比べるのをやめる'));
      await tester.pumpAndSettle();

      expect(find.text('build 1 回'), findsNWidgets(3));
      expect(logCount(tester), 3);
    });

    testWidgets('「ログを消す」は計測をやり直さず、回数を 0 にする', (tester) async {
      await pumpMediaQuery(tester);
      await tester.tap(find.byType(LogStrip));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ログを消す'));
      await tester.pumpAndSettle();

      expect(find.text('build 0 回'), findsNWidgets(3));
    });
  });

  group('NotificationListener', () {
    Future<void> pumpListener(WidgetTester tester) async {
      await pumpDetail(
        tester,
        'notificationListener',
        repository: FakeCatalogRepository([notificationListenerEntry]),
      );
      await tester.pumpAndSettle();
    }

    /// [side] のログの文（起きた順。build の記録は除く）。
    List<String> logsOf(WidgetTester tester, [DemoSide side = DemoSide.used]) {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DetailScreen)),
      );
      return [
        for (final log
            in container
                .read(probeProvider('notificationListener'))
                .logs
                .reversed)
          if (log
              case ProbeLog(side: final s, message: TextMessage(:final text))
              when s == side)
            text,
      ];
    }

    int outerCount(WidgetTester tester) =>
        logsOf(tester).where((text) => text.startsWith('外:')).length;

    /// デモの木の ListView を [offset] だけ動かす。[nth] は左右の何枚目か（0 が左・使った）。
    Future<void> scroll(
      WidgetTester tester, {
      int nth = 0,
      Offset offset = const Offset(0, -60),
    }) async {
      await tester.drag(
        find
            .descendant(
              of: find.byType(RebuildCounter),
              matching: find.byType(ListView),
            )
            .at(nth),
        offset,
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'TC-82: スクロールすると「内:」「外:」が出て、ListView は 1 回のまま。true にした後は「外:」が出ない',
      (tester) async {
        await pumpListener(tester);

        await scroll(tester);

        final logs = logsOf(tester);
        expect(logs, contains('内: ScrollUpdateNotification'));
        expect(logs, contains('外: ScrollUpdateNotification'));
        // 通知は内から外へ上がる
        expect(
          logs.indexOf('内: ScrollStartNotification'),
          lessThan(logs.indexOf('外: ScrollStartNotification')),
        );
        expect(
          find.descendant(
            of: find.byType(LogStrip),
            matching: find.textContaining('外: ScrollEndNotification'),
          ),
          findsOneWidget,
        );
        expect(find.text('build 1 回'), findsOneWidget);
        expect(stripText(tester), 'NotificationListener<ScrollNotification>(');

        await select(tester, 'onNotification');
        await tester.tap(inPanel(find.text('true')));
        await tester.pumpAndSettle();
        final outerBefore = outerCount(tester);
        final innerBefore = logsOf(tester).length - outerBefore;

        await scroll(tester);

        expect(outerCount(tester), outerBefore);
        expect(
          logsOf(tester).length - outerCount(tester),
          greaterThan(innerBefore),
        );
        // 戻り値を変えても型は同じなので、ListView は組み直されない
        expect(find.text('build 1 回'), findsOneWidget);
      },
    );

    testWidgets('受ける型を ScrollUpdateNotification にすると、「内:」はその型だけ', (
      tester,
    ) async {
      await pumpListener(tester);
      await tester.tap(inPanel(find.text('ScrollUpdateNotification')));
      await tester.pumpAndSettle();

      await scroll(tester);

      final inner = logsOf(tester).where((text) => text.startsWith('内:'));
      expect(inner, isNotEmpty);
      expect(inner.toSet(), {'内: ScrollUpdateNotification'});
      expect(
        stripText(tester),
        'NotificationListener<ScrollUpdateNotification>(',
      );
    });

    testWidgets('受ける型を OverscrollNotification にすると、端を越えて引いたときだけ「内:」', (
      tester,
    ) async {
      await pumpListener(tester);
      await tester.tap(inPanel(find.text('OverscrollNotification')));
      await tester.pumpAndSettle();

      await scroll(tester);
      expect(logsOf(tester).where((text) => text.startsWith('内:')), isEmpty);

      // 先頭まで戻して、さらに下へ引く
      await scroll(tester, offset: const Offset(0, 200));

      final inner = logsOf(tester).where((text) => text.startsWith('内:'));
      expect(inner.toSet(), {'内: OverscrollNotification'});
    }, variant: TargetPlatformVariant.mobile());

    testWidgets('TC-82: 使わない側では「外:」だけ出る', (tester) async {
      await pumpListener(tester);
      await tester.ensureVisible(inPanel(find.text('使わない場合と比べる')));
      await tester.tap(inPanel(find.text('使わない場合と比べる')));
      await tester.pumpAndSettle();

      await scroll(tester, nth: 1);

      final logs = logsOf(tester, DemoSide.unused);
      expect(logs, contains('外: ScrollUpdateNotification'));
      expect(logs.where((text) => text.startsWith('内:')), isEmpty);
      expect(logsOf(tester), isEmpty);
    });
  });

  group('仲間のタブ（TC-84）', () {
    testWidgets('タブと ON の数が出て、開いたときは最初の ON の仲間', (tester) async {
      await pumpDetail(tester, 'container');
      expect(find.byType(GroupTabs), findsOneWidget);
      expect(find.bySemanticsLabel('余白、ON が 1 件'), findsOneWidget);
      // 最初の ON は padding（余白）
      expect(find.widgetWithText(PropertyChip, 'padding'), findsOneWidget);
      expect(find.widgetWithText(PropertyChip, 'width'), findsNothing);
    });

    testWidgets('タブを替えると、その仲間のチップだけになる', (tester) async {
      await pumpDetail(tester, 'container');
      await tester.tap(find.text('大きさ'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(PropertyChip, 'width'), findsOneWidget);
      expect(find.widgetWithText(PropertyChip, 'padding'), findsNothing);
    });

    testWidgets('読み上げの操作で仲間のタブを押せる', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDetail(tester, 'container');
      tester.semantics.tap(find.semantics.byLabel('大きさ、ON が 0 件'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(PropertyChip, 'width'), findsOneWidget);
      expect(find.widgetWithText(PropertyChip, 'padding'), findsNothing);
      handle.dispose();
    });

    testWidgets('requires の相手が OFF のチップは薄い', (tester) async {
      await pumpDetail(tester, 'container');
      await tester.tap(find.text('変形'));
      await tester.pumpAndSettle();
      final chip = tester.widget<PropertyChip>(
        find.widgetWithText(PropertyChip, 'transformAlignment'),
      );
      expect(chip.dimmed, isTrue);
      final dimmedOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.widgetWithText(PropertyChip, 'transformAlignment'),
          matching: find.byType(Opacity),
        ),
      );
      expect(dimmedOpacity.opacity, 0.5);
      final normalOpacity = tester.widget<Opacity>(
        find.descendant(
          of: find.widgetWithText(PropertyChip, 'transform'),
          matching: find.byType(Opacity),
        ),
      );
      expect(normalOpacity.opacity, 1);
    });
  });
}
