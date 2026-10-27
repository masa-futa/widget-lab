import 'package:flutter/material.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// ジャンル別の一覧画面。中身は flutter-widget-screen で作る。
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: const SizedBox.shrink(),
    );
  }
}
