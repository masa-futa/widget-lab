import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_picker_default_selection_overlay.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoPickerDefaultSelectionOverlayEntry.build(
            DemoArgs(
              cupertinoPickerDefaultSelectionOverlayEntry,
              allOff(cupertinoPickerDefaultSelectionOverlayEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoPickerDefaultSelectionOverlay>(
      find.byType(CupertinoPickerDefaultSelectionOverlay),
    );
    const defaults = CupertinoPickerDefaultSelectionOverlay();
    expect(built.background, defaults.background);
    expect(built.capStartEdge, defaults.capStartEdge);
    expect(built.capEndEdge, defaults.capEndEdge);
  });
}
