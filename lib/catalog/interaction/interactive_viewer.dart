import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final interactiveViewerEntry = WidgetEntry(
  id: 'interactiveViewer',
  name: 'InteractiveViewer',
  genreIds: const ['interaction'],
  summary: '子をつまんで拡大・縮小し、ドラッグで動かして見る',
  description:
      '2 本指でつまんで拡大・縮小し、ドラッグで動かして子を見ます（地図や写真）。'
      '子が自分より大きいときは constrained を false にし、子を本来の大きさで組みます。'
      'ここでは 480×240 の色の箱の並びを包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'constrained',
      typeLabel: 'bool',
      description: '子を自分の大きさに収めて組むか。false で子を本来の大きさにする。既定は true',
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'minScale',
      typeLabel: 'double',
      description: '縮められる下限の倍率。既定は 0.8',
      initiallyOn: false,
      control: SliderControl(
        min: 0.25,
        max: 1,
        divisions: 3,
        initialValue: 0.5,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxScale',
      typeLabel: 'double',
      description: '拡大できる上限の倍率。既定は 2.5',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 5,
        divisions: 4,
        initialValue: 4,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'panEnabled',
      typeLabel: 'bool',
      description: 'ドラッグで動かせるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'scaleEnabled',
      typeLabel: 'bool',
      description: 'つまんで拡大・縮小できるか。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '見る子（480×240）',
      required: true,
      control: FixedControl(value: _Scene(), source: 'const Scene()'),
    ),
  ],
  build: _build,
  codeName: 'InteractiveViewer',
);

Widget _build(DemoArgs args) => InteractiveViewer(
  constrained: args.valueOf<bool>('constrained') ?? true,
  minScale: args.valueOf<double>('minScale') ?? 0.8,
  maxScale: args.valueOf<double>('maxScale') ?? 2.5,
  panEnabled: args.valueOf<bool>('panEnabled') ?? true,
  scaleEnabled: args.valueOf<bool>('scaleEnabled') ?? true,
  // 必須のプロパティなので、常に値がある
  child: args.valueOf<Widget>('child')!,
);

/// 480×240 の色の箱の並び（60×60 を 8 つずつ 4 行）。
class _Scene extends StatelessWidget {
  const _Scene();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 480,
    height: 240,
    // 収めて組むと（constrained）狭くなるので、はみ出さずに折り返す Wrap で並べる
    child: Wrap(
      children: [
        for (var i = 1; i <= 32; i++) DemoTile(i, width: 60, height: 60),
      ],
    ),
  );
}
