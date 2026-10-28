import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/code_strip.dart';
import 'package:widget_lab/features/detail/view_model/code_generator.dart';

import '../pump.dart';

void main() {
  Future<void> pumpStrip(
    WidgetTester tester, {
    CodeLine? line,
    VoidCallback? onTap,
  }) => pumpPart(
    tester,
    CodeStrip(propertyName: 'padding', line: line, onTap: onTap ?? () {}),
  );

  testWidgets('TC-62: 選んでいるプロパティの行を出し、変えた行なら印が付く', (tester) async {
    await pumpStrip(
      tester,
      line: const CodeLine(
        text: '  padding: EdgeInsets.all(24.0),',
        property: 'padding',
        changed: true,
      ),
    );

    expect(find.text('padding: EdgeInsets.all(24.0),'), findsOneWidget);
    expect(find.byKey(CodeStrip.changedKey), findsOneWidget);
    expect(find.text('全文'), findsOneWidget);
  });

  testWidgets('TC-62: 変えていない行には印が付かない', (tester) async {
    await pumpStrip(
      tester,
      line: const CodeLine(
        text: '  padding: EdgeInsets.all(16.0),',
        property: 'padding',
      ),
    );

    expect(find.byKey(CodeStrip.changedKey), findsNothing);
  });

  testWidgets('TC-63: 行がなければ「// padding は指定なし（既定値）」', (tester) async {
    await pumpStrip(tester);

    expect(find.text('// padding は指定なし（既定値）'), findsOneWidget);
  });

  testWidgets('帯を押すと知らせが出る', (tester) async {
    var tapped = false;
    await pumpStrip(tester, onTap: () => tapped = true);

    await tester.tap(find.byType(CodeStrip));

    expect(tapped, isTrue);
  });
}
