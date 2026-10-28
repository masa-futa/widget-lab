import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 今の設定を再現する Dart のコードを作る。
class CodeGenerator {
  const CodeGenerator();

  String generate(WidgetEntry entry, Map<String, PropertySetting> settings) {
    final on = entry.properties.where((spec) => spec.isOnIn(settings));
    final lines = [
      for (final spec in on)
        if (spec.arg == PropertyArg.positional) _value(spec, settings),
      for (final spec in on)
        if (spec.arg == PropertyArg.named)
          '${spec.name}: ${_value(spec, settings)}',
    ];
    if (lines.isEmpty) return '${entry.codeName}()';
    return [
      '${entry.codeName}(',
      for (final line in lines) '  $line,',
      ')',
    ].join('\n');
  }

  String _value(PropertySpec spec, Map<String, PropertySetting> settings) =>
      spec.control.code(spec.valueIn(settings));
}
