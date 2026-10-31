import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/accessibility/exclude_semantics.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../all_off.dart';
import 'readout.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら excluding は既定値の true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: excludeSemanticsEntry.build(
          DemoArgs(excludeSemanticsEntry, allOff(excludeSemanticsEntry)),
        ),
      ),
    );

    expect(
      tester
          .widget<ExcludeSemantics>(
            find.ancestor(
              of: find.text('おすすめ'),
              matching: find.byType(ExcludeSemantics),
            ),
          )
          .excluding,
      isTrue,
    );
  });

  testWidgets('包むと飾りを読まず、外すか excluding: false なら読む', (tester) async {
    expect(await pumpReadout(tester, excludeSemanticsEntry), '読み上げ: なし');
    expect(
      await pumpReadout(tester, excludeSemanticsEntry, without: true),
      '読み上げ:\n「星」\n「おすすめ」',
    );
    expect(
      await pumpReadout(
        tester,
        excludeSemanticsEntry,
        settings: {
          'excluding': const PropertySetting(
            on: true,
            value: SwitchValue(false),
          ),
        },
      ),
      '読み上げ:\n「星」\n「おすすめ」',
    );
  });
}
