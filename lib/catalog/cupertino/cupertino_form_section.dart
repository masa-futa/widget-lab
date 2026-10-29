import 'package:flutter/cupertino.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/demo_args.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/catalog/model/property_group.dart';
import 'package:widget_lab/catalog/model/property_spec.dart';
import 'package:widget_lab/catalog/model/reference_arg.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';

final cupertinoFormSectionEntry = WidgetEntry(
  id: 'cupertinoFormSection',
  name: 'CupertinoFormSection',
  genreIds: const ['cupertino'],
  summary: 'iOS のフォームの行を、見出しつきの 1 区画にまとめる',
  description:
      'CupertinoFormRow などの行を、上の見出し（header）・下の補足（footer）と一緒に 1 区画にまとめ、'
      '行の間に区切り線を引きます。角の丸い区画にするときは CupertinoFormSection.insetGrouped を使います。',
  docUrl: Uri.parse(
    'https://api.flutter.dev/flutter/cupertino/CupertinoFormSection-class.html',
  ),
  properties: [
    const PropertySpec(
      name: 'header',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '区画の上に出す見出し',
      control: FixedControl(value: Text('アカウント'), source: "Text('アカウント')"),
    ),
    const PropertySpec(
      name: 'footer',
      group: PropertyGroup.content,
      typeLabel: 'Widget?',
      description: '区画の下に出す補足',
      initiallyOn: false,
      control: FixedControl(
        value: Text('名前はほかの人に見えます'),
        source: "Text('名前はほかの人に見えます')",
      ),
    ),
    PropertySpec(
      name: 'backgroundColor',
      group: PropertyGroup.paint,
      typeLabel: 'Color',
      description: '区画のまわり（見出しの地）の色。指定しないと systemGroupedBackground',
      initiallyOn: false,
      control: ColorControl(
        palette: [
          const Choice(
            'systemGrey5',
            CupertinoColors.systemGrey5,
            'CupertinoColors.systemGrey5',
          ),
          Choice.color('山吹（薄）', const Color(0x33F8B500)),
        ],
      ),
    ),
    PropertySpec(
      name: 'decoration',
      group: PropertyGroup.paint,
      typeLabel: 'BoxDecoration?',
      description: '行のまとまりの地に描く飾り。指定しないと secondarySystemGroupedBackground で塗る',
      initiallyOn: false,
      control: _decorationControl(),
    ),
    PropertySpec(
      name: 'margin',
      group: PropertyGroup.spacing,
      typeLabel: 'EdgeInsetsGeometry',
      description: '区画の外の余白。指定しないと 0',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 32,
        divisions: 8,
        initialValue: 16,
        resolve: EdgeInsets.all,
        code: (v) => 'EdgeInsets.all($v)',
      ),
    ),
    const PropertySpec(
      name: 'children',
      group: PropertyGroup.content,
      typeLabel: 'List<Widget>',
      description: '区画に並べる行。1 つ以上',
      required: true,
      control: FixedControl(
        value: [
          CupertinoFormRow(prefix: Text('名前'), child: Text('ニミ')),
          CupertinoFormRow(
            prefix: Text('メール'),
            child: Text('nimi@example.com'),
          ),
        ],
        source:
            "[CupertinoFormRow(prefix: Text('名前'), child: Text('ニミ')), "
            "CupertinoFormRow(prefix: Text('メール'), child: Text('nimi@example.com'))]",
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
      name: 'clipBehavior',
      typeLabel: 'Clip',
      description:
          '行のまとまりを角の形で切り抜くか。このコンストラクタでは角が丸くないので、見た目は変わらない（insetGrouped で効く）',
    ),
  ],
  build: _build,
  codeName: 'CupertinoFormSection',
);

NestedControl _decorationControl() => NestedControl(
  typeName: 'BoxDecoration',
  children: [
    PropertySpec(
      name: 'color',
      typeLabel: 'Color?',
      description: '飾りの地の色',
      control: ColorControl(
        palette: [
          Choice.color('若竹（薄）', const Color(0x3368BE8D)),
          Choice.color('瑠璃（薄）', const Color(0x331E50A2)),
        ],
      ),
    ),
    PropertySpec(
      name: 'borderRadius',
      typeLabel: 'BorderRadiusGeometry?',
      description: '角の丸み',
      initiallyOn: false,
      control: SliderControl(
        min: 0,
        max: 24,
        divisions: 6,
        initialValue: 12,
        resolve: BorderRadius.circular,
        code: (v) => 'BorderRadius.circular($v)',
      ),
    ),
    PropertySpec(
      name: 'border',
      typeLabel: 'BoxBorder?',
      description: 'まとまりのふちの線',
      initiallyOn: false,
      control: ChoiceControl(
        choices: [Choice('細い線', Border.all(width: 2), 'Border.all(width: 2)')],
      ),
    ),
  ],
  build: (values) => BoxDecoration(
    color: values['color'] as Color?,
    borderRadius: values['borderRadius'] as BorderRadiusGeometry?,
    border: values['border'] as BoxBorder?,
  ),
);

Widget _build(DemoArgs args) => FittedBox(
  // 比較中の低いカードでも Column がはみ出さないよう、収まらなければ縮める
  fit: BoxFit.scaleDown,
  child: SizedBox(
    width: 320,
    child: CupertinoFormSection(
      header: args.valueOf<Widget>('header'),
      footer: args.valueOf<Widget>('footer'),
      backgroundColor:
          args.valueOf<Color>('backgroundColor') ??
          CupertinoColors.systemGroupedBackground,
      decoration: args.valueOf<BoxDecoration>('decoration'),
      margin: args.valueOf<EdgeInsetsGeometry>('margin') ?? EdgeInsets.zero,
      // 必須のプロパティなので、常に値がある
      children: args.valueOf<List<Widget>>('children')!,
    ),
  ),
);
