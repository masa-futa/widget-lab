import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverAppBarEntry = WidgetEntry(
  id: 'sliverAppBar',
  name: 'SliverAppBar',
  genreIds: const ['layout', 'scrolling'],
  summary: 'スクロールに合わせて縮む・隠れる・残る AppBar',
  description:
      'CustomScrollView の最初の sliver に置く AppBar。'
      'スクロールすると上へ隠れます。pinned で上に残し、floating で少し戻すだけで現れます。'
      'ここでは下に 12 行の SliverList をつないでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/SliverAppBar-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'title',
      typeLabel: 'Widget?',
      description: '題',
      control: FixedControl(
        value: Text('SliverAppBar'),
        source: "Text('SliverAppBar')",
      ),
    ),
    const PropertySpec(
      name: 'pinned',
      typeLabel: 'bool',
      description: 'スクロールしても、縮めた高さで上に残すか。既定は false',
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'floating',
      typeLabel: 'bool',
      description: '上へ戻し始めたらすぐ現れるか（一番上まで戻らなくても）。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    const PropertySpec(
      name: 'expandedHeight',
      typeLabel: 'double?',
      description: '広げたときの高さ。スクロールでツールバーの高さまで縮む',
      initiallyOn: false,
      control: SliderControl(
        min: 64,
        max: 160,
        divisions: 4,
        initialValue: 112,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      typeLabel: 'Color?',
      description: '地の色。既定はテーマの色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', DemoTile.colors[1]),
          Choice.color('若竹', DemoTile.colors[2]),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverAppBar',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverAppBar(
      title: args.valueOf<Widget>('title'),
      pinned: args.valueOf<bool>('pinned') ?? false,
      floating: args.valueOf<bool>('floating') ?? false,
      expandedHeight: args.valueOf<double>('expandedHeight'),
      backgroundColor: args.valueOf<Color>('backgroundColor'),
    ),
    SliverList.list(
      children: [for (var i = 1; i <= 12; i++) DemoTile(i, height: 32)],
    ),
  ],
);
