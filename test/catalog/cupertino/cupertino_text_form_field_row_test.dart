import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_form_field_row.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoTextFormFieldRow の既定値で組み立てる', () {
    final box = cupertinoTextFormFieldRowEntry.build(
      DemoArgs(
        cupertinoTextFormFieldRowEntry,
        allOff(cupertinoTextFormFieldRowEntry),
      ),
    ) as FittedBox;
    final built = (box.child! as SizedBox).child! as CupertinoTextFormFieldRow;
    final defaults = CupertinoTextFormFieldRow();

    expect(built.prefix, defaults.prefix);
    expect(built.padding, defaults.padding);
    expect(built.initialValue, defaults.initialValue);
    expect(built.validator, defaults.validator);
    expect(built.autovalidateMode, defaults.autovalidateMode);
  });

  testWidgets('validator と always なら、空のときに誤りの文を出す', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTextFormFieldRowEntry.build(
            DemoArgs(
              cupertinoTextFormFieldRowEntry,
              cupertinoTextFormFieldRowEntry.initialSettings(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('入力してください'), findsOneWidget);
  });
}
