import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/async/future_builder.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

import '../all_off.dart';
import '../recording.dart';

Future<RecordingRecorder> _pump(
  WidgetTester tester,
  DemoBuilder build,
  Map<String, PropertySetting> settings,
) async {
  final recorder = RecordingRecorder();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: recorder.wrap(build(DemoArgs(futureBuilderEntry, settings))),
      ),
    ),
  );
  return recorder;
}

/// future の選択肢を [index] にした最初の設定。
Map<String, PropertySetting> _withFuture(int index) => {
  ...futureBuilderEntry.initialSettings(),
  'future': PropertySetting(on: true, value: ChoiceValue(index)),
};

void main() {
  testWidgets('TC-18: 全部 OFF なら future なしで、none のまま', (tester) async {
    final recorder = await _pump(
      tester,
      futureBuilderEntry.build,
      allOff(futureBuilderEntry),
    );

    await tester.pump(const Duration(seconds: 3));

    expect(recorder.logs, ['none']);
  });

  testWidgets('2 秒後に値: waiting → done: 42。builder の外の子は組み直されない', (
    tester,
  ) async {
    final recorder = await _pump(
      tester,
      futureBuilderEntry.build,
      _withFuture(0),
    );

    await tester.pump(const Duration(seconds: 2));

    expect(recorder.logs, ['waiting', 'done: 42']);
    expect(recorder.counts['結果を出す子'], 2);
    expect(recorder.counts['外の子'], 1);
  });

  testWidgets('途中でエラー: waiting → done: Exception: 読み込みに失敗', (tester) async {
    final recorder = await _pump(
      tester,
      futureBuilderEntry.build,
      _withFuture(1),
    );

    await tester.pump(const Duration(seconds: 2));

    expect(recorder.logs, ['waiting', 'done: Exception: 読み込みに失敗']);
  });

  testWidgets('「最初から待つ」で、もう一度 waiting から待つ', (tester) async {
    final recorder = await _pump(
      tester,
      futureBuilderEntry.build,
      _withFuture(0),
    );
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('最初から待つ'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(recorder.logs, ['waiting', 'done: 42', 'waiting', 'done: 42']);
  });

  testWidgets('使わない側では、結果が届くと外の子も組み直される', (tester) async {
    final buildWithout = futureBuilderEntry.buildWithout;
    expect(buildWithout, isNotNull);
    final recorder = await _pump(
      tester,
      buildWithout ?? futureBuilderEntry.build,
      _withFuture(0),
    );

    await tester.pump(const Duration(seconds: 2));

    expect(recorder.logs, ['waiting', 'done: 42']);
    expect(recorder.counts['外の子'], 2);
  });
}
