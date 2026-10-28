import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final nestedScrollViewEntry = WidgetEntry(
  id: 'nestedScrollView',
  name: 'NestedScrollView',
  genreIds: const ['scrolling'],
  summary: '見出しの sliver と、中のスクロール（ListView など）をつないで 1 つにする',
  description:
      '外の見出し（headerSliverBuilder の SliverAppBar など）と、body の中のスクロールを'
      'つなぎます。中を上へ送ると先に見出しが縮み、縮みきってから中が動きます。'
      'タブごとに ListView を持つ画面（TabBarView）によく使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'headerSliverBuilder',
      typeLabel: 'NestedScrollViewHeaderSliversBuilder',
      description: '外の見出しの sliver を返す関数',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '広がる見出し（pinned）',
            _expandedHeader,
            '(context, innerBoxIsScrolled) => [\n'
                "    SliverAppBar(title: Text('見出し'), pinned: true, "
                'expandedHeight: 96),\n'
                '  ]',
          ),
          Choice(
            '浮く見出し（floating）',
            _floatingHeader,
            '(context, innerBoxIsScrolled) => [\n'
                "    SliverAppBar(title: Text('見出し'), floating: true),\n"
                '  ]',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'floatHeaderSlivers',
      typeLabel: 'bool',
      description:
          '浮く見出し（floating）を、中を少し戻しただけで出すか。'
          'false だと中が一番上に戻るまで出ない。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'body',
      typeLabel: 'Widget',
      description: '見出しの下の、中のスクロール',
      required: true,
      control: FixedControl(
        value: _Body(),
        source: 'ListView(children: tiles)',
      ),
    ),
  ],
  build: _build,
  codeName: 'NestedScrollView',
);

List<Widget> _expandedHeader(BuildContext context, bool innerBoxIsScrolled) =>
    const [SliverAppBar(title: Text('見出し'), pinned: true, expandedHeight: 96)];

List<Widget> _floatingHeader(BuildContext context, bool innerBoxIsScrolled) =>
    const [SliverAppBar(title: Text('見出し'), floating: true)];

// headerSliverBuilder・body は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => NestedScrollView(
  headerSliverBuilder: args.valueOf<NestedScrollViewHeaderSliversBuilder>(
    'headerSliverBuilder',
  )!,
  floatHeaderSlivers: args.valueOf<bool>('floatHeaderSlivers') ?? false,
  body: args.valueOf<Widget>('body')!,
);

/// 中のスクロール（20 行）。
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) => ListView(
    children: [for (var i = 1; i <= 20; i++) DemoTile(i, height: 32)],
  );
}
