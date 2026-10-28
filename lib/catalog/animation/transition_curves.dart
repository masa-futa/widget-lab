import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';

/// Transition 系の Widget に渡す Animation を、デモの controller（[DemoAnimation]）から作る関数。
/// 選択肢の値にする（Animation は controller ができてからでないと作れないため）。
typedef AnimationOf<T> = Animation<T> Function(Animation<double> controller);

/// 選べる曲線。どれも 0〜1 の外に出ない（FadeTransition の不透明度が範囲を超えないように）。
const _curves = [
  ('linear', Curves.linear),
  ('easeIn', Curves.easeIn),
  ('easeInOut', Curves.easeInOut),
  ('bounceOut', Curves.bounceOut),
];

/// controller の 0 → 1 を [begin] → [end] に写す、曲線ごとの選択肢。
///
/// 見本は最初の値で止まるので、[begin] を 0 より大きくすると見本でも中身が見える。
List<Choice> curveChoices({double begin = 0, double end = 1}) => [
  for (final (name, curve) in _curves)
    Choice(
      name,
      (Animation<double> controller) => controller.drive(
        Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve)),
      ),
      begin == 0 && end == 1
          ? 'controller.drive(CurveTween(curve: Curves.$name))'
          : 'controller.drive(Tween(begin: $begin, end: $end)'
                '.chain(CurveTween(curve: Curves.$name)))',
    ),
];

/// 拡大・回転などの中心の選択肢（topLeft・center・bottomRight）。
List<Choice> pivotChoices() => [
  for (final (name, value) in const [
    ('topLeft', Alignment.topLeft),
    ('center', Alignment.center),
    ('bottomRight', Alignment.bottomRight),
  ])
    Choice(name, value, 'Alignment.$name'),
];

/// 選択肢の値が渡らなかったとき（必須なので起きない）に使う、そのままの controller。
Animation<double> linearOf(Animation<double> controller) => controller;
