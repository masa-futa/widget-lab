import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final refreshIndicatorEntry = WidgetEntry(
  id: 'refreshIndicator',
  name: 'RefreshIndicator',
  genreIds: const ['scrolling'],
  summary: '一番上で下へ引くと、くるくるを出して読み直す（pull to refresh）',
  description:
      '子のスクロールを一番上から下へ引くと、くるくる（進み具合の印）を出して onRefresh を呼びます。'
      'onRefresh の Future が終わるまで、くるくるが回ります。'
      'ここでは 1 秒待つだけの onRefresh にしています。プレビューのリストを下へ引いてみてください。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/RefreshIndicator-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onRefresh',
      typeLabel: 'Future<void> Function()',
      description: '引いたときに呼ぶ関数。返した Future が終わるまでくるくるが回る',
      required: true,
      control: FixedControl(
        value: _refresh,
        source: '() => Future.delayed(const Duration(seconds: 1))',
      ),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: 'くるくるの色。既定はテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', DemoTile.colors[3]),
          Choice.color('若竹', DemoTile.colors[2]),
        ],
      ),
    ),
    const PropertySpec(
      name: 'displacement',
      typeLabel: 'double',
      description: 'くるくるを止める位置（上端からの距離）。既定は 40',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 80,
        divisions: 4,
        initialValue: 20,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: '引いて読み直すスクロール',
      required: true,
      control: FixedControl(
        value: _List(),
        source: 'ListView(children: tiles)',
      ),
    ),
  ],
  build: _build,
  codeName: 'RefreshIndicator',
);

Future<void> _refresh() => Future.delayed(const Duration(seconds: 1));

// onRefresh・child は必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => RefreshIndicator(
  onRefresh: args.valueOf<Future<void> Function()>('onRefresh')!,
  color: args.valueOf<Color>('color'),
  displacement: args.valueOf<double>('displacement') ?? 40,
  child: args.valueOf<Widget>('child')!,
);

/// 引いて読み直すリスト（12 行）。
class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) => ListView(
    children: [for (var i = 1; i <= 12; i++) DemoTile(i, height: 32)],
  );
}
