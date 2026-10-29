import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/catalog/scrolling/scroll_choices.dart';

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
  properties: [
    const PropertySpec(
      name: 'headerSliverBuilder',
      group: PropertyGroup.content,
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
    const PropertySpec(
      name: 'floatHeaderSlivers',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '浮く見出し（floating）を、中を少し戻しただけで出すか。'
          'false だと中が一番上に戻るまで出ない。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: '外のスクロールの向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '外のスクロールを逆の向き（下から）に並べるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'physics',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollPhysics?',
      description: '外のスクロールの、端に来たときの動き。指定しないと端末に合わせる',
      initiallyOn: false,
      control: ChoiceControl(choices: physicsChoices),
    ),
    PropertySpec(
      name: 'scrollBehavior',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollBehavior?',
      description:
          '外のスクロールの振る舞い（スクロールバー・端の動きなど）。指定しないと ScrollConfiguration に従う',
      initiallyOn: false,
      control: ChoiceControl(choices: scrollBehaviorChoices),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出した中身を切り抜くか。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(choices: clipChoices),
    ),
    const PropertySpec(
      name: 'body',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '見出しの下の、中のスクロール',
      required: true,
      control: FixedControl(
        value: _Body(),
        source: 'ListView(children: tiles)',
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: '外のスクロールの位置を読んだり動かしたりする',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグを、指が動き始めた位置と最初に触れた位置のどちらから始めるか',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: 'タップなどの当たり判定を、中身のない所でも受けるか',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、スクロールの位置を戻すための名前',
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
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  reverse: args.valueOf<bool>('reverse') ?? false,
  physics: args.valueOf<ScrollPhysics>('physics'),
  scrollBehavior: args.valueOf<ScrollBehavior>('scrollBehavior'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
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
