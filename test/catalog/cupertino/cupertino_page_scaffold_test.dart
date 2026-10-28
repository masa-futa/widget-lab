import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_scaffold.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoPageScaffoldEntry.build(
      DemoArgs(cupertinoPageScaffoldEntry, allOff(cupertinoPageScaffoldEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の child だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoPageScaffold>(
      find.byType(CupertinoPageScaffold).last,
    );
    expect(built.navigationBar, isNull);
    expect(built.backgroundColor, isNull);
    expect(find.text('中身'), findsOneWidget);
  });
}
