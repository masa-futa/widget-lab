import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedDefaultTextStyleEntry = WidgetEntry(
  id: 'animatedDefaultTextStyle',
  name: 'AnimatedDefaultTextStyle',
  genreIds: const ['animation'],
  summary: '下の文字の既定のスタイルが変わると、新しいスタイルへ動かす',
  description:
      'DefaultTextStyle と同じく、下の Text の既定のスタイルを決めます。'
      'style が変わると、文字の大きさ・色・太さを duration の時間をかけて移り変わらせます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedDefaultTextStyle-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'style',
      typeLabel: 'TextStyle',
      description: '下の文字の既定のスタイル。変えると移り変わる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '小さく青',
            TextStyle(fontSize: 16, color: Color(0xFF1E50A2)),
            'TextStyle(fontSize: 16, color: Color(0xFF1E50A2))',
          ),
          Choice(
            '大きく赤',
            TextStyle(
              fontSize: 40,
              color: Color(0xFFD7003A),
              fontWeight: FontWeight.bold,
            ),
            'TextStyle(fontSize: 40, color: Color(0xFFD7003A), '
                'fontWeight: FontWeight.bold)',
          ),
        ],
      ),
    ),
    durationSpec,
    curveSpec,
    const PropertySpec(
      name: 'child',
      typeLabel: 'Widget',
      description: 'スタイルを受ける Widget。Text に style を渡さなければ、この既定のスタイルになる',
      required: true,
      control: FixedControl(value: Text('こんにちは'), source: "Text('こんにちは')"),
    ),
  ],
  build: _build,
  codeName: 'AnimatedDefaultTextStyle',
);

Widget _build(DemoArgs args) => AnimatedDefaultTextStyle(
  style: args.valueOf<TextStyle>('style') ?? const TextStyle(),
  duration: durationOf(args),
  curve: curveOf(args),
  child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
);
