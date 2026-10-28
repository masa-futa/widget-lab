import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';

/// 画面の操作部品と、Widget に渡す値への写し方と、コードでの書き方をまとめたもの。
///
/// 写し方の関数を持つため、`==` は同一性で比べる。
sealed class PropertyControl {
  const PropertyControl();

  /// 開いたときの値。
  ControlValue get initial;

  /// [value] を Widget に渡す値にする。操作部品と合わない種類の値なら [ArgumentError]。
  Object resolve(ControlValue value);

  /// [value] を、そのまま貼れる Dart の式にする。
  String code(ControlValue value);
}

final class SliderControl extends PropertyControl {
  const SliderControl({
    required this.min,
    required this.max,
    required this.divisions,
    required this.initialValue,
    required this._resolve,
    required this._code,
  });

  final double min;
  final double max;
  final int divisions;
  final double initialValue;
  final Object Function(double value) _resolve;
  final String Function(double value) _code;

  @override
  SliderValue get initial => SliderValue(initialValue);

  @override
  Object resolve(ControlValue value) => _resolve(_read(value));

  @override
  String code(ControlValue value) => _code(_read(value));

  /// Slider の段の値（`min + (max - min) * i / divisions`）に出る浮動小数の誤差を、
  /// 小数第 6 位で丸めて消す（例: 109.99999999999999 → 110.0）。
  double _read(ControlValue value) => switch (value) {
    SliderValue(:final value) => double.parse(value.toStringAsFixed(6)),
    _ => throw ArgumentError.value(value, 'value', 'SliderValue ではない'),
  };
}

final class SwitchControl extends PropertyControl {
  const SwitchControl({required this.initialValue});

  final bool initialValue;

  @override
  SwitchValue get initial => SwitchValue(initialValue);

  @override
  Object resolve(ControlValue value) => _read(value);

  @override
  String code(ControlValue value) => '${_read(value)}';

  bool _read(ControlValue value) => switch (value) {
    SwitchValue(:final value) => value,
    _ => throw ArgumentError.value(value, 'value', 'SwitchValue ではない'),
  };
}

/// 選択肢から1つ選ぶ。4つまではセグメント、5つ以上はドロップダウンで出す。
final class ChoiceControl extends PropertyControl {
  const ChoiceControl({required this.choices, this.initialIndex = 0});

  final List<Choice> choices;
  final int initialIndex;

  @override
  ChoiceValue get initial => ChoiceValue(initialIndex);

  @override
  Object resolve(ControlValue value) => _choiceAt(choices, value).value;

  @override
  String code(ControlValue value) => _choiceAt(choices, value).code;
}

/// 色見本から1つ選ぶ。
final class ColorControl extends PropertyControl {
  const ColorControl({required this.palette, this.initialIndex = 0});

  final List<Choice> palette;
  final int initialIndex;

  @override
  ChoiceValue get initial => ChoiceValue(initialIndex);

  @override
  Object resolve(ControlValue value) => _choiceAt(palette, value).value;

  @override
  String code(ControlValue value) => _choiceAt(palette, value).code;
}

final class TextControl extends PropertyControl {
  const TextControl({required this.initialValue, this.maxLength = 40});

  final String initialValue;
  final int maxLength;

  @override
  TextValue get initial => TextValue(initialValue);

  @override
  Object resolve(ControlValue value) => _read(value);

  @override
  String code(ControlValue value) => dartString(_read(value));

  String _read(ControlValue value) => switch (value) {
    TextValue(:final value) => value,
    _ => throw ArgumentError.value(value, 'value', 'TextValue ではない'),
  };
}

/// 利用者が変えない値（例: デモの子の `FlutterLogo()`）。操作パネルでは ON / OFF だけを出す。
final class FixedControl extends PropertyControl {
  const FixedControl({required this.value, required this.source});

  final Object value;

  /// コードでの書き方。
  final String source;

  @override
  FixedValue get initial => const FixedValue();

  @override
  Object resolve(ControlValue value) {
    _check(value);
    return this.value;
  }

  @override
  String code(ControlValue value) {
    _check(value);
    return source;
  }

  void _check(ControlValue value) {
    if (value is! FixedValue) {
      throw ArgumentError.value(value, 'value', 'FixedValue ではない');
    }
  }
}

Choice _choiceAt(List<Choice> choices, ControlValue value) => switch (value) {
  ChoiceValue(:final index) => choices[index],
  _ => throw ArgumentError.value(value, 'value', 'ChoiceValue ではない'),
};
