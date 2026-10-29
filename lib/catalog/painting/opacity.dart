import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final opacityEntry = WidgetEntry(
  id: 'opacity',
  name: 'Opacity',
  genreIds: const ['painting'],
  summary: '子を半透明にして描く',
  description:
      '子を opacity の濃さで描きます（0 で透明、1 でそのまま）。'
      '0 でも場所は取り、押せます。0 と 1 以外は描くのに手間がかかるので、'
      '色だけなら色の透明度を、動かすなら AnimatedOpacity・FadeTransition を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/Opacity-class.html',
  ),
  properties: const [
    PropertySpec(
      name: 'opacity',
      group: PropertyGroup.paint,
      typeLabel: 'double',
      description: '濃さ（0.0〜1.0）',
      control: SliderControl(
        min: 0,
        max: 1,
        divisions: 10,
        initialValue: 0.3,
        resolve: asDouble,
        code: doubleCode,
      ),
    ),
    PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '半透明にする Widget',
      control: FixedControl(
        value: FlutterLogo(size: 48),
        source: 'FlutterLogo(size: 48)',
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
      name: 'alwaysIncludeSemantics',
      typeLabel: 'bool',
      description: '透明（0）のときも、読み上げの対象に残すか。見た目は変わらない',
    ),
  ],
  build: _build,
  codeName: 'Opacity',
);

Widget _build(DemoArgs args) => Opacity(
  // API では必須。Padding の padding と同じく、OFF はそのままの濃さで組む
  opacity: args.valueOf<double>('opacity') ?? 1,
  child: args.valueOf<Widget>('child'),
);
