import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/core/data/clipboard_client.dart';
import 'package:widget_lab/core/data/url_launcher_client.dart';

/// お試しの4件（か渡したもの）だけを返す Repository。ジャンルは本物。
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository([List<WidgetEntry>? entries])
    : _entries = entries ?? [paddingEntry, containerEntry, rowEntry, textEntry];

  final List<WidgetEntry> _entries;

  @override
  List<Genre> genres() => allGenres;

  @override
  List<WidgetEntry> entries() => _entries;

  @override
  WidgetEntry? entryById(String id) {
    for (final entry in _entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

/// 書いた文字を覚える。[succeeds] が `false` なら書けなかったことにする。
class FakeClipboardClient implements ClipboardClient {
  FakeClipboardClient({this.succeeds = true});

  final bool succeeds;
  final written = <String>[];

  @override
  Future<bool> setText(String text) async {
    if (!succeeds) return false;
    written.add(text);
    return true;
  }
}

/// 開こうとした URL を覚える。[succeeds] が `false` なら開けなかったことにする。
class FakeUrlLauncherClient implements UrlLauncherClient {
  FakeUrlLauncherClient({this.succeeds = true});

  final bool succeeds;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return succeeds;
  }
}
