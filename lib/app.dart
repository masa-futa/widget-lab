import 'package:flutter/material.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';
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
      home: const CatalogScreen(),
    );
  }
}
