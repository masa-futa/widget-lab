import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/assets/image.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら Image.asset の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, imageEntry);
    final built = demoWidget<Image>(tester);

    // name は必須なので最初の値
    expect((built.image as AssetImage).assetName, 'assets/demo/landscape.png');
    expect(built.width, isNull);
    expect(built.height, isNull);
    expect(built.fit, isNull);
    expect(built.repeat, ImageRepeat.noRepeat);
  });
}
