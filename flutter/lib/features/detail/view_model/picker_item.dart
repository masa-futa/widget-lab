import 'package:widget_lab/catalog/model/property_spec.dart';

/// 選ぶ欄の 1 か所。プロパティか、最後の補足。
sealed class PickerItem {
  const PickerItem();

  /// 一覧の見出しと点の間を分ける区切り。プロパティは仲間（なければ `null`）、補足は補足そのもの。
  Object? get section;
}

/// 1 つのプロパティ。
final class PickerProperty extends PickerItem {
  const PickerProperty(this.spec);

  final PropertySpec spec;

  @override
  Object? get section => spec.group;

  @override
  bool operator ==(Object other) =>
      other is PickerProperty && other.spec.name == spec.name;

  @override
  int get hashCode => spec.name.hashCode;

  @override
  String toString() => 'PickerProperty(${spec.name})';
}

/// 補足（見た目が変わらない引数の一覧）。
final class PickerReferences extends PickerItem {
  const PickerReferences();

  @override
  Object? get section => this;

  @override
  bool operator ==(Object other) => other is PickerReferences;

  @override
  int get hashCode => (PickerReferences).hashCode;

  @override
  String toString() => 'PickerReferences()';
}
