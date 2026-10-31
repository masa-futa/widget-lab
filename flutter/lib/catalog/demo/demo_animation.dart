import 'package:flutter/widgets.dart';

/// Transition 系の Widget に渡す Animation を持つデモの部品。0 → 1 → 0 を [duration] で
/// 繰り返す AnimationController を作り、[builder] に渡す。コードでは `controller` と書く。
///
/// 見本では `TickerMode(enabled: false)` の下に置かれるので、最初の値（0）で止まる。
class DemoAnimation extends StatefulWidget {
  const DemoAnimation({
    required this.builder,
    this.duration = const Duration(seconds: 2),
    super.key,
  });

  final Widget Function(BuildContext context, AnimationController controller)
  builder;

  /// 0 → 1 にかける時間（1 → 0 も同じ）。
  final Duration duration;

  @override
  State<DemoAnimation> createState() => _DemoAnimationState();
}

class _DemoAnimationState extends State<DemoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void didUpdateWidget(DemoAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
