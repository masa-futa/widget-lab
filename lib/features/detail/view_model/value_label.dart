import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';

/// 操作パネルの値の表示と、比較のカードの読み上げに使う、値の短い文字。
///
/// スライダーはコードと同じく浮動小数の誤差を小数第 6 位で丸める（例: `16.0`）。
/// 選択肢・色見本は名前、[FixedControl] はコードでの書き方。
String valueLabel(PropertyControl control, ControlValue value) =>
    switch ((control, value)) {
      (SliderControl(), SliderValue(:final value)) =>
        '${double.parse(value.toStringAsFixed(6))}',
      (ChoiceControl(:final choices), ChoiceValue(:final index)) =>
        choices[index].label,
      (ColorControl(:final palette), ChoiceValue(:final index)) =>
        palette[index].label,
      (SwitchControl(), SwitchValue(:final value)) => '$value',
      (TextControl(), TextValue(:final value)) => value,
      (FixedControl(:final source), FixedValue()) => source,
      (NestedControl(:final typeName), NestedValue()) => typeName,
      _ => throw ArgumentError.value(value, 'value', '$control と合わない値'),
    };

/// チップに出す、さらに短い値の文字。
///
/// スライダーは整数なら小数点を省き（例: `16`）、[FixedControl] は末尾の `()` を省く
/// （例: `FlutterLogo`）。[FixedControl] の書き方が長いときは先頭の型の名前だけにする
/// （例: `OverflowBox`・`[BoxShadow]`）。ほかは [valueLabel] と同じ。
String chipValueLabel(PropertyControl control, ControlValue value) =>
    switch ((control, value)) {
      (SliderControl(), SliderValue()) => valueLabel(
        control,
        value,
      ).replaceFirst(RegExp(r'\.0$'), ''),
      (FixedControl(:final source), FixedValue()) => _shortSource(source),
      _ => valueLabel(control, value),
    };

/// 書き方のまま出す長さの上限。超えたら型の名前だけにする。
const _maxSourceLength = 20;

/// 先頭の型の名前（`Padding`・`EdgeInsets.symmetric`）。リストの `[` と `const` は飛ばす。
final _leadingType = RegExp(r'^\[?(?:const )?([A-Za-z_][\w.]*)');

String _shortSource(String source) {
  final trimmed = source.replaceFirst(RegExp(r'\(\)$'), '');
  if (trimmed.length <= _maxSourceLength) return trimmed;
  final type = _leadingType.firstMatch(source)?.group(1);
  // 型の名前が取れない（文字の値など）ときは、長くても書き方のまま返す
  if (type == null) return trimmed;
  return source.startsWith('[') ? '[$type]' : type;
}
