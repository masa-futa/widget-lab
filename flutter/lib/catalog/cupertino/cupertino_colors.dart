import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 選べる色。CupertinoColors の多くは明るさで変わる CupertinoDynamicColor。
const _colors = [
  Choice(
    'systemBlue',
    CupertinoColors.systemBlue,
    'CupertinoColors.systemBlue.resolveFrom(context)',
  ),
  Choice(
    'systemGreen',
    CupertinoColors.systemGreen,
    'CupertinoColors.systemGreen.resolveFrom(context)',
  ),
  Choice(
    'systemRed',
    CupertinoColors.systemRed,
    'CupertinoColors.systemRed.resolveFrom(context)',
  ),
  Choice(
    'systemOrange',
    CupertinoColors.systemOrange,
    'CupertinoColors.systemOrange.resolveFrom(context)',
  ),
  Choice(
    'systemGrey',
    CupertinoColors.systemGrey,
    'CupertinoColors.systemGrey.resolveFrom(context)',
  ),
  Choice(
    'label',
    CupertinoColors.label,
    'CupertinoColors.label.resolveFrom(context)',
  ),
  Choice(
    'systemGroupedBackground',
    CupertinoColors.systemGroupedBackground,
    'CupertinoColors.systemGroupedBackground.resolveFrom(context)',
  ),
];

final cupertinoColorsEntry = WidgetEntry(
  id: 'cupertinoColors',
  name: 'CupertinoColors',
  genreIds: const ['cupertino'],
  summary: 'iOS のシステムの色の集まり',
  description:
      'iOS のシステムの色（systemBlue・label など）を集めたクラスです。Widget ではないので、'
      'ここでは ColoredBox の色に使って見せます。多くは明るさ・コントラストで変わる '
      'CupertinoDynamicColor なので、resolveFrom(context) で今の明るさの色にしてから使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoColors-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '塗る色。CupertinoColors から選ぶ',
      required: true,
      control: ChoiceControl(choices: _colors),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '色を塗る範囲を決める子。ここでは幅 120・高さ 80 の空の箱',
      required: true,
      control: FixedControl(
        value: SizedBox(width: 120, height: 80),
        source: 'const SizedBox(width: 120, height: 80)',
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
      name: 'isAntiAlias',
      typeLabel: 'bool',
      description: '塗りの縁をなめらかにするか。傾けない四角では違いが見えない',
    ),
  ],
  build: _build,
  codeName: 'ColoredBox',
);

Widget _build(DemoArgs args) {
  // color は必須のプロパティなので、常に値がある
  final color = args.valueOf<Color>('color')!;
  final child = args.valueOf<Widget>('child');
  return Builder(
    builder: (context) => ColoredBox(
      color: CupertinoDynamicColor.resolve(color, context),
      child: child,
    ),
  );
}
