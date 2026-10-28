import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/input/autocomplete.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Autocomplete の既定値で組み立てる（optionsBuilder は必須）', () {
    final box = autocompleteEntry.build(
      DemoArgs(autocompleteEntry, allOff(autocompleteEntry)),
    ) as SizedBox;
    final autocomplete = box.child! as Autocomplete<String>;

    expect(autocomplete.optionsMaxHeight, 200);
    expect(
      autocomplete.optionsViewOpenDirection,
      OptionsViewOpenDirection.down,
    );
    expect(autocomplete.initialValue, isNull);
    expect(autocomplete.optionsBuilder(const TextEditingValue(text: 'ap')), [
      'apple',
      'apricot',
    ]);
    expect(autocomplete.optionsBuilder(TextEditingValue.empty), isEmpty);
  });
}
