import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:widget_lab/core/data/catalog_repository.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';

part 'catalog_notifier.g.dart';

/// 一覧の検索と、ジャンルごとの並び。
///
/// 検索の入力は画面の中だけの状態に近いが、絞った結果をチップ・見出し・行・
/// 空状態の 4 か所で使うので、ここで絞る（docs/design/functions/demo-engine.md）。
@riverpod
class CatalogNotifier extends _$CatalogNotifier {
  @override
  CatalogState build() {
    ref.watch(catalogRepositoryProvider);
    // 収録データが差し替わっても、画面の検索欄に残っている入力で絞り直す。
    return _filter(stateOrNull?.query ?? '');
  }

  /// 名前に [input] を含む Widget に絞る。大文字・小文字と前後の空白は無視する。
  void queryChanged(String input) => state = _filter(input.trim());

  void queryCleared() => state = _filter('');

  CatalogState _filter(String query) {
    final repository = ref.read(catalogRepositoryProvider);
    final needle = query.toLowerCase();
    final matched = repository
        .entries()
        .where((entry) => entry.name.toLowerCase().contains(needle))
        .toList();
    final sections = <CatalogSection>[];
    for (final genre in repository.genres()) {
      final entries = matched
          .where((entry) => entry.genreIds.contains(genre.id))
          .toList();
      if (entries.isNotEmpty) {
        sections.add(CatalogSection(genre: genre, entries: entries));
      }
    }
    return CatalogState(query: query, sections: sections);
  }
}
