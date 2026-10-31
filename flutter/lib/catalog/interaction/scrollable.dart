import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'axisDirection',
      group: PropertyGroup.layout,
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
    const PropertySpec(
      name: 'physics',
      group: PropertyGroup.behavior,
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
      name: 'scrollBehavior',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollBehavior?',
      description:
          'スクロールのふるまいの決まりをまとめて差し替える。指定しないと ScrollConfiguration の決まりに従う',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '端の伸びなし',
            const MaterialScrollBehavior().copyWith(overscroll: false),
            'const MaterialScrollBehavior().copyWith(overscroll: false)',
          ),
          Choice(
            'マウスだけで動かす',
            const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse},
            ),
            'const MaterialScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.mouse})',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'viewportBuilder',
      group: PropertyGroup.content,
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
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: 'スクロールの位置を読んだり、コードから動かしたりする',
    ),
    ReferenceArg(
      name: 'incrementCalculator',
      typeLabel: 'ScrollIncrementCalculator?',
      description: 'キーボードで 1 回スクロールするときの量を決める',
    ),
    ReferenceArg(
      name: 'excludeFromSemantics',
      typeLabel: 'bool',
      description: '読み上げなどの支援技術に、スクロールできることを知らせないようにするか。既定は false',
    ),
    ReferenceArg(
      name: 'semanticChildCount',
      typeLabel: 'int?',
      description: '読み上げで伝える、中の項目の数',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグの始まりを、指が触れた所にするか、動き出した所にするか',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、スクロールの位置を戻すための ID',
    ),
    ReferenceArg(
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description: '端の伸びなどの飾りを、はみ出した所で切り取るか。見本では違いは出ない',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: 'ドラッグを受ける当たり判定のしかた。見本は項目で埋まっているので違いは出ない',
    ),
  ],
  build: _build,
  codeName: 'Scrollable',
);

Widget _build(DemoArgs args) => Scrollable(
  axisDirection:
      args.valueOf<AxisDirection>('axisDirection') ?? AxisDirection.down,
  physics: args.valueOf<ScrollPhysics>('physics'),
  scrollBehavior: args.valueOf<ScrollBehavior>('scrollBehavior'),
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
