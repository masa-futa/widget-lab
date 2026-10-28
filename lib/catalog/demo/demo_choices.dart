/// 収録データで繰り返し使う、選択肢とスライダーの写し方。
library;

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';

/// `Alignment` の 9 か所。
const alignmentChoices = [
  Choice('topLeft', Alignment.topLeft, 'Alignment.topLeft'),
  Choice('topCenter', Alignment.topCenter, 'Alignment.topCenter'),
  Choice('topRight', Alignment.topRight, 'Alignment.topRight'),
  Choice('centerLeft', Alignment.centerLeft, 'Alignment.centerLeft'),
  Choice('center', Alignment.center, 'Alignment.center'),
  Choice('centerRight', Alignment.centerRight, 'Alignment.centerRight'),
  Choice('bottomLeft', Alignment.bottomLeft, 'Alignment.bottomLeft'),
  Choice('bottomCenter', Alignment.bottomCenter, 'Alignment.bottomCenter'),
  Choice('bottomRight', Alignment.bottomRight, 'Alignment.bottomRight'),
];

/// [alignmentChoices] の center の位置。
const alignmentCenter = 4;

/// `Axis` の 2 つ。
const axisChoices = [
  Choice('vertical', Axis.vertical, 'Axis.vertical'),
  Choice('horizontal', Axis.horizontal, 'Axis.horizontal'),
];

/// スライダーの値をそのまま `double` で渡す。
double asDouble(double v) => v;

/// スライダーの値を `double` のコードにする（例: `16.0`）。
String doubleCode(double v) => '$v';

/// スライダーの値を `int` で渡す（段を整数にしたスライダーで使う）。
int asInt(double v) => v.round();

/// スライダーの値を `int` のコードにする（例: `3`）。
String intCode(double v) => '${v.round()}';

/// スライダーの値を四辺に同じ幅の `EdgeInsets` のコードにする。
String insetsCode(double v) => 'EdgeInsets.all($v)';
