import 'dart:ui';

import 'package:widget_lab/catalog/model/dart_code.dart';

/// 選択肢・色見本の1つ。[value] は Widget に渡す値、[code] はコードでの書き方。
final class Choice {
  const Choice(this.label, this.value, this.code);

  Choice.color(this.label, Color color)
    : value = color,
      code = colorCode(color);

  final String label;
  final Object value;
  final String code;

  @override
  bool operator ==(Object other) =>
      other is Choice &&
      other.label == label &&
      other.value == value &&
      other.code == code;

  @override
  int get hashCode => Object.hash(label, value, code);
}
