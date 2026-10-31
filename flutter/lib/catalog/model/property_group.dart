/// プロパティの仲間。詳細画面のタブに使い、タブはこの順に並べる。
///
/// どの仲間に入れるか迷うものは、公式ドキュメントでの説明の順と、利用者が探すときの言葉で決める。
enum PropertyGroup {
  /// 大きさ（width・height・constraints）
  size,

  /// 余白（padding・margin）
  spacing,

  /// 配置（alignment・mainAxisAlignment）
  layout,

  /// 色と装飾（color・decoration・shape）
  paint,

  /// 変形（transform・clipBehavior）
  transform,

  /// 文字（style・maxLines）
  text,

  /// 挙動（enabled・duration・physics）
  behavior,

  /// 中身（child・children・title）
  content,
}
