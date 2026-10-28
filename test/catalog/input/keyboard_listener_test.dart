import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/input/keyboard_listener.dart';
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
        body: recorder.wrap(build(DemoArgs(keyboardListenerEntry, settings))),
      ),
    ),
  );
  return recorder;
}

void main() {
  testWidgets('キーを押すとログに出て、子は組み直されない', (tester) async {
    final recorder = await _pump(
      tester,
      keyboardListenerEntry.build,
      keyboardListenerEntry.initialSettings(),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();

    expect(recorder.logs, ['KeyDownEvent: A', 'KeyUpEvent: A']);
    expect(recorder.counts['キーを受ける枠'], 1);
  });

  testWidgets('TC-18: 全部 OFF（autofocus なし・onKeyEvent なし）なら、押してもログに出ない', (
    tester,
  ) async {
    final recorder = await _pump(
      tester,
      keyboardListenerEntry.build,
      allOff(keyboardListenerEntry),
    );

    await tester.tap(find.text('ハードウェアキーボードのキーを押す'));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();

    expect(recorder.logs, isEmpty);
  });

  testWidgets('使わない側では、キーを押しても何もログに出ない', (tester) async {
    final buildWithout = keyboardListenerEntry.buildWithout;
    expect(buildWithout, isNotNull);
    final recorder = await _pump(
      tester,
      buildWithout ?? keyboardListenerEntry.build,
      keyboardListenerEntry.initialSettings(),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();

    expect(recorder.logs, isEmpty);
  });
}
