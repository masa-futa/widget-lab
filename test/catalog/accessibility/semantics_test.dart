import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/accessibility/semantics.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';
import 'readout.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Semantics の既定値（名前なし・役割なし）で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: semanticsEntry.build(
          DemoArgs(semanticsEntry, allOff(semanticsEntry)),
        ),
      ),
    );

    final built = tester.widget<Semantics>(
      find
          .byWidgetPredicate(
            (widget) => widget is Semantics && widget.child is! Semantics,
          )
          .last,
    );
    expect(built.properties.label, isNull);
    expect(built.properties.button, isNull);
    expect(built.properties.hint, isNull);
  });

  testWidgets('名前と役割を付けると「保存」をボタンとして読み、外すと何も読まない', (tester) async {
    expect(await pumpReadout(tester, semanticsEntry), '読み上げ:\n「保存」、ボタン');
    expect(
      await pumpReadout(tester, semanticsEntry, without: true),
      '読み上げ: なし',
    );
  });
}
