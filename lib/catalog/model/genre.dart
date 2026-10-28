/// 公式 Widget カタログのジャンル。並びは genres.dart の順。
final class Genre {
  const Genre({required this.id, required this.name});

  /// 公式カタログのページの名前（例: `layout`）。
  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Genre && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'Genre($id)';
}
