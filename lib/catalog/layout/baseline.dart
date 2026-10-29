import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final baselineEntry = WidgetEntry(
  id: 'baseline',
  name: 'Baseline',
  genreIds: const ['layout'],
  summary: '子の文字のベースラインを、上から決めた位置に合わせる',
  description:
      '子の文字のベースライン（文字が乗る線）が、自分の上端から baseline の位置に来るように子をずらします。'
      '自分の高さもその分変わります。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Baseline-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'baseline',
      group: PropertyGroup.layout,
      typeLabel: 'double',
      description: '上端からベースラインまでの距離',
      required: true,
      control: SliderControl(
        min: 0,
        max: 48,
        divisions: 12,
        initialValue: 40,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'baselineType',
      group: PropertyGroup.layout,
      typeLabel: 'TextBaseline',
      description: 'どのベースラインに合わせるか。alphabetic は欧文、ideographic は漢字の下端',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            'alphabetic',
            TextBaseline.alphabetic,
            'TextBaseline.alphabetic',
          ),
          Choice(
            'ideographic',
            TextBaseline.ideographic,
            'TextBaseline.ideographic',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: 'ベースラインを合わせる Widget',
      control: FixedControl(
        value: Text('Baseline 字', style: TextStyle(fontSize: 24)),
        source: "Text('Baseline 字', style: TextStyle(fontSize: 24))",
      ),
    ),
  ],
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
  ],
  build: _build,
  codeName: 'Baseline',
);

// どちらも必須のプロパティなので、常に値がある
Widget _build(DemoArgs args) => Baseline(
  baseline: args.valueOf<double>('baseline')!,
  baselineType: args.valueOf<TextBaseline>('baselineType')!,
  child: args.valueOf<Widget>('child'),
);
