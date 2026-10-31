import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/assets/icon.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Icon の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, iconEntry);
    final built = demoWidget<Icon>(tester);

    // icon は必須なので最初の値
    expect(built.icon, Icons.favorite);
    expect(built.size, isNull);
    expect(built.color, isNull);
    expect(built.semanticLabel, isNull);
  });
}
