import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_view.dart';

import '../pump.dart';

void main() {
  final longLine = 'Padding(${'padding: EdgeInsets.all(16.0), ' * 10})';
  final scrollable = find
      .descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('TC-51: 長い行は折り返さない', (tester) async {
    await pumpPart(tester, const CodeView(code: 'Padding()'));
    final lineHeight = tester.getSize(find.text('Padding()')).height;

    await pumpPart(tester, CodeView(code: longLine));

    expect(tester.getSize(find.text(longLine)).height, lineHeight);
  });

  testWidgets(
    'TC-51: 文字の上を横にドラッグするとスクロールする',
    (tester) async {
      await pumpPart(tester, CodeView(code: longLine));

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
      await pumpPart(tester, CodeView(code: longLine));
      // スクロールの中の選べる範囲は、次のフレームで SelectionArea に登録される
      await tester.pump();

      await tester.longPressAt(
        tester.getTopLeft(scrollable) + const Offset(40, 24),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveTextSelectionToolbar), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
