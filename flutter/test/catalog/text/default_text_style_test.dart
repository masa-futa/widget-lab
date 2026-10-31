import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/text/default_text_style.dart';

import '../demo_pump.dart';

void main() {
  Widget build(int styleIndex) {
    final settings = defaultTextStyleEntry.initialSettings()
      ..['style'] = PropertySetting(on: true, value: ChoiceValue(styleIndex));
    return defaultTextStyleEntry.build(
      DemoArgs(defaultTextStyleEntry, settings),
    );
  }

  testWidgets(
    'DefaultTextStyle: style を変えると、DefaultTextStyle.of で読んだ子だけが組み直される',
    (tester) async {
      final recorder = await pumpDemo(tester, build(0));
      expect(find.text('fontSize 20'), findsOneWidget);

      await pumpDemo(tester, build(1), recorder: recorder);

      expect(find.text('fontSize 14'), findsOneWidget);
      expect(recorder.buildsOf('大きさを読む子'), 2);
      expect(recorder.buildsOf('受ける Text'), 1);
      expect(recorder.buildsOf('受けない Text'), 1);
    },
  );

  testWidgets(
    'DefaultTextStyle: style のない Text は既定を受け、inherit: false の Text は受けない',
    (tester) async {
      await pumpDemo(tester, build(0));

      TextStyle styleOf(String text) => tester
          .widget<RichText>(
            find.descendant(
              of: find.text(text),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;
      expect(styleOf('既定の見た目を受けて描く、少し長めの文です').fontSize, 20);
      expect(styleOf('既定を受けない').fontSize, 14);
    },
  );
}
