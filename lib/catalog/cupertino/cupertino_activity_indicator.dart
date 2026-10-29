import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoActivityIndicatorEntry = WidgetEntry(
  id: 'cupertinoActivityIndicator',
  name: 'CupertinoActivityIndicator',
  genreIds: const ['cupertino'],
  summary: '回り続ける iOS の読み込み中の印',
  description:
      '放射状の線が回り続ける、iOS の読み込み中の印です。'
      'animating を false にすると止まります。進み具合を見せるときは '
      'CupertinoActivityIndicator.partiallyRevealed を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoActivityIndicator-class.html',
  ),
  properties: [
    PropertySpec(
      name: 'color',
      group: PropertyGroup.paint,
      typeLabel: 'Color?',
      description: '線の色。指定しないと灰色',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'activeBlue',
            CupertinoColors.activeBlue,
            'CupertinoColors.activeBlue',
          ),
          const Choice(
            'systemOrange',
            CupertinoColors.systemOrange,
            'CupertinoColors.systemOrange',
          ),
          Choice.color('墨', const Color(0xFF18181B)),
        ],
      ),
    ),
    const PropertySpec(
      name: 'animating',
      group: PropertyGroup.behavior,
      typeLabel: 'bool',
      description: '回すか。false なら止まる',
      initiallyOn: false,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'radius',
      group: PropertyGroup.size,
      typeLabel: 'double',
      description: '印の半径',
      control: SliderControl(
        min: 4,
        max: 40,
        divisions: 9,
        initialValue: 20,
        resolve: (v) => v,
        code: (v) => '$v',
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
  codeName: 'CupertinoActivityIndicator',
);

Widget _build(DemoArgs args) => CupertinoActivityIndicator(
  color: args.valueOf<Color>('color'),
  animating: args.valueOf<bool>('animating') ?? true,
  radius: args.valueOf<double>('radius') ?? 10,
);
