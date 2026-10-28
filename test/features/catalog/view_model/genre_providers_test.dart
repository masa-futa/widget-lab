import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/features/catalog/view_model/genre_providers.dart';

import '../fake_catalog_repository.dart';

const _basics = Genre(
  id: 'basics',
  name: 'Basics',
  group: GenreGroupKind.base,
  description: 'アプリの骨組みになる基本の Widget',
);
const _layout = Genre(
  id: 'layout',
  name: 'Layout',
  group: GenreGroupKind.base,
  description: '',
);

final _container = fakeEntry('Container', ['basics', 'layout']);
final _padding = fakeEntry('Padding', ['layout']);
final _row = fakeEntry('Row', ['basics', 'layout']);

ProviderContainer _createContainer() {
  final container = ProviderContainer(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(
        FakeCatalogRepository(
          genreList: const [_basics, _layout],
          entryList: [_container, _padding, _row],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('TC-14: ジャンルの Widget を収録の順に返す', () {
    final container = _createContainer();

    expect(container.read(genreEntriesProvider('layout')), [
      _container,
      _padding,
      _row,
    ]);
    expect(container.read(genreEntriesProvider('basics')), [_container, _row]);
  });

  test('ID からジャンルを返す', () {
    expect(_createContainer().read(genreProvider('basics')), _basics);
  });

  test('ない ID のジャンルは StateError', () {
    expect(
      () => _createContainer().read(genreProvider('unknown')),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<StateError>(),
        ),
      ),
    );
  });
}
