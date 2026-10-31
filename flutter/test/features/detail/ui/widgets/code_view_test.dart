import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

import '../pump.dart';

void main() {
  final longText = '  padding: ${'EdgeInsets.all(16.0) + ' * 10}x,';
  final lines = [
    const CodeLine(text: 'Padding('),
    CodeLine(text: longText, property: 'padding', changed: true),
    const CodeLine(text: '  child: FlutterLogo(),', property: 'child'),
    const CodeLine(text: ')'),
  ];
  final scrollable = find
      .descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('TC-51: 行番号を付け、長い行は折り返さない', (tester) async {
    await pumpPart(tester, CodeView(lines: lines));

    for (final number in ['1', '2', '3', '4']) {
      expect(find.text(number), findsOneWidget);
    }
    expect(
      tester.getSize(find.text(longText)).height,
      tester.getSize(find.text('Padding(')).height,
    );
  });

  testWidgets('TC-51: 変えた行にだけ印が付く', (tester) async {
    await pumpPart(tester, CodeView(lines: lines));

    expect(find.byKey(CodeView.changedKey(2)), findsOneWidget);
    expect(find.byKey(CodeView.changedKey(1)), findsNothing);
    expect(find.byKey(CodeView.changedKey(3)), findsNothing);
  });

  testWidgets(
    'TC-51: 文字の上を横にドラッグするとスクロールする',
    (tester) async {
      await pumpPart(tester, CodeView(lines: lines));

      await tester.drag(scrollable, const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(
        tester.state<ScrollableState>(scrollable).position.pixels,
        greaterThan(0),
      );
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'TC-51: 長押しで文字を選べる',
    (tester) async {
      await pumpPart(tester, CodeView(lines: lines));
      // スクロールの中の選べる範囲は、次のフレームで SelectionArea に登録される
      await tester.pump();

      await tester.longPressAt(tester.getCenter(find.text('Padding(')));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
