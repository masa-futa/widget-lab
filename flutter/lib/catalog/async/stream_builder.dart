import 'dart:async';

import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// Stream を作る関数。「最初から流す」のたびに新しい Stream を作る。
typedef _StreamSource = Stream<int> Function();

const _streams = [
  Choice('3 回流して終わる', _countStream, 'countStream()'),
  Choice('途中でエラー', _failingStream, 'failingStream()'),
  Choice('何も流さない', _silentStream, 'StreamController<int>().stream'),
];

final streamBuilderEntry = WidgetEntry(
  id: 'streamBuilder',
  name: 'StreamBuilder',
  genreIds: const ['async'],
  summary: 'Stream の最新の値と状態に合わせて組み立てる',
  description:
      'Stream を listen し、値・エラー・終わりが届くたびに builder だけを呼び直します。'
      'builder の外の子は組み直されません。Stream は build の中で作らず、'
      'State に持って渡します（作り直すと最初から listen し直すため）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'stream',
      group: PropertyGroup.behavior,
      typeLabel: 'Stream<int>?',
      description: 'listen する Stream。値は 1 秒おきに届きます。変えると最初から流し直します。',
      control: ChoiceControl(choices: _streams),
    ),
    PropertySpec(
      name: 'initialData',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '最初の値が届くまでの間、snapshot が持つ値。',
      initiallyOn: false,
      control: FixedControl(value: 0, source: '0'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'builder',
      typeLabel: 'AsyncWidgetBuilder<int>',
      description: 'snapshot（Stream の状態と結果）から子を組み立てる関数。ここでは snapshot を文にして出す',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'StreamBuilder<int>',
  codeArguments: const ['builder: (context, snapshot) => Status(snapshot)'],
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。StatefulWidget で listen して setState する。
const _codeWithout = '''
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  StreamSubscription<int>? _subscription;
  int? _value;

  @override
  void initState() {
    super.initState();
    // エラーや終わりも受けるなら onError・onDone を足す
    _subscription = countStream().listen(
      (value) => setState(() => _value = value),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('\${_value ?? '-'}'),
      Text('外の子'), // const でないので、値が来るたびに組み直される
    ],
  );
}''';

Widget _build(DemoArgs args) {
  final source = args.valueOf<_StreamSource>('stream');
  final initialData = args.valueOf<int>('initialData');
  final values = [
    if (source != null) 'stream: ${_codeOf(source)}',
    if (initialData != null) 'initialData: $initialData',
  ];
  return _StreamDemo(
    source: source,
    initialData: initialData,
    label: 'StreamBuilder<int>(${values.join(', ')})',
  );
}

/// StreamBuilder を使わず、listen して setState する。値が来るたびに外の子も組み直される。
Widget _buildWithout(DemoArgs args) => _ListeningDemo(
  source: args.valueOf<_StreamSource>('stream'),
  initialData: args.valueOf<int>('initialData'),
);

String _codeOf(_StreamSource source) =>
    _streams.firstWhere((choice) => choice.value == source).code;

/// ログと子に出す snapshot の文（例: `waiting`・`active: 2`・`done: Exception: 途中で失敗`）。
String _describe(AsyncSnapshot<int> snapshot) {
  final state = snapshot.connectionState.name;
  if (snapshot.hasError) return '$state: ${snapshot.error}';
  if (snapshot.hasData) return '$state: ${snapshot.data}';
  return state;
}

/// 1・2・3 秒に値を流し、4 秒に閉じる。3 つ目と閉じるのを同じ時刻にすると、
/// StreamBuilder は同じフレームで閉じた状態しか組まず `active: 3` が見えないため、1 秒ずらす。
Stream<int> _countStream() => _timeline([
  (c) => c.add(1),
  (c) => c.add(2),
  (c) => c.add(3),
  (c) => c.close(),
]);

/// 1 秒に 1、2 秒にエラー、3 秒に閉じる。
Stream<int> _failingStream() => _timeline([
  (c) => c.add(1),
  (c) => c.addError(Exception('途中で失敗')),
  (c) => c.close(),
]);

/// 何も流さず、閉じない。
Stream<int> _silentStream() => StreamController<int>().stream;

/// [steps] を 1 秒おきに 1 つずつ行う Stream。listen をやめるとタイマーも止める
/// （テストの fake の時刻で進められ、画面を離れたあとにタイマーを残さない）。
Stream<int> _timeline(List<void Function(StreamController<int>)> steps) {
  Timer? timer;
  late final StreamController<int> controller;
  controller = StreamController<int>(
    onListen: () {
      var next = 0;
      timer = Timer.periodic(const Duration(seconds: 1), (periodic) {
        steps[next++](controller);
        if (next == steps.length) periodic.cancel();
      });
    },
    onCancel: () => timer?.cancel(),
  );
  return controller.stream;
}

/// 使う側。Stream を State に持ち、StreamBuilder に渡す。
class _StreamDemo extends StatefulWidget {
  const _StreamDemo({
    required this.source,
    required this.initialData,
    required this.label,
  });

  /// OFF なら `null`（StreamBuilder は none のまま）。
  final _StreamSource? source;
  final int? initialData;
  final String label;

  @override
  State<_StreamDemo> createState() => _StreamDemoState();
}

class _StreamDemoState extends State<_StreamDemo> {
  /// 1 回しか listen できない Stream なので、StreamBuilder を作り直すときは必ず作り直す（[_start]）。
  late Stream<int>? _stream = widget.source?.call();

  /// 流し直した回数。StreamBuilder の key にする。Stream を差し替えるだけだと、StreamBuilder は
  /// 前の値を持ったまま waiting に戻り、initialData も使わないので、作り直して最初から見せる。
  int _run = 0;

  @override
  void didUpdateWidget(_StreamDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.initialData != widget.initialData) {
      _start();
    }
  }

  void _start() {
    _stream = widget.source?.call();
    _run++;
  }

  void _restart() => setState(_start);

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _RestartButton(onPressed: _restart),
        DemoScope(
          label: widget.label,
          child: StreamBuilder<int>(
            key: ValueKey(_run),
            stream: _stream,
            initialData: widget.initialData,
            builder: (context, snapshot) {
              DemoRecorder.of(context).log(_describe(snapshot));
              return RebuildCounter(
                label: '値を出す子',
                builder: (context) => Text(_describe(snapshot)),
              );
            },
          ),
        ),
        // const にして、「最初から流す」で State が組み直されても外の子は組み直さない
        const _Outside(),
      ],
    ),
  );
}

/// 使わない側。listen して、届くたびに setState する。
class _ListeningDemo extends StatefulWidget {
  const _ListeningDemo({required this.source, required this.initialData});

  final _StreamSource? source;
  final int? initialData;

  @override
  State<_ListeningDemo> createState() => _ListeningDemoState();
}

class _ListeningDemoState extends State<_ListeningDemo> {
  StreamSubscription<int>? _subscription;
  late AsyncSnapshot<int> _snapshot;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(_ListeningDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.initialData != widget.initialData) {
      _listen();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _restart() => setState(_listen);

  /// listen し直す。ログは StreamBuilder と同じ文で、届いたとき（フレームの外）に出す。
  void _listen() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    final source = widget.source;
    final initialData = widget.initialData;
    final state = source == null
        ? ConnectionState.none
        : ConnectionState.waiting;
    _update(
      initialData == null
          ? const AsyncSnapshot<int>.nothing().inState(state)
          : AsyncSnapshot.withData(state, initialData),
    );
    if (source == null) return;
    _subscription = source().listen(
      (value) => setState(
        () => _update(AsyncSnapshot.withData(ConnectionState.active, value)),
      ),
      onError: (Object error, StackTrace stackTrace) => setState(
        () => _update(
          AsyncSnapshot.withError(ConnectionState.active, error, stackTrace),
        ),
      ),
      onDone: () =>
          setState(() => _update(_snapshot.inState(ConnectionState.done))),
    );
  }

  void _update(AsyncSnapshot<int> snapshot) {
    _snapshot = snapshot;
    DemoRecorder.of(context).log(_describe(snapshot));
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _RestartButton(onPressed: _restart),
        RebuildCounter(
          label: '値を出す子',
          builder: (context) => Text(_describe(_snapshot)),
        ),
        RebuildCounter(label: '外の子', builder: (context) => const Text('固定の文')),
      ],
    ),
  );
}

/// builder の外の子。
class _Outside extends StatelessWidget {
  const _Outside();

  @override
  Widget build(BuildContext context) =>
      RebuildCounter(label: '外の子', builder: (context) => const Text('固定の文'));
}

/// 「最初から流す」のボタン（デモの部品。コードには出さない）。
class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.replay),
      label: Text('最初から流す', textScaler: DemoRecorder.textScalerOf(context)),
    ),
  );
}
