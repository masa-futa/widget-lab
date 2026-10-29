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

/// デモの Future の結果。「最初から待つ」のたびに、これから新しい Future を作る。
enum _Outcome { value, error, never }

const _futures = [
  Choice('2 秒後に値', _Outcome.value, 'fetchValue()'),
  Choice('途中でエラー', _Outcome.error, 'fetchFailing()'),
  Choice('終わらない', _Outcome.never, 'Completer<int>().future'),
];

final futureBuilderEntry = WidgetEntry(
  id: 'futureBuilder',
  name: 'FutureBuilder',
  genreIds: const ['async'],
  summary: 'Future の結果と状態に合わせて組み立てる',
  description:
      'Future を待ち、終わったら（値でもエラーでも）builder だけを呼び直します。'
      'builder の外の子は組み直されません。Future は build の中で作らず、'
      'State に持って渡します（作り直すと最初から待ち直すため）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'future',
      group: PropertyGroup.behavior,
      typeLabel: 'Future<int>?',
      description: '待つ Future。結果は 2 秒後に届きます。変えると最初から待ち直します。',
      control: ChoiceControl(choices: _futures),
    ),
    PropertySpec(
      name: 'initialData',
      group: PropertyGroup.behavior,
      typeLabel: 'int?',
      description: '結果が届くまでの間、snapshot が持つ値。',
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
      description: 'snapshot（Future の状態と結果）から子を組み立てる関数。ここでは snapshot を文にして出す',
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'FutureBuilder<int>',
  codeArguments: const ['builder: (context, snapshot) => Status(snapshot)'],
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。StatefulWidget で then を付けて setState する。
const _codeWithout = '''
class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  int? _value;

  @override
  void initState() {
    super.initState();
    // エラーも受けるなら onError を足す。待つ間に画面を離れたら mounted で確かめる
    fetchValue().then((value) {
      if (mounted) setState(() => _value = value);
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('\${_value ?? '-'}'),
      Text('外の子'), // const でないので、結果が届くと組み直される
    ],
  );
}''';

Widget _build(DemoArgs args) {
  final outcome = args.valueOf<_Outcome>('future');
  final initialData = args.valueOf<int>('initialData');
  final values = [
    if (outcome != null) 'future: ${_codeOf(outcome)}',
    if (initialData != null) 'initialData: $initialData',
  ];
  return _FutureDemo(
    outcome: outcome,
    initialData: initialData,
    label: 'FutureBuilder<int>(${values.join(', ')})',
  );
}

/// FutureBuilder を使わず、then で setState する。結果が届くと外の子も組み直される。
Widget _buildWithout(DemoArgs args) => _ThenDemo(
  outcome: args.valueOf<_Outcome>('future'),
  initialData: args.valueOf<int>('initialData'),
);

String _codeOf(_Outcome outcome) =>
    _futures.firstWhere((choice) => choice.value == outcome).code;

/// ログと子に出す snapshot の文（例: `waiting`・`done: 42`・`done: Exception: 読み込みに失敗`）。
String _describe(AsyncSnapshot<int> snapshot) {
  final state = snapshot.connectionState.name;
  if (snapshot.hasError) return '$state: ${snapshot.error}';
  if (snapshot.hasData) return '$state: ${snapshot.data}';
  return state;
}

/// [outcome] の Future を作って待つもの。2 秒のタイマーを持ち、[cancel] で止める
/// （テストの fake の時刻で進められ、画面を離れたあとにタイマーを残さない）。
final class _Pending {
  _Pending(_Outcome outcome) {
    switch (outcome) {
      case _Outcome.value:
        _timer = Timer(_delay, () => _completer.complete(42));
      case _Outcome.error:
        _timer = Timer(
          _delay,
          () => _completer.completeError(Exception('読み込みに失敗')),
        );
      case _Outcome.never:
        break;
    }
  }

  static const _delay = Duration(seconds: 2);

  final _completer = Completer<int>();
  Timer? _timer;

  Future<int> get future => _completer.future;

  void cancel() => _timer?.cancel();
}

/// 使う側。Future を State に持ち、FutureBuilder に渡す。
class _FutureDemo extends StatefulWidget {
  const _FutureDemo({
    required this.outcome,
    required this.initialData,
    required this.label,
  });

  /// OFF なら `null`（FutureBuilder は none のまま）。
  final _Outcome? outcome;
  final int? initialData;
  final String label;

  @override
  State<_FutureDemo> createState() => _FutureDemoState();
}

class _FutureDemoState extends State<_FutureDemo> {
  late _Pending? _pending = _create();

  /// 待ち直した回数。FutureBuilder の key にする。Future を差し替えるだけだと、FutureBuilder は
  /// 前の結果を持ったまま waiting に戻り、initialData も使わないので、作り直して最初から見せる。
  int _run = 0;

  _Pending? _create() {
    final outcome = widget.outcome;
    return outcome == null ? null : _Pending(outcome);
  }

  @override
  void didUpdateWidget(_FutureDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outcome != widget.outcome ||
        oldWidget.initialData != widget.initialData) {
      _start();
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  void _start() {
    _pending?.cancel();
    _pending = _create();
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
          child: FutureBuilder<int>(
            key: ValueKey(_run),
            future: _pending?.future,
            initialData: widget.initialData,
            builder: (context, snapshot) {
              DemoRecorder.of(context).log(_describe(snapshot));
              return RebuildCounter(
                label: '結果を出す子',
                builder: (context) => Text(_describe(snapshot)),
              );
            },
          ),
        ),
        // const にして、「最初から待つ」で State が組み直されても外の子は組み直さない
        const _Outside(),
      ],
    ),
  );
}

/// 使わない側。then を付けて、届いたら setState する。
class _ThenDemo extends StatefulWidget {
  const _ThenDemo({required this.outcome, required this.initialData});

  final _Outcome? outcome;
  final int? initialData;

  @override
  State<_ThenDemo> createState() => _ThenDemoState();
}

class _ThenDemoState extends State<_ThenDemo> {
  _Pending? _pending;
  late AsyncSnapshot<int> _snapshot;

  @override
  void initState() {
    super.initState();
    _wait();
  }

  @override
  void didUpdateWidget(_ThenDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outcome != widget.outcome ||
        oldWidget.initialData != widget.initialData) {
      _wait();
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  void _restart() => setState(_wait);

  /// 待ち直す。ログは FutureBuilder と同じ文で、届いたとき（フレームの外）に出す。
  void _wait() {
    _pending?.cancel();
    final outcome = widget.outcome;
    final initialData = widget.initialData;
    final state = outcome == null
        ? ConnectionState.none
        : ConnectionState.waiting;
    _update(
      initialData == null
          ? const AsyncSnapshot<int>.nothing().inState(state)
          : AsyncSnapshot.withData(state, initialData),
    );
    if (outcome == null) {
      _pending = null;
      return;
    }
    final pending = _pending = _Pending(outcome);
    pending.future.then(
      (value) {
        // 待ち直した後に前の Future が終わっても使わない
        if (!mounted || _pending != pending) return;
        setState(
          () => _update(AsyncSnapshot.withData(ConnectionState.done, value)),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || _pending != pending) return;
        setState(
          () => _update(
            AsyncSnapshot.withError(ConnectionState.done, error, stackTrace),
          ),
        );
      },
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
          label: '結果を出す子',
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

/// 「最初から待つ」のボタン（デモの部品。コードには出さない）。
class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.replay),
      label: Text('最初から待つ', textScaler: DemoRecorder.textScalerOf(context)),
    ),
  );
}
