import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
import 'package:widget_lab/features/detail/ui/detail_screen.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

class WidgetLabApp extends StatelessWidget {
  const WidgetLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CatalogScreen(onEntryTapped: _openDetail),
    );
  }
}

/// ジャンル画面の行・ホームの検索の結果から詳細へ進む（docs/architecture.md の遷移）。
/// ホームからジャンル画面へは、同じ機能の中なので CatalogScreen が開く。
void _openDetail(BuildContext context, String entryId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => DetailScreen(entryId: entryId)),
  );
}
