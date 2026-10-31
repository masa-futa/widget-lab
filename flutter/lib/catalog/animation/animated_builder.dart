import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedBuilderEntry = WidgetEntry(
  id: 'animatedBuilder',
  name: 'AnimatedBuilder',
  genreIds: const ['animation'],
  summary: 'Animation が進むたびに builder だけを呼び直す',
  description:
      'animation（Listenable）が知らせるたびに builder だけを呼び直します。'
      'builder の外の子は組み直されません。動かない部分を child に渡すと、'
      '一度だけ作ったものを builder が毎回受け取って使うので、毎フレーム組み直さずに済みます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'animation',
      group: PropertyGroup.behavior,
      typeLabel: 'Listenable',
      description: '聞く Listenable。ここでは「動かす」で 1 回転する AnimationController',
      required: true,
      control: FixedControl(value: 'controller', source: 'controller'),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description:
          'builder に渡す、動かない部分。OFF にすると builder の中で作るので、'
          '毎フレーム組み直されます。',
      control: FixedControl(value: _Logo(), source: 'const Logo()'),
    ),
  ],
  references: const [
    keyReference,
    ReferenceArg(
      name: 'builder',
      typeLabel: 'TransitionBuilder',
      description: 'animation が知らせるたびに呼ばれ、動く部分を組み立てる関数。ここでは子を回す',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'AnimatedBuilder',
  codeArguments: const [
    'builder: (context, child) => Transform.rotate(\n'
        '    angle: controller.value * 2 * pi,\n'
        '    child: child,\n'
        '  )',
  ],
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
        child: Logo(), // 毎フレーム組み直される
      ),
      Text('外の子'), // これも毎フレーム組み直される
    ],
  );
}''';

/// 1 回転にかける時間。
const _duration = Duration(seconds: 1);

Widget _build(DemoArgs args) {
  final child = args.valueOf<Widget>('child');
  return _BuilderDemo(
    label: 'AnimatedBuilder(${child == null ? '' : 'child: Logo()'})',
    child: child,
  );
}

/// AnimatedBuilder を使わず、addListener で setState する。
Widget _buildWithout(DemoArgs args) => const _ListeningDemo();

/// 使う側。setState は「動かす」のときだけで、動いている間は builder だけが呼ばれる。
class _BuilderDemo extends StatefulWidget {
  const _BuilderDemo({required this.child, required this.label});

  /// OFF なら `null`（builder の中でロゴを作る）。
  final Widget? child;
  final String label;

  @override
  State<_BuilderDemo> createState() => _BuilderDemoState();
}

class _BuilderDemoState extends State<_BuilderDemo>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _SpinButton(controller: _controller),
        DemoScope(
          label: widget.label,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => RebuildCounter(
              label: '回す子',
              builder: (context) => Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                // OFF なら builder の中で作るので、毎フレーム作り直される
                // ignore: prefer_const_constructors
                child: child ?? _Logo(),
              ),
            ),
            child: widget.child,
          ),
        ),
        const _Outside(),
      ],
    ),
  );
}

/// 使わない側。AnimationController が進むたびに setState し、build を全部呼び直す。
class _ListeningDemo extends StatefulWidget {
  const _ListeningDemo();

  @override
  State<_ListeningDemo> createState() => _ListeningDemoState();
}

class _ListeningDemoState extends State<_ListeningDemo>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: _duration)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _SpinButton(controller: _controller),
        RebuildCounter(
          label: '回す子',
          builder: (context) => Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            // const にしないよくある書き方。毎フレーム作り直される
            // ignore: prefer_const_constructors
            child: _Logo(),
          ),
        ),
        // const でないので、setState のたびに組み直される
        RebuildCounter(label: '外の子', builder: (context) => const Text('固定の文')),
      ],
    ),
  );
}

/// 回るロゴ。child に渡したときは一度しか作られないことを回数で見せる。
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'ロゴ',
    builder: (context) => const FlutterLogo(size: 32),
  );
}

/// builder の外の子。
class _Outside extends StatelessWidget {
  const _Outside();

  @override
  Widget build(BuildContext context) =>
      RebuildCounter(label: '外の子', builder: (context) => const Text('固定の文'));
}

/// 「動かす」のボタン（デモの部品。コードには出さない）。1 回転して止まる。
class _SpinButton extends StatelessWidget {
  const _SpinButton({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: OutlinedButton.icon(
      onPressed: () {
        DemoRecorder.of(context).log('controller.forward(from: 0)');
        controller.forward(from: 0);
      },
      icon: const Icon(Icons.play_arrow),
      label: Text('動かす', textScaler: DemoRecorder.textScalerOf(context)),
    ),
  );
}
