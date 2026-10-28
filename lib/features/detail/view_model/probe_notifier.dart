import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/features/detail/view_model/probe_state.dart';

part 'probe_notifier.g.dart';

/// ログの時刻を取る（テストで差し替える）。
@Riverpod(keepAlive: true)
DateTime Function() probeClock(Ref ref) => DateTime.now;

/// 見た目を持たない Widget の build の回数とログ。画面を離れると捨てる（autoDispose）。
@riverpod
class ProbeNotifier extends _$ProbeNotifier {
  /// ログに残す件数。あふれたら古いものから消す。
  static const maxLogs = 50;

  @override
  ProbeState build(String entryId) => ProbeState.empty;

  /// 1 フレームの間に起きたこと（起きた順）を反映する。
  void recorded(List<ProbeEvent> events) {
    if (events.isEmpty) return;
    final time = ref.read(probeClockProvider)();
    final counts = {...state.counts};
    final added = <ProbeLog>[];
    for (final event in events) {
      final ProbeMessage message;
      var repeat = 1;
      switch (event) {
        case BuildEvent(:final side, :final label):
          final key = ProbeKey(side, label);
          final count = (counts[key] ?? 0) + 1;
          counts[key] = count;
          message = BuildMessage(label: label, count: count);
        case LogEvent(:final text, repeat: final r):
          message = TextMessage(text);
          repeat = r;
      }
      added.add(
        ProbeLog(
          time: time,
          side: event.side,
          message: message,
          comparing: event.comparing,
          repeat: repeat,
        ),
      );
    }
    state = ProbeState(
      counts: counts,
      logs: [...added.reversed, ...state.logs].take(maxLogs).toList(),
    );
  }

  /// ログと回数を空にする。
  void logCleared() {
    state = ProbeState.empty;
  }
}
