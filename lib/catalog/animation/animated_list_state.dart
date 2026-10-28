import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// AnimatedListState は AnimatedList の State。Widget ではないので、
/// GlobalKey から引いて insertItem を呼ぶ書き方を見せる。
final animatedListStateEntry = WidgetEntry(
  id: 'animatedListState',
  name: 'AnimatedListState',
  genreIds: const ['animation'],
  summary: 'AnimatedList に、項目を足した・消したと知らせる State',
  description:
      'AnimatedList の State です。GlobalKey<AnimatedListState> の currentState か '
      'AnimatedList.of(context) で引き、insertItem・removeItem で項目の出入りを知らせます。'
      'リストが自分で組み直し、動きを付けるので、呼ぶ側は setState しません。'
      '元のデータ（items）は自分で同じように足し引きしておきます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedListState-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    const PropertySpec(
      name: 'index',
      typeLabel: 'int',
      description: '足す位置。ここでは先頭（0）',
      required: true,
      arg: PropertyArg.positional,
      control: FixedControl(value: 0, source: '0'),
    ),
    PropertySpec(
      name: 'duration',
      typeLabel: 'Duration',
      description: '入ってくる動きにかける時間。指定しないと 300 ミリ秒',
      initiallyOn: false,
      control: SliderControl(
        min: 100,
        max: 1500,
        divisions: 14,
        initialValue: 1000,
        resolve: (v) => Duration(milliseconds: v.round()),
        code: (v) => 'Duration(milliseconds: ${v.round()})',
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'listKey.currentState!.insertItem',
  codeWithout: _codeWithout,
);

/// 使わない場合のよくある書き方。ListView の items を足して setState する。
const _codeWithout = '''
setState(() => items.insert(0, next++));

// build の中
ListView(
  children: [for (final item in items) Item(item)],
)''';

/// insertItem・removeItem の既定の時間。
const _defaultDuration = Duration(milliseconds: 300);

Widget _build(DemoArgs args) {
  final duration = args.valueOf<Duration>('duration');
  return _StateDemo(
    duration: duration ?? _defaultDuration,
    label:
        'insertItem(0${duration == null ? '' : ', duration: ${duration.inMilliseconds}ms'})',
  );
}

/// AnimatedListState を使わず、ListView の項目を setState で足し引きする。
Widget _buildWithout(DemoArgs args) => const _SetStateDemo();

/// 最初の項目。
const _initialItems = [1, 2];

/// 使う側。ボタンは AnimatedListState を呼ぶだけで、setState しない。
class _StateDemo extends StatefulWidget {
  const _StateDemo({required this.duration, required this.label});

  final Duration duration;
  final String label;

  @override
  State<_StateDemo> createState() => _StateDemoState();
}

class _StateDemoState extends State<_StateDemo> {
  /// State ごとに作るので、比較の左右にあっても重ならない。
  final _listKey = GlobalKey<AnimatedListState>();
  final _items = [..._initialItems];
  var _next = _initialItems.length + 1;

  void _add() {
    _items.insert(0, _next++);
    DemoRecorder.of(context).log('insertItem(0)');
    _listKey.currentState?.insertItem(0, duration: widget.duration);
  }

  void _remove() {
    if (_items.isEmpty) return;
    final removed = _items.removeAt(0);
    DemoRecorder.of(context).log('removeItem(0, …)');
    _listKey.currentState?.removeItem(
      0,
      (context, animation) => _Item(number: removed, animation: animation),
      duration: widget.duration,
    );
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _Buttons(onAdd: _add, onRemove: _remove),
        DemoScope(
          label: widget.label,
          child: SizedBox(
            height: _listHeight,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) =>
                  _Item(number: _items[index], animation: animation),
            ),
          ),
        ),
        const _Outside(),
      ],
    ),
  );
}

/// 使わない側。項目を足し引きして setState し、全体を組み直す（動きは付かない）。
class _SetStateDemo extends StatefulWidget {
  const _SetStateDemo();

  @override
  State<_SetStateDemo> createState() => _SetStateDemoState();
}

class _SetStateDemoState extends State<_SetStateDemo> {
  final _items = [..._initialItems];
  var _next = _initialItems.length + 1;

  void _add() {
    DemoRecorder.of(context).log('setState で items に足す');
    setState(() => _items.insert(0, _next++));
  }

  void _remove() {
    if (_items.isEmpty) return;
    DemoRecorder.of(context).log('setState で items から消す');
    setState(() => _items.removeAt(0));
  }

  @override
  Widget build(BuildContext context) => DemoFit(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _Buttons(onAdd: _add, onRemove: _remove),
        SizedBox(
          height: _listHeight,
          child: ListView(
            children: [
              for (final item in _items)
                _Item(number: item, animation: kAlwaysCompleteAnimation),
            ],
          ),
        ),
        // const でないので、setState のたびに組み直される
        RebuildCounter(
          label: 'リストの外の子',
          builder: (context) => const Text('固定の文'),
        ),
      ],
    ),
  );
}

/// リストの高さ（DemoFit の中は高さに上限がないので決めておく）。
const _listHeight = 120.0;

/// リストの外の子。
class _Outside extends StatelessWidget {
  const _Outside();

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'リストの外の子',
    builder: (context) => const Text('固定の文'),
  );
}

/// 「足す」「消す」のボタン（デモの部品。コードには出さない）。
class _Buttons extends StatelessWidget {
  const _Buttons({required this.onAdd, required this.onRemove});

  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textScaler = DemoRecorder.textScalerOf(context);
    return Row(
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text('足す', textScaler: textScaler),
        ),
        OutlinedButton.icon(
          onPressed: onRemove,
          icon: const Icon(Icons.remove),
          label: Text('消す', textScaler: textScaler),
        ),
      ],
    );
  }
}

/// 1 つの項目。animation に合わせて縦に伸び縮みする。
class _Item extends StatelessWidget {
  const _Item({required this.number, required this.animation});

  final int number;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => SizeTransition(
    sizeFactor: animation,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('項目 $number'),
    ),
  );
}
