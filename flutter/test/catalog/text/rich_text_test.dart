import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/text/rich_text.dart';

import '../demo_pump.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら RichText の既定値で組み立てる', (tester) async {
    await pumpEntry(tester, richTextEntry);
    final built = demoWidget<RichText>(tester);

    // text は必須なので最初の値
    expect(built.text, isA<TextSpan>());
    expect(built.textAlign, TextAlign.start);
    expect(built.maxLines, isNull);
    expect(built.overflow, TextOverflow.clip);
  });
}
