import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_widget.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import 'recording.dart';

/// 「動かす」を押し、1 回転（1 秒）が終わるまで進める。
Future<void> _spin(WidgetTester tester) async {
  await tester.tap(find.text('動かす'));
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  final entry = animatedWidgetEntry;

  testWidgets('サブクラスの SpinningLogo だけが組み直され、外の子は組み直されない', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.build(DemoArgs(entry, entry.initialSettings())),
    );
    await _spin(tester);

    expect(recorder.counts['SpinningLogo'], greaterThan(5));
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

    expect(recorder.counts['SpinningLogo'], greaterThan(5));
    expect(recorder.counts['外の子'], greaterThan(5));
  });
}
