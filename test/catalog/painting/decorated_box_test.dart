import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/decorated_box.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら DecoratedBox の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, decoratedBoxEntry);
    final built = demoWidget<DecoratedBox>(tester);

    expect(built.decoration, const BoxDecoration());
    expect(built.position, DecorationPosition.background);
    expect(built.child, isNull);
  });
}
