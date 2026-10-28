import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_tile.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
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
