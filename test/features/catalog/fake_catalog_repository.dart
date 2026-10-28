import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';

/// 渡したジャンルと Widget をそのまま返す Repository。
class FakeCatalogRepository implements CatalogRepository {
  const FakeCatalogRepository({
    required this.genreList,
    required this.entryList,
  });

  final List<Genre> genreList;
  final List<WidgetEntry> entryList;

  @override
  List<Genre> genres() => genreList;

  @override
  List<WidgetEntry> entries() => entryList;

  @override
  WidgetEntry? entryById(String id) {
    for (final entry in entryList) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

/// 一覧のテストに要る項目だけを持つ収録データ。
WidgetEntry fakeEntry(String name, List<String> genreIds) => WidgetEntry(
  id: name.toLowerCase(),
  name: name,
  genreIds: genreIds,
  summary: '$name の要約',
  description: '',
  docUrl: Uri.parse('https://api.flutter.dev/'),
  properties: const [],
  build: (args) => const SizedBox(),
  codeName: name,
);
