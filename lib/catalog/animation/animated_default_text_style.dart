import 'package:flutter/widgets.dart';
import 'package:widget_lab/catalog/animation/implicit_animation_specs.dart';
import 'package:widget_lab/catalog/animation/shared_specs.dart';
import 'package:widget_lab/catalog/demo/demo_choices.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final animatedDefaultTextStyleEntry = WidgetEntry(
  id: 'animatedDefaultTextStyle',
  name: 'AnimatedDefaultTextStyle',
  genreIds: const ['animation'],
  summary: '下の文字の既定のスタイルが変わると、新しいスタイルへ動かす',
  description:
      'DefaultTextStyle と同じく、下の Text の既定のスタイルを決めます。'
      'style が変わると、文字の大きさ・色・太さを duration の時間をかけて移り変わらせます。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/widgets/AnimatedDefaultTextStyle-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'style',
      group: PropertyGroup.text,
      typeLabel: 'TextStyle',
      description: '下の文字の既定のスタイル。変えると移り変わる',
      required: true,
      control: ChoiceControl(
        choices: [
          Choice(
            '小さく青',
            TextStyle(fontSize: 16, color: Color(0xFF1E50A2)),
            'TextStyle(fontSize: 16, color: Color(0xFF1E50A2))',
          ),
          Choice(
            '大きく赤',
            TextStyle(
              fontSize: 40,
              color: Color(0xFFD7003A),
              fontWeight: FontWeight.bold,
            ),
            'TextStyle(fontSize: 40, color: Color(0xFFD7003A), '
                'fontWeight: FontWeight.bold)',
          ),
        ],
      ),
    ),
    durationSpec,
    curveSpec,
    PropertySpec(
      name: 'textAlign',
      typeLabel: 'TextAlign?',
      description: '下の Text の、行の中での横の揃え方',
      initiallyOn: false,
      group: PropertyGroup.text,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in const [
            TextAlign.left,
            TextAlign.right,
            TextAlign.center,
          ])
            Choice(value.name, value, 'TextAlign.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'softWrap',
      typeLabel: 'bool',
      description: '幅が足りないときに折り返すか。false なら 1 行のまま伸ばす',
      initiallyOn: false,
      group: PropertyGroup.text,
      control: SwitchControl(initialValue: false),
    ),
    PropertySpec(
      name: 'overflow',
      typeLabel: 'TextOverflow',
      description: '入りきらない文字の見せ方。指定しないと切る（TextOverflow.clip）',
      initiallyOn: false,
      group: PropertyGroup.text,
      control: ChoiceControl(
        initialIndex: 2,
        choices: [
          for (final value in TextOverflow.values)
            Choice(value.name, value, 'TextOverflow.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'maxLines',
      typeLabel: 'int?',
      description: '下の Text の行数の上限',
      initiallyOn: false,
      group: PropertyGroup.text,
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
      name: 'textWidthBasis',
      typeLabel: 'TextWidthBasis',
      description: '複数行の文字の幅の測り方。longestLine にすると、いちばん長い行の幅に縮む',
      initiallyOn: false,
      group: PropertyGroup.text,
      control: ChoiceControl(
        initialIndex: 1,
        choices: [
          for (final value in TextWidthBasis.values)
            Choice(value.name, value, 'TextWidthBasis.${value.name}'),
        ],
      ),
    ),
    const PropertySpec(
      name: 'child',
      group: PropertyGroup.content,
      typeLabel: 'Widget',
      description: 'スタイルを受ける Widget。Text に style を渡さなければ、この既定のスタイルになる',
      required: true,
      control: FixedControl(value: Text('こんにちは'), source: "Text('こんにちは')"),
    ),
  ],
  references: const [
    keyReference,
    ReferenceArg(
      name: 'textHeightBehavior',
      typeLabel: 'TextHeightBehavior?',
      description: '行の高さ（height）を、最初の行の上と最後の行の下にも効かせるか。見本では違いが見えない',
    ),
    onEndReference,
  ],
  build: _build,
  codeName: 'AnimatedDefaultTextStyle',
);

Widget _build(DemoArgs args) => AnimatedDefaultTextStyle(
  style: args.valueOf<TextStyle>('style') ?? const TextStyle(),
  duration: durationOf(args),
  curve: curveOf(args),
  textAlign: args.valueOf<TextAlign>('textAlign'),
  softWrap: args.valueOf<bool>('softWrap') ?? true,
  overflow: args.valueOf<TextOverflow>('overflow') ?? TextOverflow.clip,
  maxLines: args.valueOf<int>('maxLines'),
  textWidthBasis:
      args.valueOf<TextWidthBasis>('textWidthBasis') ?? TextWidthBasis.parent,
  child: args.valueOf<Widget>('child') ?? const SizedBox.shrink(),
);
