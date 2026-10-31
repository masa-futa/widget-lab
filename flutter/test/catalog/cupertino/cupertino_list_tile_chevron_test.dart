import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_tile_chevron.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: プロパティがなく、引数なしの CupertinoListTileChevron で組み立てる', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoListTileChevronEntry.build(
            DemoArgs(
              cupertinoListTileChevronEntry,
              allOff(cupertinoListTileChevronEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoListTileChevron>(
      find.byType(CupertinoListTileChevron),
    );
    expect(built.key, isNull);
    expect(cupertinoListTileChevronEntry.properties, isEmpty);
  });
}
