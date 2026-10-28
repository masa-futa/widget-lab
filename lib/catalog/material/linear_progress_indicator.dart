import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final linearProgressIndicatorEntry = WidgetEntry(
  id: 'linearProgressIndicator',
  name: 'LinearProgressIndicator',
  genreIds: const ['material'],
  summary: '進み具合を横の線で見せる',
  description:
      '処理の進み具合を横に伸びる線で見せます。value に 0〜1 を渡すとその割合まで塗り、'
      '渡さないと終わりの分からない処理として線が流れ続けます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      typeLabel: 'double?',
      description: '進み具合（0〜1）。指定しないと線が流れ続ける',
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'minHeight',
      typeLabel: 'double?',
      description: '線の太さ。指定しないと 4',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 16,
        divisions: 7,
        initialValue: 8,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '進んだ分の色。指定しないとテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      typeLabel: 'BorderRadiusGeometry?',
      description: '線の端の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
  ],
  build: _build,
  codeName: 'LinearProgressIndicator',
);

/// 線は幅いっぱいに広がるので、プレビューでは見やすい幅に決める（コードには出さない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  child: LinearProgressIndicator(
    value: args.valueOf<double>('value'),
    minHeight: args.valueOf<double>('minHeight'),
    color: args.valueOf<Color>('color'),
    borderRadius: args.valueOf<BorderRadiusGeometry>('borderRadius'),
  ),
);
