import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// AnimatedWidget は抽象クラスなので、デモの中のサブクラス `SpinningLogo` で見せる。
final animatedWidgetEntry = WidgetEntry(
  id: 'animatedWidget',
  name: 'AnimatedWidget',
  genreIds: const ['animation'],
  summary: 'Listenable が変わるたびに自分を組み直す Widget の土台',
  description:
      '継承して使う抽象クラスです。listenable（Animation など）が知らせるたびに、'
      'サブクラスの build だけを呼び直します。FadeTransition などの Transition 系もこれを継承しています。'
      'ここでは `class SpinningLogo extends AnimatedWidget` を書き、build で '
      '`Transform.rotate(angle: (listenable as Animation<double>).value * 2 * pi, …)` を返します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedWidget-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'turns',
      group: PropertyGroup.transform,
      typeLabel: 'Animation<double>',
      description:
          'サブクラスが super(listenable: turns) で渡す Animation。'
          '「動かす」で 0 から 1 へ進み、1 回転します。',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('controller', Curves.linear, 'controller'),
          Choice(
            'easeInOut',
            Curves.easeInOut,
            'CurvedAnimation(parent: controller, curve: Curves.easeInOut)',
          ),
          Choice(
            'elasticOut',
            Curves.elasticOut,
            'CurvedAnimation(parent: controller, curve: Curves.elasticOut)',
          ),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'SpinningLogo',
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。addListener で setState し、build を全部呼び直す。
const _codeWithout = '''
class Spinner extends StatefulWidget {
  const Spinner({super.key});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..addListener(() => setState(() {}));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Transform.rotate(
        angle: controller.value * 2 * pi,
        child: const FlutterLogo(),
      ),
      Text('外の子'), // const でないので、毎フレーム組み直される
    ],
  );
}''';

/// 1 回転にかける時間。
const _duration = Duration(seconds: 1);

Widget _build(DemoArgs args) {
  // 必須のプロパティなので、常に値がある
  final curve = args.valueOf<Curve>('turns')!;
  return _Demo(curve: curve, useAnimatedWidget: true);
}

Widget _buildWithout(DemoArgs args) =>
    _Demo(curve: args.valueOf<Curve>('turns')!, useAnimatedWidget: false);

/// デモの木。[useAnimatedWidget] なら SpinningLogo に Animation を渡し、
/// そうでなければ addListener で setState して全体を組み直す。
class _Demo extends StatefulWidget {
  const _Demo({required this.curve, required this.useAnimatedWidget});

  final Curve curve;
  final bool useAnimatedWidget;

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  /// controller に curve をかけたもの（linear なら controller そのもの）。
  CurvedAnimation? _curved;
  late Animation<double> _turns = _curve();

  @override
  void initState() {
    super.initState();
    if (!widget.useAnimatedWidget) _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(_Demo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curve != widget.curve) _turns = _curve();
  }

  @override
  void dispose() {
    _curved?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Animation<double> _curve() {
    _curved?.dispose();
    _curved = widget.curve == Curves.linear
        ? null
        : CurvedAnimation(parent: _controller, curve: widget.curve);
    return _curved ?? _controller;
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: () {
              DemoRecorder.of(context).log('controller.forward(from: 0)');
              _controller.forward(from: 0);
            },
            icon: const Icon(Icons.play_arrow),
            label: Text('動かす', textScaler: DemoRecorder.textScalerOf(context)),
          ),
        ),
        if (widget.useAnimatedWidget)
          DemoScope(
            label: 'SpinningLogo(turns: …)',
            child: _SpinningLogo(turns: _turns),
          )
        else
          RebuildCounter(
            label: 'SpinningLogo',
            builder: (context) => Transform.rotate(
              angle: _turns.value * 2 * math.pi,
              child: const FlutterLogo(size: 32),
            ),
          ),
        // 使う側では setState しないので組み直されない。使わない側では毎フレーム組み直される
        RebuildCounter(label: '外の子', builder: (context) => const Text('固定の文')),
      ],
    ),
  );
}

/// AnimatedWidget のサブクラス。turns が進むたびに、この Widget の build だけが呼ばれる。
class _SpinningLogo extends AnimatedWidget {
  const _SpinningLogo({required Animation<double> turns})
    : super(listenable: turns);

  Animation<double> get _turns => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'SpinningLogo',
    builder: (context) => Transform.rotate(
      angle: _turns.value * 2 * math.pi,
      child: const FlutterLogo(size: 32),
    ),
  );
}
