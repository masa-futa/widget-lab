import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/dismissible.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Dismissible の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, dismissibleEntry);
    final built = demoWidget<Dismissible>(tester);

    expect(built.direction, DismissDirection.horizontal);
    expect(built.background, isNull);
  });

  testWidgets('Dismissible: スワイプした項目が消え、全部消すと元に戻せる', (tester) async {
    final args = DemoArgs(dismissibleEntry, dismissibleEntry.initialSettings());
    await pumpDemo(tester, dismissibleEntry.build(args));

    for (final n in ['1', '2', '3']) {
      await tester.drag(find.text(n), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text(n), findsNothing);
    }

    await tester.tap(find.text('元に戻す'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
