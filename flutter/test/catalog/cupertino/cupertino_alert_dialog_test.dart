import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_alert_dialog.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら CupertinoAlertDialog の既定値で組み立てる', () {
    final built = cupertinoAlertDialogEntry.build(
      DemoArgs(cupertinoAlertDialogEntry, allOff(cupertinoAlertDialogEntry)),
    ) as CupertinoAlertDialog;
    const defaults = CupertinoAlertDialog();

    expect(built.title, defaults.title);
    expect(built.content, defaults.content);
    expect(built.actions, defaults.actions);
  });
}
