import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoDynamicColorEntry = WidgetEntry(
  id: 'cupertinoDynamicColor',
  name: 'CupertinoDynamicColor',
  genreIds: const ['cupertino'],
  summary: '明るさに合わせて変わる色',
  description:
      '明るいときの色と暗いときの色を 1 つにまとめた Color です。Widget ではありません。'
      'resolveFrom(context) で、そこの明るさ（CupertinoTheme か MediaQuery）に合う色になります。'
      'プレビューでは、明るい下と暗い下で同じ色を resolve して並べています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoDynamicColor-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color',
      description: '明るいときの色',
      required: true,
      control: ColorControl(palette: _palette),
    ),
    PropertySpec(
      name: 'darkColor',
      typeLabel: 'Color',
      description: '暗いときの色',
      required: true,
      control: ColorControl(palette: _palette, initialIndex: 1),
    ),
  ],
  build: _build,
  codeName: 'CupertinoDynamicColor.withBrightness',
);

final _palette = [
  Choice.color('瑠璃', const Color(0xFF1E50A2)),
  Choice.color('山吹', const Color(0xFFF8B500)),
  Choice.color('若竹', const Color(0xFF68BE8D)),
  Choice.color('紅', const Color(0xFFD7003A)),
];

Widget _build(DemoArgs args) {
  // どちらも必須のプロパティなので、常に値がある
  final color = CupertinoDynamicColor.withBrightness(
    color: args.valueOf<Color>('color')!,
    darkColor: args.valueOf<Color>('darkColor')!,
  );
  // 比較中の低いカードでははみ出さないように縮める
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _Swatch(color: color, brightness: Brightness.light),
        _Swatch(color: color, brightness: Brightness.dark),
      ],
    ),
  );
}

/// [brightness] の下で [color] を resolve して塗った箱と、明るさの名前（デモの部品）。
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.brightness});

  final CupertinoDynamicColor color;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      CupertinoTheme(
        data: CupertinoThemeData(brightness: brightness),
        child: Builder(
          builder: (context) => SizedBox(
            width: 96,
            height: 64,
            child: ColoredBox(color: color.resolveFrom(context)),
          ),
        ),
      ),
      // 名前はプレビューの明るさで読めるように、CupertinoTheme の外に置く
      Text('${brightness.name} の下'),
    ],
  );
}
