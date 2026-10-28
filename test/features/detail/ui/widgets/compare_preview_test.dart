import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';

import '../pump.dart';

void main() {
  testWidgets('TC-50: 上に「付けた」と✓、下に「付けない」と−を、文言とアイコンで出す', (tester) async {
    await pumpPart(
      tester,
      const ComparePreview(
        propertyName: 'padding',
        valueLabel: '16.0',
        withChild: Text('上の中身'),
        withoutChild: Text('下の中身'),
      ),
    );

    final withLabel = tester.getTopLeft(find.text('付けた'));
    final withoutLabel = tester.getTopLeft(find.text('付けない'));
    expect(withLabel.dy, lessThan(withoutLabel.dy));
    expect(tester.getTopLeft(find.text('上の中身')).dy, lessThan(withoutLabel.dy));
    expect(
      tester.getTopLeft(find.text('下の中身')).dy,
      greaterThan(withoutLabel.dy),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
  });

  testWidgets('TC-50: 2 枚は同じ高さ', (tester) async {
    await pumpPart(
      tester,
      const ComparePreview(
        propertyName: 'padding',
        valueLabel: '16.0',
        withChild: SizedBox.shrink(key: Key('with')),
        withoutChild: SizedBox.shrink(key: Key('without')),
      ),
    );

    final cards = find.byKey(const Key('compareCard'));
    expect(cards, findsNWidgets(2));
    expect(
      tester.getSize(cards.first).height,
      tester.getSize(cards.last).height,
    );
  });

  testWidgets('TC-50: カードを「付けた、padding、16.0」「付けない、padding」と読む', (tester) async {
    await pumpPart(
      tester,
      const ComparePreview(
        propertyName: 'padding',
        valueLabel: '16.0',
        withChild: SizedBox.shrink(),
        withoutChild: SizedBox.shrink(),
      ),
    );

    expect(find.bySemanticsLabel('付けた、padding、16.0'), findsOneWidget);
    expect(find.bySemanticsLabel('付けない、padding'), findsOneWidget);
  });
}
