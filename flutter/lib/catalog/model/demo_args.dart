import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 組み立ての関数に渡す、ON のプロパティの値。
final class DemoArgs {
  DemoArgs(WidgetEntry entry, Map<String, PropertySetting> settings)
    : _names = {for (final spec in entry.properties) spec.name},
      _values = {
        for (final spec in entry.properties)
          if (spec.isOnIn(settings))
            spec.name: spec.control.resolve(spec.valueIn(settings)),
      };

  final Set<String> _names;
  final Map<String, Object> _values;

  /// [name] のプロパティの値。OFF なら `null`。
  ///
  /// 収録データにない名前なら [ArgumentError]、値が [T] でなければ [StateError]（収録データの不備）。
  T? valueOf<T extends Object>(String name) {
    if (!_names.contains(name)) {
      throw ArgumentError.value(name, 'name', '収録データにないプロパティ');
    }
    final value = _values[name];
    if (value == null) return null;
    if (value is! T) {
      throw StateError('$name は $T ではなく ${value.runtimeType}');
    }
    return value;
  }
}
