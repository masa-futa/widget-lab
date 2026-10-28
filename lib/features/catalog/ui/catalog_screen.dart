import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/catalog/model/genre.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_notifier.dart';
import 'package:widget_lab/features/catalog/view_model/catalog_state.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ジャンル別の一覧画面（ca_lst）。
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  /// タブレットでも 1 カラムのまま、本文をこの幅に収めて中央に置く。
  static const _maxContentWidth = 640.0;

  final _searchController = TextEditingController();
  final _listController = ScrollController();

  /// チップから飛ぶ先の見出し（ジャンルの ID ごと）。
  final _headerKeys = <String, GlobalKey>{};

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

  /// 絞り直した結果が画面の外に隠れないように、一覧の先頭に戻す。
  void _scrollToTop() {
    if (_listController.hasClients) _listController.jumpTo(0);
  }

  GlobalKey _headerKey(String genreId) =>
      _headerKeys.putIfAbsent(genreId, GlobalKey.new);

  Future<void> _scrollToGenre(String genreId) async {
    final headerContext = _headerKeys[genreId]?.currentContext;
    if (headerContext == null) return;
    await Scrollable.ensureVisible(
      headerContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogProvider);
    final spacing = NimiSpacing.of(context);
    return Scaffold(
      appBar: AppBar(title: const _AppTitle()),
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
              if (!state.isEmpty) ...[
                Gap(spacing.xs),
                _GenreChips(sections: state.sections, onTap: _scrollToGenre),
              ],
              Expanded(
                child: state.isEmpty
                    ? _EmptyView(query: state.query, onCleared: _clearSearch)
                    : _SectionList(
                        sections: state.sections,
                        controller: _listController,
                        headerKey: _headerKey,
                      ),
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

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.sections, required this.onTap});

  final List<CatalogSection> sections;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(NimiRadius.of(context).full),
    );
    final background = NimiColors.of(context).surfaceMuted;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Row(
        spacing: spacing.xs,
        children: [
          for (final section in sections)
            ActionChip(
              label: Text(section.genre.name),
              backgroundColor: background,
              side: BorderSide.none,
              shape: shape,
              onPressed: () => onTap(section.genre.id),
            ),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    required this.sections,
    required this.controller,
    required this.headerKey,
  });

  final List<CatalogSection> sections;
  final ScrollController controller;
  final GlobalKey Function(String genreId) headerKey;

  @override
  Widget build(BuildContext context) {
    // チップから画面の外の見出しへ飛べるように、遅延させずに全部を組み立てる。
    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in sections) ...[
            CatalogSectionHeader(
              key: headerKey(section.genre.id),
              genre: section.genre,
              count: section.entries.length,
            ),
            for (final entry in section.entries) _EntryTile(entry: entry),
          ],
        ],
      ),
    );
  }
}

/// ジャンルの見出し（ls-head）。ジャンル名と件数。
class CatalogSectionHeader extends StatelessWidget {
  const CatalogSectionHeader({
    super.key,
    required this.genre,
    required this.count,
  });

  final Genre genre;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Semantics(
      header: true,
      label: AppLocalizations.of(context)
          .catalogSectionLabel(genre.name, count),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.lg,
          spacing.md,
          spacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(genre.name, style: theme.textTheme.titleMedium),
            ),
            Gap(spacing.xs),
            Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget の行（ls-item）。名前と一行の要約。
class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final WidgetEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: ListTile(
        title: Text(entry.name),
        titleTextStyle: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        subtitle: Text(
          entry.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitleTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        trailing: const Icon(Icons.chevron_right),
        // TODO(PR 4/5): 詳細画面への遷移（Navigator.push）は feat/detail-screen が
        // PR 3/5 のマージ後に配線する（TC-15・16・46 もそちらで書く）。
        onTap: () {},
      ),
    );
  }
}

/// 検索の結果が 0 件のとき（ls-empt）。
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query, required this.onCleared});

  final String query;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = NimiSpacing.of(context);
    return Center(
      child: Padding(
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
