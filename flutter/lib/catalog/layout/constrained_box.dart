import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final constrainedBoxEntry = WidgetEntry(
  id: 'constrainedBox',
  name: 'ConstrainedBox',
  genreIds: const ['layout'],
  summary: '子の大きさに、最小・最大の制約を足す',
  description:
      '親からの制約に constraints を重ねて子に渡します。'
      '最小を大きくすると子は広がり、最大を小さくすると子は縮みます。'
      '親の制約は越えられません。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'constraints',
      group: PropertyGroup.size,
      typeLabel: 'BoxConstraints',
      description: '子に足す制約',
      control: ChoiceControl(
        choices: [
          Choice(
            '最小 160×48',
            BoxConstraints(minWidth: 160, minHeight: 48),
            'BoxConstraints(minWidth: 160, minHeight: 48)',
          ),
          Choice(
            '最大 16×16',
            BoxConstraints(maxWidth: 16, maxHeight: 16),
            'BoxConstraints(maxWidth: 16, maxHeight: 16)',
          ),
          Choice(
            'ちょうど 96×32',
            BoxConstraints.tightFor(width: 96, height: 32),
            'BoxConstraints.tightFor(width: 96, height: 32)',
          ),
          Choice('いっぱい', BoxConstraints.expand(), 'BoxConstraints.expand()'),
        ],
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '制約を受ける Widget。FlutterLogo はふだん 24×24',
      control: FixedControl(value: FlutterLogo(), source: 'FlutterLogo()'),
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
  codeName: 'ConstrainedBox',
);

Widget _build(DemoArgs args) => ConstrainedBox(
  // API では必須。Padding の padding と同じく、OFF は効かない値（制約なし）で組む
  constraints:
      args.valueOf<BoxConstraints>('constraints') ?? const BoxConstraints(),
  child: args.valueOf<Widget>('child'),
);
