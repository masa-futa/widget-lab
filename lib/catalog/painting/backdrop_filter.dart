import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final backdropFilterEntry = WidgetEntry(
  id: 'backdropFilter',
  name: 'BackdropFilter',
  genreIds: const ['painting'],
  summary: '自分の後ろにすでに描かれたものに、ぼかしなどのフィルターをかける',
  description:
      '子を描く前に、後ろの絵（先に描かれたもの）に filter をかけます。'
      'すりガラスのような見た目に使います。'
      'かかる範囲は一番近い Clip の範囲なので、ClipRect などで包みます'
      '（包まないと画面全体にかかります）。'
      'ここでは色の箱の上に重ね、ClipRect で包んでいます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/BackdropFilter-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'filter',
      group: PropertyGroup.paint,
      typeLabel: 'ImageFilter',
      description: '後ろの絵にかけるフィルター',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            'ぼかし 4',
            ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            'ImageFilter.blur(sigmaX: 4, sigmaY: 4)',
          ),
          Choice(
            'ぼかし 12',
            ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            'ImageFilter.blur(sigmaX: 12, sigmaY: 12)',
          ),
          Choice(
            '横だけぼかす',
            ImageFilter.blur(sigmaX: 8),
            'ImageFilter.blur(sigmaX: 8)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'フィルターの上に描く Widget（フィルターはかからない）',
      control: FixedControl(
        value: SizedBox(
          width: 120,
          height: 40,
          child: Center(child: Text('すりガラス')),
        ),
        source: "SizedBox(width: 120, height: 40, child: Center(child: Text('すりガラス')))",
      ),
    ),
    const PropertySpec(
      name: 'blendMode',
      group: PropertyGroup.paint,
      typeLabel: 'BlendMode',
      description: 'フィルターをかけた絵を、後ろの絵に重ねる方法。既定は srcOver（そのまま重ねる）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('difference', BlendMode.difference, 'BlendMode.difference'),
          Choice('multiply', BlendMode.multiply, 'BlendMode.multiply'),
          Choice('src', BlendMode.src, 'BlendMode.src'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'enabled',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: 'false にするとフィルターをかけない（子はそのまま描く）。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'filterConfig',
      typeLabel: 'ImageFilterConfig?',
      description:
          'filter の代わりに渡す、フィルターの設定。ぼかしの範囲（bounds）なども決められる。filter とは同時に渡せない',
    ),
    ReferenceArg(
      name: 'backdropGroupKey',
      typeLabel: 'BackdropKey?',
      description: '同じ鍵の BackdropFilter どうしで、後ろの絵を一度だけ読んで共有する（速くなる）。見た目は変わらない',
    ),
  ],
  build: _build,
  codeName: 'BackdropFilter',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 200,
  height: 56,
  child: Stack(
    alignment: Alignment.center,
    children: [
      const _Backdrop(),
      ClipRect(
        child: BackdropFilter(
          // 必須のプロパティなので、常に値がある
          filter: args.valueOf<ImageFilter>('filter')!,
          blendMode: args.valueOf<BlendMode>('blendMode') ?? BlendMode.srcOver,
          enabled: args.valueOf<bool>('enabled') ?? true,
          child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
        ),
      ),
    ],
  ),
);

/// フィルターをかける後ろの絵（色の箱を 5 つ並べたもの）。
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) => Row(
    children: [for (var i = 1; i <= 5; i++) Expanded(child: DemoTile(i))],
  );
}
