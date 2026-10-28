import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';

import 'all_off.dart';

const _demoKey = Key('demo');

/// build の回数とログを貯めるだけの窓口。
final class FakeRecorder implements DemoRecorder {
  final builds = <String>[];
  final logs = <String>[];

  @override
  void recordBuild(String label) => builds.add(label);

  @override
  void log(String text) => logs.add(text);

  @override
  bool get comparing => false;

  @override
  Widget? badge(String label) => null;

  /// [label] の子が build された回数。
  int buildsOf(String label) => builds.where((b) => b == label).length;
}

/// [demo] をプレビューのカードと同じ大きさ（[size]）に置いて表示し、記録の窓口を返す。
Future<FakeRecorder> pumpDemo(
  WidgetTester tester,
  Widget demo, {
  Size size = const Size(328, 240),
}) async {
  final recorder = FakeRecorder();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: DemoRecorderScope(
          recorder: recorder,
          textScaler: TextScaler.noScaling,
          child: Center(
            child: SizedBox.fromSize(key: _demoKey, size: size, child: demo),
          ),
        ),
      ),
    ),
  );
  return recorder;
}

/// [entry] を [settings]（省けば全部 OFF）で組み立てて表示する。
Future<FakeRecorder> pumpEntry(
  WidgetTester tester,
  WidgetEntry entry, [
  Map<String, PropertySetting>? settings,
]) => pumpDemo(tester, entry.build(DemoArgs(entry, settings ?? allOff(entry))));

/// 表示したデモの中で、一番外側の [T]。
T demoWidget<T extends Widget>(WidgetTester tester) => tester.widget<T>(
  find
      .descendant(
        of: find.byKey(_demoKey),
        // 大きさ 0 の sliver なども探す
        matching: find.byType(T, skipOffstage: false),
        skipOffstage: false,
      )
      .first,
);
