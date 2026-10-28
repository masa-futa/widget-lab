import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/features/detail/view_model/probe_notifier.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

/// プレビューのカードの根に置き、デモの木で起きたこと（build の回数・出来事）を集める。
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

  /// [context] の上の DemoProbe。依存を作らないので、DemoProbe の変化で子が組み直される
  /// ことはない。DemoProbe の外（見本など）では何もしない。
  static DemoProbeHandle of(BuildContext context) => DemoProbeHandle._(
    context.getInheritedWidgetOfExactType<_DemoProbeScope>()?.state,
  );

  @override
  ConsumerState<DemoProbe> createState() => _DemoProbeState();
}

/// デモの木から DemoProbe に記録するための窓口。
final class DemoProbeHandle {
  const DemoProbeHandle._(this._state);

  final _DemoProbeState? _state;

  /// DemoProbe の中にいる（回数の印を出す）。
  bool get isActive => _state != null;

  /// 回数を見る相手。DemoProbe の外では `null`。
  String? get entryId => _state?.widget.entryId;
  DemoSide get side => _state?.widget.side ?? DemoSide.used;

  /// デモが文字の倍率を変えても、アプリの部品（名前の札・回数の印）はアプリの倍率で描く。
  TextScaler get appTextScaler =>
      _state?._appTextScaler ?? TextScaler.noScaling;

  /// [label] の子が build された。
  void recordBuild(String label) => _state?._add(
    BuildEvent(side: side, label: label, comparing: _state.widget.comparing),
  );

  /// 出来事をログに出す。
  void log(String text) => _state?._add(
    LogEvent(side: side, text: text, comparing: _state.widget.comparing),
  );
}

class _DemoProbeState extends ConsumerState<DemoProbe> {
  final _pending = <ProbeEvent>[];
  bool _scheduled = false;
  TextScaler _appTextScaler = TextScaler.noScaling;

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
    ref.read(probeProvider(widget.entryId).notifier).recorded(events);
  }

  /// 同じ（側・文）の出来事を、最初に起きた位置に 1 件にまとめる。build の記録はまとめない。
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
    _appTextScaler = MediaQuery.textScalerOf(context);
    return _DemoProbeScope(state: this, child: widget.child);
  }
}

class _DemoProbeScope extends InheritedWidget {
  const _DemoProbeScope({required this.state, required super.child});

  final _DemoProbeState state;

  // 子は依存を作らずに引くので、知らせる相手はいない
  @override
  bool updateShouldNotify(_DemoProbeScope oldWidget) => false;
}
