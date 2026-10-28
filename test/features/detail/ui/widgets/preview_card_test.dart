import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/features/detail/ui/widgets/preview_card.dart';

import '../pump.dart';

void main() {
  testWidgets('子の外枠に outline-variant の線を引き、余白の大きさの違いが見える', (tester) async {
    Future<Size> boundsOf(double padding) async {
      await pumpPart(
        tester,
        PreviewCard(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: const SizedBox(width: 24, height: 24),
          ),
        ),
      );
      return tester.getSize(find.byKey(PreviewCard.boundsKey));
    }

    expect(await boundsOf(32), const Size(88, 88));
    expect(await boundsOf(0), const Size(24, 24));
    final bounds = tester.widget<DecoratedBox>(
      find.byKey(PreviewCard.boundsKey),
    );
    final context = tester.element(find.byType(PreviewCard));
    expect(
      bounds.decoration,
      BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
    expect(bounds.position, DecorationPosition.foreground);
  });

  testWidgets('地は Material なので、中の Widget の波紋が見える', (tester) async {
    await pumpPart(
      tester,
      PreviewCard(
        child: InkWell(onTap: () {}, child: const Text('押す')),
      ),
    );

    final material = tester.widget<Material>(
      find.ancestor(of: find.text('押す'), matching: find.byType(Material)).first,
    );
    final context = tester.element(find.byType(PreviewCard));
    expect(material.color, Theme.of(context).colorScheme.surfaceContainer);
  });
}
