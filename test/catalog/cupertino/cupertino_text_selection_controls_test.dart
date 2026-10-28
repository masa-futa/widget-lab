import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_controls.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Future<CupertinoTextField> _fieldOf(WidgetTester tester, DemoArgs args) async {
  await tester.pumpWidget(
    CupertinoApp(
      home: Center(child: cupertinoTextSelectionControlsEntry.build(args)),
    ),
  );
  return tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
}

void main() {
  testWidgets('TC-18: 全部 OFF なら selectionControls は既定値（null）', (tester) async {
    final field = await _fieldOf(
      tester,
      DemoArgs(
        cupertinoTextSelectionControlsEntry,
        allOff(cupertinoTextSelectionControlsEntry),
      ),
    );

    expect(field.selectionControls, isNull);
    expect(field.controller?.text, isNotEmpty);
  });

  testWidgets('ON なら CupertinoTextSelectionControls を渡す', (tester) async {
    final field = await _fieldOf(
      tester,
      DemoArgs(
        cupertinoTextSelectionControlsEntry,
        cupertinoTextSelectionControlsEntry.initialSettings(),
      ),
    );

    expect(field.selectionControls, isA<CupertinoTextSelectionControls>());
  });
}
