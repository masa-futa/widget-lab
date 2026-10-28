import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_spell_check_suggestions_toolbar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF でも必須の値で組み立て、候補が並ぶ', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoSpellCheckSuggestionsToolbarEntry.build(
            DemoArgs(
              cupertinoSpellCheckSuggestionsToolbarEntry,
              allOff(cupertinoSpellCheckSuggestionsToolbarEntry),
            ),
          ),
        ),
      ),
    );

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('help'), findsOneWidget);
  });
}
