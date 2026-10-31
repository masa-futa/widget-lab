import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/core/theme/app_theme.dart';

/// [entry] を組み立て（[without] なら使わない側）、書き出された読み上げの文を返す。
Future<String> pumpReadout(
  WidgetTester tester,
  WidgetEntry entry, {
  Map<String, PropertySetting>? settings,
  bool without = false,
}) async {
  final build = without ? entry.buildWithout : entry.build;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: build!(DemoArgs(entry, settings ?? entry.initialSettings())),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return readoutText(tester);
}

/// 今書き出されている読み上げの文。
String readoutText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((text) => text.data)
    .whereType<String>()
    .firstWhere((data) => data.startsWith('読み上げ'));
