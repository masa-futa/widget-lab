/// 操作部品が扱う値。Widget に渡す値への写し方は [PropertyControl] が持つ。
sealed class ControlValue {
  const ControlValue();
}

final class SliderValue extends ControlValue {
  const SliderValue(this.value);

  final double value;

  @override
  bool operator ==(Object other) =>
      other is SliderValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SliderValue($value)';
}

final class SwitchValue extends ControlValue {
  const SwitchValue(this.value);

  final bool value;

  @override
  bool operator ==(Object other) =>
      other is SwitchValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SwitchValue($value)';
}

/// 選択肢・色見本の何番目を選んだか。
final class ChoiceValue extends ControlValue {
  const ChoiceValue(this.index);

  final int index;

  @override
  bool operator ==(Object other) =>
      other is ChoiceValue && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'ChoiceValue($index)';
}

final class TextValue extends ControlValue {
  const TextValue(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is TextValue && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TextValue($value)';
}

/// 利用者が変えない値（ON / OFF だけを切り替える）。
final class FixedValue extends ControlValue {
  const FixedValue();

  @override
  bool operator ==(Object other) => other is FixedValue;

  @override
  int get hashCode => (FixedValue).hashCode;

  @override
  String toString() => 'FixedValue()';
}
