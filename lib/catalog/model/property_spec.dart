import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

/// コードでの渡し方。
enum PropertyArg {
  /// `padding: …`
  named,

  /// `Text('こんにちは')` の最初の引数
  positional,
}

/// 収録する Widget の1つのプロパティの定義。
///
/// [control] が写し方の関数を持つため、`==` は同一性で比べる。
final class PropertySpec {
  const PropertySpec({
    required this.name,
    required this.typeLabel,
    required this.description,
    required this.control,
    this.required = false,
    this.initiallyOn = true,
    this.arg = PropertyArg.named,
  });

  final String name;

  /// 型の表示（例: `EdgeInsetsGeometry`）。
  final String typeLabel;
  final String description;
  final PropertyControl control;

  /// 必須のプロパティは常に ON（スイッチを出さない）。
  final bool required;

  /// 開いたときに ON か。
  final bool initiallyOn;
  final PropertyArg arg;

  /// 開いたときの設定。
  PropertySetting get initialSetting =>
      PropertySetting(on: required || initiallyOn, value: control.initial);

  /// [settings] のもとで ON か。必須なら常に ON、設定がなければ OFF。
  bool isOnIn(Map<String, PropertySetting> settings) =>
      required || (settings[name]?.on ?? false);

  /// [settings] のもとでの値。設定がなければ最初の値。
  ControlValue valueIn(Map<String, PropertySetting> settings) =>
      settings[name]?.value ?? control.initial;
}
