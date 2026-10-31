import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_form_section.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の行だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoFormSectionEntry.build(
            DemoArgs(
              cupertinoFormSectionEntry,
              allOff(cupertinoFormSectionEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoFormSection>(
      find.byType(CupertinoFormSection),
    );
    final defaults = CupertinoFormSection(children: const [Text('行')]);
    expect(built.children, hasLength(2));
    expect(built.header, isNull);
    expect(built.footer, isNull);
    expect(built.backgroundColor, defaults.backgroundColor);
    expect(built.margin, defaults.margin);
  });
}
