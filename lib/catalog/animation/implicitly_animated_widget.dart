import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// ImplicitlyAnimatedWidget は抽象クラスなので、角丸を動かす小さなサブクラス
/// （AnimatedRadius）をデモの中で書いて見せる。
final implicitlyAnimatedWidgetEntry = WidgetEntry(
  id: 'implicitlyAnimatedWidget',
  name: 'ImplicitlyAnimatedWidget',
  genreIds: const ['animation'],
  summary: 'AnimatedContainer などの土台。値が変わると自分で動く Widget を作る',
  description:
      'AnimatedContainer・AnimatedOpacity などの暗黙のアニメーションの土台になる抽象クラスです。'
      'サブクラスは duration と curve を受け取り、State（AnimatedWidgetBaseState）の '
      'forEachTween で「動かす値」と Tween を結びます。値が変わると、前の値から新しい値へ'
      '自分で動きます。ここでは角丸を動かすサブクラス AnimatedRadius を書いて見せます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'radius',
      typeLabel: 'double',
      description: 'サブクラスで足した、動かす値（角の丸み）。変えると新しい丸みへ動く',
      required: true,
      control: SliderControl(
        min: 0,
        max: 60,
        divisions: 6,
        initialValue: 40,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    durationSpec,
    curveSpec,
  ],
  build: _build,
  codeName: 'AnimatedRadius',
);

Widget _build(DemoArgs args) => _AnimatedRadius(
  radius: args.valueOf<double>('radius') ?? 0,
  duration: durationOf(args),
  curve: curveOf(args),
);

/// 角丸を動かす、ImplicitlyAnimatedWidget のサブクラス（コードでは AnimatedRadius）。
class _AnimatedRadius extends ImplicitlyAnimatedWidget {
  const _AnimatedRadius({
    required this.radius,
    required super.duration,
    super.curve,
  });

  final double radius;

  @override
  AnimatedWidgetBaseState<_AnimatedRadius> createState() =>
      _AnimatedRadiusState();
}

class _AnimatedRadiusState extends AnimatedWidgetBaseState<_AnimatedRadius> {
  Tween<double>? _radius;

  /// 動かす値ごとに、今の値から widget の新しい値への Tween を作り直す。
  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _radius = visitor(
      _radius,
      widget.radius,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(_radius?.evaluate(animation) ?? 0),
    child: const SizedBox(
      width: 160,
      height: 120,
      child: ColoredBox(color: Color(0xFF1E50A2)),
    ),
  );
}
