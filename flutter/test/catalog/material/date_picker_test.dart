import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/demo/demo_stage.dart';
import 'package:widget_lab/catalog/material/date_picker.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら DatePickerDialog の既定値（未選択・カレンダー・日）で組み立てる', () {
    final stage = datePickerEntry.build(
      DemoArgs(datePickerEntry, allOff(datePickerEntry)),
    ) as DemoStage;
    final dialog = stage.child as DatePickerDialog;

    expect(dialog.initialDate, isNull);
    expect(dialog.initialEntryMode, DatePickerEntryMode.calendar);
    expect(dialog.initialCalendarMode, DatePickerMode.day);
  });
}
