import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/menu.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら MenuAnchor の既定値で組み立てる（項目と builder は必須）', () {
    final built = menuEntry.build(DemoArgs(menuEntry, allOff(menuEntry)));
    final anchor = built as MenuAnchor;

    expect(anchor.menuChildren, hasLength(3));
    expect(anchor.builder, isNotNull);
    expect(anchor.style, isNull);
    expect(anchor.alignmentOffset, Offset.zero);
  });

  testWidgets('プレビューのボタンを押すとメニューが開き、もう一度押すと閉じる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: menuEntry.build(
              DemoArgs(menuEntry, menuEntry.initialSettings()),
            ),
          ),
        ),
      ),
    );
    expect(find.text('編集'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('編集'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('編集'), findsNothing);
  });
}
