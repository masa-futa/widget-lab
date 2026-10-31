import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverFillRemainingEntry = WidgetEntry(
  id: 'sliverFillRemaining',
  name: 'SliverFillRemaining',
  genreIds: const ['layout', 'scrolling'],
  summary: 'スクロールの残りの高さを、1 つの子で埋める',
  description:
      'CustomScrollView の最後に置き、前の sliver を並べた残りの高さいっぱいに子を広げます。'
      '「中身が少なくても、ボタンを一番下に置く」画面によく使います。'
      'ここでは上に高さ 24 の見出し（SliverToBoxAdapter）を置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverFillRemaining-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'hasScrollBody',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '子がスクロールするもの（ListView など）か。false にすると、'
          '子が残りより大きいときは子の大きさに合わせる。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'fillOverscroll',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description:
          '端を越えて引いたとき、その分まで子を伸ばすか（hasScrollBody が false のとき）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '残りを埋める Widget',
      control: FixedControl(value: DemoTile(2), source: 'Tile(2)'),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'SliverFillRemaining',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    const SliverToBoxAdapter(child: DemoTile(1, height: 24)),
    SliverFillRemaining(
      hasScrollBody: args.valueOf<bool>('hasScrollBody') ?? true,
      fillOverscroll: args.valueOf<bool>('fillOverscroll') ?? false,
      child: args.valueOf<Widget>('child'),
    ),
  ],
);
