import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_builder.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';
import '../recording.dart';

/// 「動かす」を押し、1 回転（1 秒）が終わるまで進める。
Future<void> _spin(WidgetTester tester) async {
  await tester.tap(find.text('動かす'));
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final entry = animatedBuilderEntry;

  testWidgets('child に渡したロゴと builder の外の子は、回っている間も組み直されない', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.build(DemoArgs(entry, entry.initialSettings())),
    );
    await _spin(tester);

    expect(recorder.counts['回す子'], greaterThan(5));
    expect(recorder.counts['ロゴ'], 1);
    expect(recorder.counts['外の子'], 1);
    expect(recorder.logs, contains('controller.forward(from: 0)'));
  });

  testWidgets('TC-18: child を OFF にすると builder の中でロゴを作り、毎フレーム組み直される', (
    tester,
  ) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.build(DemoArgs(entry, allOff(entry))),
    );
    await _spin(tester);

    expect(recorder.counts['ロゴ'], greaterThan(5));
    expect(recorder.counts['外の子'], 1);
  });

  testWidgets('使わない側（setState）では外の子も毎フレーム組み直される', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.buildWithout!(DemoArgs(entry, entry.initialSettings())),
    );
    await _spin(tester);

    expect(recorder.counts['外の子'], greaterThan(5));
    expect(recorder.counts['ロゴ'], greaterThan(5));
  });
}
