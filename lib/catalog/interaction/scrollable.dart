import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final scrollableEntry = WidgetEntry(
  id: 'scrollable',
  name: 'Scrollable',
  genreIds: const ['interaction', 'scrolling'],
  summary: 'ドラッグをスクロールの位置に変える、スクロールの土台',
  description:
      'ドラッグやはじく動きを受けて、スクロールの位置（ViewportOffset）を動かします。'
      '見た目は viewportBuilder が返す Viewport が、その位置に合わせて描きます。'
      'ListView・CustomScrollView はこれと Viewport を組み合わせたものです。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Scrollable-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'axisDirection',
      typeLabel: 'AxisDirection',
      description: '先頭から並べる向き。up は下から上へ並べる。既定は down',
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('down', AxisDirection.down, 'AxisDirection.down'),
          Choice('up', AxisDirection.up, 'AxisDirection.up'),
          Choice('right', AxisDirection.right, 'AxisDirection.right'),
          Choice('left', AxisDirection.left, 'AxisDirection.left'),
        ],
      ),
    ),
    PropertySpec(
      name: 'physics',
      typeLabel: 'ScrollPhysics?',
      description: '端に来たときの動き。指定しないと端末に合わせる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('はね返る', BouncingScrollPhysics(), 'BouncingScrollPhysics()'),
          Choice('端で止まる', ClampingScrollPhysics(), 'ClampingScrollPhysics()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'viewportBuilder',
      typeLabel: 'ViewportBuilder',
      description: 'スクロールの位置を受けて、見た目（Viewport）を返す関数',
      required: true,
      control: FixedControl(
        value: _viewport,
        source:
            '(context, offset) => Viewport(\n'
            '    axisDirection: axisDirection,\n'
            '    offset: offset,\n'
            '    slivers: [SliverList.list(children: tiles)],\n'
            '  )',
      ),
    ),
  ],
  build: _build,
  codeName: 'Scrollable',
);

Widget _build(DemoArgs args) => Scrollable(
  axisDirection:
      args.valueOf<AxisDirection>('axisDirection') ?? AxisDirection.down,
  physics: args.valueOf<ScrollPhysics>('physics'),
  // 必須のプロパティなので、常に値がある
  viewportBuilder: args.valueOf<ViewportBuilder>('viewportBuilder')!,
);

/// Viewport を返す。並べる向きは、上の Scrollable に合わせる。
Widget _viewport(BuildContext context, ViewportOffset offset) => Builder(
  builder: (context) => Viewport(
    axisDirection: Scrollable.of(context).axisDirection,
    offset: offset,
    slivers: [
      SliverList.list(
        children: [
          for (var i = 1; i <= 12; i++) DemoTile(i, width: 56, height: 32),
        ],
      ),
    ],
  ),
);
