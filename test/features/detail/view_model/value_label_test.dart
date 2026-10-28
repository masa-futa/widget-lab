import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';

void main() {
  final slider = SliderControl(
    min: 0,
    max: 48,
    divisions: 12,
    initialValue: 16,
    resolve: EdgeInsets.all,
    code: (v) => 'EdgeInsets.all($v)',
  );
  const choice = ChoiceControl(
    choices: [
      Choice('start', MainAxisAlignment.start, 'MainAxisAlignment.start'),
      Choice('center', MainAxisAlignment.center, 'MainAxisAlignment.center'),
    ],
  );
  final color = ColorControl(
    palette: [
      Choice.color('瑠璃', const Color(0xFF1E50A2)),
      Choice.color('山吹', const Color(0xFFF8B500)),
    ],
  );

  for (final (control, value, expected) in [
    (slider, const SliderValue(16), '16.0'),
    (slider, const SliderValue(109.99999999999999), '110.0'),
    (choice, const ChoiceValue(1), 'center'),
    (color, const ChoiceValue(1), '山吹'),
    (
      const SwitchControl(initialValue: true),
      const SwitchValue(false),
      'false',
    ),
    (const TextControl(initialValue: ''), const TextValue("It's"), "It's"),
    (
      const FixedControl(value: SizedBox(), source: 'SizedBox()'),
      const FixedValue(),
      'SizedBox()',
    ),
  ]) {
    test('TC-19: 値の表示 ${control.runtimeType} $value → $expected', () {
      expect(valueLabel(control, value), expected);
    });
  }
}
