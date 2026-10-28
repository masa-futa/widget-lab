import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/probe/log_sheet.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

import '../pump.dart';

const _entryId = 'behavior';

void main() {
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 10, 28, 12, 3, 31);
    container = ProviderContainer(
      overrides: [probeClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    container.listen(probeProvider(_entryId), (_, _) {});
  });

  void record(List<ProbeEvent> events) =>
      container.read(probeProvider(_entryId).notifier).recorded(events);

  Future<void> pumpSheet(WidgetTester tester) => pumpPart(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: const SingleChildScrollView(child: LogSheet(entryId: _entryId)),
    ),
  );

  testWidgets('TC-74: 新しい順に全件を、時刻と側の札つきで出す', (tester) async {
    record(const [BuildEvent(side: DemoSide.used, label: '読む子')]);
    now = DateTime(2026, 10, 28, 12, 3, 48);
    record(const [
      BuildEvent(side: DemoSide.unused, label: '読む子', comparing: true),
    ]);
    await pumpSheet(tester);

    expect(find.text('ログ'), findsOneWidget);
    expect(find.text('読む子を build（1 回目）'), findsNWidgets(2));
    // 新しい（12:03:48・使わない）が上
    expect(
      tester.getTopLeft(find.text('12:03:48')).dy,
      lessThan(tester.getTopLeft(find.text('12:03:31')).dy),
    );
    expect(find.text('使わない'), findsOneWidget);
    // 比較していないときに起きた行には札を出さない
    expect(find.text('使った'), findsNothing);
  });

  testWidgets('TC-74: ログが 0 件なら「まだ何も起きていません」', (tester) async {
    await pumpSheet(tester);

    expect(find.text('まだ何も起きていません'), findsOneWidget);
  });

  testWidgets('TC-37: 「ログを消す」でログと回数が空になり、開いたまま空を出す', (tester) async {
    record(const [BuildEvent(side: DemoSide.used, label: '読む子')]);
    await pumpSheet(tester);

    await tester.tap(find.text('ログを消す'));
    await tester.pump();

    expect(find.text('まだ何も起きていません'), findsOneWidget);
    expect(container.read(probeProvider(_entryId)).counts, isEmpty);
  });

  testWidgets('開いている間に起きたものもすぐ足す', (tester) async {
    await pumpSheet(tester);

    record(const [LogEvent(side: DemoSide.used, text: '外: Scroll')]);
    await tester.pump();

    expect(find.text('外: Scroll'), findsOneWidget);
  });
}
