import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/catalog.dart';
import 'package:widget_lab/catalog/genres.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';

void main() {
  test('同梱の収録データのジャンルと Widget を返す', () {
    const repository = BundledCatalogRepository();

    expect(repository.genres(), allGenres);
    expect(repository.entries(), allEntries);
  });

  test('ID で 1 件を返し、ない ID は null', () {
    const repository = BundledCatalogRepository();

    expect(repository.entryById('padding'), paddingEntry);
    expect(repository.entryById('nothing'), isNull);
  });

  test('Provider は同梱の収録データの Repository を返す', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogRepositoryProvider).entries(), allEntries);
  });
}
