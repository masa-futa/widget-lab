import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final rowEntry = WidgetEntry(
  id: 'row',
  name: 'Row',
  genreIds: const ['basics', 'layout'],
  summary: '子を横一列に並べる',
  description:
      '子を左から右へ横一列に並べます。横の並べ方（主軸）と、'
      '縦の揃え方（交差軸）を指定できます。はみ出しても折り返しません。',
  docUrl: Uri.parse('https://api.flutter.dev/flutter/widgets/Row-class.html'),
  properties: const [
    PropertySpec(
      name: 'mainAxisAlignment',
      typeLabel: 'MainAxisAlignment',
      description: '横の並べ方。余った幅をどこに置くか',
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
      typeLabel: 'MainAxisSize',
      description: '横の広さ。max は使える幅いっぱい、min は子の幅の合計',
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
      typeLabel: 'CrossAxisAlignment',
      description: '縦の揃え方。stretch は子を縦いっぱいに伸ばす',
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
      typeLabel: 'double',
      description: '子と子のあいだの幅',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 8,
        resolve: _identity,
        code: _decimal,
      ),
    ),
    PropertySpec(
      name: 'children',
      typeLabel: 'List<Widget>',
      description: '横に並べる Widget',
      control: FixedControl(
        value: <Widget>[FlutterLogo(), FlutterLogo(), FlutterLogo()],
        source: '[FlutterLogo(), FlutterLogo(), FlutterLogo()]',
      ),
    ),
  ],
  build: _build,
  codeName: 'Row',
);

double _identity(double v) => v;

String _decimal(double v) => '$v';

Widget _build(DemoArgs args) => Row(
  mainAxisAlignment:
      args.valueOf<MainAxisAlignment>('mainAxisAlignment') ??
      MainAxisAlignment.start,
  mainAxisSize: args.valueOf<MainAxisSize>('mainAxisSize') ?? MainAxisSize.max,
  crossAxisAlignment:
      args.valueOf<CrossAxisAlignment>('crossAxisAlignment') ??
      CrossAxisAlignment.center,
  spacing: args.valueOf<double>('spacing') ?? 0,
  children: args.valueOf<List<Widget>>('children') ?? const [],
);
