import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/core/theme/app_theme.dart';

/// build の回数とログを貯めるだけの窓口（詳細画面の DemoProbe の代わり。収録ごとのテストで使う）。
final class RecordingRecorder implements DemoRecorder {
  final counts = <String, int>{};
  final logs = <String>[];

  @override
  void recordBuild(String label) =>
      counts.update(label, (n) => n + 1, ifAbsent: () => 1);

  @override
  void log(String text) => logs.add(text);

  @override
  bool get comparing => false;

  @override
  Widget? badge(String label) => null;

  /// [child] の上に、この窓口を置く。
  Widget wrap(Widget child) => DemoRecorderScope(
    recorder: this,
    textScaler: TextScaler.noScaling,
    child: child,
  );
}

/// [demo] を [recorder] の窓口の下に置いて組み立てる。
Future<void> pumpRecorded(
  WidgetTester tester,
  RecordingRecorder recorder,
  Widget demo,
) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: recorder.wrap(
        Center(child: SizedBox(width: 328, height: 400, child: demo)),
      ),
    ),
  ),
);
