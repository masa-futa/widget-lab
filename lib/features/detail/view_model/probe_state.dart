import 'package:flutter/foundation.dart';

/// 比較の左右のどちらで起きたか。比較していないときは [used]。
enum DemoSide { used, unused }

/// build を数える単位（側と、数える子の名前）。
final class ProbeKey {
  const ProbeKey(this.side, this.label);

  final DemoSide side;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is ProbeKey && other.side == side && other.label == label;

  @override
  int get hashCode => Object.hash(side, label);

  @override
  String toString() => 'ProbeKey($side, $label)';
}

/// デモの木で起きたこと。DemoProbe がフレームの後にまとめて ProbeNotifier に渡す。
sealed class ProbeEvent {
  const ProbeEvent({required this.side, this.comparing = false});

  final DemoSide side;

  /// 比較中に起きた（ログに側の札を付ける）。
  final bool comparing;
}

/// [label] の子が build された。
final class BuildEvent extends ProbeEvent {
  const BuildEvent({required super.side, required this.label, super.comparing});

  final String label;
}

/// デモの木が出した出来事。同じフレームの同じ（側・文）は [repeat] にまとめてある。
final class LogEvent extends ProbeEvent {
  const LogEvent({
    required super.side,
    required this.text,
    super.comparing,
    this.repeat = 1,
  });

  final String text;
  final int repeat;
}

/// ログの 1 行の中身。文言は View が作る。
sealed class ProbeMessage {
  const ProbeMessage();
}

/// 「{label}を build（{count} 回目）」。
final class BuildMessage extends ProbeMessage {
  const BuildMessage({required this.label, required this.count});

  final String label;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is BuildMessage && other.label == label && other.count == count;

  @override
  int get hashCode => Object.hash(label, count);

  @override
  String toString() => 'BuildMessage($label, $count)';
}

/// 収録データが書いた文をそのまま出す。
final class TextMessage extends ProbeMessage {
  const TextMessage(this.text);

  final String text;

  @override
  bool operator ==(Object other) => other is TextMessage && other.text == text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextMessage($text)';
}

/// ログの 1 行。
@immutable
final class ProbeLog {
  const ProbeLog({
    required this.time,
    required this.side,
    required this.message,
    this.comparing = false,
    this.repeat = 1,
  });

  final DateTime time;
  final DemoSide side;
  final ProbeMessage message;

  /// 比較中に起きた（側の札を出す）。
  final bool comparing;

  /// 同じフレームにまとめた数。1 なら「×」を出さない。
  final int repeat;

  @override
  bool operator ==(Object other) =>
      other is ProbeLog &&
      other.time == time &&
      other.side == side &&
      other.message == message &&
      other.comparing == comparing &&
      other.repeat == repeat;

  @override
  int get hashCode => Object.hash(time, side, message, comparing, repeat);

  @override
  String toString() => 'ProbeLog($time, $side, $message, ×$repeat)';
}

/// 見た目を持たない Widget の build の回数とログ。
final class ProbeState {
  const ProbeState({required this.counts, required this.logs, this.epoch = 0});

  static const empty = ProbeState(counts: {}, logs: []);

  /// 子ごとの build の回数（最初の組み立ても数える）。
  final Map<ProbeKey, int> counts;

  /// 新しい順。
  final List<ProbeLog> logs;

  /// 計測をやり直した回数。プレビューはこれを key にしてデモの木を組み直す。
  final int epoch;

  int countOf(ProbeKey key) => counts[key] ?? 0;

  @override
  bool operator ==(Object other) =>
      other is ProbeState &&
      mapEquals(other.counts, counts) &&
      listEquals(other.logs, logs) &&
      other.epoch == epoch;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(counts.entries.map((e) => (e.key, e.value))),
    Object.hashAll(logs),
    epoch,
  );

  @override
  String toString() =>
      'ProbeState(counts: $counts, logs: ${logs.length}, epoch: $epoch)';
}
