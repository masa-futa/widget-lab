import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/probe/rebuild_badge.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

import '../pump.dart';

const _entryId = 'behavior';
const _key = ProbeKey(DemoSide.used, '読む子');

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        probeClockProvider.overrideWithValue(() => DateTime(2026, 10, 28)),
      ],
    );
    addTearDown(container.dispose);
    // 印が外れたときの autoDispose の予約がテストの後に残らないように持ち続ける
    container.listen(probeProvider(_entryId), (_, _) {});
  });

  void build(int times) =>
      container.read(probeProvider(_entryId).notifier).recorded([
        for (var i = 0; i < times; i++)
          const BuildEvent(side: DemoSide.used, label: '読む子'),
      ]);

  Future<void> pumpBadge(WidgetTester tester, {bool reduceMotion = false}) =>
      pumpPart(
        tester,
        UncontrolledProviderScope(
          container: container,
          child: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: const Center(
              child: RebuildBadge(entryId: _entryId, probeKey: _key),
            ),
          ),
        ),
      );

  Color? badgeColor(WidgetTester tester) {
    final box = tester.widget<Container>(find.byKey(RebuildBadge.boxKey));
    return (box.decoration as BoxDecoration?)?.color;
  }

  testWidgets('TC-52: 回数を出し、増えた瞬間だけ地が accent に光る', (tester) async {
    build(3);
    await pumpBadge(tester);
    final scheme = Theme.of(tester.element(find.byType(RebuildBadge)))
        .colorScheme;

    expect(find.text('build 3 回'), findsOneWidget);
    expect(badgeColor(tester), isNot(scheme.primary));

    build(1);
    await tester.pump();

    expect(find.text('build 4 回'), findsOneWidget);
    expect(badgeColor(tester), scheme.primary);

    await tester.pump(const Duration(milliseconds: 200));

    expect(badgeColor(tester), isNot(scheme.primary));
  });

  testWidgets('TC-52: 視差効果を減らす設定なら光らない', (tester) async {
    build(3);
    await pumpBadge(tester, reduceMotion: true);
    final scheme = Theme.of(tester.element(find.byType(RebuildBadge)))
        .colorScheme;

    build(1);
    await tester.pump();

    expect(find.text('build 4 回'), findsOneWidget);
    expect(badgeColor(tester), isNot(scheme.primary));
  });

  testWidgets('TC-52: 「読む子、build 4 回」と読む', (tester) async {
    final semantics = tester.ensureSemantics();
    build(4);
    await pumpBadge(tester);

    expect(find.bySemanticsLabel('読む子、build 4 回'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('回数が 0 に戻っても光らない', (tester) async {
    build(2);
    await pumpBadge(tester);
    final scheme = Theme.of(tester.element(find.byType(RebuildBadge)))
        .colorScheme;

    container.read(probeProvider(_entryId).notifier).logCleared();
    await tester.pump();

    expect(find.text('build 0 回'), findsOneWidget);
    expect(badgeColor(tester), isNot(scheme.primary));
  });
}
