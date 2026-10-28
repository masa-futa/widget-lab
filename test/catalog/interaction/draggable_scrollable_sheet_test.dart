import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/draggable_scrollable_sheet.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら DraggableScrollableSheet の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, draggableScrollableSheetEntry);
    final built = demoWidget<DraggableScrollableSheet>(tester);

    expect(built.initialChildSize, 0.5);
    expect(built.minChildSize, 0.25);
    expect(built.maxChildSize, 1.0);
    expect(built.snap, isFalse);
  });
}
