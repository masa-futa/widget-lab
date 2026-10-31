import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_app.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Widget _allOff() => CupertinoApp(
  home: Center(
    child: cupertinoAppEntry.build(
      DemoArgs(cupertinoAppEntry, allOff(cupertinoAppEntry)),
    ),
  ),
);

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の home だけを渡し、ほかは CupertinoApp の既定値で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(_allOff());

    final built = tester.widget<CupertinoApp>(find.byType(CupertinoApp).last);
    const defaults = CupertinoApp();
    expect(built.home, isNotNull);
    expect(built.title, defaults.title);
    expect(built.color, defaults.color);
    expect(built.theme, defaults.theme);
    expect(
      built.debugShowCheckedModeBanner,
      defaults.debugShowCheckedModeBanner,
    );
    expect(find.text('CupertinoApp の中'), findsOneWidget);
  });
}
