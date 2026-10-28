import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/navigator.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';
import '../demo_pump.dart';

void main() {
  final args = DemoArgs(navigatorEntry, allOff(navigatorEntry));

  testWidgets('Navigator: 詳細へ進むと push、戻ると pop がログに出る', (tester) async {
    final recorder = await pumpDemo(tester, navigatorEntry.build(args));
    expect(recorder.logs, ['push: /']);

    await tester.tap(find.text('詳細へ'));
    await tester.pumpAndSettle();
    expect(find.text('詳細'), findsOneWidget);

    await tester.tap(find.text('戻る'));
    await tester.pumpAndSettle();
    expect(find.text('ホーム'), findsOneWidget);
    expect(recorder.logs, ['push: /', 'push: /detail', 'pop: /detail']);
  });

  testWidgets('Navigator: 使わない側は setState で画面を入れ替える', (tester) async {
    final recorder = await pumpDemo(tester, navigatorEntry.buildWithout!(args));

    await tester.tap(find.text('詳細へ'));
    await tester.pump();

    expect(find.text('詳細'), findsOneWidget);
    expect(recorder.logs, ['setState: 詳細を出す']);
  });
}
