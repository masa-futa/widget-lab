import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/layout/offstage.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Offstage の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, offstageEntry);
    final built = demoWidget<Offstage>(tester);

    expect(built.offstage, isTrue);
    expect(built.child, isNull);
  });
}
