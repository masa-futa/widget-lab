import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/interaction/ignore_pointer.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

import '../demo_pump.dart';

void main() {
  DemoArgs argsWith({required bool ignoring}) => DemoArgs(ignorePointerEntry, {
    ...ignorePointerEntry.initialSettings(),
    'ignoring': PropertySetting(on: true, value: SwitchValue(ignoring)),
  });

  testWidgets('IgnorePointer: ignoring が true なら、ボタンを押しても後ろの面に届く', (
    tester,
  ) async {
    final recorder = await pumpDemo(
      tester,
      ignorePointerEntry.build(argsWith(ignoring: true)),
    );
    await tester.tap(find.text('押す'), warnIfMissed: false);

    expect(recorder.logs, ['後ろの面: onTap']);
  });

  testWidgets('IgnorePointer: 使わない側はボタンが押せる', (tester) async {
    final recorder = await pumpDemo(
      tester,
      ignorePointerEntry.buildWithout!(argsWith(ignoring: true)),
    );
    await tester.tap(find.text('押す'));

    expect(recorder.logs, ['手前のボタン: onPressed']);
  });
}
