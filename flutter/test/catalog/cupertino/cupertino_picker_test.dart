import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_picker.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  testWidgets('TC-18: 全部 OFF なら必須の行の高さ・関数・子だけを渡し、ほかは既定値で組み立てる', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: cupertinoPickerEntry.build(
            DemoArgs(cupertinoPickerEntry, allOff(cupertinoPickerEntry)),
          ),
        ),
      ),
    );

    final built = tester.widget<CupertinoPicker>(find.byType(CupertinoPicker));
    final defaults = CupertinoPicker(
      itemExtent: 32,
      onSelectedItemChanged: null,
      children: const [Text('1')],
    );
    expect(built.itemExtent, 32);
    expect(built.diameterRatio, defaults.diameterRatio);
    expect(built.squeeze, defaults.squeeze);
    expect(built.useMagnifier, defaults.useMagnifier);
    expect(built.magnification, defaults.magnification);
    expect(built.offAxisFraction, defaults.offAxisFraction);
    expect(built.backgroundColor, defaults.backgroundColor);
    expect(
      built.selectionOverlay,
      isA<CupertinoPickerDefaultSelectionOverlay>(),
    );
    expect(built.childDelegate, isA<ListWheelChildListDelegate>());
  });
}
