import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/hero.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../recording.dart';

void main() {
  final entry = heroEntry;

  testWidgets('ロゴを押すとデモの中の Navigator で移り、ロゴが飛ぶ', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.build(DemoArgs(entry, entry.initialSettings())),
    );

    await tester.tap(find.text('ロゴを押す'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // 飛んでいる間、ロゴは Overlay の上を飛ぶ 1 つだけになる（前後の Hero は隠れる）
    expect(find.byType(FlutterLogo), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    expect(recorder.logs, ['push: 大きなロゴの画面へ']);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(recorder.logs.last, 'pop: 小さなロゴの画面へ');
  });

  testWidgets('使わない側には Hero がなく、画面ごと入れ替わる', (tester) async {
    final recorder = RecordingRecorder();
    await pumpRecorded(
      tester,
      recorder,
      entry.buildWithout!(DemoArgs(entry, entry.initialSettings())),
    );
    expect(find.byType(Hero), findsNothing);

    await tester.tap(find.text('ロゴを押す'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // 移る間は前後の画面のロゴが両方見える
    expect(find.byType(FlutterLogo), findsNWidgets(2));
    await tester.pumpAndSettle();
    expect(recorder.logs, ['push: 大きなロゴの画面へ']);
  });
}
