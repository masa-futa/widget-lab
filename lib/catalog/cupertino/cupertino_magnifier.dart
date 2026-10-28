import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoMagnifierEntry = WidgetEntry(
  id: 'cupertinoMagnifier',
  name: 'CupertinoMagnifier',
  genreIds: const ['cupertino'],
  summary: '下にあるものを拡大して見せる、iOS の見た目のレンズ',
  description:
      '自分の下にあるものを拡大して映す、角の丸いレンズです。青い縁と薄い影がつきます。'
      '入力欄の拡大鏡（CupertinoTextMagnifier）の見た目はこれで描かれています。'
      'プレビューでは、文字の上に重ねて置きます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoMagnifier-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'magnificationScale',
      typeLabel: 'double',
      description: '拡大の倍率。1 なら拡大しない',
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 8,
        initialValue: 1.5,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'borderSide',
      typeLabel: 'BorderSide',
      description: '縁の線。指定しないと幅 2 の青',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (label, color, code) in const [
            (
              'systemRed',
              CupertinoColors.systemRed,
              'CupertinoColors.systemRed',
            ),
            (
              'systemGreen',
              CupertinoColors.systemGreen,
              'CupertinoColors.systemGreen',
            ),
          ])
            Choice(
              label,
              BorderSide(color: color, width: 2),
              'BorderSide(color: $code, width: 2.0)',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'size',
      typeLabel: 'Size',
      description: 'レンズの大きさ。ここでは幅を変える（高さは 50）',
      initiallyOn: false,
      control: SliderControl(
        min: 40,
        max: 160,
        divisions: 6,
        initialValue: 120,
        resolve: (v) => Size(v, 50),
        code: (v) => 'Size($v, 50.0)',
      ),
    ),
  ],
  build: _build,
  codeName: 'CupertinoMagnifier',
);

Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  height: 100,
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Text('拡大鏡の下の文字を\n大きく映します', textAlign: TextAlign.center),
      CupertinoMagnifier(
        magnificationScale: args.valueOf<double>('magnificationScale') ?? 1,
        borderSide:
            args.valueOf<BorderSide>('borderSide') ??
            const BorderSide(color: Color.fromARGB(255, 0, 124, 255), width: 2),
        size: args.valueOf<Size>('size') ?? CupertinoMagnifier.kDefaultSize,
      ),
    ],
  ),
);
