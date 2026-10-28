import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/basics/scaffold.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Scaffold() の既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: scaffoldEntry.build(
            DemoArgs(scaffoldEntry, allOff(scaffoldEntry)),
          ),
        ),
      ),
    );
    final built = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(built.appBar, isNull);
    expect(built.body, isNull);
    expect(built.floatingActionButton, isNull);
    expect(built.floatingActionButtonLocation, isNull);
    expect(built.bottomNavigationBar, isNull);
    expect(built.backgroundColor, isNull);
  });
}
