import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/core/theme/app_theme.dart';
import 'package:widget_lab/l10n/gen/app_localizations.dart';

/// 部品だけを、アプリのテーマと文言で包んで表示する。
Future<void> pumpPart(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);
