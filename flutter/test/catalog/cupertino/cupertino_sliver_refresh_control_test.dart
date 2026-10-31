import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliver_refresh_control.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoSliverRefreshControlEntry.build(
            DemoArgs(
              cupertinoSliverRefreshControlEntry,
              allOff(cupertinoSliverRefreshControlEntry),
            ),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoSliverRefreshControl>(
      find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
    );
    const defaults = CupertinoSliverRefreshControl();
    expect(
      built.refreshTriggerPullDistance,
      defaults.refreshTriggerPullDistance,
    );
    expect(built.refreshIndicatorExtent, defaults.refreshIndicatorExtent);
    expect(built.onRefresh, isNull);
  });
}
