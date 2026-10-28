import 'package:flutter/foundation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 一覧の 1 ジャンル分。[entries] は絞った結果で、空にはしない。
@immutable
final class CatalogSection {
  const CatalogSection({required this.genre, required this.entries});

  final Genre genre;
  final List<WidgetEntry> entries;

  @override
  bool operator ==(Object other) =>
      other is CatalogSection &&
      other.genre == genre &&
      listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(genre, Object.hashAll(entries));
}

/// 一覧画面の状態。読み込み中・エラーは同梱データなので持たない。
@immutable
final class CatalogState {
  const CatalogState({required this.query, required this.sections});

  /// 検索の入力（前後の空白を除いたもの）。
  final String query;

  /// 公式カタログの順のジャンル。0 件のジャンルは入れない。
  final List<CatalogSection> sections;

  /// 検索の結果が 0 件。
  bool get isEmpty => query.isNotEmpty && sections.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is CatalogState &&
      other.query == query &&
      listEquals(other.sections, sections);

  @override
  int get hashCode => Object.hash(query, Object.hashAll(sections));
}
