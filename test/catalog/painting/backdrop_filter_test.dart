import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/painting/backdrop_filter.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら BackdropFilter の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, backdropFilterEntry);
    final built = demoWidget<BackdropFilter>(tester);

    // filter は必須なので最初の値。child は OFF なら大きさ 0 の箱で組む
    expect(built.blendMode, BlendMode.srcOver);
    expect(built.enabled, isTrue);
  });
}
