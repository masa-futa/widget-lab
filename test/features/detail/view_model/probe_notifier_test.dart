import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

void main() {
  late DateTime now;

  ProviderContainer makeContainer() {
    now = DateTime(2026, 10, 28, 9, 30, 15);
    final container = ProviderContainer(
      overrides: [probeClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    return container;
  }

  ProbeState read(ProviderContainer container) =>
      container.read(probeProvider('mediaQuery'));

  ProbeNotifier notifierOf(ProviderContainer container) =>
      container.read(probeProvider('mediaQuery').notifier);

  const usedReader = ProbeKey(DemoSide.used, '読む子');

  test('開いたときは回数もログも空', () {
    final container = makeContainer();

    final state = read(container);

    expect(state.counts, isEmpty);
    expect(state.logs, isEmpty);
    expect(state.countOf(usedReader), 0);
  });

  test('build の記録で回数が増え、「n 回目」のログが付く', () {
    final container = makeContainer();

    notifierOf(container).recorded(const [
      BuildEvent(side: DemoSide.used, label: '読む子'),
      BuildEvent(side: DemoSide.used, label: '読む子'),
    ]);

    final state = read(container);
    expect(state.countOf(usedReader), 2);
    expect(state.logs.map((log) => log.message), const [
      BuildMessage(label: '読む子', count: 2),
      BuildMessage(label: '読む子', count: 1),
    ]);
    expect(state.logs.first.time, now);
  });

  test('使った側と使わない側を別に数え、比較中に起きたかを残す', () {
    final container = makeContainer();

    notifierOf(container).recorded(const [
      BuildEvent(side: DemoSide.used, label: '読む子', comparing: true),
      BuildEvent(side: DemoSide.unused, label: '読む子', comparing: true),
      BuildEvent(side: DemoSide.unused, label: '読む子', comparing: true),
    ]);

    final state = read(container);
    expect(state.countOf(usedReader), 1);
    expect(state.countOf(const ProbeKey(DemoSide.unused, '読む子')), 2);
    expect(state.logs.first.side, DemoSide.unused);
    expect(state.logs.every((log) => log.comparing), isTrue);
  });

  test('出来事のログは文と、まとめた数をそのまま持つ', () {
    final container = makeContainer();

    notifierOf(container).recorded(const [
      LogEvent(
        side: DemoSide.used,
        text: 'ScrollUpdateNotification',
        repeat: 6,
      ),
    ]);

    final log = read(container).logs.single;
    expect(log.message, const TextMessage('ScrollUpdateNotification'));
    expect(log.repeat, 6);
    expect(log.comparing, isFalse);
  });

  test('TC-36: 50 件あるところにもう 1 件起きると、一番古いものが消えて 50 件のまま', () {
    final container = makeContainer();
    final notifier = notifierOf(container);
    for (var i = 0; i < ProbeNotifier.maxLogs; i++) {
      notifier.recorded([LogEvent(side: DemoSide.used, text: '$i')]);
    }
    expect(read(container).logs, hasLength(50));

    notifier.recorded(const [LogEvent(side: DemoSide.used, text: 'new')]);

    final logs = read(container).logs;
    expect(logs, hasLength(50));
    expect(logs.first.message, const TextMessage('new'));
    expect(logs.last.message, const TextMessage('1'));
  });

  test('TC-37: ログを消すと回数も 0 になり、次の build は 1 から数える', () {
    final container = makeContainer();
    final notifier = notifierOf(container);
    notifier.recorded(const [
      BuildEvent(side: DemoSide.used, label: '読む子'),
      BuildEvent(side: DemoSide.used, label: '読む子'),
    ]);

    notifier.logCleared();

    expect(read(container).counts, isEmpty);
    expect(read(container).logs, isEmpty);

    notifier.recorded(const [BuildEvent(side: DemoSide.used, label: '読む子')]);

    expect(read(container).countOf(usedReader), 1);
    expect(
      read(container).logs.single.message,
      const BuildMessage(label: '読む子', count: 1),
    );
  });
}
