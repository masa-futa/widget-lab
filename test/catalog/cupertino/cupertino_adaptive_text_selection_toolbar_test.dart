import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_adaptive_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF でも必須の値で組み立て、iOS では横長のメニューになる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoAdaptiveTextSelectionToolbarEntry.build(
            DemoArgs(
              cupertinoAdaptiveTextSelectionToolbarEntry,
              allOff(cupertinoAdaptiveTextSelectionToolbarEntry),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoTextSelectionToolbar), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
