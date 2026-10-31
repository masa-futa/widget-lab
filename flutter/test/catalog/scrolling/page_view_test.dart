import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/scrolling/page_view.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら PageView の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, pageViewEntry);
    final built = demoWidget<PageView>(tester);

    expect(built.scrollDirection, Axis.horizontal);
    expect(built.pageSnapping, isTrue);
    expect(built.reverse, isFalse);
  });
}
