import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/fractional_translation.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら FractionalTranslation の既定値で組み立てる', (
    tester,
  ) async {
    await pumpEntry(tester, fractionalTranslationEntry);
    final built = demoWidget<FractionalTranslation>(tester);

    expect(built.translation, Offset.zero);
    expect(built.child, isNull);
  });
}
