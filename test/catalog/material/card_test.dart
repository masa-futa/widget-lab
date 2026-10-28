import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_lab/catalog/material/card.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';

import '../all_off.dart';

void main() {
  test('TC-18: 全部 OFF なら Card の既定値で組み立てる', () {
    final card =
        cardEntry.build(DemoArgs(cardEntry, allOff(cardEntry))) as Card;

    expect(card.color, isNull);
    expect(card.elevation, isNull);
    expect(card.shape, isNull);
    expect(card.margin, isNull);
    expect(card.child, isNull);
  });
}
