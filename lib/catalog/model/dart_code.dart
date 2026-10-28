import 'dart:ui';

/// [value] を、そのまま貼れる Dart の文字列の式（一重引用符）にする。
String dartString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
  return "'$escaped'";
}

/// [color] を `Color(0xAARRGGBB)` の式にする。
String colorCode(Color color) {
  final hex = color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');
  return 'Color(0x$hex)';
}
