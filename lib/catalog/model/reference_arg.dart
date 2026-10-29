/// 見た目が変わらない引数（`key`・見た目に出ないコールバックなど）。触れないが、補足に載せる。
final class ReferenceArg {
  const ReferenceArg({
    required this.name,
    required this.typeLabel,
    required this.description,
  });

  final String name;
  final String typeLabel;
  final String description;
}
