import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final draggableScrollableSheetEntry = WidgetEntry(
  id: 'draggableScrollableSheet',
  name: 'DraggableScrollableSheet',
  genreIds: const ['interaction', 'scrolling'],
  summary: '引き上げて広げ、広げきったら中をスクロールするシート',
  description:
      '親の高さに対する割合（initialChildSize など）の高さで下からシートを出します。'
      'シートの中のスクロールを上へ送ると、先にシートが広がり、maxChildSize まで広がってから中が動きます。'
      'builder に渡る ScrollController を、中のスクロールに渡します。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DraggableScrollableSheet-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'initialChildSize',
      typeLabel: 'double',
      description: '開いたときの高さ（親の高さに対する割合）。既定は 0.5',
      control: SliderControl(
        min: 0.3,
        max: 0.9,
        divisions: 6,
        initialValue: 0.4,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'minChildSize',
      typeLabel: 'double',
      description: '縮められる下限の高さ。既定は 0.25',
      initiallyOn: false,
      control: SliderControl(
        min: 0.1,
        max: 0.3,
        divisions: 2,
        initialValue: 0.2,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxChildSize',
      typeLabel: 'double',
      description: '広げられる上限の高さ。既定は 1.0',
      initiallyOn: false,
      control: SliderControl(
        min: 0.9,
        max: 1,
        divisions: 1,
        initialValue: 0.9,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'snap',
      typeLabel: 'bool',
      description: '指を離したら、下限か上限まで動かして止めるか。既定は false',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'builder',
      typeLabel: 'ScrollableWidgetBuilder',
      description: 'シートの中身を作る関数。渡る ScrollController を中のスクロールに渡す',
      required: true,
      control: FixedControl(
        value: _sheet,
        source:
            '(context, scrollController) =>\n'
            '      ListView(controller: scrollController, children: tiles)',
      ),
    ),
  ],
  build: _build,
  codeName: 'DraggableScrollableSheet',
);

Widget _build(DemoArgs args) => Stack(
  children: [
    const Center(child: Text('後ろの画面')),
    DraggableScrollableSheet(
      initialChildSize: args.valueOf<double>('initialChildSize') ?? 0.5,
      minChildSize: args.valueOf<double>('minChildSize') ?? 0.25,
      maxChildSize: args.valueOf<double>('maxChildSize') ?? 1,
      snap: args.valueOf<bool>('snap') ?? false,
      // 必須のプロパティなので、常に値がある
      builder: args.valueOf<ScrollableWidgetBuilder>('builder')!,
    ),
  ],
);

/// シートの中身（角の丸い地に 20 行のリスト）。
Widget _sheet(BuildContext context, ScrollController scrollController) =>
    Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 2,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollController,
        children: [for (var i = 1; i <= 20; i++) DemoTile(i, height: 24)],
      ),
    );
