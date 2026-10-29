import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final sliderEntry = WidgetEntry(
  id: 'slider',
  name: 'Slider',
  genreIds: const ['material'],
  summary: 'つまみを動かして、範囲の中の値を選ぶ',
  description:
      '線の上のつまみを動かして、min から max の間の値を選びます。Slider 自身は値を持たないので、'
      '動かされると onChanged で新しい値を知らせ、親が value を変えて描き直します'
      '（ここでは value をパネルで変えます）。divisions を渡すと、決まった段にだけ止まります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/Slider-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      group: PropertyGroup.behavior,
      typeLabel: 'double',
      description: '今の値。min から max の間（指定しないと 0 から 1）',
      required: true,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    const PropertySpec(
      name: 'onChanged',
      group: PropertyGroup.behavior,
      typeLabel: 'ValueChanged<double>?',
      description: '動かされたときに新しい値で呼ばれる。null（指定なし）だと動かせない見た目になる',
      control: FixedControl(value: _onChanged, source: '(value) {}'),
    ),
    PropertySpec(
      name: 'min',
      group: PropertyGroup.behavior,
      pairsWith: const ['max'],
      typeLabel: 'double',
      description: '選べるいちばん小さい値。左端の値になる。指定しないと 0',
      initiallyOn: false,
      control: SliderControl(
        min: -1,
        max: 0,
        divisions: 4,
        initialValue: -1,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'max',
      group: PropertyGroup.behavior,
      pairsWith: const ['min'],
      typeLabel: 'double',
      description: '選べるいちばん大きい値。右端の値になる。指定しないと 1',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 2,
        divisions: 4,
        initialValue: 2,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'divisions',
      group: PropertyGroup.behavior,
      pairsWith: const ['label'],
      typeLabel: 'int?',
      description: '範囲を何段に分けるか。分けると線の上に段の点が出る',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 10,
        divisions: 8,
        initialValue: 5,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    PropertySpec(
      name: 'secondaryTrackValue',
      group: PropertyGroup.behavior,
      pairsWith: const ['secondaryActiveColor'],
      typeLabel: 'double?',
      description: 'もう 1 つの目印の値。value より大きいと、その位置まで線を別の色で塗る（読み込み済みの位置など）',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.7,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'allowedInteraction',
      group: PropertyGroup.behavior,
      typeLabel: 'SliderInteraction?',
      description: 'どう触ると値が変わるか。tapOnly ならたたくだけ、slideThumb ならつまみを引くだけ。指定しないと tapAndSlide',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in SliderInteraction.values)
            Choice(value.name, value, 'SliderInteraction.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'padding',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry?',
      description: 'Slider のまわりの余白。指定しないと、上下はつまみの波紋の高さ、左右はつまみの幅',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 8,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    PropertySpec(
      name: 'activeColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'つまみより左（選んだ側）の線とつまみの色',
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
      name: 'inactiveColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'つまみより右の線の色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('若竹', const Color(0xFF68BE8D)),
          Choice.color('山吹', const Color(0xFFF8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'secondaryActiveColor',
      group: PropertyGroup.paint,
      requires: 'secondaryTrackValue',
      typeLabel: 'Color?',
      description: 'secondaryTrackValue までの線の色。指定しないとテーマの primary を薄くしたもの',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('山吹', const Color(0xFFF8B500)),
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'thumbColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'つまみの色。指定しないと activeColor、それもなければテーマの primary',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('墨', const Color(0xFF18181B)),
          Choice.color('紅', const Color(0xFFD7003A)),
        ],
      ),
    ),
    PropertySpec(
      name: 'overlayColor',
      group: PropertyGroup.paint,
      typeLabel: 'WidgetStateProperty<Color?>?',
      description: 'つまみを押している・引いている間に、つまみのまわりに出す色。指定しないと activeColor を薄くしたもの',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (label, color) in const [
            ('紅（半透明）', Color(0x66D7003A)),
            ('若竹（半透明）', Color(0x6668BE8D)),
          ])
            Choice(
              label,
              WidgetStatePropertyAll<Color?>(color),
              'WidgetStatePropertyAll(${colorCode(color)})',
            ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'label',
      group: PropertyGroup.text,
      pairsWith: ['divisions'],
      typeLabel: 'String?',
      description: '動かしている間、つまみの上に出す文字。指定しないと出ない。段（divisions）があるときだけ出るのが既定',
      initiallyOn: false,
      control: TextControl(initialValue: '40%'),
    ),
    PropertySpec(
      name: 'showValueIndicator',
      group: PropertyGroup.text,
      requires: 'label',
      typeLabel: 'ShowValueIndicator?',
      description: 'label をいつ出すか。指定しないと onlyForDiscrete（段があるときだけ）',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final value in ShowValueIndicator.values)
            Choice(value.name, value, 'ShowValueIndicator.${value.name}'),
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
      name: 'onChangeStart',
      typeLabel: 'ValueChanged<double>?',
      description: '動かし始めたときに、そのときの値で呼ばれる。見た目は変わらない',
    ),
    ReferenceArg(
      name: 'onChangeEnd',
      typeLabel: 'ValueChanged<double>?',
      description: '動かし終えたときに、最後の値で呼ばれる。保存などに使う',
    ),
    ReferenceArg(
      name: 'semanticFormatterCallback',
      typeLabel: 'SemanticFormatterCallback?',
      description: '読み上げで値をどう読むかを決める。指定しないと百分率で読む',
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
      name: 'year2023',
      typeLabel: 'bool?',
      description: '非推奨。2023 年版の見た目にするか。SliderThemeData で一つずつ決めるのを使う',
    ),
  ],
  build: _build,
  codeName: 'Slider',
);

void _onChanged(double value) {}

Widget _build(DemoArgs args) => Slider(
  value: args.valueOf<double>('value') ?? 0,
  onChanged: args.valueOf<ValueChanged<double>>('onChanged'),
  // Flutter の既定値（0 と 1）。OFF のときも省いたコードと同じ範囲にそろえる。
  min: args.valueOf<double>('min') ?? 0,
  max: args.valueOf<double>('max') ?? 1,
  divisions: args.valueOf<int>('divisions'),
  secondaryTrackValue: args.valueOf<double>('secondaryTrackValue'),
  allowedInteraction: args.valueOf<SliderInteraction>('allowedInteraction'),
  padding: args.valueOf<EdgeInsetsGeometry>('padding'),
  activeColor: args.valueOf<Color>('activeColor'),
  inactiveColor: args.valueOf<Color>('inactiveColor'),
  secondaryActiveColor: args.valueOf<Color>('secondaryActiveColor'),
  thumbColor: args.valueOf<Color>('thumbColor'),
  overlayColor: args.valueOf<WidgetStateProperty<Color?>>('overlayColor'),
  label: args.valueOf<String>('label'),
  showValueIndicator: args.valueOf<ShowValueIndicator>('showValueIndicator'),
);
