import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_form_row.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の child だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoFormRowEntry.build(
            DemoArgs(cupertinoFormRowEntry, allOff(cupertinoFormRowEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoFormRow>(
      find.byType(CupertinoFormRow),
    );
    expect(built.child, isA<CupertinoSwitch>());
    expect(built.prefix, isNull);
    expect(built.helper, isNull);
    expect(built.error, isNull);
    expect(built.padding, isNull);
  });
}
