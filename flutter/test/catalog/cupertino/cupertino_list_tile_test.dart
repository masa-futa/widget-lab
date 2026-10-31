import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の題だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoListTileEntry.build(
            DemoArgs(cupertinoListTileEntry, allOff(cupertinoListTileEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoListTile>(
      find.byType(CupertinoListTile),
    );
    expect(built.title, isA<Text>());
    expect(built.subtitle, isNull);
    expect(built.leading, isNull);
    expect(built.additionalInfo, isNull);
    expect(built.trailing, isNull);
    expect(built.onTap, isNull);
    expect(built.backgroundColor, isNull);
  });
}
