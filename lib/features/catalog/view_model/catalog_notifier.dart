import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';

part 'catalog_notifier.g.dart';

/// ホームのジャンルのタイルと、検索の結果。
///
/// 検索の入力は画面の中だけの状態に近いが、結果はロジックで作るので
/// ここで探す（docs/design/functions/demo-engine.md の CatalogState）。
@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  /// タイルに出す代表の名前の数。
  static const _exampleCount = 3;

  @override
  CatalogState build() {
    ref.watch(catalogRepositoryProvider);
    // 収録データが差し替わっても、画面の検索欄に残っている入力で探し直す。
    return _search(stateOrNull?.query ?? '');
  }

  /// 名前に [input] を含む Widget を探す。大文字・小文字と前後の空白は無視する。
  void queryChanged(String input) => state = _search(input.trim());

  void queryCleared() => state = _search('');

  CatalogState _search(String query) {
    final repository = ref.read(catalogRepositoryProvider);
    final genres = repository.genres();
    final entries = repository.entries();
    return CatalogState(
      query: query,
      groups: _groups(genres, entries),
      results: query.isEmpty ? const [] : _results(query, genres, entries),
    );
  }

  /// 段の順に、収録のあるジャンルのタイルを並べる。空の段は入れない。
  List<GenreGroup> _groups(List<Genre> genres, List<WidgetEntry> entries) {
    final groups = <GenreGroup>[];
    for (final kind in GenreGroupKind.values) {
      final tiles = <GenreTile>[];
      for (final genre in genres.where((genre) => genre.group == kind)) {
        final inGenre = entries
            .where((entry) => entry.genreIds.contains(genre.id))
            .toList();
        if (inGenre.isEmpty) continue;
        tiles.add(
          GenreTile(
            genre: genre,
            count: inGenre.length,
            examples: [
              for (final entry in inGenre.take(_exampleCount)) entry.name,
            ],
          ),
        );
      }
      if (tiles.isNotEmpty) groups.add(GenreGroup(kind: kind, tiles: tiles));
    }
    return groups;
  }

  List<SearchResult> _results(
    String query,
    List<Genre> genres,
    List<WidgetEntry> entries,
  ) {
    final needle = query.toLowerCase();
    final matched =
        entries
            .where((entry) => entry.name.toLowerCase().contains(needle))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    return [
      for (final entry in matched)
        SearchResult(
          entry: entry,
          genres: [
            for (final id in entry.genreIds)
              ...genres.where((genre) => genre.id == id),
          ],
        ),
    ];
  }
}
