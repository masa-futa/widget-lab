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

final pageViewEntry = WidgetEntry(
  id: 'pageView',
  name: 'PageView',
  genreIds: const ['scrolling'],
  summary: '子を 1 ページずつ、めくるように送る',
  description:
      '子を自分と同じ大きさのページにして並べ、指を離すとページの境目に止まります。'
      'オンボーディングや写真の一覧に使います。'
      '1 ページの幅を変えるときは PageController の viewportFraction を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/PageView-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'scrollDirection',
      group: PropertyGroup.layout,
      typeLabel: 'Axis',
      description: 'めくる向き。既定は horizontal',
      initiallyOn: false,
      control: ChoiceControl(choices: axisChoices),
    ),
    const PropertySpec(
      name: 'pageSnapping',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '指を離したら、ページの境目に止めるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'reverse',
      group: PropertyGroup.layout,
      typeLabel: 'bool',
      description: '逆の向き（右から・下から）に並べるか。既定は false',
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
      name: 'scrollBehavior',
      group: PropertyGroup.behavior,
      typeLabel: 'ScrollBehavior?',
      description: 'スクロールの振る舞い（スクロールバー・端の動きなど）。指定しないと ScrollConfiguration に従う',
      initiallyOn: false,
      control: ChoiceControl(choices: scrollBehaviorChoices),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: '見える範囲の外にはみ出したページを切り抜くか。既定は hardEdge',
      initiallyOn: false,
      control: ChoiceControl(choices: clipChoices),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: 'ページ（5 枚）',
      control: FixedControl(
        value: <Widget>[
          DemoTile(1),
          DemoTile(2),
          DemoTile(3),
          DemoTile(4),
          DemoTile(5),
        ],
        source: '[Tile(1), Tile(2), Tile(3), Tile(4), Tile(5)]',
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
      typeLabel: 'PageController?',
      description: '今のページを読んだり、ページを送ったりする。1 ページの幅（viewportFraction）もここで決める',
    ),
    ReferenceArg(
      name: 'onPageChanged',
      typeLabel: 'ValueChanged<int>?',
      description: '真ん中のページが変わったときに呼ばれる',
    ),
    ReferenceArg(
      name: 'dragStartBehavior',
      typeLabel: 'DragStartBehavior',
      description: 'ドラッグを、指が動き始めた位置と最初に触れた位置のどちらから始めるか',
    ),
    ReferenceArg(
      name: 'allowImplicitScrolling',
      typeLabel: 'bool',
      description: '読み上げ（スクリーンリーダー）で、となりのページへ送れるようにするか',
    ),
    ReferenceArg(
      name: 'scrollCacheExtent',
      typeLabel: 'ScrollCacheExtent?',
      description: '見える範囲の外に、前もって作っておくページの広さ。allowImplicitScrolling と合わせる',
    ),
    ReferenceArg(
      name: 'restorationId',
      typeLabel: 'String?',
      description: 'アプリを作り直したときに、スクロールの位置を戻すための名前',
    ),
    ReferenceArg(
      name: 'hitTestBehavior',
      typeLabel: 'HitTestBehavior',
      description: 'タップなどの当たり判定を、中身のない所でも受けるか',
    ),
    ReferenceArg(
      name: 'padEnds',
      typeLabel: 'bool',
      description: '最初と最後のページを真ん中に寄せるか。viewportFraction が 1 より小さいときだけ違いが出る',
    ),
  ],
  build: _build,
  codeName: 'PageView',
);

Widget _build(DemoArgs args) => PageView(
  scrollDirection: args.valueOf<Axis>('scrollDirection') ?? Axis.horizontal,
  pageSnapping: args.valueOf<bool>('pageSnapping') ?? true,
  reverse: args.valueOf<bool>('reverse') ?? false,
  physics: args.valueOf<ScrollPhysics>('physics'),
  scrollBehavior: args.valueOf<ScrollBehavior>('scrollBehavior'),
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.hardEdge,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
