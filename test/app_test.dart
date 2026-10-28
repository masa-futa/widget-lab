import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/app.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/features/catalog/ui/catalog_screen.dart';

void main() {
  testWidgets('起動すると一覧画面がアプリ名つきで表示される', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WidgetLabApp()));
    await tester.pumpAndSettle();

    expect(find.byType(CatalogScreen), findsOneWidget);
    expect(find.text('Widget Lab'), findsOneWidget);
  });

  testWidgets('ライトとダークの両方のテーマが土台の色の拡張を持つ', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WidgetLabApp()));
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.theme?.extension<NimiColors>(), NimiColors.light);
    expect(app.darkTheme?.extension<NimiColors>(), NimiColors.dark);
  });
}
