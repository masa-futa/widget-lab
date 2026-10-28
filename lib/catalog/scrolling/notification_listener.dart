import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final notificationListenerEntry = WidgetEntry(
  id: 'notificationListener',
  name: 'NotificationListener',
  genreIds: const ['scrolling'],
  summary: '子孫から上へ伝わる通知（スクロールなど）を受け取る',
  description:
      '子孫が出した通知のうち、型引数の型のものを onNotification で受け取ります。'
      'true を返すと通知はそこで止まり、上の聞き手には届きません。'
      '通知を受けても子は組み直されません'
      '（受ける型を変えると NotificationListener ごと作り直すので、そのときは組み直されます）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/NotificationListener-class.html',
  ),
  kind: EntryKind.behavior,
  properties: const [
    PropertySpec(
      name: 'type',
      typeLabel: 'Type',
      description:
          '受け取る通知の型。この型（とそのサブクラス）の通知だけが onNotification に来ます。'
          'OverscrollNotification は端を越えて引いたときに来ます。',
      required: true,
      arg: PropertyArg.typeArgument,
      // Dart では型引数を値から作れないので、型ごとに組み立ての関数を持つ
      control: ChoiceControl(
        choices: [
          Choice(
            'ScrollNotification',
            _listener<ScrollNotification>,
            'ScrollNotification',
          ),
          Choice(
            'ScrollUpdateNotification',
            _listener<ScrollUpdateNotification>,
            'ScrollUpdateNotification',
          ),
          Choice(
            'OverscrollNotification',
            _listener<OverscrollNotification>,
            'OverscrollNotification',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'onNotification',
      typeLabel: 'bool Function(T)',
      description: '通知を受けたときに呼ばれる。true を返すと通知はここで止まり、上の聞き手に届きません。',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice('false', false, '(notification) => false'),
          Choice('true', true, '(notification) => true'),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'NotificationListener',
  codeArguments: const ['child: const Rows()'],
);

typedef _ListenerBuilder = Widget Function({required bool stops});

Widget _build(DemoArgs args) {
  // どちらも必須のプロパティなので、常に値がある
  final listener = args.valueOf<_ListenerBuilder>('type')!;
  final stops = args.valueOf<bool>('onNotification')!;
  return _OuterListener(child: listener(stops: stops));
}

/// 包みを外す。外の聞き手には、聞き手がいなくても通知が届く。
Widget _buildWithout(DemoArgs args) =>
    const _OuterListener(child: DemoFit(child: _Rows()));

/// [T] を受ける NotificationListener。受けたら「内:」をログに出し、[stops] を返す。
Widget _listener<T extends ScrollNotification>({required bool stops}) =>
    DemoScope(
      label: 'NotificationListener<${_typeName<T>()}>(→ $stops)',
      child: Builder(
        builder: (context) {
          // 通知は木を作り直している途中にも来うるので、窓口は build のうちに引いておく
          final recorder = DemoRecorder.of(context);
          return NotificationListener<T>(
            onNotification: (notification) {
              recorder.log('内: ${_nameOf(notification)}');
              return stops;
            },
            child: const _Rows(),
          );
        },
      ),
    );

/// デモの部品（コードには出さない）。上へ伝わってきたスクロールの通知を「外:」でログに出す。
class _OuterListener extends StatelessWidget {
  const _OuterListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        recorder.log('外: ${_nameOf(notification)}');
        return false;
      },
      child: child,
    );
  }
}

/// 通知の型の名前。ビルドの設定で型の名前が変わっても、ログの文が変わらないように書き出す。
String _nameOf(ScrollNotification notification) => switch (notification) {
  ScrollStartNotification() => 'ScrollStartNotification',
  ScrollUpdateNotification() => 'ScrollUpdateNotification',
  OverscrollNotification() => 'OverscrollNotification',
  ScrollEndNotification() => 'ScrollEndNotification',
  UserScrollNotification() => 'UserScrollNotification',
  // ScrollNotification は sealed ではないので、ほかのサブクラスに備える
  _ => 'ScrollNotification',
};

/// 受ける型の名前（[_nameOf] と同じく書き出す）。
String _typeName<T extends ScrollNotification>() => switch (T) {
  const (ScrollUpdateNotification) => 'ScrollUpdateNotification',
  const (OverscrollNotification) => 'OverscrollNotification',
  _ => 'ScrollNotification',
};

/// NotificationListener の下に置く 20 行の ListView。const にして、
/// 通知を受けても組み直されないことを回数で見せる。
/// 端で止まるスクロールに揃え、iOS でも端を越えて引くと OverscrollNotification が出るようにする。
class _Rows extends StatelessWidget {
  const _Rows();

  /// カードの中でスクロールできる高さ（DemoFit の中は高さに上限がないので決めておく）。
  static const _height = 120.0;

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'ListView',
    builder: (context) => SizedBox(
      height: _height,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: 20,
        itemBuilder: (context, index) => Text('${index + 1} 行目'),
      ),
    ),
  );
}
