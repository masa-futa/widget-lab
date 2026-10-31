import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/scrolling/scroll_configuration.dart';

import '../demo_pump.dart';

void main() {
  Widget build(int behaviorIndex) => scrollConfigurationEntry.build(
    DemoArgs(scrollConfigurationEntry, {
      'behavior': PropertySetting(on: true, value: ChoiceValue(behaviorIndex)),
    }),
  );

  Future<void> pullDown(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, 80));
    await tester.pumpAndSettle();
  }

  testWidgets('ScrollConfiguration: はね返るにすると、端を越えて動く', (tester) async {
    final recorder = await pumpDemo(tester, build(0));
    await pullDown(tester);

    expect(recorder.logs, contains('端を越えて動く（はね返り）'));
    expect(recorder.logs, isNot(contains('端で止まる（OverscrollNotification）')));
  });

  testWidgets('ScrollConfiguration: 端で止まるにすると、端を越えずに止まる', (tester) async {
    final recorder = await pumpDemo(tester, build(1));
    await pullDown(tester);

    expect(recorder.logs, contains('端で止まる（OverscrollNotification）'));
    expect(recorder.logs, isNot(contains('端を越えて動く（はね返り）')));
  });

  testWidgets('ScrollConfiguration: 振る舞いを変えても、包む子（ListView の外）は組み直されない', (
    tester,
  ) async {
    final recorder = await pumpDemo(tester, build(0));
    await pumpDemo(tester, build(1), recorder: recorder);

    expect(recorder.buildsOf('ListView'), 1);
  });
}
