import 'package:widget_lab/catalog/model/control_value.dart';

/// 1つのプロパティの今の設定。OFF にしても [value] は覚えておく。
final class PropertySetting {
  const PropertySetting({required this.on, required this.value});

  final bool on;
  final ControlValue value;

  PropertySetting copyWith({bool? on, ControlValue? value}) =>
      PropertySetting(on: on ?? this.on, value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      other is PropertySetting && other.on == on && other.value == value;

  @override
  int get hashCode => Object.hash(on, value);

  @override
  String toString() => 'PropertySetting(on: $on, value: $value)';
}
