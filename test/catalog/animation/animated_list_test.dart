import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/animation/animated_list.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/core/theme/app_theme.dart';

import '../all_off.dart';

Future<void> _pump(WidgetTester tester, Widget demo) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: demo)),
  ),
);

void main() {
  final entry = animatedListEntry;

  testWidgets('TC-18: 全部 OFF なら AnimatedList の既定値（0 件・縦・逆にしない）で組み立てる', (
    tester,
  ) async {
    await _pump(tester, entry.build(DemoArgs(entry, allOff(entry))));

    final list = tester.widget<AnimatedList>(find.byType(AnimatedList));
    expect(list.initialItemCount, 0);
    expect(list.scrollDirection, Axis.vertical);
    expect(list.reverse, isFalse);
  });

  testWidgets('「足す」で先頭に項目が入り、「消す」で先頭の項目が出ていく', (tester) async {
    await _pump(tester, entry.build(DemoArgs(entry, entry.initialSettings())));
    expect(find.text('項目 1'), findsOneWidget);
    expect(find.text('項目 2'), findsOneWidget);

    await tester.tap(find.text('足す'));
    await tester.pumpAndSettle();
    expect(find.text('項目 3'), findsOneWidget);

    await tester.tap(find.text('消す'));
    await tester.pumpAndSettle();
    expect(find.text('項目 3'), findsNothing);
    expect(find.text('項目 1'), findsOneWidget);
  });
}
