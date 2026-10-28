import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final textEntry = WidgetEntry(
  id: 'text',
  name: 'Text',
  genreIds: const ['basics', 'text'],
  summary: '1つのスタイルで文字を表示する',
  description:
      '文字列を1つのスタイルで表示します。幅に収まらなければ折り返し、'
      '行数の上限と、はみ出したときの見せ方を指定できます。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Text-class.html'),
  properties: [
    const PropertySpec(
      name: 'data',
      typeLabel: 'String',
      description: '表示する文字',
      required: true,
      arg: PropertyArg.positional,
      control: TextControl(initialValue: 'こんにちは'),
    ),
    PropertySpec(
      name: 'style',
      typeLabel: 'TextStyle?',
      description: '文字のスタイル。ここでは文字の大きさだけを変える',
      control: SliderControl(
        min: 8,
        max: 48,
        divisions: 20,
        initialValue: 24,
        resolve: (v) => TextStyle(fontSize: v),
        code: (v) => 'TextStyle(fontSize: $v)',
      ),
    ),
    PropertySpec(
      name: 'textAlign',
      typeLabel: 'TextAlign?',
      description: '行の中での横の揃え方。幅が文字より広いときに違いが出る',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 4,
        choices: [
          for (final value in const [
            TextAlign.left,
            TextAlign.right,
            TextAlign.center,
            TextAlign.justify,
            TextAlign.start,
            TextAlign.end,
          ])
            Choice(value.name, value, 'TextAlign.${value.name}'),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLines',
      typeLabel: 'int?',
      description: '行数の上限。超えた分は overflow の見せ方になる',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 5,
        divisions: 4,
        initialValue: 2,
        resolve: (v) => v.round(),
        code: (v) => '${v.round()}',
      ),
    ),
    const PropertySpec(
      name: 'softWrap',
      typeLabel: 'bool?',
      description: '幅に収まらないときに折り返すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'overflow',
      typeLabel: 'TextOverflow?',
      description: 'はみ出した文字の見せ方',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in TextOverflow.values)
            Choice(value.name, value, 'TextOverflow.${value.name}'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'Text',
);

Widget _build(DemoArgs args) => Text(
  args.valueOf<String>('data') ?? '',
  style: args.valueOf<TextStyle>('style'),
  textAlign: args.valueOf<TextAlign>('textAlign'),
  maxLines: args.valueOf<int>('maxLines'),
  softWrap: args.valueOf<bool>('softWrap'),
  overflow: args.valueOf<TextOverflow>('overflow'),
);
