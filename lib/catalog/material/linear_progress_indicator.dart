import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/dart_code.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final linearProgressIndicatorEntry = WidgetEntry(
  id: 'linearProgressIndicator',
  name: 'LinearProgressIndicator',
  genreIds: const ['material'],
  summary: '進み具合を横の線で見せる',
  description:
      '処理の進み具合を横に伸びる線で見せます。value に 0〜1 を渡すとその割合まで塗り、'
      '渡さないと終わりの分からない処理として線が流れ続けます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'value',
      group: PropertyGroup.behavior,
      typeLabel: 'double?',
      description: '進み具合（0〜1）。指定しないと線が流れ続ける',
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.4,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'minHeight',
      group: PropertyGroup.size,
      typeLabel: 'double?',
      description: '線の太さ。指定しないと 4',
      initiallyOn: false,
      control: SliderControl(
        min: 2,
        max: 16,
        divisions: 7,
        initialValue: 8,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '進んだ分の色。valueColor を指定するとそちらが使われる。指定しないとテーマの primary',
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
      name: 'valueColor',
      group: PropertyGroup.paint,
      typeLabel: 'Animation<Color?>?',
      description: '進んだ分の色を、アニメーションの値として渡す。指定すると color より優先される',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (label, color) in const [
            ('瑠璃', Color(0xFF1E50A2)),
            ('墨', Color(0xFF18181B)),
          ])
            Choice(
              label,
              AlwaysStoppedAnimation<Color?>(color),
              'AlwaysStoppedAnimation<Color?>(${colorCode(color)})',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: 'まだ進んでいない分（下地の線）の色。指定しないとテーマの secondaryContainer',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('桜', const Color(0xFFFEF4F4)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      group: PropertyGroup.paint,
      typeLabel: 'BorderRadiusGeometry?',
      description: '線の端の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
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
      name: 'semanticsLabel',
      typeLabel: 'String?',
      description: '読み上げで伝える、何の進み具合かの名前',
    ),
    ReferenceArg(
      name: 'semanticsValue',
      typeLabel: 'String?',
      description: '読み上げで伝える進み具合。指定しないと value を百分率にしたもの',
    ),
    ReferenceArg(
      name: 'stopIndicatorColor',
      typeLabel: 'Color?',
      description: '線の右端の点の色。year2023 が true（今の既定）の間は描かれないので、この見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'stopIndicatorRadius',
      typeLabel: 'double?',
      description: '線の右端の点の半径。year2023 が true（今の既定）の間は描かれないので、この見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'trackGap',
      typeLabel: 'double?',
      description:
          '進んだ分と下地の線のあいだのすき間。year2023 が true（今の既定）の間は描かれないので、この見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'year2023',
      typeLabel: 'bool?',
      description: '非推奨。2023 年の見た目にするか。新しい見た目は ProgressIndicatorThemeData で year2023: false にして使う',
    ),
    ReferenceArg(
      name: 'controller',
      typeLabel: 'AnimationController?',
      description: '流れ続ける線のアニメーションを外から動かすもの。value と同時には渡せない',
    ),
  ],
  build: _build,
  codeName: 'LinearProgressIndicator',
);

/// 線は幅いっぱいに広がるので、プレビューでは見やすい幅に決める（コードには出さない）。
Widget _build(DemoArgs args) => SizedBox(
  width: 240,
  child: LinearProgressIndicator(
    value: args.valueOf<double>('value'),
    minHeight: args.valueOf<double>('minHeight'),
    backgroundColor: args.valueOf<Color>('backgroundColor'),
    color: args.valueOf<Color>('color'),
    valueColor: args.valueOf<Animation<Color?>>('valueColor'),
    borderRadius: args.valueOf<BorderRadiusGeometry>('borderRadius'),
  ),
);
