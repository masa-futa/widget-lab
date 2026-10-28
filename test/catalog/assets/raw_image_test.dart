import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/assets/raw_image.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら RawImage の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, rawImageEntry);
    final built = demoWidget<RawImage>(tester);

    // image は必須なので、描いて作った 8×5 の絵
    expect(built.image?.width, 8);
    expect(built.image?.height, 5);
    expect(built.width, isNull);
    expect(built.height, isNull);
    expect(built.filterQuality, FilterQuality.medium);
    expect(built.fit, isNull);
  });
}
