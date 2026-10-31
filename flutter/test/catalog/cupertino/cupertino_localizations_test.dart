import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_localizations.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../all_off.dart';

Future<void> _pump(WidgetTester tester, DemoArgs args) async {
  await tester.pumpWidget(
    CupertinoApp(home: Center(child: cupertinoLocalizationsEntry.build(args))),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('TC-18: 全部 OFF でも必須の言語（最初は ja）で文言を出す', (tester) async {
    await _pump(
      tester,
      DemoArgs(
        cupertinoLocalizationsEntry,
        allOff(cupertinoLocalizationsEntry),
      ),
    );

    expect(find.text('todayLabel: 今日'), findsOneWidget);
  });

  testWidgets('en を選ぶと英語の文言になる', (tester) async {
    await _pump(
      tester,
      DemoArgs(cupertinoLocalizationsEntry, {
        'locale': const PropertySetting(on: true, value: ChoiceValue(1)),
      }),
    );

    expect(find.text('todayLabel: Today'), findsOneWidget);
  });
}
