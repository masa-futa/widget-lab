import 'package:widget_lab/features/detail/view_model/probe_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ログの 1 行の文（「読む子を build（4 回目）」「内: ScrollUpdateNotification ×6」）。
String logText(AppLocalizations l10n, ProbeLog log) {
  final text = switch (log.message) {
    BuildMessage(:final label, :final count) => l10n.probeLogBuild(
      label,
      count,
    ),
    TextMessage(:final text) => text,
  };
  return log.repeat > 1 ? l10n.probeLogRepeat(text, log.repeat) : text;
}

/// 側の札（「使った」「使わない」）。
String sideText(AppLocalizations l10n, DemoSide side) => switch (side) {
  DemoSide.used => l10n.probeSideUsed,
  DemoSide.unused => l10n.probeSideUnused,
};

/// ログの時刻（`HH:mm:ss`）。
String logTime(DateTime time) => [
  time.hour,
  time.minute,
  time.second,
].map((n) => n.toString().padLeft(2, '0')).join(':');
