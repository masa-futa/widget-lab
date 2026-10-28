import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/core/theme/app_theme.dart';

/// build の回数とログを貯めるだけの窓口（詳細画面の DemoProbe の代わり）。
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
      body: DemoRecorderScope(
        recorder: recorder,
        textScaler: TextScaler.noScaling,
        child: Center(child: SizedBox(width: 328, height: 400, child: demo)),
      ),
    ),
  ),
);
