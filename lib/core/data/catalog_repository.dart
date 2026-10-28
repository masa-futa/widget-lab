import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/catalog/catalog.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

part 'catalog_repository.g.dart';

/// 収録データを返す。テストでは fake に差し替える。
abstract interface class CatalogRepository {
  /// 公式カタログの順のジャンル。
  List<Genre> genres();

  List<WidgetEntry> entries();

  /// ない ID なら `null`。
  WidgetEntry? entryById(String id);
}

/// 同梱の収録データを返す。通信も保存もしないので同期。
class BundledCatalogRepository implements CatalogRepository {
  const BundledCatalogRepository();

  @override
  List<Genre> genres() => allGenres;

  @override
  List<WidgetEntry> entries() => allEntries;

  @override
  WidgetEntry? entryById(String id) {
    for (final entry in entries()) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
CatalogRepository catalogRepository(Ref ref) =>
    const BundledCatalogRepository();
