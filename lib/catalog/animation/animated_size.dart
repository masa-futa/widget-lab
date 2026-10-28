import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedSizeEntry = WidgetEntry(
  id: 'animatedSize',
  name: 'AnimatedSize',
  genreIds: const ['animation'],
  summary: '子の大きさが変わると、自分の大きさを新しい大きさへ動かす',
  description:
      '子の大きさが変わったとき、自分の大きさを duration の時間をかけて合わせます。'
      '中身はすぐ変わり、外枠だけがなめらかに伸び縮みします（はみ出す分は切ります）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedSize-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget?',
      description: '大きさの変わる子。ここでは大きさの違う 2 つの箱から選ぶ',
      control: ChoiceControl(
        choices: [
          Choice(
            '小さい箱',
            SizedBox(
              width: 60,
              height: 40,
              child: ColoredBox(color: Color(0xFF1E50A2)),
            ),
            'SizedBox(width: 60, height: 40, '
                'child: ColoredBox(color: Color(0xFF1E50A2)))',
          ),
          Choice(
            '大きい箱',
            SizedBox(
              width: 200,
              height: 120,
              child: ColoredBox(color: Color(0xFF1E50A2)),
            ),
            'SizedBox(width: 200, height: 120, '
                'child: ColoredBox(color: Color(0xFF1E50A2)))',
          ),
        ],
      ),
    ),
    durationSpec,
    curveSpec,
    PropertySpec(
      name: 'alignment',
      typeLabel: 'AlignmentGeometry',
      description: '伸び縮みの途中で、子を外枠のどこに寄せるか。指定しないと真ん中',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final (name, value) in const [
            ('topLeft', Alignment.topLeft),
            ('center', Alignment.center),
            ('bottomRight', Alignment.bottomRight),
          ])
            Choice(name, value, 'Alignment.$name'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'AnimatedSize',
);

Widget _build(DemoArgs args) => AnimatedSize(
  duration: durationOf(args),
  curve: curveOf(args),
  alignment: args.valueOf<AlignmentGeometry>('alignment') ?? Alignment.center,
  child: args.valueOf<Widget>('child'),
);
