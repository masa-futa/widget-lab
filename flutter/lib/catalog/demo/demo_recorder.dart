import 'package:flutter/widgets.dart';

/// 見た目を持たない Widget のデモの木から、build の回数と出来事を記録する窓口。
///
/// 収録データは [DemoRecorder.of] で引いて使う。記録をどこへ渡すか（回数とログの状態）は
/// 詳細画面がこの窓口を [DemoRecorderScope] で置いて決める（収録データは詳細画面に依存しない）。
abstract interface class DemoRecorder {
  /// [context] の上の窓口。依存を作らないので、窓口の変化で子が組み直されることはない。
  /// 窓口の外（見本・全件のテストなど）では何もしない窓口を返す。
  static DemoRecorder of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DemoRecorderScope>()?.recorder ??
      const _NoRecorder();

  /// アプリの文字の倍率。デモが文字の倍率を変えても、アプリの部品（名前の札・回数の印）は
  /// これで描く。依存を作るので、数える子ではなく札や印の Widget から呼ぶ（倍率が変わると
  /// 札と印だけが描き直される）。窓口の外では倍率をかけない。
  static TextScaler textScalerOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<DemoRecorderScope>()
          ?.textScaler ??
      TextScaler.noScaling;

  /// [label] の子が build された。
  void recordBuild(String label);

  /// 出来事をログに出す。
  void log(String text);

  /// 比較中（左右のカードの片方）。
  bool get comparing;

  /// [label] の子の回数の印。窓口の外では `null`。
  Widget? badge(String label);
}

/// [recorder] とアプリの文字の倍率をデモの木に置く。
class DemoRecorderScope extends InheritedWidget {
  const DemoRecorderScope({
    required this.recorder,
    required this.textScaler,
    required super.child,
    super.key,
  });

  final DemoRecorder recorder;

  /// アプリの文字の倍率（[DemoRecorder.textScalerOf]）。
  final TextScaler textScaler;

  // 窓口（recorder）は依存を作らずに引くので、知らせるのは倍率の変化だけ
  @override
  bool updateShouldNotify(DemoRecorderScope oldWidget) =>
      oldWidget.textScaler != textScaler;
}

final class _NoRecorder implements DemoRecorder {
  const _NoRecorder();

  @override
  void recordBuild(String label) {}

  @override
  void log(String text) {}

  @override
  bool get comparing => false;

  @override
  Widget? badge(String label) => null;
}
