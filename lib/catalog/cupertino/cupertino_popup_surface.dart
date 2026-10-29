import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoPopupSurfaceEntry = WidgetEntry(
  id: 'cupertinoPopupSurface',
  name: 'CupertinoPopupSurface',
  genreIds: const ['cupertino'],
  summary: '下をぼかした、角の丸い iOS のポップアップの地',
  description:
      'iOS のダイアログやシートの地です。下にあるものをぼかし、角を丸く切り、半透明の色を塗ります。'
      'プレビューでは、ぼかしが分かるように縞の上に置いています。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoPopupSurface-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'blurSigma',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '下をぼかす強さ。0 ならぼかさない',
      control: SliderControl(
        min: 0,
        max: 60,
        divisions: 6,
        initialValue: 30,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'isSurfacePainted',
      group: PropertyGroup.paint,
      typeLabel: 'bool',
      description: 'false なら半透明の色を塗らず、ぼかしだけにする',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: '地の上に置く中身',
      required: true,
      control: FixedControl(
        value: SizedBox(
          width: 200,
          height: 100,
          child: Center(child: Text('ポップアップ')),
        ),
        source: "const SizedBox(width: 200, height: 100, child: Center(child: Text('ポップアップ')))",
      ),
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
  codeName: 'CupertinoPopupSurface',
);

Widget _build(DemoArgs args) => Stack(
  alignment: Alignment.center,
  children: [
    const _Stripes(),
    CupertinoPopupSurface(
      blurSigma:
          args.valueOf<double>('blurSigma') ??
          CupertinoPopupSurface.defaultBlurSigma,
      isSurfacePainted: args.valueOf<bool>('isSurfacePainted') ?? true,
      // 必須のプロパティなので、常に値がある
      child: args.valueOf<Widget>('child')!,
    ),
  ],
);

/// ぼかしが分かるように、ポップアップの下に敷く縞（デモの部品。コードには出さない）。
class _Stripes extends StatelessWidget {
  const _Stripes();

  static const _colors = [
    CupertinoColors.systemRed,
    CupertinoColors.systemYellow,
    CupertinoColors.systemGreen,
    CupertinoColors.systemBlue,
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    height: 140,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 8; i++)
          Expanded(child: ColoredBox(color: _colors[i % _colors.length])),
      ],
    ),
  );
}
