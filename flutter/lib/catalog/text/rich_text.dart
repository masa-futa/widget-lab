import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
  properties: [
    const PropertySpec(
      name: 'text',
      group: PropertyGroup.content,
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
    const PropertySpec(
      name: 'textAlign',
      group: PropertyGroup.text,
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
    const PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.text,
      typeLabel: 'TextDirection?',
      description:
          '文字の向き。textAlign の start・end がどちら側かも決まる。指定しないとまわりの Directionality',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          Choice('ltr', TextDirection.ltr, 'TextDirection.ltr'),
          Choice('rtl', TextDirection.rtl, 'TextDirection.rtl'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'softWrap',
      group: PropertyGroup.text,
      typeLabel: 'bool',
      description: 'false にすると折り返さず 1 行で描く。既定は true',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'textScaler',
      group: PropertyGroup.text,
      typeLabel: 'TextScaler',
      description: '文字の倍率。RichText は端末の文字の大きさの設定を受けないので、ここで渡す。既定は倍率なし',
      initiallyOn: false,
      control: SliderControl(
        min: 1,
        max: 2,
        divisions: 4,
        initialValue: 1.5,
        resolve: TextScaler.linear,
        code: (v) => 'TextScaler.linear($v)',
      ),
    ),
    const PropertySpec(
      name: 'strutStyle',
      group: PropertyGroup.text,
      typeLabel: 'StrutStyle?',
      description: '行の高さの下限。部分ごとに大きさが違っても、行の間をそろえる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            '行の高さ 2 倍',
            StrutStyle(fontSize: 16, height: 2),
            'StrutStyle(fontSize: 16, height: 2)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'maxLines',
      group: PropertyGroup.text,
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
    const PropertySpec(
      name: 'overflow',
      group: PropertyGroup.text,
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
  references: const [
    ReferenceArg(
      name: 'key',
      typeLabel: 'Key?',
      description: 'Widget を見分ける印。並べ替えたときや、状態を引き継ぐときに使う',
    ),
    ReferenceArg(
      name: 'textScaleFactor',
      typeLabel: 'double',
      description: '非推奨。textScaler を使う',
    ),
    ReferenceArg(
      name: 'locale',
      typeLabel: 'Locale?',
      description: '漢字などの字形を選ぶ言語。日本語と中国語で同じ字の形が変わる',
    ),
    ReferenceArg(
      name: 'textWidthBasis',
      typeLabel: 'TextWidthBasis',
      description: '幅を、親の幅と一番長い行のどちらで測るか。プレビューでは違いが見えにくい',
    ),
    ReferenceArg(
      name: 'textHeightBehavior',
      typeLabel: 'TextHeightBehavior?',
      description: '最初の行の上と最後の行の下に、行の高さの余りを足すか',
    ),
    ReferenceArg(
      name: 'selectionRegistrar',
      typeLabel: 'SelectionRegistrar?',
      description: 'SelectionArea の中で文字を選べるようにする登録先。ふつうは Text が自分で渡す',
    ),
    ReferenceArg(
      name: 'selectionColor',
      typeLabel: 'Color?',
      description: '選んだ文字の地の色。selectionRegistrar を渡すときは必須',
    ),
  ],
  build: _build,
  codeName: 'RichText',
);

Widget _build(DemoArgs args) => RichText(
  // 必須のプロパティなので、常に値がある
  text: args.valueOf<InlineSpan>('text')!,
  textAlign: args.valueOf<TextAlign>('textAlign') ?? TextAlign.start,
  textDirection: args.valueOf<TextDirection>('textDirection'),
  softWrap: args.valueOf<bool>('softWrap') ?? true,
  textScaler: args.valueOf<TextScaler>('textScaler') ?? TextScaler.noScaling,
  strutStyle: args.valueOf<StrutStyle>('strutStyle'),
  maxLines: args.valueOf<int>('maxLines'),
  overflow: args.valueOf<TextOverflow>('overflow') ?? TextOverflow.clip,
);
