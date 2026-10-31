import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/catalog/ui/widgets/entry_tile.dart';
import 'package:widget_lab/features/catalog/view_model/genre_providers.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ジャンル画面（cc_gnr）。1 つのジャンルの Widget を見本つきの行で並べる。
///
/// 行を押したときの遷移は [onEntryTapped] で受け取る（機能をまたいで詳細画面を
/// 直接参照しないため。組み立ては app.dart）。
class GenreScreen extends ConsumerWidget {
  const GenreScreen({
    required this.genreId,
    required this.onEntryTapped,
    super.key,
  });

  /// タブレットでも 1 カラムのまま、本文をこの幅に収めて中央に置く。
  static const _maxContentWidth = 640.0;

  /// 開くジャンルの `Genre.id`。
  final String genreId;

  /// 行を押したとき。押した Widget の `WidgetEntry.id` を渡す。
  final void Function(BuildContext context, String entryId) onEntryTapped;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genre = ref.watch(genreProvider(genreId));
    final entries = ref.watch(genreEntriesProvider(genreId));
    final theme = Theme.of(context);
    final spacing = NimiSpacing.of(context);
    return Scaffold(
      appBar: AppBar(
        // iOS の既定は中央寄せだが、Figma の案B に合わせて左に寄せる。
        centerTitle: false,
        // 長いジャンル名は省略せず縮める。
        title: FittedBox(fit: BoxFit.scaleDown, child: Text(genre.name)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          // 見本は行が画面に入ったときだけ組み立てる。
          child: ListView.builder(
            itemCount: entries.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.md,
                    0,
                    spacing.md,
                    spacing.xs,
                  ),
                  child: Text(
                    AppLocalizations.of(context)
                        .catalogGenreIntro(entries.length, genre.description),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final entry = entries[index - 1];
              return EntryTile(
                entry: entry,
                onTap: () => onEntryTapped(context, entry.id),
              );
            },
          ),
        ),
      ),
    );
  }
}
