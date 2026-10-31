import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/features/detail/ui/probe/demo_probe.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

import '../pump.dart';

const _entryId = 'behavior';

/// build のたびに、同じ文を [times] 回ログに出す。
class _Logger extends StatelessWidget {
  const _Logger({required this.text, required this.times});

  final String text;
  final int times;

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < times; i++) {
      DemoRecorder.of(context).log(text);
    }
    return const SizedBox();
  }
}

/// 1 秒後に、フレームの外（タイマー）でログを 1 回出す。
class _TimerLogger extends StatefulWidget {
  const _TimerLogger();

  @override
  State<_TimerLogger> createState() => _TimerLoggerState();
}

class _TimerLoggerState extends State<_TimerLogger> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(seconds: 1),
      () => DemoRecorder.of(context).log('tick'),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

/// 倍率を読む子と読まない子。
class _Readers extends StatelessWidget {
  const _Readers();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RebuildCounter(
        label: '読む子',
        builder: (context) =>
            Text('${MediaQuery.textScalerOf(context).scale(1)}'),
      ),
      RebuildCounter(label: '読まない子', builder: (context) => const Text('固定')),
    ],
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        probeClockProvider.overrideWithValue(() => DateTime(2026, 10, 28)),
      ],
    );
    addTearDown(container.dispose);
  });

  ProbeState probe() => container.read(probeProvider(_entryId));

  Future<void> pumpProbe(
    WidgetTester tester,
    Widget child, {
    DemoSide side = DemoSide.used,
    bool comparing = false,
  }) => pumpPart(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: DemoProbe(
        entryId: _entryId,
        side: side,
        comparing: comparing,
        child: child,
      ),
    ),
  );

  testWidgets('TC-35: build の最中に数えても例外が出ず、フレームの後に回数とログに出る', (tester) async {
    await pumpProbe(
      tester,
      RebuildCounter(label: '読む子', builder: (context) => const Text('中身')),
    );

    expect(tester.takeException(), isNull);
    expect(probe().countOf(const ProbeKey(DemoSide.used, '読む子')), 1);
    expect(
      probe().logs.single.message,
      const BuildMessage(label: '読む子', count: 1),
    );
    expect(find.text('中身'), findsOneWidget);
  });

  testWidgets('比較中の右側は、使わない側として比較中の印つきで数える', (tester) async {
    await pumpProbe(
      tester,
      RebuildCounter(label: '読む子', builder: (context) => const SizedBox()),
      side: DemoSide.unused,
      comparing: true,
    );

    expect(probe().countOf(const ProbeKey(DemoSide.unused, '読む子')), 1);
    expect(probe().logs.single.side, DemoSide.unused);
    expect(probe().logs.single.comparing, isTrue);
  });

  testWidgets('TC-72: 同じフレームの同じ出来事は 1 行の ×6 にまとまる', (tester) async {
    await pumpProbe(
      tester,
      const _Logger(text: 'ScrollUpdateNotification', times: 6),
    );

    final log = probe().logs.single;
    expect(log.message, const TextMessage('ScrollUpdateNotification'));
    expect(log.repeat, 6);
  });

  testWidgets('TC-72: 別のフレームの出来事は別の行になる', (tester) async {
    await pumpProbe(tester, const _Logger(text: 'a', times: 1));
    await pumpProbe(tester, const _Logger(text: 'a', times: 2));

    // 新しい順。2 フレーム目は 2 回出したので ×2
    expect(probe().logs.map((log) => log.repeat), [2, 1]);
  });

  testWidgets('回数の印が変わっても、数えている子は組み直さない', (tester) async {
    var built = 0;
    await pumpProbe(
      tester,
      RebuildCounter(
        label: '読む子',
        builder: (context) {
          built++;
          return const SizedBox();
        },
      ),
    );
    // 印が「build 1 回」に書き変わるフレームを進める
    await tester.pumpAndSettle();

    expect(built, 1);
    expect(probe().countOf(const ProbeKey(DemoSide.used, '読む子')), 1);
  });

  testWidgets('依存している値が変わると、その子だけ組み直されて数が増える', (tester) async {
    final scale = ValueNotifier(1.0);
    addTearDown(scale.dispose);
    await pumpProbe(
      tester,
      ValueListenableBuilder(
        valueListenable: scale,
        builder: (context, value, _) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(value)),
          // 値が変わっても組み直さないように const の木を置く（収録データも同じ）
          child: const _Readers(),
        ),
      ),
    );

    scale.value = 1.5;
    await tester.pumpAndSettle();

    expect(probe().countOf(const ProbeKey(DemoSide.used, '読む子')), 2);
    expect(probe().countOf(const ProbeKey(DemoSide.used, '読まない子')), 1);
  });

  testWidgets('フレームの外（タイマー）で出したログも、次のフレームで渡す', (tester) async {
    await pumpProbe(tester, const _TimerLogger());
    await tester.pumpAndSettle();
    expect(probe().logs, isEmpty);
    expect(tester.binding.hasScheduledFrame, isFalse);

    // フレームを回さずに時刻だけ進めると、タイマーのログが次のフレームを予約する
    await tester.binding.delayed(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();

    expect(probe().logs.single.message, const TextMessage('tick'));
  });

  testWidgets('計測をやり直した後は、前の木（消える途中）の記録を捨てる', (tester) async {
    await pumpProbe(tester, const _TimerLogger());
    await tester.pumpAndSettle();

    // 比較の切り替えの間、前の木は AnimatedSwitcher に残ってまだ動いている
    container.read(probeProvider(_entryId).notifier).restarted();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(probe().logs, isEmpty);
  });

  testWidgets('窓口（DemoProbe）の外で数えてもログに出しても、何も起きない', (tester) async {
    await pumpPart(
      tester,
      Column(
        children: [
          RebuildCounter(label: '読む子', builder: (context) => const Text('中身')),
          const _Logger(text: 'a', times: 1),
        ],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('中身'), findsOneWidget);
  });

  testWidgets('アプリの文字の倍率が変わると、名前の札と回数の印もその倍率で描き直す', (tester) async {
    final scale = ValueNotifier(1.0);
    addTearDown(scale.dispose);
    await pumpPart(
      tester,
      UncontrolledProviderScope(
        container: container,
        child: ValueListenableBuilder(
          valueListenable: scale,
          builder: (context, value, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(value)),
            child: child!,
          ),
          child: DemoProbe(
            entryId: _entryId,
            side: DemoSide.used,
            child: RebuildCounter(
              label: '読まない子',
              builder: (context) => const SizedBox(),
            ),
          ),
        ),
      ),
    );

    scale.value = 2;
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('読まない子')).textScaler,
      const TextScaler.linear(2),
    );
    expect(
      tester.widget<Text>(find.text('build 1 回')).textScaler,
      const TextScaler.linear(2),
    );
    // 札と印だけを描き直し、数えている子は組み直さない
    expect(probe().countOf(const ProbeKey(DemoSide.used, '読まない子')), 1);
  });
}
