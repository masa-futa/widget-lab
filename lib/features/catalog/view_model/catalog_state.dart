import 'package:flutter/foundation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// ホームのジャンルのタイル 1 枚分。
@immutable
final class GenreTile {
  const GenreTile({
    required this.genre,
    required this.count,
    required this.examples,
  });

  final Genre genre;

  /// そのジャンルに収録している Widget の数。0 のタイルは作らない。
  final int count;

  /// 代表の Widget 名。収録の順の最初の 3 件まで。
  final List<String> examples;

  /// 代表の名前に入りきらない Widget がある。
  bool get hasMore => count > examples.length;

  @override
  bool operator ==(Object other) =>
      other is GenreTile &&
      other.genre == genre &&
      other.count == count &&
      listEquals(other.examples, examples);

  @override
  int get hashCode => Object.hash(genre, count, Object.hashAll(examples));
}

/// ホームの段 1 つ分。[tiles] は空にしない。
@immutable
final class GenreGroup {
  const GenreGroup({required this.kind, required this.tiles});

  final GenreGroupKind kind;
  final List<GenreTile> tiles;

  @override
  bool operator ==(Object other) =>
      other is GenreGroup &&
      other.kind == kind &&
      listEquals(other.tiles, tiles);

  @override
  int get hashCode => Object.hash(kind, Object.hashAll(tiles));
}

/// 検索の結果の 1 件。
@immutable
final class SearchResult {
  const SearchResult({required this.entry, required this.genres});

  final WidgetEntry entry;

  /// [entry] が載っているジャンル（`entry.genreIds` の順）。
  final List<Genre> genres;

  @override
  bool operator ==(Object other) =>
      other is SearchResult &&
      other.entry == entry &&
      listEquals(other.genres, genres);

  @override
  int get hashCode => Object.hash(entry, Object.hashAll(genres));
}

/// ホーム画面の状態。読み込み中・エラーは同梱データなので持たない。
@immutable
final class CatalogState {
  const CatalogState({
    required this.query,
    required this.groups,
    required this.results,
  });

  /// 検索の入力（前後の空白を除いたもの）。
  final String query;

  /// 段の順に並べたジャンルのタイル。空の段は入れない。
  final List<GenreGroup> groups;

  /// 検索の結果。名前の ABC 順で、同じ Widget は 1 回だけ。
  final List<SearchResult> results;

  /// 検索中（タイルの代わりに結果を出す）。
  bool get isSearching => query.isNotEmpty;

  /// 検索の結果が 0 件。
  bool get isEmpty => isSearching && results.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is CatalogState &&
      other.query == query &&
      listEquals(other.groups, groups) &&
      listEquals(other.results, results);

  @override
  int get hashCode =>
      Object.hash(query, Object.hashAll(groups), Object.hashAll(results));
}
