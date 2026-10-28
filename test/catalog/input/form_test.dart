import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/input/form.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Form の既定値（autovalidateMode: disabled）で組み立てる', () {
    final stage =
        formEntry.build(DemoArgs(formEntry, allOff(formEntry))) as DemoStage;
    final form = stage.child as Form;

    expect(form.autovalidateMode, AutovalidateMode.disabled);
  });

  testWidgets('「送信」を押すと、全部の欄のエラーが一度に出る', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: formEntry.build(DemoArgs(formEntry, allOff(formEntry))),
        ),
      ),
    );
    expect(find.text('名前を入れてください'), findsNothing);

    await tester.tap(find.text('送信'));
    await tester.pump();

    expect(find.text('名前を入れてください'), findsOneWidget);
    expect(find.text('@ を含めてください'), findsOneWidget);
  });
}
