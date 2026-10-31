import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_toolbar_button.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の文字だけを渡し、onPressed は既定値（null）', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoTextSelectionToolbarButtonEntry.build(
            DemoArgs(
              cupertinoTextSelectionToolbarButtonEntry,
              allOff(cupertinoTextSelectionToolbarButtonEntry),
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<CupertinoTextSelectionToolbarButton>(
      find.byType(CupertinoTextSelectionToolbarButton),
    );
    expect(button.text, 'コピー');
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
