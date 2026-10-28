import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_desktop_text_selection_controls.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

Future<CupertinoTextField> _fieldOf(WidgetTester tester, DemoArgs args) async {
  await tester.pumpWidget(
    CupertinoApp(
      home: Center(
        child: cupertinoDesktopTextSelectionControlsEntry.build(args),
      ),
    ),
  );
  return tester.widget<CupertinoTextField>(find.byType(CupertinoTextField));
}

void main() {
  testWidgets('TC-18: 全部 OFF なら selectionControls は既定値（null）', (tester) async {
    final field = await _fieldOf(
      tester,
      DemoArgs(
        cupertinoDesktopTextSelectionControlsEntry,
        allOff(cupertinoDesktopTextSelectionControlsEntry),
      ),
    );

    expect(field.selectionControls, isNull);
    expect(field.controller?.text, isNotEmpty);
  });

  testWidgets('ON なら CupertinoDesktopTextSelectionControls を渡す', (
    tester,
  ) async {
    final field = await _fieldOf(
      tester,
      DemoArgs(
        cupertinoDesktopTextSelectionControlsEntry,
        cupertinoDesktopTextSelectionControlsEntry.initialSettings(),
      ),
    );

    expect(
      field.selectionControls,
      isA<CupertinoDesktopTextSelectionControls>(),
    );
  });
}
