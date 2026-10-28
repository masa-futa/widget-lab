import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final flutterLogoEntry = WidgetEntry(
  id: 'flutterLogo',
  name: 'FlutterLogo',
  genreIds: const ['basics'],
  summary: 'Flutter のロゴを描く',
  description:
      'Flutter のロゴを描きます。大きさは IconTheme に合わせ（既定は 24）、'
      'ロゴだけ・横に文字・下に文字の 3 つの形があります。'
      '形を変えると、duration の時間をかけて切り替わります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/FlutterLogo-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'size',
      typeLabel: 'double?',
      description: 'ロゴの大きさ。指定しないと IconTheme の大きさ（既定は 24）',
      control: SliderControl(
        min: 16,
        max: 160,
        divisions: 9,
        initialValue: 64,
        resolve: (v) => v,
        code: (v) => '$v',
      ),
    ),
    PropertySpec(
      name: 'style',
      typeLabel: 'FlutterLogoStyle',
      description: 'ロゴの形。markOnly はロゴだけ、horizontal は右に、stacked は下に文字',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in FlutterLogoStyle.values)
            Choice(value.name, value, 'FlutterLogoStyle.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textColor',
      typeLabel: 'Color',
      description: '「Flutter」の文字の色。style が markOnly 以外のときに見える',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          Choice.color('瑠璃', const Color(0xFF1E50A2)),
          Choice.color('紅', const Color(0xFFD7003A)),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'FlutterLogo',
);

Widget _build(DemoArgs args) => FlutterLogo(
  size: args.valueOf<double>('size'),
  style: args.valueOf<FlutterLogoStyle>('style') ?? FlutterLogoStyle.markOnly,
  textColor: args.valueOf<Color>('textColor') ?? const Color(0xFF757575),
);
