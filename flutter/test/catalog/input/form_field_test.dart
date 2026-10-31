import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/input/form_field.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら FormField の既定値で組み立てる', () {
    final field = formFieldEntry.build(
      DemoArgs(formFieldEntry, allOff(formFieldEntry)),
    ) as FormField<int>;

    expect(field.initialValue, isNull);
    expect(field.validator, isNull);
    expect(field.autovalidateMode, AutovalidateMode.disabled);
    expect(field.enabled, isTrue);
  });

  testWidgets('always で星が 0 ならエラーが出て、星を押すと消える', (tester) async {
    final settings = formFieldEntry.initialSettings();
    // 最初の値（星）を OFF にして 0 から始める
    settings['initialValue'] = settings['initialValue']!.copyWith(on: false);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: formFieldEntry.build(DemoArgs(formFieldEntry, settings)),
        ),
      ),
    );
    expect(find.text('星を 1 つ以上'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pump();

    expect(find.text('星を 1 つ以上'), findsNothing);
  });
}
