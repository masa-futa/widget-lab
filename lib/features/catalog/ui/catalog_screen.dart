import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/catalog/ui/genre_screen.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/features/catalog/ui/widgets/genre_card.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_notifier.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ホーム画面（ca_lst）。検索と、ジャンルのタイル（検索中は結果の行）。
///
/// タイルを押すと、同じ機能のジャンル画面（cc_gnr）を開く。行を押したときの
/// 遷移は [onEntryTapped] で受け取る（機能をまたいで詳細画面を直接参照しないため。
/// 組み立ては app.dart）。ジャンル画面にも同じものを渡す。
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({required this.onEntryTapped, super.key});

  /// 検索の結果やジャンル画面の行を押したとき。押した Widget の `WidgetEntry.id` を渡す。
  final void Function(BuildContext context, String entryId) onEntryTapped;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  /// タブレットでも 1 カラムのまま、本文をこの幅に収めて中央に置く。
  static const _maxContentWidth = 640.0;

  final _searchController = TextEditingController();
  // タイルと結果の行は別のスクロールなので、切り替えたら先頭から出す。
  final _listController = ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _changeQuery(String input) {
    ref.read(catalogProvider.notifier).queryChanged(input);
    _scrollToTop();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(catalogProvider.notifier).queryCleared();
    _scrollToTop();
  }

  /// 探し直した結果が画面の外に隠れないように、本文の先頭に戻す。
  void _scrollToTop() {
    if (_listController.hasClients) _listController.jumpTo(0);
  }

  void _openGenre(String genreId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GenreScreen(genreId: genreId, onEntryTapped: widget.onEntryTapped),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogProvider);
    final spacing = NimiSpacing.of(context);
    return Scaffold(
      // iOS の既定は中央寄せだが、Figma の案B に合わせて左に寄せる。
      appBar: AppBar(title: const _AppTitle(), centerTitle: false),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.md),
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _changeQuery,
                  onCleared: _clearSearch,
                ),
              ),
              Gap(spacing.xs),
              Expanded(
                child: switch (state) {
                  CatalogState(isEmpty: true) => _EmptyView(
                    query: state.query,
                    onCleared: _clearSearch,
                  ),
                  CatalogState(isSearching: true) => _ResultList(
                    results: state.results,
                    controller: _listController,
                    onEntryTapped: (entryId) =>
                        widget.onEntryTapped(context, entryId),
                  ),
                  _ => _GenreGroups(
                    groups: state.groups,
                    controller: _listController,
                    onGenreTapped: _openGenre,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 飾りなので読み上げない。
        ExcludeSemantics(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: NimiColors.of(context).brand,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: spacing.sm),
          ),
        ),
        Gap(spacing.xs),
        Flexible(
          child: Text(
            AppLocalizations.of(context).appTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onCleared,
  });

  static const _maxLength = 50;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // SearchBar は文字数の上限と自動修正の切り替えを持たないため、TextField で組む。
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        maxLength: _maxLength,
        decoration: InputDecoration(
          hintText: l10n.catalogSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.catalogSearchClear,
                  icon: const Icon(Icons.close),
                  onPressed: onCleared,
                ),
          counterText: '',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NimiRadius.of(context).md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// ジャンルのタイルを段ごとに 2 列で並べる（gt）。
class _GenreGroups extends StatelessWidget {
  const _GenreGroups({
    required this.groups,
    required this.controller,
    required this.onGenreTapped,
  });

  static const _columns = 2;

  final List<GenreGroup> groups;
  final ScrollController controller;
  final ValueChanged<String> onGenreTapped;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    // タイルは最大 14 枚なので、遅延させずに組み立てる。
    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // SingleChildScrollView は ListView と違い、下の安全領域を自分で足さない。
      padding: EdgeInsets.fromLTRB(
        spacing.md,
        0,
        spacing.md,
        spacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in groups) ...[
            _GroupHeader(kind: group.kind),
            for (var i = 0; i < group.tiles.length; i += _columns) ...[
              if (i > 0) Gap(spacing.sm),
              // 同じ行のタイルの高さをそろえる。
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + _columns; j++) ...[
                      if (j > i) Gap(spacing.sm),
                      Expanded(
                        child: j < group.tiles.length
                            ? GenreCard(
                                tile: group.tiles[j],
                                onTap: () =>
                                    onGenreTapped(group.tiles[j].genre.id),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// 段の見出し（gt-head）。
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.kind});

  final GenreGroupKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Padding(
      padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.xs),
      child: Semantics(
        header: true,
        child: Text(
          switch (kind) {
            GenreGroupKind.designSystem => l10n.catalogGroupDesignSystem,
            GenreGroupKind.base => l10n.catalogGroupBase,
          },
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 検索の結果の行（rs-item）。名前の ABC 順。
class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.results,
    required this.controller,
    required this.onEntryTapped,
  });

  final List<SearchResult> results;
  final ScrollController controller;
  final ValueChanged<String> onEntryTapped;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return EntryTile(
          entry: result.entry,
          genres: result.genres,
          onTap: () => onEntryTapped(result.entry.id),
        );
      },
    );
  }
}

/// 検索の結果が 0 件のとき（rs-empt）。
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query, required this.onCleared});

  final String query;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.catalogEmpty(query),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Gap(spacing.md),
            TextButton(
              onPressed: onCleared,
              child: Text(l10n.catalogSearchClear),
            ),
          ],
        ),
      ),
    );
  }
}
