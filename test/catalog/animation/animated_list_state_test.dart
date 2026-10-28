import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_list_state.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../recording.dart';

void main() {
  final entry = animatedListStateEntry;

  testWidgets('insertItem・removeItem で項目が出入りし、リストの外の子は組み直されない', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.build(DemoArgs(entry, entry.initialSettings())),
    );

    await tester.tap(find.text('足す'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('消す'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('足す'));
    await tester.pumpAndSettle();

    expect(find.text('項目 3'), findsNothing);
    expect(find.text('項目 4'), findsOneWidget);
    expect(recorder.logs, [
      'insertItem(0)',
      'removeItem(0, …)',
      'insertItem(0)',
    ]);
    expect(recorder.counts['リストの外の子'], 1);
  });

  testWidgets('使わない側（setState）ではリストの外の子も組み直される', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.buildWithout!(DemoArgs(entry, entry.initialSettings())),
    );

    await tester.tap(find.text('足す'));
    await tester.pump();

    expect(find.text('項目 3'), findsOneWidget);
    expect(recorder.logs, ['setState で items に足す']);
    expect(recorder.counts['リストの外の子'], 2);
  });
}
