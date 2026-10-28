import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_popup_surface.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の child だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoPopupSurfaceEntry.build(
            DemoArgs(
              cupertinoPopupSurfaceEntry,
              allOff(cupertinoPopupSurfaceEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoPopupSurface>(
      find.byType(CupertinoPopupSurface),
    );
    const defaults = CupertinoPopupSurface(child: SizedBox());
    expect(built.blurSigma, defaults.blurSigma);
    expect(built.isSurfacePainted, defaults.isSurfacePainted);
  });
}
