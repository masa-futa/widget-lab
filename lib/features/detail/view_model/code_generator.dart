import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
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
    final initial = _lines(entry, entry.initialSettings());
    return [
      for (final (property, text) in _lines(entry, settings))
        CodeLine(
          text: text,
          property: property,
          changed: property != null && !initial.contains((property, text)),
        ),
    ];
  }

  /// （その行のプロパティ名, 行の文字）の一覧。
  ///
  /// 型引数を最初の行に書き、位置で渡す引数・入れ子の式・名前つきの引数・固定の引数の順に
  /// 1 行ずつ書く。引数が 1 つもなければ 1 行にする。
  List<(String?, String)> _lines(
    WidgetEntry entry,
    Map<String, PropertySetting> settings,
  ) {
    final on = entry.properties.where((spec) => spec.isWrittenIn(settings));
    final typeSpec = on
        .where((spec) => spec.arg == PropertyArg.typeArgument)
        .firstOrNull;
    final head = typeSpec == null
        ? entry.codeName
        : '${entry.codeName}<${_value(typeSpec, settings)}>';
    final arguments = <(String?, String)>[
      for (final spec in on)
        if (spec.arg == PropertyArg.positional)
          (spec.name, '  ${_value(spec, settings)},'),
      ..._nested(entry, on, settings),
      for (final spec in on)
        if (spec.arg == PropertyArg.named) ..._namedArgument(spec, settings),
      for (final argument in entry.codeArguments) (null, '  $argument,'),
    ];
    if (arguments.isEmpty) return [(typeSpec?.name, '$head()')];
    return [(typeSpec?.name, '$head('), ...arguments, (null, ')')];
  }

  /// 入れ子の式。中のプロパティ（ON のもの）を 1 行ずつ、なければもとの式だけを 1 行で。
  List<(String?, String)> _nested(
    WidgetEntry entry,
    Iterable<PropertySpec> on,
    Map<String, PropertySetting> settings,
  ) {
    final nest = entry.codeNest;
    if (nest == null) return const [];
    final inner = on.where((spec) => spec.arg == PropertyArg.nested);
    if (inner.isEmpty) return [(null, '  ${nest.name}: ${nest.receiver},')];
    return [
      (null, '  ${nest.name}: ${nest.receiver}.${nest.method}('),
      for (final spec in inner)
        (spec.name, '    ${spec.name}: ${_value(spec, settings)},'),
      (null, '  ),'),
    ];
  }

  /// 名前つきの引数。入れ子のプロパティは、ON の子を 1 行ずつ字下げして書く
  /// （子の行のプロパティ名は `親.子`）。ON の子がなければ `const 型()` の 1 行。
  List<(String?, String)> _namedArgument(
    PropertySpec spec,
    Map<String, PropertySetting> settings,
  ) {
    final control = spec.control;
    if (control is! NestedControl) {
      return [(spec.name, '  ${spec.name}: ${_value(spec, settings)},')];
    }
    final inner = switch (spec.valueIn(settings)) {
      NestedValue(:final settings) => settings,
      _ => const <String, PropertySetting>{},
    };
    final on = control.children.where((child) => child.isWrittenIn(inner));
    if (on.isEmpty) {
      return [(spec.name, '  ${spec.name}: const ${control.typeName}(),')];
    }
    return [
      (spec.name, '  ${spec.name}: ${control.typeName}('),
      for (final child in on)
        (
          '${spec.name}.${child.name}',
          '    ${child.name}: ${child.control.code(child.valueIn(inner))},',
        ),
      (spec.name, '  ),'),
    ];
  }

  String _value(PropertySpec spec, Map<String, PropertySetting> settings) =>
      spec.control.code(spec.valueIn(settings));
}
