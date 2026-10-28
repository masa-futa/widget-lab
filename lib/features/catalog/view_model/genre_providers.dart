import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';

part 'genre_providers.g.dart';

/// ジャンル画面に並べる Widget（収録データの順）。
@riverpod
List<WidgetEntry> genreEntries(Ref ref, String genreId) => [
  for (final entry in ref.watch(catalogRepositoryProvider).entries())
    if (entry.genreIds.contains(genreId)) entry,
];

/// ジャンル画面の題と一言の説明に使うジャンル。
///
/// ない ID なら `StateError`（ホームは同じ収録データからタイルを作るので起きない）。
@riverpod
Genre genre(Ref ref, String genreId) {
  for (final genre in ref.watch(catalogRepositoryProvider).genres()) {
    if (genre.id == genreId) return genre;
  }
  throw StateError('ジャンルがありません: $genreId');
}
