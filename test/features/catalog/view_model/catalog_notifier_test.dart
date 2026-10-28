import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_notifier.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';

import '../fake_catalog_repository.dart';

const _basics = Genre(id: 'basics', name: 'Basics');
const _input = Genre(id: 'input', name: 'Input');
const _layout = Genre(id: 'layout', name: 'Layout');
const _styling = Genre(id: 'styling', name: 'Styling');

final _container = fakeEntry('Container', ['basics', 'layout']);
final _row = fakeEntry('Row', ['basics', 'layout']);
final _padding = fakeEntry('Padding', ['layout', 'styling']);
final _sliverPadding = fakeEntry('SliverPadding', ['layout']);

final _repository = FakeCatalogRepository(
  genreList: const [_basics, _input, _layout, _styling],
  entryList: [_container, _row, _padding, _sliverPadding],
);

ProviderContainer _createContainer() {
  final container = ProviderContainer(
    overrides: [catalogRepositoryProvider.overrideWithValue(_repository)],
  );
  addTearDown(container.dispose);
  return container;
}

/// 絞った結果の、ジャンルごとの Widget 名。
Map<String, List<String>> _names(CatalogState state) => {
  for (final section in state.sections)
    section.genre.id: [for (final entry in section.entries) entry.name],
};

void main() {
  test('最初は入力が空で、Widget のあるジャンルを公式の順に全件並べる', () {
    final state = _createContainer().read(catalogProvider);

    expect(state.query, '');
    expect(state.isEmpty, isFalse);
    expect(_names(state), {
      'basics': ['Container', 'Row'],
      'layout': ['Container', 'Row', 'Padding', 'SliverPadding'],
      'styling': ['Padding'],
    });
  });

  test('TC-02: 見出しの件数は、そのジャンルに入っている Widget の数と同じ', () {
    final state = _createContainer().read(catalogProvider);

    final counts = {
      for (final section in state.sections)
        section.genre.id: section.entries.length,
    };
    expect(counts, {'basics': 2, 'layout': 4, 'styling': 1});
  });

  test('TC-07: 名前に入力を含む Widget だけが残り、0 件のジャンルは入れない', () {
    final container = _createContainer();

    container.read(catalogProvider.notifier).queryChanged('pad');

    final state = container.read(catalogProvider);
    expect(state.query, 'pad');
    expect(_names(state), {
      'layout': ['Padding', 'SliverPadding'],
      'styling': ['Padding'],
    });
  });

  test('TC-08: 大文字で入れても小文字と同じ結果になる', () {
    final container = _createContainer();
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('pad');
    final lower = container.read(catalogProvider).sections;
    notifier.queryChanged('PAD');

    expect(container.read(catalogProvider).sections, lower);
  });

  test('TC-09: 前後の空白は無視し、除いた入力を持つ', () {
    final container = _createContainer();
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('pad');
    final trimmed = container.read(catalogProvider);
    notifier.queryChanged(' pad ');

    expect(container.read(catalogProvider), trimmed);
  });

  test('一致が 0 件なら空状態になる', () {
    final container = _createContainer();

    container.read(catalogProvider.notifier).queryChanged('zzzz');

    final state = container.read(catalogProvider);
    expect(state.sections, isEmpty);
    expect(state.isEmpty, isTrue);
  });

  test('空白だけの入力は、入力なしとして全件に戻す', () {
    final container = _createContainer();
    final initial = container.read(catalogProvider);

    container.read(catalogProvider.notifier).queryChanged('   ');

    expect(container.read(catalogProvider), initial);
  });

  test('Repository が差し替わっても、検索の入力を残して絞り直す', () {
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
    expect(_names(state), {
      'layout': ['Padding'],
    });
  });

  test('検索を消すと、入力が空になり全件に戻る', () {
    final container = _createContainer();
    final initial = container.read(catalogProvider);
    final notifier = container.read(catalogProvider.notifier);

    notifier.queryChanged('zzzz');
    notifier.queryCleared();

    expect(container.read(catalogProvider), initial);
  });
}
