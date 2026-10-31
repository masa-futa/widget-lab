import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_setting.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final overflowBoxEntry = WidgetEntry(
  id: 'overflowBox',
  name: 'OverflowBox',
  genreIds: const ['layout'],
  summary: '親の制約を無視した大きさを子に許し、はみ出させる',
  description:
      '親からの制約の代わりに、minWidth・maxWidth などで決めた制約を子に渡します。'
      '自分は親の制約どおりの大きさのままなので、子ははみ出して描かれます。'
      'ここでは 64×32 の枠（SizedBox）の中に、120×56 にしたい子を置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/OverflowBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'minWidth',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '子に求める幅の下限。指定しないと親の下限（64）のまま。上限より大きいときは渡さない',
      initiallyOn: false,
      omitIf: _minWidthOverMax,
      control: SliderControl(
        min: 64,
        max: 160,
        divisions: 6,
        initialValue: 144,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxWidth',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      // 下限（minWidth）を指定しないと親の下限（64）のままなので、上限はそれより小さくできない
      description: '子に許す幅の上限。指定しないと親の上限（64）のまま',
      control: SliderControl(
        min: 64,
        max: 160,
        divisions: 6,
        initialValue: 128,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'minHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '子に求める高さの下限。指定しないと親の下限（32）のまま。上限より大きいときは渡さない',
      initiallyOn: false,
      omitIf: _minHeightOverMax,
      control: SliderControl(
        min: 32,
        max: 56,
        divisions: 3,
        initialValue: 48,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'maxHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '子に許す高さの上限。指定しないと親の上限（32）のまま',
      control: SliderControl(
        min: 32,
        max: 56,
        divisions: 3,
        initialValue: 56,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'alignment',
      group: PropertyGroup.layout,
      typeLabel: 'AlignmentGeometry',
      description: '子を置く位置。既定は center',
      initiallyOn: false,
      control: ChoiceControl(choices: alignmentChoices),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'はみ出させる Widget（120×56 にしたい）',
      control: FixedControl(
        value: DemoTile(1, width: 120, height: 56),
        source: 'Tile(1)',
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
      name: 'fit',
      typeLabel: 'OverflowBoxFit',
      description:
          '親の制約がゆるいとき、自分の大きさを子に合わせるか（deferToChild）。'
          'ここでは枠の大きさが決まっているので違いは出ない。既定は max',
    ),
  ],
  build: _build,
  codeName: 'OverflowBox',
);

/// 枠（SizedBox）の大きさ。maxWidth・maxHeight を指定しないときの上限。
const _frameWidth = 64.0;
const _frameHeight = 32.0;

/// 下限が上限より大きいと制約が崩れる（assert）ので、そのときは下限を渡さない。
bool _over(PropertySetting? min, PropertySetting? max, double frame) {
  if (min == null || !min.on) return false;
  final upper = max != null && max.on ? _sliderOf(max) : frame;
  return _sliderOf(min) > upper;
}

double _sliderOf(PropertySetting setting) => switch (setting.value) {
  SliderValue(:final value) => value,
  _ => 0,
};

bool _minWidthOverMax(Map<String, PropertySetting> settings) =>
    _over(settings['minWidth'], settings['maxWidth'], _frameWidth);

bool _minHeightOverMax(Map<String, PropertySetting> settings) =>
    _over(settings['minHeight'], settings['maxHeight'], _frameHeight);

Widget _build(DemoArgs args) {
  final maxWidth = args.valueOf<double>('maxWidth');
  final maxHeight = args.valueOf<double>('maxHeight');
  final minWidth = args.valueOf<double>('minWidth');
  final minHeight = args.valueOf<double>('minHeight');
  return SizedBox(
    width: _frameWidth,
    height: _frameHeight,
    child: OverflowBox(
      // omitIf と同じ条件で、上限より大きい下限は渡さない
      minWidth: minWidth != null && minWidth <= (maxWidth ?? _frameWidth)
          ? minWidth
          : null,
      maxWidth: maxWidth,
      minHeight: minHeight != null && minHeight <= (maxHeight ?? _frameHeight)
          ? minHeight
          : null,
      maxHeight: maxHeight,
      alignment:
          args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
      child: args.valueOf<Widget>('child'),
    ),
  );
}
