import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/layout_builder.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../demo_pump.dart';

void main() {
  final args = DemoArgs(
    layoutBuilderEntry,
    layoutBuilderEntry.initialSettings(),
  );

  testWidgets('LayoutBuilder: 置かれた幅がしきい値（240）より狭いと縦に並べ、builder の幅をログに出す', (
    tester,
  ) async {
    final wide = await pumpDemo(tester, layoutBuilderEntry.build(args));
    expect(find.text('横に並べる子'), findsOneWidget);
    expect(wide.logs.single, startsWith('builder: maxWidth '));

    await pumpDemo(
      tester,
      layoutBuilderEntry.build(args),
      size: const Size(160, 240),
    );
    expect(find.text('縦に並べる子'), findsOneWidget);
  });

  testWidgets('LayoutBuilder: 使わない側は画面の幅で組み分けるので、狭い所でも横のまま', (tester) async {
    final recorder = await pumpDemo(
      tester,
      layoutBuilderEntry.buildWithout!(args),
      size: const Size(160, 240),
    );

    expect(find.text('横に並べる子'), findsOneWidget);
    expect(recorder.logs.single, startsWith('画面の幅 '));
  });
}
