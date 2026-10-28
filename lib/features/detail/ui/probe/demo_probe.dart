import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/features/detail/ui/probe/rebuild_badge.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

/// プレビューのカードの根に置き、デモの木で起きたこと（build の回数・出来事）を集める
/// [DemoRecorder]。
///
/// build の最中に Provider を書き換えると Riverpod が例外を出すので、出来事は貯めておき、
/// フレームの後にまとめて [ProbeNotifier.recorded] に渡す。同じフレームの同じ文の出来事は
/// 1 件にまとめて回数を持たせる（ログに「×6」）。
class DemoProbe extends ConsumerStatefulWidget {
  const DemoProbe({
    required this.entryId,
    required this.side,
    required this.child,
    this.comparing = false,
    super.key,
  });

  final String entryId;

  /// 比較の左右のどちらか。比較していないときは [DemoSide.used]。
  final DemoSide side;

  /// 比較中（ログに側の札を付ける）。
  final bool comparing;
  final Widget child;

  @override
  ConsumerState<DemoProbe> createState() => _DemoProbeState();
}

class _DemoProbeState extends ConsumerState<DemoProbe> implements DemoRecorder {
  final _pending = <ProbeEvent>[];
  bool _scheduled = false;

  /// 作られたときの計測の回（[ProbeState.epoch]）。
  late final int _epoch;

  @override
  void initState() {
    super.initState();
    _epoch = ref.read(probeProvider(widget.entryId)).epoch;
  }

  @override
  bool get comparing => widget.comparing;

  @override
  void recordBuild(String label) =>
      _add(BuildEvent(side: widget.side, label: label, comparing: comparing));

  @override
  void log(String text) =>
      _add(LogEvent(side: widget.side, text: text, comparing: comparing));

  @override
  Widget badge(String label) => RebuildBadge(
    entryId: widget.entryId,
    probeKey: ProbeKey(widget.side, label),
  );

  void _add(ProbeEvent event) {
    _pending.add(event);
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => _flush())
      // フレームの外（タイマーや Stream）で起きたときも、次のフレームで渡す
      ..ensureVisualUpdate();
  }

  void _flush() {
    _scheduled = false;
    final events = _merged(_pending);
    _pending.clear();
    if (!mounted) return;
    // 計測をやり直した後も、前の木は比較の切り替え（AnimatedSwitcher）の間だけ残って動くので、
    // その記録は捨てる
    if (ref.read(probeProvider(widget.entryId)).epoch != _epoch) return;
    ref.read(probeProvider(widget.entryId).notifier).recorded(events);
  }

  /// 同じ（側・文）の出来事を、最初に起きた位置に 1 件にまとめる。build の記録は毎回
  /// 「n 回目」が違う文になるのでまとめない（`repeat` を持つのは LogEvent だけ）。
  /// 同じ DemoProbe の出来事なので、まとめても側と comparing は変わらない。
  static List<ProbeEvent> _merged(List<ProbeEvent> events) {
    final merged = <ProbeEvent>[];
    final logIndex = <(DemoSide, String), int>{};
    for (final event in events) {
      switch (event) {
        case BuildEvent():
          merged.add(event);
        case LogEvent(:final side, :final text):
          final index = logIndex[(side, text)];
          if (index == null) {
            logIndex[(side, text)] = merged.length;
            merged.add(event);
          } else {
            final first = merged[index] as LogEvent;
            merged[index] = LogEvent(
              side: side,
              text: text,
              comparing: first.comparing,
              repeat: first.repeat + event.repeat,
            );
          }
      }
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    // 回数の印やログの帯が見ていなくても、記録を捨てないように持ち続ける
    ref.listen(probeProvider(widget.entryId), (_, _) {});
    return DemoRecorderScope(
      recorder: this,
      textScaler: MediaQuery.textScalerOf(context),
      child: widget.child,
    );
  }
}
