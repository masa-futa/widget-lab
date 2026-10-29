import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';

/// コードでの渡し方。
enum PropertyArg {
  /// `padding: …`
  named,

  /// `Text('こんにちは')` の最初の引数
  positional,

  /// 入れ子の式の中（`MediaQuery.of(context).copyWith(textScaler: …)`）。
  /// 書き方は `WidgetEntry.codeNest`
  nested,

  /// 型引数（`NotificationListener<ScrollUpdateNotification>`）。必須にする
  typeArgument,
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
    this.omitIf,
    this.group,
    this.pairsWith = const [],
    this.requires,
    this.excludes = const [],
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

  /// ほかのプロパティとの組み合わせで、ON でも Widget に渡さない（コードにも書かない）条件。
  /// 例: NavigationRail は extended の間、labelType を渡せない（assert）。
  /// 入れ子の子（[NestedControl] の children）にも効く。その場合 [settings] は入れ子の中の設定。
  final bool Function(Map<String, PropertySetting> settings)? omitIf;

  /// 仲間（タブ）。`null` は仲間を決めていない収録（段 2 で埋める）。
  final PropertyGroup? group;

  /// 組で使うことが多い相手（プロパティ名）。向きは問わない。
  final List<String> pairsWith;

  /// これが ON でないと効かない相手（プロパティ名）。
  final String? requires;

  /// 同時には使えない相手（プロパティ名）。相手の側にも書く（全件のテストで見張る）。
  final List<String> excludes;

  /// 開いたときの設定。
  PropertySetting get initialSetting =>
      PropertySetting(on: required || initiallyOn, value: control.initial);

  /// [settings] のもとで ON か。必須なら常に ON、設定がなければ OFF。
  bool isOnIn(Map<String, PropertySetting> settings) =>
      required || (settings[name]?.on ?? false);

  /// [settings] のもとでコードに書くか。ON で、[omitIf] に当たらない。
  bool isWrittenIn(Map<String, PropertySetting> settings) =>
      isOnIn(settings) && !(omitIf?.call(settings) ?? false);

  /// [settings] のもとでの値。設定がなければ最初の値。
  ControlValue valueIn(Map<String, PropertySetting> settings) =>
      settings[name]?.value ?? control.initial;

  /// 入れ子の中身。入れ子のプロパティでなければ空。
  List<PropertySpec> get children => switch (control) {
    NestedControl(:final children) => children,
    _ => const [],
  };
}
