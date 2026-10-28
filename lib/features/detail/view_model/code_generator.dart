import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// コードの 1 行。
final class CodeLine {
  const CodeLine({required this.text, this.property, this.changed = false});

  final String text;

  /// その行のプロパティ名。`Padding(` と `)` は `null`。
  final String? property;

  /// 最初の値で作ったときの行と違う（値が変わった、または最初は書かれていなかった）。
  final bool changed;

  @override
  bool operator ==(Object other) =>
      other is CodeLine &&
      other.text == text &&
      other.property == property &&
      other.changed == changed;

  @override
  int get hashCode => Object.hash(text, property, changed);

  @override
  String toString() =>
      'CodeLine($text, property: $property, changed: $changed)';
}

/// 今の設定を再現する Dart のコードを作る。
class CodeGenerator {
  const CodeGenerator();

  String generate(WidgetEntry entry, Map<String, PropertySetting> settings) =>
      lines(entry, settings).map((line) => line.text).join('\n');

  /// [generate] を行ごとに返す。最初の値の行と比べて `changed` を付ける。
  List<CodeLine> lines(
    WidgetEntry entry,
    Map<String, PropertySetting> settings,
  ) {
    final initial = _arguments(entry, entry.initialSettings());
    final arguments = _arguments(entry, settings);
    if (arguments.isEmpty) return [CodeLine(text: '${entry.codeName}()')];
    return [
      CodeLine(text: '${entry.codeName}('),
      for (final (name, text) in arguments)
        CodeLine(
          text: '  $text,',
          property: name,
          changed: !initial.contains((name, text)),
        ),
      const CodeLine(text: ')'),
    ];
  }

  /// ON のプロパティの（名前, 引数の書き方）。位置で渡す引数を先に書く。
  List<(String, String)> _arguments(
    WidgetEntry entry,
    Map<String, PropertySetting> settings,
  ) {
    final on = entry.properties.where((spec) => spec.isOnIn(settings));
    return [
      for (final spec in on)
        if (spec.arg == PropertyArg.positional)
          (spec.name, _value(spec, settings)),
      for (final spec in on)
        if (spec.arg == PropertyArg.named)
          (spec.name, '${spec.name}: ${_value(spec, settings)}'),
    ];
  }

  String _value(PropertySpec spec, Map<String, PropertySetting> settings) =>
      spec.control.code(spec.valueIn(settings));
}
