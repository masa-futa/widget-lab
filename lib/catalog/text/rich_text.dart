import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

const _sumi = Color(0xFF18181B);
const _ruri = Color(0xFF1E50A2);
const _beni = Color(0xFFD7003A);

final richTextEntry = WidgetEntry(
  id: 'richText',
  name: 'RichText',
  genreIds: const ['text'],
  summary: '1 つの文の中で、部分ごとに文字の見た目を変える',
  description:
      'TextSpan を入れ子にして、部分ごとに色・太さ・下線などを変えた文を描きます。'
      'DefaultTextStyle を受けないので、色や大きさは TextSpan の style に書きます'
      '（受けたいときは Text.rich を使います）。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/RichText-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'text',
      typeLabel: 'InlineSpan',
      description: '描く文。TextSpan の children で部分ごとに見た目を変える',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '色と太さ',
            TextSpan(
              style: TextStyle(color: _sumi, fontSize: 16),
              children: [
                TextSpan(
                  text: 'RichText',
                  style: TextStyle(color: _ruri, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' は、1 つの文の中で部分ごとに見た目を変えられます'),
              ],
            ),
            "TextSpan(style: TextStyle(fontSize: 16), children: [TextSpan(text: 'RichText', "
                "style: TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: ' は、…')])",
          ),
          Choice(
            '下線と斜体',
            TextSpan(
              style: TextStyle(color: _sumi, fontSize: 16),
              children: [
                TextSpan(text: '注意: '),
                TextSpan(
                  text: 'この部分',
                  style: TextStyle(
                    color: _beni,
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' だけに下線を引き、ここは斜体にします',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            "TextSpan(children: [TextSpan(text: '注意: '), TextSpan(text: 'この部分', "
                'style: TextStyle(decoration: TextDecoration.underline)), …])',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'textAlign',
      typeLabel: 'TextAlign',
      description: '行の中での揃え方。既定は start',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('start', TextAlign.start, 'TextAlign.start'),
          Choice('center', TextAlign.center, 'TextAlign.center'),
          Choice('end', TextAlign.end, 'TextAlign.end'),
        ],
      ),
    ),
    PropertySpec(
      name: 'maxLines',
      typeLabel: 'int?',
      description: '行数の上限',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 3,
        divisions: 2,
        initialValue: 1,
        resolve: asInt,
        code: intCode,
      ),
    ),
    PropertySpec(
      name: 'overflow',
      typeLabel: 'TextOverflow',
      description: '入りきらない文字の見せ方。既定は clip（切る）',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('clip', TextOverflow.clip, 'TextOverflow.clip'),
          Choice('ellipsis', TextOverflow.ellipsis, 'TextOverflow.ellipsis'),
          Choice('fade', TextOverflow.fade, 'TextOverflow.fade'),
        ],
      ),
    ),
  ],
  build: _build,
  codeName: 'RichText',
);

Widget _build(DemoArgs args) => RichText(
  // 必須のプロパティなので、常に値がある
  text: args.valueOf<InlineSpan>('text')!,
  textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
  maxLines: args.valueOf<int>('maxLines'),
  overflow: args.valueOf<TextOverflow>('overflow') ?? TextOverflow.clip,
);
