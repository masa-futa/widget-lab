import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_recorder.dart';
import 'package:widget_lab/catalog/demo/demo_scope.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/demo/rebuild_counter.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final scrollConfigurationEntry = WidgetEntry(
  id: 'scrollConfiguration',
  name: 'ScrollConfiguration',
  genreIds: const ['scrolling'],
  summary: '子孫のスクロールの振る舞い（端の動き・スクロールバーなど）を決める',
  description:
      'ScrollBehavior を子孫のスクロールに配ります。端に来たときの動き（physics）、'
      'スクロールバーを付けるか、マウスでドラッグできるかなどを、まとめて変えられます。'
      '既定はアプリ（MaterialApp）が端末に合わせて決めます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ScrollConfiguration-class.html',
  ),
  kind: EntryKind.behavior,
  properties: [
    PropertySpec(
      name: 'behavior',
      typeLabel: 'ScrollBehavior',
      description: '配る振る舞い。リストを端まで送って、ログで端の動きを比べられます。',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            'はね返る',
            const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
            ),
            'const MaterialScrollBehavior().copyWith(\n'
                '    physics: const BouncingScrollPhysics(),\n'
                '  )',
          ),
          Choice(
            '端で止まる',
            const MaterialScrollBehavior().copyWith(
              physics: const ClampingScrollPhysics(),
            ),
            'const MaterialScrollBehavior().copyWith(\n'
                '    physics: const ClampingScrollPhysics(),\n'
                '  )',
          ),
          Choice(
            'スクロールバーなし',
            const MaterialScrollBehavior().copyWith(scrollbars: false),
            'const MaterialScrollBehavior().copyWith(scrollbars: false)',
          ),
        ],
      ),
    ),
  ],
  build: _build,
  buildWithout: _buildWithout,
  codeName: 'ScrollConfiguration',
  codeArguments: const ['child: const Rows()'],
);

Widget _build(DemoArgs args) =>
    // 必須のプロパティなので、常に値がある
    _EdgeLogger(
      child: DemoScope(
        label: 'ScrollConfiguration(…)',
        child: ScrollConfiguration(
          behavior: args.valueOf<ScrollBehavior>('behavior')!,
          child: const _Rows(),
        ),
      ),
    );

/// 包みを外す。子はアプリ（端末）の振る舞いのまま。
Widget _buildWithout(DemoArgs args) =>
    const _EdgeLogger(child: DemoFit(child: _Rows()));

/// デモの部品（コードには出さない）。端に来たときの動きをログに出す。
class _EdgeLogger extends StatelessWidget {
  const _EdgeLogger({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final recorder = DemoRecorder.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        switch (notification) {
          case OverscrollNotification():
            recorder.log('端で止まる（OverscrollNotification）');
          case ScrollUpdateNotification(:final metrics) when metrics.outOfRange:
            recorder.log('端を越えて動く（はね返り）');
          default:
            break;
        }
        return false;
      },
      child: child,
    );
  }
}

/// 振る舞いを受けるリスト（20 行）。const にして、振る舞いを変えたときに
/// 組み直されるのはスクロールの中だけで、包む子は組み直されないことを回数で見せる。
class _Rows extends StatelessWidget {
  const _Rows();

  static const _height = 120.0;

  @override
  Widget build(BuildContext context) => RebuildCounter(
    label: 'ListView',
    builder: (context) => SizedBox(
      height: _height,
      child: ListView(
        children: [for (var i = 1; i <= 20; i++) DemoTile(i, height: 24)],
      ),
    ),
  );
}
