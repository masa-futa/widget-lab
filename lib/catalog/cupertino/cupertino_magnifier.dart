import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.transform,
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
      name: 'additionalFocalPointOffset',
      group: PropertyGroup.transform,
      typeLabel: 'Offset',
      description: '拡大して映す場所を、レンズの真下からずらす量',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (label, x, y) in const [
            ('右へ 40', 40.0, 0.0),
            ('左へ 40', -40.0, 0.0),
            ('上へ 20', 0.0, -20.0),
          ])
            Choice(label, Offset(x, y), 'Offset($x, $y)'),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderSide',
      group: PropertyGroup.paint,
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
      name: 'borderRadius',
      group: PropertyGroup.paint,
      typeLabel: 'BorderRadius',
      description: 'レンズの角の丸み。指定しないと横 60・縦 50 の楕円の角',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: (v) => BorderRadius.circular(v),
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    const PropertySpec(
      name: 'shadows',
      group: PropertyGroup.paint,
      typeLabel: 'List<BoxShadow>',
      description: 'レンズの外に落とす影。指定しないと薄くぼかした影',
      initiallyOn: false,
      pairsWith: ['clipBehavior'],
      control: ChoiceControl(
        choices: [
          Choice(
            '濃い影',
            [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                blurStyle: BlurStyle.outer,
              ),
            ],
            '[BoxShadow(color: Color(0x66000000), blurRadius: 16, blurStyle: BlurStyle.outer)]',
          ),
          Choice('影なし', <BoxShadow>[], '[]'),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: 'レンズの形で切り抜くか。影がレンズの内側に描かれるときに切ると、影が中に重ならない',
      initiallyOn: false,
      pairsWith: const ['shadows'],
      control: ChoiceControl(
        choices: [
          for (final clip in const [
            Clip.hardEdge,
            Clip.antiAlias,
            Clip.antiAliasWithSaveLayer,
          ])
            Choice(clip.name, clip, 'Clip.${clip.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'size',
      group: PropertyGroup.size,
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
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'inOutAnimation',
      typeLabel: 'Animation<double>?',
      description: 'レンズが出る・消えるときの動きの進み具合。拡大鏡を出し入れする仕組みが渡す',
    ),
  ],
  build: _build,
  codeName: 'CupertinoMagnifier',
);

/// CupertinoMagnifier の shadows の既定値（SDK のコンストラクタと同じ）。
const _defaultShadows = [
  BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    blurRadius: 11,
    spreadRadius: 0.2,
    blurStyle: BlurStyle.outer,
  ),
];

Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  height: 100,
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Text('拡大鏡の下の文字を\n大きく映します', textAlign: TextAlign.center),
      CupertinoMagnifier(
        magnificationScale: args.valueOf<double>('magnificationScale') ?? 1,
        additionalFocalPointOffset:
            args.valueOf<Offset>('additionalFocalPointOffset') ?? Offset.zero,
        borderSide:
            args.valueOf<BorderSide>('borderSide') ??
            const BorderSide(color: Color.fromARGB(255, 0, 124, 255), width: 2),
        borderRadius:
            args.valueOf<BorderRadius>('borderRadius') ??
            const BorderRadius.all(Radius.elliptical(60, 50)),
        shadows: args.valueOf<List<BoxShadow>>('shadows') ?? _defaultShadows,
        clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
        size: args.valueOf<Size>('size') ?? CupertinoMagnifier.kDefaultSize,
      ),
    ],
  ),
);
