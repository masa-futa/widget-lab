import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
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
      group: PropertyGroup.content,
      typeLabel: 'String',
      description: '表示する文字',
      required: true,
      arg: PropertyArg.positional,
      control: TextControl(initialValue: 'こんにちは'),
    ),
    PropertySpec(
      name: 'style',
      group: PropertyGroup.text,
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
      group: PropertyGroup.text,
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
      group: PropertyGroup.text,
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
      group: PropertyGroup.text,
      typeLabel: 'bool?',
      description: '幅に収まらないときに折り返すか',
      initiallyOn: false,
      control: SwitchControl(initialValue: true),
    ),
    PropertySpec(
      name: 'overflow',
      group: PropertyGroup.text,
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
    const PropertySpec(
      name: 'strutStyle',
      group: PropertyGroup.text,
      typeLabel: 'StrutStyle?',
      description: '行の高さの下限。折り返したときの行と行のあいだが変わる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice(
            'height 2',
            StrutStyle(height: 2, forceStrutHeight: true),
            'StrutStyle(height: 2, forceStrutHeight: true)',
          ),
          Choice(
            'height 1',
            StrutStyle(height: 1, forceStrutHeight: true),
            'StrutStyle(height: 1, forceStrutHeight: true)',
          ),
        ],
      ),
    ),
    const PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.text,
      typeLabel: 'TextDirection?',
      description: '文字の向き。rtl にすると textAlign の start と end が入れ替わる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('rtl', TextDirection.rtl, 'TextDirection.rtl'),
          Choice('ltr', TextDirection.ltr, 'TextDirection.ltr'),
        ],
      ),
    ),
    PropertySpec(
      name: 'textScaler',
      group: PropertyGroup.text,
      typeLabel: 'TextScaler?',
      description: '文字の拡大率。端末の文字の大きさの設定の代わりに使う',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          for (final factor in const [1.5, 0.75])
            Choice(
              '×$factor',
              TextScaler.linear(factor),
              'TextScaler.linear($factor)',
            ),
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
      name: 'locale',
      typeLabel: 'Locale?',
      description: '漢字の字形などを選ぶための言語。日本語の見本では違いが出にくい',
    ),
    ReferenceArg(
      name: 'textScaleFactor',
      typeLabel: 'double?',
      description: '非推奨。代わりに textScaler を使う',
    ),
    ReferenceArg(
      name: 'semanticsLabel',
      typeLabel: 'String?',
      description: '読み上げで、表示している文字の代わりに読ませる文',
    ),
    ReferenceArg(
      name: 'semanticsIdentifier',
      typeLabel: 'String?',
      description: '読み上げの木に付ける、自動テストなどで探すための名前',
    ),
    ReferenceArg(
      name: 'textWidthBasis',
      typeLabel: 'TextWidthBasis?',
      description: 'Widget の幅を、親の幅にするか、いちばん長い行の幅にするか。地の色がない見本では違いが出ない',
    ),
    ReferenceArg(
      name: 'textHeightBehavior',
      typeLabel: 'TextHeightBehavior?',
      description: '最初の行の上と最後の行の下に、行の高さの余白を付けるか。見本では違いが出にくい',
    ),
    ReferenceArg(
      name: 'selectionColor',
      typeLabel: 'Color?',
      description: '選択したときの地の色。SelectionArea の中で選べるときだけ使う',
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
  strutStyle: args.valueOf<StrutStyle>('strutStyle'),
  textDirection: args.valueOf<TextDirection>('textDirection'),
  textScaler: args.valueOf<TextScaler>('textScaler'),
);
