import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final columnEntry = WidgetEntry(
  id: 'column',
  name: 'Column',
  genreIds: const ['basics', 'layout'],
  summary: '子を縦一列に並べる',
  description:
      '子を上から下へ縦一列に並べます。縦の並べ方（主軸）と、'
      '横の揃え方（交差軸）を指定できます。はみ出してもスクロールしません。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Column-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'mainAxisAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'MainAxisAlignment',
      description: '縦の並べ方。余った高さをどこに置くか',
      control: ChoiceControl(
        choices: [
          Choice('start', MainAxisAlignment.start, 'MainAxisAlignment.start'),
          Choice('end', MainAxisAlignment.end, 'MainAxisAlignment.end'),
          Choice(
            'center',
            MainAxisAlignment.center,
            'MainAxisAlignment.center',
          ),
          Choice(
            'spaceBetween',
            MainAxisAlignment.spaceBetween,
            'MainAxisAlignment.spaceBetween',
          ),
          Choice(
            'spaceAround',
            MainAxisAlignment.spaceAround,
            'MainAxisAlignment.spaceAround',
          ),
          Choice(
            'spaceEvenly',
            MainAxisAlignment.spaceEvenly,
            'MainAxisAlignment.spaceEvenly',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'mainAxisSize',
      group: PropertyGroup.size,
      typeLabel: 'MainAxisSize',
      description: '縦の広さ。max は使える高さいっぱい、min は子の高さの合計',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('max', MainAxisSize.max, 'MainAxisSize.max'),
          Choice('min', MainAxisSize.min, 'MainAxisSize.min'),
        ],
      ),
    ),
    PropertySpec(
      name: 'crossAxisAlignment',
      group: PropertyGroup.layout,
      typeLabel: 'CrossAxisAlignment',
      description: '横の揃え方。stretch は子を横いっぱいに伸ばす',
      initiallyOn: false,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          Choice('start', CrossAxisAlignment.start, 'CrossAxisAlignment.start'),
          Choice('end', CrossAxisAlignment.end, 'CrossAxisAlignment.end'),
          Choice(
            'center',
            CrossAxisAlignment.center,
            'CrossAxisAlignment.center',
          ),
          Choice(
            'stretch',
            CrossAxisAlignment.stretch,
            'CrossAxisAlignment.stretch',
          ),
        ],
      ),
    ),
    PropertySpec(
      name: 'spacing',
      group: PropertyGroup.spacing,
      typeLabel: 'double',
      description: '子と子のあいだの高さ',
      initiallyOn: false,
      // 比較中の低いカード（高さ 64）にも収まる範囲にする
      control: SliderControl(
        min: 0,
        max: 8,
        divisions: 4,
        initialValue: 4,
        resolve: _identity,
        code: _decimal,
      ),
    ),
    PropertySpec(
      name: 'textDirection',
      group: PropertyGroup.layout,
      typeLabel: 'TextDirection?',
      description: '横の左右の向き。rtl にすると crossAxisAlignment の start と end が入れ替わる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('rtl', TextDirection.rtl, 'TextDirection.rtl'),
          Choice('ltr', TextDirection.ltr, 'TextDirection.ltr'),
        ],
      ),
    ),
    PropertySpec(
      name: 'verticalDirection',
      group: PropertyGroup.layout,
      typeLabel: 'VerticalDirection',
      description: '子を並べる向き。up にすると下から上へ並び、start と end が入れ替わる',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [
          Choice('up', VerticalDirection.up, 'VerticalDirection.up'),
          Choice('down', VerticalDirection.down, 'VerticalDirection.down'),
        ],
      ),
    ),
    PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '縦に並べる Widget',
      control: FixedControl(
        value: <Widget>[
          FlutterLogo(size: 16),
          FlutterLogo(size: 16),
          FlutterLogo(size: 16),
        ],
        source:
            '[FlutterLogo(size: 16), FlutterLogo(size: 16), '
            'FlutterLogo(size: 16)]',
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
      name: 'textBaseline',
      typeLabel: 'TextBaseline?',
      description:
          'crossAxisAlignment を baseline にしたときに揃える文字の基準線。'
          'この見本の子（ロゴ）は基準線を持たないので違いが出ない',
    ),
  ],
  build: _build,
  codeName: 'Column',
);

double _identity(double v) => v;

String _decimal(double v) => '$v';

Widget _build(DemoArgs args) => Column(
  mainAxisAlignment:
      args.valueOf<MainAxisAlignment>('mainAxisAlignment') ??
      MainAxisAlignment.start,
  mainAxisSize: args.valueOf<MainAxisSize>('mainAxisSize') ?? MainAxisSize.max,
  crossAxisAlignment:
      args.valueOf<CrossAxisAlignment>('crossAxisAlignment') ??
      CrossAxisAlignment.center,
  textDirection: args.valueOf<TextDirection>('textDirection'),
  verticalDirection:
      args.valueOf<VerticalDirection>('verticalDirection') ??
      VerticalDirection.down,
  spacing: args.valueOf<double>('spacing') ?? 0,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
