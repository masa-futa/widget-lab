import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/probe/log_strip.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

import '../pump.dart';

const _entryId = 'behavior';

void main() {
  late ProviderContainer container;
  late int tapped;

  setUp(() {
    tapped = 0;
    container = ProviderContainer(
      overrides: [
        probeClockProvider.overrideWithValue(() => DateTime(2026, 10, 28)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(probeProvider(_entryId), (_, _) {});
  });

  void record(List<ProbeEvent> events) =>
      container.read(probeProvider(_entryId).notifier).recorded(events);

  Future<void> pumpStrip(WidgetTester tester) => pumpPart(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: LogStrip(entryId: _entryId, onTap: () => tapped++),
    ),
  );

  testWidgets('TC-74: 最新の 1 件と件数を出し、押せる', (tester) async {
    record(const [
      BuildEvent(side: DemoSide.used, label: '読まない子'),
      BuildEvent(side: DemoSide.used, label: '読む子'),
      BuildEvent(side: DemoSide.used, label: '読む子'),
    ]);
    await pumpStrip(tester);

    expect(find.text('読む子を build（2 回目）'), findsOneWidget);
    expect(find.text('3 件'), findsOneWidget);

    await tester.tap(find.byType(LogStrip));

    expect(tapped, 1);
  });

  testWidgets('TC-74: ログが 0 件なら「まだ何も起きていません」', (tester) async {
    await pumpStrip(tester);

    expect(find.text('まだ何も起きていません'), findsOneWidget);
    expect(find.text('0 件'), findsOneWidget);
  });

  testWidgets('比較中に起きたものは、文の前に側の札を付ける', (tester) async {
    record(const [
      BuildEvent(side: DemoSide.unused, label: '読む子', comparing: true),
    ]);
    await pumpStrip(tester);

    expect(find.text('使わない'), findsOneWidget);
    expect(find.text('読む子を build（1 回目）'), findsOneWidget);
  });

  testWidgets('まとめた出来事は「×n」を付ける', (tester) async {
    record(const [LogEvent(side: DemoSide.used, text: '内: Scroll', repeat: 6)]);
    await pumpStrip(tester);

    expect(find.text('内: Scroll ×6'), findsOneWidget);
  });

  testWidgets('「ログ、{n} 件、最新: …」と読み、ボタンとして扱う', (tester) async {
    final semantics = tester.ensureSemantics();
    record(const [BuildEvent(side: DemoSide.used, label: '読む子')]);
    await pumpStrip(tester);

    expect(
      tester.getSemantics(find.byType(LogStrip)),
      matchesSemantics(
        label: 'ログ、1 件、最新: 読む子を build（1 回目）',
        isButton: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
