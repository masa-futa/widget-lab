/// ホームでジャンルを分ける段。並びはこの順。
enum GenreGroupKind {
  /// Cupertino・Material design。
  designSystem,

  /// 残りの基本の Widget のジャンル。
  base,
}

/// 公式 Widget カタログのジャンル。並びは genres.dart の順。
final class Genre {
  const Genre({
    required this.id,
    required this.name,
    required this.group,
    required this.description,
  });

  /// 公式カタログのページの名前（例: `layout`）。
  final String id;
  final String name;

  /// ホームでどの段に置くか。
  final GenreGroupKind group;

  /// ジャンル画面に出す一言の説明。
  final String description;

  @override
  bool operator ==(Object other) =>
      other is Genre &&
      other.id == id &&
      other.name == name &&
      other.group == group &&
      other.description == description;

  @override
  int get hashCode => Object.hash(id, name, group, description);

  @override
  String toString() => 'Genre($id)';
}
