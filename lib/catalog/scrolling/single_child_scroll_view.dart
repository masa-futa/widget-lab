import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/catalog/scrolling/scroll_choices.dart';

final singleChildScrollViewEntry = WidgetEntry(
  id: 'singleChildScrollView',
  name: 'SingleChildScrollView',
  genreIds: const ['scrolling'],
  summary: '1 つの子を、入りきらなければスクロールして見せる',
  description:
      '子を上限なしの高さで組み、入りきらない分をスクロールで見せます。'
      'ふだんは収まるが、小さい画面やキーボードで足りなくなる画面（フォームなど）に使います。'
      '子は全部一度に作るので、長いリストには ListView を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: 'スクロールする向き。既定は vertical',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices, initialIndex: 1),
    ),
    const PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: '子のまわりの余白。余白もスクロールする',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 3,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '下の端から見せるか（チャットのように）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'physics',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollPhysics?',
      description: '端に来たときの動き。指定しないと端末に合わせる',
      initiallyOn: false,
      control: ChoiceControl(choices: physicsChoices),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出した子を切り抜くか。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(choices: clipChoices),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'スクロールする子（8 つの箱を、スクロールの向きに並べた Flex）',
      control: FixedControl(
        value: _Tiles(),
        source: 'Flex(direction: scrollDirection, children: tiles)',
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
      name: 'primary',
      typeLabel: 'bool?',
      description: '画面のいちばん外のスクロールとして、PrimaryScrollController を使うか',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'ScrollController?',
      description: 'スクロールの位置を読んだり動かしたりする。primary: true とは一緒に使えない',
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
    ReferenceArg(
      name: 'keyboardDismissBehavior',
      typeLabel: 'ScrollViewKeyboardDismissBehavior?',
      description: 'スクロールしたときに、キーボードを閉じるか',
    ),
  ],
  build: _build,
  codeName: 'SingleChildScrollView',
);

Widget _build(DemoArgs args) => SingleChildScrollView(
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.vertical,
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  reverse: args.valueOf<bool>('reverse') ?? false,
  physics: args.valueOf<ScrollPhysics>('physics'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  child: args.valueOf<Widget>('child'),
);

/// 8 つの箱を、まわりのスクロールの向きに並べる（横向きでも縦にはみ出さない）。
class _Tiles extends StatelessWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context) {
    final direction = Scrollable.maybeOf(context)?.axisDirection;
    final axis = direction == null
        ? Axis.vertical
        : axisDirectionToAxis(direction);
    return Flex(
      direction: axis,
      children: [
        for (var i = 1; i <= 8; i++)
          axis == Axis.vertical
              ? DemoTile(i, height: 32)
              : DemoTile(i, width: 48),
      ],
    );
  }
}
