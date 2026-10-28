import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/interactive_viewer.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら InteractiveViewer の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, interactiveViewerEntry);
    final built = demoWidget<InteractiveViewer>(tester);

    expect(built.constrained, isTrue);
    expect(built.minScale, 0.8);
    expect(built.maxScale, 2.5);
    expect(built.panEnabled, isTrue);
    expect(built.scaleEnabled, isTrue);
  });
}
