import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/transition_curves.dart';
import 'package:widget_lab/catalog/demo/demo_animation.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

/// 始まりの文字のスタイル。どの選択肢もここから動かす。
const _begin = TextStyle(fontSize: 20, color: Color(0xFF1E50A2));

final defaultTextStyleTransitionEntry = WidgetEntry(
  id: 'defaultTextStyleTransition',
  name: 'DefaultTextStyleTransition',
  genreIds: const ['animation'],
  summary: 'Animation の値に合わせて、子孫の Text の既定のスタイルを変える',
  description:
      'style に渡した Animation の TextStyle を、子孫の Text の既定のスタイル（DefaultTextStyle）にします。'
      'ふつうは TextStyleTween で 2 つのスタイルのあいだを動かします。'
      'ここでの controller は 0→1→0 を繰り返す AnimationController です。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/DefaultTextStyleTransition-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'style',
      typeLabel: 'Animation<TextStyle>',
      description: 'スタイルの Animation。ここでは TextStyle(fontSize: 20, color: Color(0xFF1E50A2)) から動かす',
      required: true,
      control: ChoiceControl(
        choices: [
          for (final (name, end, code) in const [
            (
              '大きくなる',
              TextStyle(fontSize: 36, color: Color(0xFF1E50A2)),
              'TextStyle(fontSize: 36, color: Color(0xFF1E50A2))',
            ),
            (
              '色が変わる',
              TextStyle(fontSize: 20, color: Color(0xFFD7003A)),
              'TextStyle(fontSize: 20, color: Color(0xFFD7003A))',
            ),
            (
              '字間が開く',
              TextStyle(
                fontSize: 20,
                color: Color(0xFF1E50A2),
                letterSpacing: 8,
              ),
              'TextStyle(fontSize: 20, color: Color(0xFF1E50A2), '
                  'letterSpacing: 8)',
            ),
          ])
            Choice(
              name,
              (Animation<double> controller) =>
                  controller.drive(TextStyleTween(begin: _begin, end: end)),
              'controller.drive(TextStyleTween(begin: TextStyle(fontSize: 20, '
              'color: Color(0xFF1E50A2)), end: $code))',
            ),
        ],
      ),
    ),
    PropertySpec(
      name: 'textAlign',
      typeLabel: 'TextAlign?',
      description: '子孫の Text の、行の中での横の揃え方',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in const [
            TextAlign.left,
            TextAlign.right,
            TextAlign.center,
          ])
            Choice(value.name, value, 'TextAlign.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLines',
      typeLabel: 'int?',
      description: '子孫の Text の行数の上限',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 2,
        initialValue: 1,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'スタイルを受ける Widget。中の Text はスタイルを指定しない',
      required: true,
      control: FixedControl(
        value: SizedBox(width: 240, child: Text('こんにちは、Flutter')),
        source: "SizedBox(width: 240, child: Text('こんにちは、Flutter'))",
      ),
    ),
  ],
  build: _build,
  codeName: 'DefaultTextStyleTransition',
);

Widget _build(DemoArgs args) => DemoAnimation(
  builder: (context, controller) => DefaultTextStyleTransition(
    style: (args.valueOf<AnimationOf<TextStyle>>('style') ?? _still)(
      controller,
    ),
    textAlign: args.valueOf<TextAlign>('textAlign'),
    maxLines: args.valueOf<int>('maxLines'),
    child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
  ),
);

/// 選択肢の値が渡らなかったとき（必須なので起きない）は動かさない。
Animation<TextStyle> _still(Animation<double> controller) =>
    const AlwaysStoppedAnimation(_begin);
