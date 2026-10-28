import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/time_picker.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら TimePickerDialog の既定値（文字盤・向きは画面に合わせる）で組み立てる', () {
    final built = timePickerEntry.build(
      DemoArgs(timePickerEntry, allOff(timePickerEntry)),
    );
    final dialog = (built as DemoStage).child as TimePickerDialog;

    expect(dialog.initialTime, const TimeOfDay(hour: 10, minute: 30));
    expect(dialog.initialEntryMode, TimePickerEntryMode.dial);
    expect(dialog.orientation, isNull);
    expect(dialog.helpText, isNull);
  });
}
