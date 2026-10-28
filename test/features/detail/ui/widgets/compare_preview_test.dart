import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/compare_preview.dart';

import '../pump.dart';

void main() {
  Future<void> pumpCompare(WidgetTester tester, {double scale = 1}) => pumpPart(
    tester,
    Center(
      child: SizedBox(
        width: 400,
        height: 300,
        child: ComparePreview(
          withLabel: '付けた',
          withoutLabel: '付けない',
          withSemanticsLabel: '付けた、color、瑠璃',
          scale: scale,
          withChild: const Text('with'),
          withoutChild: const Text('without'),
        ),
      ),
    ),
  );

  /// 仕切りの位置（ComparePreview の左端からの x）。
  double dividerX(WidgetTester tester) =>
      tester.getCenter(find.byKey(ComparePreview.dividerKey)).dx -
      tester.getTopLeft(find.byType(ComparePreview)).dx;

  testWidgets('TC-50: 左に「付けた」と✓、右に「付けない」と−、仕切りが中央に出る', (tester) async {
    await pumpCompare(tester);

    expect(find.text('付けた'), findsOneWidget);
    expect(find.text('付けない'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.text('with'), findsOneWidget);
    expect(find.text('without'), findsOneWidget);
    expect(dividerX(tester), closeTo(200, 1));
    expect(
      tester.getCenter(find.text('付けた')).dx,
      lessThan(tester.getCenter(find.text('付けない')).dx),
    );
  });

  testWidgets('TC-50: 2 枚を「付けた、color、瑠璃」「付けない」と読み上げる', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpCompare(tester);

    expect(find.bySemanticsLabel('付けた、color、瑠璃'), findsOneWidget);
    expect(find.bySemanticsLabel('付けない'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('TC-68: 仕切りをドラッグすると動き、幅の 10〜90% で止まる', (tester) async {
    await pumpCompare(tester);

    await tester.drag(
      find.byKey(ComparePreview.dividerKey),
      const Offset(80, 0),
    );
    await tester.pump();
    expect(dividerX(tester), closeTo(280, 1));

    await tester.drag(
      find.byKey(ComparePreview.dividerKey),
      const Offset(-1000, 0),
    );
    await tester.pump();
    expect(dividerX(tester), closeTo(40, 1));

    await tester.drag(
      find.byKey(ComparePreview.dividerKey),
      const Offset(1000, 0),
    );
    await tester.pump();
    expect(dividerX(tester), closeTo(360, 1));
  });

  testWidgets('TC-68: 読み上げの調整操作で 10% ずつ動く', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpCompare(tester);
    tester.semantics.increase(find.semantics.byLabel('比較の仕切り'));
    await tester.pump();

    expect(dividerX(tester), closeTo(240, 1));
    expect(tester.getSemantics(find.bySemanticsLabel('比較の仕切り')).value, '60%');
    semantics.dispose();
  });

  testWidgets('TC-67: 拡大を渡すと 2 枚とも同じ倍率で描く', (tester) async {
    await pumpCompare(tester, scale: 2);

    for (final text in ['with', 'without']) {
      final scale = tester.widget<Transform>(
        find
            .ancestor(of: find.text(text), matching: find.byType(Transform))
            .first,
      );
      expect(scale.transform.getMaxScaleOnAxis(), 2);
    }
  });
}
