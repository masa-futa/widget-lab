import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/absorb_pointer.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../demo_pump.dart';

void main() {
  DemoArgs argsWith({required bool absorbing}) => DemoArgs(absorbPointerEntry, {
    ...absorbPointerEntry.initialSettings(),
    'absorbing': PropertySetting(on: true, value: SwitchValue(absorbing)),
  });

  testWidgets('AbsorbPointer: absorbing が true なら、ボタンにも後ろの面にも届かない', (
    tester,
  ) async {
    final recorder = await pumpDemo(
      tester,
      absorbPointerEntry.build(argsWith(absorbing: true)),
    );
    await tester.tap(find.text('押す'), warnIfMissed: false);

    expect(recorder.logs, isEmpty);
  });

  testWidgets('AbsorbPointer: absorbing が false なら、ボタンが押せる', (tester) async {
    final recorder = await pumpDemo(
      tester,
      absorbPointerEntry.build(argsWith(absorbing: false)),
    );
    await tester.tap(find.text('押す'));

    expect(recorder.logs, ['手前のボタン: onPressed']);
  });

  testWidgets('AbsorbPointer: 使わない側はボタンが押せる', (tester) async {
    final recorder = await pumpDemo(
      tester,
      absorbPointerEntry.buildWithout!(argsWith(absorbing: true)),
    );
    await tester.tap(find.text('押す'));

    expect(recorder.logs, ['手前のボタン: onPressed']);
  });
}
