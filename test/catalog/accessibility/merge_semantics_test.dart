import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/accessibility/merge_semantics.dart';

import 'readout.dart';

void main() {
  testWidgets('TC-18: プロパティはなく、MergeSemantics で包む', (tester) async {
    await pumpReadout(tester, mergeSemanticsEntry);

    expect(find.byType(MergeSemantics), findsOneWidget);
  });

  testWidgets('包むとチェックボックスと文を 1 つに読み、外すと別々に読む', (tester) async {
    expect(
      await pumpReadout(tester, mergeSemanticsEntry),
      '読み上げ:\n「お知らせを受け取る」、チェックあり',
    );
    expect(
      await pumpReadout(tester, mergeSemanticsEntry, without: true),
      '読み上げ:\nチェックあり\n「お知らせを受け取る」',
    );
  });

  testWidgets('チェックボックスを押すと、書き出しも変わる', (tester) async {
    await pumpReadout(tester, mergeSemanticsEntry);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(readoutText(tester), '読み上げ:\n「お知らせを受け取る」、チェックなし');
  });
}
