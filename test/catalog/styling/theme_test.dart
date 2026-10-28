import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/styling/theme.dart';

import '../demo_pump.dart';

void main() {
  Widget build(int colorIndex) {
    final settings = themeEntry.initialSettings()
      ..['colorScheme'] = PropertySetting(
        on: true,
        value: ChoiceValue(colorIndex),
      );
    return themeEntry.build(DemoArgs(themeEntry, settings));
  }

  testWidgets('Theme: 色を変えると、Theme.of で読んだ子は文字の子も組み直され、読まない子は組み直されない', (
    tester,
  ) async {
    final recorder = await pumpDemo(tester, build(1));
    await pumpDemo(tester, build(0), recorder: recorder);

    expect(recorder.buildsOf('色を読む子'), 2);
    expect(recorder.buildsOf('文字を読む子'), 2);
    expect(recorder.buildsOf('読まない子'), 1);
  });

  testWidgets('Theme: 使わない側は、アプリのテーマの色のまま', (tester) async {
    final args = DemoArgs(themeEntry, themeEntry.initialSettings());
    await pumpDemo(tester, themeEntry.buildWithout!(args));

    // 色を読む子の 48×20 の箱
    final box = tester.widget<Container>(
      find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 48,
      ),
    );
    final context = tester.element(find.text('固定の文'));
    expect(box.color, Theme.of(context).colorScheme.primary);
  });
}
