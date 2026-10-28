import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliverPaddingEntry = WidgetEntry(
  id: 'sliverPadding',
  name: 'SliverPadding',
  genreIds: const ['layout', 'scrolling'],
  summary: 'sliver のまわりに余白を入れる',
  description:
      'CustomScrollView の中で、ほかの sliver のまわりに余白を入れます（sliver 用の Padding）。'
      '余白も一緒にスクロールします。ここでは SliverList を包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/SliverPadding-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'padding',
      typeLabel: 'EdgeInsetsGeometry',
      description: 'sliver のまわりに入れる余白。ここでは四辺に同じ幅を入れる',
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 4,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: insetsCode,
      ),
    ),
    PropertySpec(
      name: 'sliver',
      typeLabel: 'Widget?',
      description: '余白の内側に置く sliver',
      control: FixedControl(
        value: SliverList.list(
          children: [for (var i = 1; i <= 8; i++) DemoTile(i, height: 24)],
        ),
        source: 'SliverList.list(children: tiles)',
      ),
    ),
  ],
  build: _build,
  codeName: 'SliverPadding',
);

Widget _build(DemoArgs args) => CustomScrollView(
  slivers: [
    SliverPadding(
      padding: args.valueOf<EdgeInsetsGeometry>('padding') ?? EdgeInsets.zero,
      sliver: args.valueOf<Widget>('sliver'),
    ),
  ],
);
