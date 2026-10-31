import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final floatingActionButtonEntry = WidgetEntry(
  id: 'floatingActionButton',
  name: 'FloatingActionButton',
  genreIds: const ['material'],
  summary: '画面の主な操作を 1 つだけ置く、浮いた丸いボタン',
  description:
      '画面でいちばん大事な操作（新規作成など）を 1 つだけ置く、浮き上がったボタンです。'
      'ふつうは Scaffold の floatingActionButton に渡し、右下に置きます。'
      'onPressed が null でも見た目は変わらないので、押せないときはボタンごと出さないのが基本です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/FloatingActionButton-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'onPressed',
      group: PropertyGroup.behavior,
      typeLabel: 'VoidCallback?',
      description: '押されたときに呼ばれる。null（指定なし）だと押せない',
      control: FixedControl(value: _noop, source: '() {}'),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ボタンの中に置く Widget。ふつうは Icon',
      control: FixedControl(value: Icon(Icons.add), source: 'Icon(Icons.add)'),
    ),
    const PropertySpec(
      name: 'mini',
      group: PropertyGroup.size,
      pairsWith: ['materialTapTargetSize'],
      typeLabel: 'bool',
      description: '小さい（40×40）ボタンにするか。指定しないと 56×56',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'materialTapTargetSize',
      group: PropertyGroup.size,
      pairsWith: const ['mini'],
      typeLabel: 'MaterialTapTargetSize?',
      description: '押せる範囲の最小の大きさ。padded なら 48×48 まで外側を広げ、shrinkWrap なら見た目の大きさのまま。指定しないとテーマの値',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in MaterialTapTargetSize.values)
            Choice(value.name, value, 'MaterialTapTargetSize.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'ボタンの地の色。指定しないとテーマの primaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'foregroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '中のアイコンや文字の色。指定しないとテーマの onPrimaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'splashColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '押したときに広がる波紋の色。指定しないと onPrimaryContainer を薄くしたもの',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('紅（半透明）', const Color(0x99D7003A)),
          Choice.color('瑠璃（半透明）', const Color(0x991E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'elevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: 'ボタンの浮き上がりの高さ。影の濃さが変わる。指定しないと 6',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'highlightElevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押している間の浮き上がりの高さ。指定しないと 12',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'disabledElevation',
      group: PropertyGroup.paint,
      typeLabel: 'double?',
      description: '押せないとき（onPressed が null）の浮き上がりの高さ。指定しないと elevation と同じ',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 12,
        divisions: 6,
        initialValue: 0,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'shape',
      group: PropertyGroup.paint,
      typeLabel: 'ShapeBorder?',
      description: 'ボタンの形。指定しないと角の丸い四角',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('CircleBorder', CircleBorder(), 'CircleBorder()'),
          Choice('StadiumBorder', StadiumBorder(), 'StadiumBorder()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'clipBehavior',
      group: PropertyGroup.transform,
      typeLabel: 'Clip',
      description: 'shape の形で中身を切り抜くか。指定しないと none（切り抜かない）',
      initiallyOn: false,
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
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'heroTag',
      typeLabel: 'Object?',
      description:
          '画面を移るときに、同じ印のボタンどうしを飛ぶように動かす Hero の印。'
          '指定しないと全部のボタンで同じ印になるので、1 つの画面に 2 つ置くときは別の値か null を渡す',
    ),
    ReferenceArg(
      name: 'tooltip',
      typeLabel: 'String?',
      description: '長押ししたときに出す説明の文字。読み上げにも使われる',
    ),
    ReferenceArg(
      name: 'isExtended',
      typeLabel: 'bool',
      description:
          '横に長い形のボタンか。Scaffold が出し入れのアニメーションを選ぶのに使い、'
          'このコンストラクタでは見た目は変わらない。横に長い形は FloatingActionButton.extended で作る',
    ),
    ReferenceArg(
      name: 'focusElevation',
      typeLabel: 'double?',
      description: 'キーボードなどで選ばれている（フォーカスがある）ときの浮き上がりの高さ。指定しないと 8',
    ),
    ReferenceArg(
      name: 'hoverElevation',
      typeLabel: 'double?',
      description: 'マウスのポインタが乗っているときの浮き上がりの高さ。指定しないと 8',
    ),
    ReferenceArg(
      name: 'focusColor',
      typeLabel: 'Color?',
      description: 'キーボードなどで選ばれている（フォーカスがある）ときに重ねる色',
    ),
    ReferenceArg(
      name: 'hoverColor',
      typeLabel: 'Color?',
      description: 'マウスのポインタが乗っているときに重ねる色',
    ),
    ReferenceArg(
      name: 'mouseCursor',
      typeLabel: 'MouseCursor?',
      description: 'マウスのポインタが乗ったときのカーソルの形',
    ),
    ReferenceArg(
      name: 'focusNode',
      typeLabel: 'FocusNode?',
      description: 'フォーカスを外から操作したり、状態を調べたりするときに渡す',
    ),
    ReferenceArg(
      name: 'autofocus',
      typeLabel: 'bool',
      description: '最初からフォーカスを持つか。指定しないと false',
    ),
    ReferenceArg(
      name: 'enableFeedback',
      typeLabel: 'bool?',
      description: '押したときに音や振動で知らせるか。指定しないと true',
    ),
  ],
  build: _build,
  codeName: 'FloatingActionButton',
);

void _noop() {}

Widget _build(DemoArgs args) => FloatingActionButton(
  // 一覧の見本と詳細の両方に出るので、画面の切り替えで Hero が重ならないようにする
  heroTag: null,
  onPressed: args.valueOf<VoidCallback>('onPressed'),
  mini: args.valueOf<bool>('mini') ?? false,
  materialTapTargetSize: args.valueOf<MaterialTapTargetSize>(
    'materialTapTargetSize',
  ),
  backgroundColor: args.valueOf<Color>('backgroundColor'),
  foregroundColor: args.valueOf<Color>('foregroundColor'),
  splashColor: args.valueOf<Color>('splashColor'),
  elevation: args.valueOf<double>('elevation'),
  highlightElevation: args.valueOf<double>('highlightElevation'),
  disabledElevation: args.valueOf<double>('disabledElevation'),
  shape: args.valueOf<ShapeBorder>('shape'),
  // Flutter の既定値（Clip.none）。OFF のときも省いたコードと同じ挙動にそろえる。
  clipBehavior: args.valueOf<Clip>('clipBehavior') ?? Clip.none,
  child: args.valueOf<Widget>('child'),
);
