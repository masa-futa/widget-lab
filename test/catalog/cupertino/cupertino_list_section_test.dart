import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_section.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の行だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoListSectionEntry.build(
            DemoArgs(
              cupertinoListSectionEntry,
              allOff(cupertinoListSectionEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoListSection>(
      find.byType(CupertinoListSection),
    );
    final defaults = CupertinoListSection(children: const [Text('行')]);
    expect(built.children, hasLength(2));
    expect(built.header, isNull);
    expect(built.footer, isNull);
    expect(built.dividerMargin, defaults.dividerMargin);
    expect(built.additionalDividerMargin, defaults.additionalDividerMargin);
    expect(built.backgroundColor, defaults.backgroundColor);
  });
}
