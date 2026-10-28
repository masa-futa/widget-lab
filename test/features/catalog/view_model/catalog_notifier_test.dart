import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_notifier.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';

import '../fake_catalog_repository.dart';

const _cupertino = Genre(
  id: 'cupertino',
  name: 'Cupertino',
  group: GenreGroupKind.designSystem,
  description: '',
);
const _material = Genre(
  id: 'material',
  name: 'Material design',
  group: GenreGroupKind.designSystem,
  description: '',
);
const _basics = Genre(
  id: 'basics',
  name: 'Basics',
  group: GenreGroupKind.base,
  description: '',
);
const _input = Genre(
  id: 'input',
  name: 'Input',
  group: GenreGroupKind.base,
  description: '',
);
const _layout = Genre(
  id: 'layout',
  name: 'Layout',
  group: GenreGroupKind.base,
  description: '',
);
const _styling = Genre(
  id: 'styling',
  name: 'Styling',
  group: GenreGroupKind.base,
  description: '',
);

final _cupertinoButton = fakeEntry('CupertinoButton', ['cupertino']);
final _container = fakeEntry('Container', ['basics', 'layout']);
final _row = fakeEntry('Row', ['basics', 'layout']);
final _text = fakeEntry('Text', ['basics', 'text']);
final _icon = fakeEntry('Icon', ['basics']);
final _padding = fakeEntry('Padding', ['layout', 'styling']);
final _sliverPadding = fakeEntry('SliverPadding', ['layout']);

final _repository = FakeCatalogRepository(
  genreList: const [_cupertino, _material, _basics, _input, _layout, _styling],
  entryList: [
    _cupertinoButton,
    _container,
    _row,
    _text,
    _icon,
    _padding,
    _sliverPadding,
  ],
);

ProviderContainer _createContainer([CatalogRepository? repository]) {
  final container = ProviderContainer(
    overrides: [
      catalogRepositoryProvider.overrideWithValue(repository ?? _repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// 段ごとの、タイルのジャンルの ID。
Map<GenreGroupKind, List<String>> _tileIds(CatalogState state) => {
  for (final group in state.groups)
    group.kind: [for (final tile in group.tiles) tile.genre.id],
};

List<String> _resultNames(CatalogState state) => [
  for (final result in state.results) result.entry.name,
];

void main() {
  test('TC-01: 最初は検索していず、段を「デザインシステム」「基本の Widget」の順に、'
      'タイルを公式の順に並べる', () {
    final state = _createContainer().read(catalogProvider);

    expect(state.query, '');
    expect(state.isSearching, isFalse);
    expect(state.results, isEmpty);
    expect(_tileIds(state).keys, [
      GenreGroupKind.designSystem,
      GenreGroupKind.base,
    ]);
    expect(_tileIds(state)[GenreGroupKind.base], [
      'basics',
      'layout',
      'styling',
    ]);
  });

  test('TC-02: タイルの件数はそのジャンルの Widget の数で、代表の名前は収録の順の最初の 3 件', () {
    final state = _createContainer().read(catalogProvider);

    final tiles = {
      for (final group in state.groups)
        for (final tile in group.tiles) tile.genre.id: tile,
    };
    expect(tiles['basics']?.count, 4);
    expect(tiles['basics']?.examples, ['Container', 'Row', 'Text']);
    expect(tiles['styling']?.count, 1);
    expect(tiles['styling']?.examples, ['Padding']);
  });

  test('TC-70: 0 件のジャンルのタイルは出さず、段のジャンルが全部 0 件なら段も出さない', () {
    final state = _createContainer(
      FakeCatalogRepository(
        genreList: const [_cupertino, _material, _basics, _input],
        entryList: [_container],
      ),
    ).read(catalogProvider);

    expect(_tileIds(state), {
      GenreGroupKind.base: ['basics'],
    });
  });

  test('TC-07: 名前に入力を含む Widget だけが結果に出る', () {
    final container = _createContainer();

    container.read(catalogProvider.notifier).queryChanged('pad');

    final state = container.read(catalogProvider);
    expect(state.query, 'pad');
    expect(state.isSearching, isTrue);
    expect(_resultNames(state), ['Padding', 'SliverPadding']);
  });

  test('TC-08: 大文字で入れても小文字と同じ結果になる', () {
    final container = _createContainer();
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('pad');
    final lower = container.read(catalogProvider).results;
    notifier.queryChanged('PAD');

    expect(container.read(catalogProvider).results, lower);
  });

  test('TC-09: 前後の空白は無視し、除いた入力を持つ', () {
    final container = _createContainer();
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('pad');
    final trimmed = container.read(catalogProvider);
    notifier.queryChanged(' pad ');

    expect(container.read(catalogProvider), trimmed);
  });

  test('TC-71: 複数のジャンルに載る Widget は 1 回だけ、載っているジャンルを添えて出る', () {
    final container = _createContainer();

    container.read(catalogProvider.notifier).queryChanged('Padding');

    final results = container.read(catalogProvider).results;
    expect(results, hasLength(2));
    expect(results.first.entry, _padding);
    expect(results.first.genres, [_layout, _styling]);
  });

  test('TC-71: 結果は名前の ABC 順で、大文字・小文字を区別しない', () {
    final container = _createContainer(
      FakeCatalogRepository(
        genreList: const [_basics],
        entryList: [
          fakeEntry('Row', ['basics']),
          fakeEntry('cupertinoRow', ['basics']),
          fakeEntry('ListRow', ['basics']),
        ],
      ),
    );

    container.read(catalogProvider.notifier).queryChanged('row');

    expect(_resultNames(container.read(catalogProvider)), [
      'cupertinoRow',
      'ListRow',
      'Row',
    ]);
  });

  test('一致が 0 件なら空状態になる', () {
    final container = _createContainer();

    container.read(catalogProvider.notifier).queryChanged('zzzz');

    final state = container.read(catalogProvider);
    expect(state.results, isEmpty);
    expect(state.isEmpty, isTrue);
  });

  test('空白だけの入力は、検索していない状態に戻す', () {
    final container = _createContainer();
    final initial = container.read(catalogProvider);

    container.read(catalogProvider.notifier).queryChanged('   ');

    final state = container.read(catalogProvider);
    expect(state, initial);
    expect(state.isEmpty, isFalse);
  });

  test('Repository が差し替わっても、検索の入力を残して探し直す', () {
    final container = _createContainer();
    container.read(catalogProvider.notifier).queryChanged('pad');

    container.updateOverrides([
      catalogRepositoryProvider.overrideWithValue(
        FakeCatalogRepository(
          genreList: const [_layout],
          entryList: [_padding, _row],
        ),
      ),
    ]);

    final state = container.read(catalogProvider);
    expect(state.query, 'pad');
    expect(_resultNames(state), ['Padding']);
  });

  test('検索を消すと、入力が空になりタイルに戻る', () {
    final container = _createContainer();
    final initial = container.read(catalogProvider);
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('zzzz');
    notifier.queryCleared();

    expect(container.read(catalogProvider), initial);
  });
}
